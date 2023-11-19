setup_task_stage() {
    OLD_REF_KEY=$PPID"_skeleton_old_commit"
    PROJECT_PATH_KEY=$PPID"_skeleton_project_path"
    DID_STASH_KEY=$PPID"_skeleton_did_stash"

    if test $(pwd | grep "^/tmp/")
    then
        if test $(pwd | grep "old_copy")
        redis-cli set $PROJECT_PATH_KEY $(cat /proc/$$/cmdline | awk 'NF{ print $NF }')
        then
            export TASK_STAGE="CHECKOUT_CURRENT_SKELETON"
        else
            export TASK_STAGE="CHECKOUT_NEW_SKELETON"
        fi
    else
        redis-cli set $PROJECT_PATH_KEY $(pwd)
        git ls-remote https://github.com/{{github_username}}/{{repo_name}} HEAD
        if [ $? -eq 0 ]
        then
            export TASK_STAGE="UPDATE"
        else
            export TASK_STAGE="COPY"
        fi
    fi

    echo "[Task stage: $TASK_STAGE]"
    echo "[Project path: $(project_path)]"
}

toggle_workflows() {
    echo "Toggling workflows..."{% if visibility == "public" %}
    supply_smokeshow_key
    gh workflow enable smokeshow.yml || :
    {% else %}
    gh workflow disable smokeshow.yml || :
    {% endif %}{% if publish_on_pypi %}
    gh workflow enable release.yml || :
    {% else %}
    gh workflow disable release.yml || :
    {% endif %}
    echo "Done! 🎉"
}

project_path() {
    return $(redis-cli get $PROJECT_PATH_KEY)
}

did_stash() {
    return $(redis-cli get $DID_STASH_KEY)
}

run_copier_hook() {
    echo "Running copier hook..."
    python copier_hook.py
    echo "Copier hook exited with code $?."
    echo "Removing copier hook..."
    rm copier_hook.py || echo "Failed to remove copier hook." && exit 1
}

setup_poetry_virtualenv() {
    echo "Running poetry installation routines..."
    poetry lock
    poetry install || echo "Failed to install dependencies." && exit 1
    PYTHON_VERSION="$(cat .python-version)"
    echo "Using Python version $PYTHON_VERSION"
    poetry env use $PYTHON_VERSION
    echo "Updating poetry lock..."
    poetry run poe lock
}

supply_smokeshow_key() {
    echo "Checking if smokeshow secret needs to be created..."
    if test "$(gh secret list -e Smokeshow | grep -o SMOKESHOW_AUTH_KEY)"
    then
        echo "Smokeshow secret already exists, aborting." && exit 0
    fi
    echo "Smokeshow secret does not exist, creating..."
    SMOKESHOW_AUTH_KEY=$(smokeshow generate-key | grep SMOKESHOW_AUTH_KEY | grep -oP "='\K[^']+")
    gh secret set SMOKESHOW_AUTH_KEY --env Smokeshow --body "$SMOKESHOW_AUTH_KEY"
    if [$? -eq 0]
    then
        echo "Smokeshow secret created."
    else
        echo "Failed to create smokeshow secret."
    fi
}

after_copy() {
    echo "Setting up the project..."
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
    poetry run pre-commit install --hook-type pre-commit --hook-type pre-push
    git commit --no-verify -m "Copy bswck/skeleton@{{_copier_answers['_commit']}}" -m "Skeleton revision: https://github.com/bswck/skeleton/tree/{{_copier_answers['_commit']}}"
    git push --no-verify -u origin {{main_branch}}
    sleep 3
    toggle_workflows
    echo
    echo "----"
    echo "Done! 🎉"
    echo "Your repository is now set up at https://github.com/{{github_username}}/{{repo_name}}"
    echo "$ cd "$(project_path)
    echo "Happy coding!"
}

after_checkout_current_skeleton() {
    echo "TASK STAGE 1: Checking out the current skeleton and hiding local files."
    echo "-----------------------------------------------------------------------"
    run_copier_hook
    echo "-----------------------------------------------------------------------"
    echo "STAGE 1 COMPLETE. ✅"
}

before_update() {
    cd $(project_path)
    if test $(git diff --name-only HEAD || grep '.*')
    then
        echo "Stashing local changes..."
        git stash push -u -m "Stash local changes before updating skeleton."
        redis-cli set $DID_STASH_KEY 1
    fi
}

after_update() {
    echo "TASK STAGE 2: Updating the project with the latest skeleton."
    echo "------------------------------------------------------------"
    echo "Re-setting up the project..."
    setup_poetry_virtualenv
    run_copier_hook
    echo "------------------------------------------------------------"
}

before_checkout_new_skeleton() {
}

after_checkout_new_skeleton() {
    echo "TASK STAGE 3: Incorporating the new skeleton into the current project."
    echo "----------------------------------------------------------------------"
    run_copier_hook
    cd $(project_path)
    OLD_REF=$(redis-cli get $OLD_REF_KEY)
    echo "Previous skeleton revision: $OLD_REF"
    echo "Current skeleton revision: {{_copier_answers['_commit']}}"
    REVISION_PARAGRAPH="Skeleton revision: https://github.com/bswck/skeleton/tree/{{_copier_answers['_commit']}}"
    git add .
    if test "$OLD_REF" = "{{_copier_answers['_commit']}}"
    then
        echo "The version of the skeleton has not changed."
        git commit --no-verify -m "Patch {{_copier_conf.answers_file}} at bswck/skeleton@$OLD_REF" -m $REVISION_PARAGRAPH
    else
        git commit --no-verify -m "Upgrade to bswck/skeleton@{{_copier_answers['_commit']}}" -m $REVISION_PARAGRAPH
    fi
    git push --no-verify
    sleep 3
    toggle_workflows
    if test did_stash = 1
    then
        echo "Unstashing local changes..."
        git stash pop
        redis-cli del $DID_STASH_KEY
    fi
    cd --
    echo "----------------------------------------------------------------------"
    echo "Done! 🎉"
    echo
    echo "Your repository is now up to date with this bswck/skeleton revision:"
    echo "https://github.com/bswck/skeleton/tree/{{_copier_answers['_commit']}}"
    echo
}

handle_task_stage() {
    if test "$TASK_STAGE" = "COPY"
    then
        after_copy
    elif test "$TASK_STAGE" = "CHECKOUT_CURRENT_SKELETON"
    then
        after_checkout_current_skeleton
        before_update
    elif test "$TASK_STAGE" = "UPDATE"
    then
        after_update
        before_checkout_new_skeleton
    elif test "$TASK_STAGE" = "CHECKOUT_NEW_SKELETON"
    then
        after_checkout_new_skeleton
    fi
}

setup_task_stage
handle_task_stage
