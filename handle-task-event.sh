#%- if not bump_script -%#
# (C) 2023–present Bartosz Sławecki (bswck)
#
# This script is run on every copier task event.
# Implemented as a workaround for copier-org/copier#240.
# https://github.com/copier-org/copier/issues/240
#
# Usage:
# $ copier copy --trust --vcs-ref HEAD gh:{{skeleton}} project
# Later on, this script will be included in your project and run automatically within:
# $ poe bump

# shellcheck shell=sh
# shellcheck disable=SC1054,SC1073,SC2005,SC1083

setup_task_event() {
    # By default use PPID not to overlap with other running copier processes
    echo "--- Project path key: ${PROJECT_PATH_KEY:="${PPID}_skeleton_project_path"}"

    # It is a temporary directory that copier uses before or after updating
    if test "$(pwd | grep "^/tmp/")"
    then
        # Before update
        if test "$(pwd | grep "old_copy")"
        then
            export TASK_EVENT="CHECKOUT_LAST_SKELETON"
        # After update
        else
            export TASK_EVENT="CHECKOUT_PROJECT"
        fi
    else
        # Export the project path to parent process
        redis-cli set "$PROJECT_PATH_KEY" "$(pwd)" > /dev/null 2>&1

        # Does this repository exist remotely?
        git ls-remote "{{repo_url}}" HEAD > /dev/null 2>&1

        if test $? = 0 && test "$LAST_REF"  # Missing $LAST_REF means we are not updating.
        then
            # Let the parent process know what is the new skeleton revision
            redis-cli set "$NEW_REF_KEY" "{{_copier_answers['_commit']}}"
            export TASK_EVENT="UPDATE"
            export BRANCH
            BRANCH="$(git rev-parse --abbrev-ref HEAD)"
        else
            # Integrate the skeleton for the first time or even create a new repository
            export TASK_EVENT="COPY"
        fi
    fi

    determine_project_path
    echo "--- Task stage: $TASK_EVENT"
    echo "--- Last skeleton revision: ${LAST_REF:-"N/A"}"
    echo "--- Project path: ${PROJECT_PATH:-"N/A"}"
    echo "--- Runner ID: $PPID"
    echo
}

run_copier_hook() {
    # Run a temporary hook that might generate LICENSE file and other stuff
    echo "Running copier hook..."
    python copier_hook.py
    echo "Copier hook exited with code $?."
    echo "Removing copier hook..."
    rm copier_hook.py || (echo "Failed to remove copier hook." 1>&2 && exit 1)
}

setup_poetry_virtualenv() {
    # Set up poetry virtualenv. This is needed for copier to work flawlessly.
    echo "Using Python version ${PYTHON_VERSION:=$(cat .python-version)}"
    poetry env use "$PYTHON_VERSION"
    echo "Running poetry installation for the $TASK_EVENT routine..."
    if test "$TASK_EVENT" = "COPY"
    then
        poetry update || (echo "Failed to install dependencies." 1>&2 && exit 1)
    fi
    poetry lock --no-update
}

after_copy() {
    # This is the first time the skeleton is integrated into the project.
    echo "Setting up the project..."
    echo
    setup_poetry_virtualenv
    run_copier_hook
    echo
    if test "$(git rev-parse --show-toplevel)" != "$(pwd)"
    then
        BRANCH="master"
        echo "Initializing git repository..."
        git init .
        git branch -M "$BRANCH"
        echo "Main branch: $BRANCH"
        gh repo create {{gh.repo_args}}
        git remote add origin "{{repo_url}}.git"
        CREATED=1
    else
        BRANCH="$(git rev-parse --abbrev-ref HEAD)"
    fi
    echo
    #%- if use_precommit %#
    poetry run pre-commit install --hook-type pre-commit --hook-type pre-push
    #%- endif %#
    COMMIT_MSG="Copy {{sr}}"
    REVISION_PARAGRAPH="Skeleton revision: {{skeleton_rev}}"
    echo
    git add .
    echo "Press ENTER to commit the changes or CTRL+C to abort."
    read -r _ || exit 1
    git commit --no-verify -m "$COMMIT_MSG" -m "$REVISION_PARAGRAPH"
    echo
    if test "$CREATED"
    then
        git push --no-verify -u origin "$BRANCH"
        setup_gh
    else
        git revert --no-commit HEAD
        echo "Reverted the latest commit to complete the integration process."
        echo "Patch your files and commit your changes to inform copier what needs to be kept."
        echo "Then run:"
        echo "$ poe bump"
    fi
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
    #% if use_precommit %#
    poetry run pre-commit install --hook-type pre-commit --hook-type pre-push
    #% else %#
    poetry run pre-commit uninstall
    #% endif %#
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
        echo "Your repository is now set up at {{repo_url}}"
        echo "$ cd $PROJECT_PATH"
        echo
        echo "Happy coding!"
        echo "-- bswck"
        redis-cli del "$PROJECT_PATH_KEY" > /dev/null 2>&1
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
#%- endif %#
#%- if bump_script %#
# Automatically copied from {{skeleton_url}}/tree/{{_copier_answers['_commit']}}/handle-task-event.sh
#%- endif %#
make_token() {
    export TOKEN
    TOKEN="$(echo "$(date +%s%N)" | sha256sum | head -c "${1:-10}")"
}

stash() {
    make_token 32
    export STASH_TOKEN="$TOKEN"
    git stash push -m "$STASH_TOKEN"
}

unstash() {
    STASH_ID="$(echo "$("$(git stash list)" | grep "${1:-STASH_TOKEN}" | grep -oP "^stash@{\K(\d)+")")"
    git stash pop "stash@{$STASH_ID}"
}

setup_gh() {
    echo "Calling GitHub setup hooks..."
    #%- if public %#
    supply_smokeshow_key
    #%- endif %#
}

determine_project_path() {
    # Determine the project path set by the preceding copier task process
    export PROJECT_PATH
    PROJECT_PATH=$(redis-cli get "$PROJECT_PATH_KEY")
}

ensure_gh_environment() {
    # Ensure that the GitHub environment exists
    echo "{{ensure_gh_environment}}" > /dev/null 2>&1 || return 1
}

supply_smokeshow_key() {
    # Supply smokeshow key to the repository
    echo "Checking if smokeshow secret needs to be created..."
    ensure_gh_environment "Smokeshow"
    if test "$(gh secret list -e Smokeshow | grep -o SMOKESHOW_AUTH_KEY)"
    then
        echo "Smokeshow secret already exists, aborting." && return 0
    fi
    echo "Smokeshow secret does not exist, creating..."
    SMOKESHOW_AUTH_KEY=$(smokeshow generate-key | grep SMOKESHOW_AUTH_KEY | grep -oP "='\K[^']+")
    gh secret set SMOKESHOW_AUTH_KEY --env Smokeshow --body "$SMOKESHOW_AUTH_KEY" 2> /dev/null
    if test $? = 0
    then
        echo "Smokeshow secret created."
    else
        echo "Failed to create smokeshow secret." 1>&2
    fi
}

#%- if bump_script %#
# End of copied code
#%- endif -%#
