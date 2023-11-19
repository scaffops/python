setup_task_event() {
    echo "--- Last ref key: ${LAST_REF_KEY:="${PPID}_skeleton_last_ref"}"
    echo "--- Project path key: ${PROJECT_PATH_KEY:="${PPID}_skeleton_project_path"}"

    if test "$(pwd | grep "^/tmp/")"
    then
        if test "$(pwd | grep "old_copy")"
        then
            redis-cli set "$LAST_REF_KEY" "{{_copier_answers['_commit']}}"
            export TASK_EVENT="CHECKOUT_LAST_SKELETON"
        else
            export TASK_EVENT="CHECKOUT_PROJECT"
        fi
    else
        redis-cli set "$PROJECT_PATH_KEY" "$(pwd)" $__SILENT
        git ls-remote https://github.com/{{github_username}}/{{repo_name}} HEAD $__SILENT
        if test $? = 0
        then
            export TASK_EVENT="UPDATE"
        else
            export TASK_EVENT="COPY"
        fi
    fi

    determine_project_path
    determine_last_ref
    echo "--- Task stage: $TASK_EVENT"
    echo "--- Last skeleton revision: ${LAST_REF:-"N/A"}"
    echo "--- Project path: ${PROJECT_PATH:-"N/A"}"
    echo "--- Runner ID: $PPID"
    echo
}

toggle_workflows() {
    echo "Toggling workflows..."{% if visibility == "public" %}
    supply_smokeshow_key
    gh workflow enable smokeshow.yml
    {% else %}
    gh workflow disable smokeshow.yml
    {% endif %}{% if publish_on_pypi %}
    gh workflow enable release.yml
    {% else %}
    gh workflow disable release.yml
    {% endif %}
}

determine_project_path() {
    export PROJECT_PATH=$(redis-cli get "$PROJECT_PATH_KEY")
}

determine_last_ref() {
    export LAST_REF=$(redis-cli get "$LAST_REF_KEY")
}

run_copier_hook() {
    echo "Running copier hook..."
    python copier_hook.py
    echo "Copier hook exited with code $?."
    echo "Removing copier hook..."
    rm copier_hook.py || (echo "Failed to remove copier hook." $__STDERR && exit 1)
}

setup_poetry_virtualenv() {
    echo "Using Python version ${PYTHON_VERSION:=$(cat .python-version)}"
    poetry env use $PYTHON_VERSION
    echo "Running poetry installation routines..."
    if test "$TASK_EVENT" = "COPY"
    then
        poetry install || (echo "Failed to install dependencies." $__STDERR && exit 1)
    fi
    poetry run poe lock
}

supply_smokeshow_key() {
    echo "Checking if smokeshow secret needs to be created..."
    if test "$(gh secret list -e Smokeshow | grep -o SMOKESHOW_AUTH_KEY)"
    then
        echo "Smokeshow secret already exists, aborting." && return 0
    fi
    echo "Smokeshow secret does not exist, creating..."
    SMOKESHOW_AUTH_KEY=$(smokeshow generate-key | grep SMOKESHOW_AUTH_KEY | grep -oP "='\K[^']+")
    gh secret set SMOKESHOW_AUTH_KEY --env Smokeshow --body "$SMOKESHOW_AUTH_KEY" $__SILENT_STDERR
    if test $? = 0
    then
        echo "Smokeshow secret created."
    else
        echo "Failed to create smokeshow secret." $__STDERR
    fi
}

after_copy() {
    echo "Setting up the project..."
    echo
    setup_poetry_virtualenv
    run_copier_hook
    echo
    if test "$(git rev-parse --show-toplevel)" != "$(pwd)"
    then
        echo "Initializing git repository..."
        git init .
        git add .
        git branch -M {{main_branch}}
        echo "Main branch: {{main_branch}}"
        gh repo create {{repo_name}} --{{visibility}} --source=./ --remote=upstream --description="{{project_description}}"
        git remote add origin https://github.com/{{github_username}}/{{repo_name}}.git
    fi
    echo
    poetry run pre-commit install --hook-type pre-commit --hook-type pre-push
    local COMMIT_MSG="Copy bswck/skeleton@{{_copier_answers['_commit']}}"
    local REVISION_PARAGRAPH="Skeleton revision: https://github.com/bswck/skeleton/tree/{{_copier_answers['_commit']}}"
    echo
    git commit --no-verify -m "$COMMIT_MSG" -m "$REVISION_PARAGRAPH"
    git push --no-verify -u origin {{main_branch}}
    echo
    echo "Sleeping for 3 seconds..."
    sleep 3
    toggle_workflows
}

after_checkout_last_skeleton() {
    run_copier_hook
}

before_update() {
    :
}

after_update() {
    setup_poetry_virtualenv
    run_copier_hook
}

before_checkout_project() {
    :
}

after_checkout_project() {
    run_copier_hook
}

handle_task_event() {
    if test "$TASK_EVENT" = "COPY"
    then
        echo "COPY ROUTINE: Copying the skeleton."
        echo "-----------------------------------"
        after_copy
        determine_project_path
        echo "-----------------------------------"
        echo "COPY ROUTINE COMPLETE. ✅"
        echo
        echo "Done! 🎉"
        echo "Your repository is now set up at https://github.com/{{github_username}}/{{repo_name}}"
        echo "$ cd $PROJECT_PATH"
        echo
        echo "Happy coding!"
        echo "-- bswck"
        redis-cli del "$PROJECT_PATH_KEY" $__SILENT
    elif test "$TASK_EVENT" = "CHECKOUT_LAST_SKELETON"
    then
        echo "UPDATE ALGORITHM [1/3]: Checked out the last used skeleton before update."
        echo "-------------------------------------------------------------------------"
        after_checkout_last_skeleton
        before_update
        echo "-------------------------------------------------------------------------"
        echo "UPDATE ALGORITHM [1/3] COMPLETE. ✅"
        echo
        echo "Answer the following questions to update your project with the new skeleton."
        echo
    elif test "$TASK_EVENT" = "UPDATE"
    then
        echo "UPDATE ALGORITHM [2/3]: Overwrote the old skeleton before checking out the project."
        echo "-----------------------------------------------------------------------------------"
        echo "Re-setting up the project..."
        after_update
        before_checkout_project
        echo "-----------------------------------------------------------------------------------"
        echo "UPDATE ALGORITHM [2/3] COMPLETE. ✅"
        echo
    elif test "$TASK_EVENT" = "CHECKOUT_PROJECT"
    then
        echo "UPDATE ALGORITHM [3/3]: Checked out the project."
        echo "------------------------------------------------"
        after_checkout_project
        echo "------------------------------------------------"
        echo "UPDATE ALGORITHM [3/3] COMPLETE. ✅"
    fi
}