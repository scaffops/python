# (C) 2023–present Bartosz Sławecki (bswck)
#
# This script is run on every copier task event.
# Implemented as a workaround for copier-org/copier#240.
# https://github.com/copier-org/copier/issues/240
#
# Usage:
# $ copier copy --trust --vcs-ref HEAD gh:{{skeleton}} project
# Later on, this script will be included in your project and run automatically within:
# $ poe skeleton upgrade

# shellcheck shell=bash
# shellcheck disable=SC1054,SC1073,SC2005,SC1083

set -eEuo pipefail

BOLD="\033[1m"
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
GREY="\033[0;90m"
NC="\033[0m"

UI_INFO="${BLUE}🛈${NC}"
UI_NOTE="${GREY}→${NC}"
UI_TICK="${GREEN}✔${NC}"
UI_CROSS="${RED}✘${NC}"

#% include "make_context.bash" %#

setup_task_event() {
    # By default use PPID not to overlap with other running copier processes
    export SKELETON_COMMAND
    note "(Setting up task event)"
    info "${GREY}Skeleton command:$NC ${SKELETON_COMMAND:="copy"}"
    info "${GREY}Project path key:$NC ${PROJECT_PATH_KEY:="${PPID}_skeleton_project_path"}"

    # It is a temporary directory that copier uses before or after updating
    set +eE
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
        silent redis-cli set "$PROJECT_PATH_KEY" "$(pwd)"

        # Does this repository exist remotely?
        silent git ls-remote "$REPO_URL" HEAD
        if test $? = 0 && test "${LAST_REF:=""}"  # Missing $LAST_REF means we are not updating.
        then
            # Let the parent process know what is the new skeleton revision
            set -eE
            silent redis-cli set "$NEW_REF_KEY" "$SREF"
            export TASK_EVENT="UPGRADE"
            export BRANCH
            BRANCH="$(git rev-parse --abbrev-ref HEAD)"
        else
            # Integrate the skeleton for the first time or even create a new repository
            export TASK_EVENT="COPY"
        fi
    fi
    set -eE

    determine_project_path
    info "${GREY}Task stage:$NC $TASK_EVENT"
    info "${GREY}Last skeleton revision:$NC ${LAST_REF:-"N/A"}"
    info "${GREY}Project path:$NC ${PROJECT_PATH:-"N/A"}"
    info "${GREY}Runner ID:$NC $PPID"
    echo
}

run_python_hook() {
    # Run a temporary hook that might generate LICENSE file and other stuff
    note "Running copier hook..."
    python python_hook.py
    info "Copier hook exited with code $BOLD$?$NC."
    note "Removing copier hook..."
    rm python_hook.py || (error $? "Failed to remove copier hook.")
}

setup_poetry_virtualenv() {
    # Set up Poetry virtualenv. This is needed for copier to work flawlessly.
    #% if not ctt %#
    note "Setting Python version to ${PYTHON_VERSION:=$(cat .python-version)}..."
    poetry env use "$PYTHON_VERSION"
    echo
    note "Running Poetry installation for the $TASK_EVENT routine..."
    if test "$TASK_EVENT" = "COPY"
    then
        poetry update || (error $? "Failed to install dependencies.")
    fi
    poetry lock --no-update
    #% else %#
    :
    #% endif %#
    clear
}

after_copy() {
    # This is the first time the skeleton is integrated into the project.
    note "Setting up the project..."
    echo
    setup_poetry_virtualenv
    run_python_hook
    silent rm -f ./setup-local.bash
    #% if not ctt %#
    if test "$(git rev-parse --show-toplevel 2> /dev/null)" != "$(pwd)"
    then
        BRANCH="main"
        echo
        note "Initializing git repository..."
        silent git init .
        silent git branch -M "$BRANCH"
        info "Main branch: $BRANCH"
        eval "gh repo create $GH_REPO_ARGS"
        git remote add origin "$REPO_URL.git"
        CREATED=1
    else
        BRANCH="$(git rev-parse --abbrev-ref HEAD)"
    fi
    echo
    #%- if precommit %#
    note "Installing pre-commit..."
    silent poetry run pre-commit install
    success "Pre-commit installed."
    #%- endif %#
    COMMIT_MSG="Copy $SNREF"
    REVISION_PARAGRAPH="Skeleton revision: $SKELETON_REV"
    silent git add .
    silent git commit --no-verify -m "$COMMIT_MSG" -m "$REVISION_PARAGRAPH"
    echo
    if test "${CREATED:-0}" != 0
    then
        silent git push --no-verify -u origin "$BRANCH"
        setup_gh && echo
    else
        silent git revert --no-commit HEAD
        info "Reverted the latest commit to complete the integration process."
        echo "Patch your files and commit your changes with the --am option"
        echo "to inform copier what needs to be kept."
        echo
        echo "Then run:"
        echo "💲 poe skeleton upgrade"
    fi
    #% endif %#
}

after_checkout_last_skeleton() {
    run_python_hook
}

before_update() {
    :
}

after_update() {
    setup_poetry_virtualenv
    run_python_hook
    #% if precommit %#
    poetry run pre-commit install
    #% else %#
    poetry run pre-commit uninstall
    #% endif %#
}

before_checkout_project() {
    :
}

after_checkout_project() {
    run_python_hook
}

handle_task_event() {
    if test "$TASK_EVENT" = "COPY"
    then
        clear
        note "COPY ROUTINE: Copying the skeleton."
        after_copy
        determine_project_path
        success "COPY ROUTINE COMPLETE."
        echo
        #% if not ctt %#
        success "Done! 🎉"
        info "Your repository is now set up at ${BOLD}$REPO_URL$NC"
        echo -e "  💲 ${BOLD}cd $PROJECT_PATH$NC"
        echo
        echo "Happy coding!"
        echo -e "$GREY-- bswck$NC"
        silent redis-cli del "$PROJECT_PATH_KEY"
        #% endif %#
    elif test "$TASK_EVENT" = "CHECKOUT_LAST_SKELETON"
    then
        info "UPGRADE ALGORITHM [1/3]: Checked out the last used skeleton before update."
        after_checkout_last_skeleton
        before_update
        success "UPGRADE ALGORITHM [1/3] COMPLETE."
        echo
    elif test "$TASK_EVENT" = "UPGRADE"
    then
        info "UPGRADE ALGORITHM [2/3]: Overwrote the old skeleton before checking out the project."
        note "Re-setting up the project..."
        after_update
        before_checkout_project
        success "UPGRADE ALGORITHM [2/3] COMPLETE."
        echo
    elif test "$TASK_EVENT" = "CHECKOUT_PROJECT"
    then
        info "UPGRADE ALGORITHM [3/3]: Checked out the project."
        after_checkout_project
        success "UPGRADE ALGORITHM [3/3] COMPLETE."
    fi
}

info() {
    echo -e "$UI_INFO $*"
}

note() {
    echo -e "$UI_NOTE $GREY$*$NC"
}

success() {
    echo -e "$UI_TICK $*"
}

silent() {
    "$1" "${@:2}" > /dev/null 2>&1
}

error() {
    local CODE=$1
    echo -e "$UI_CROSS ${*:2}" >&2
    return "$CODE"
}

setup_gh() {
    note "Calling GitHub setup hooks..."
    #%- if public %#
    echo
    provision_gh_envs
    #%- endif %#
}

determine_project_path() {
    # Determine the project path set by the preceding copier task process
    export PROJECT_PATH
    PROJECT_PATH=$(redis-cli get "$PROJECT_PATH_KEY")
}

create_gh_env() {
    # Ensure that the GitHub environment exists
    eval "echo \$($GH_ENSURE_ENV)" || error 0 "Failed to ensure GitHub environment $BLUE$1$NC exists."
}

provision_gh_envs() {
    local SMOKESHOW_KEY
    local CODECOV_TOKEN
    local ENV_NAME="Upload Coverage"
    note "Creating a GitHub Actions environment $BLUE$ENV_NAME$GREY if necessary..."
    create_gh_env "$ENV_NAME" && success "Environment $BLUE$ENV_NAME$NC exists."
    echo
    note "Checking if Smokeshow secret key needs to be created..."
    set +eE
    if test "$(gh secret list -e "$ENV_NAME" | grep -o SMOKESHOW_AUTH_KEY)"
    then
        note "Smokeshow secret key already set."
    else
        note "Smokeshow secret key does not exist yet."
        note "Creating Smokeshow secret key..."
        SMOKESHOW_KEY=$(smokeshow generate-key | grep SMOKESHOW_AUTH_KEY | grep -oP "='\K[^']+")
        gh secret set SMOKESHOW_AUTH_KEY --env "$ENV_NAME" --body "$SMOKESHOW_KEY" 2> /dev/null || error 0 "Failed to set Smokeshow secret key."
        echo
    fi
    note "Checking if Codecov secret token needs to be created..."
    if test "$(gh secret list -e "$ENV_NAME" | grep -o CODECOV_TOKEN)"
    then
        note "Codecov secret key already set."
    else
        note "Setting Codecov secret token..."
        CODECOV_TOKEN=$(keyring get codecov token)
        gh secret set CODECOV_TOKEN --env "$ENV_NAME" --body "$CODECOV_TOKEN" 2> /dev/null || error 0 "Failed to set Codecov secret token."
    fi
    set -eE
}

determine_new_ref() {
    # Determine the new skeleton revision set by the child process
    export NEW_REF
    NEW_REF=$(redis-cli get "$NEW_REF_KEY")
}

before_update_algorithm() {
    # Stash changes if any
    if test "$(git status --porcelain)"
    then
        error 0 "There are uncommitted changes in the project."
        error 1 "Stash them and continue."
    else
        note "Working tree clean, no need to stash."
    fi
}

do_update() {
    copier update --trust --vcs-ref "$1" "${@:2}"
}

run_update_algorithm() {
    # Run the underlying update algorithm
    export SKELETON_COMMAND
    SKELETON_COMMAND="${1:-"upgrade"}"
    if test "$SKELETON_COMMAND" = "upgrade-patch"
    then
        do_update "${2:-"HEAD"}"
    elif test "$SKELETON_COMMAND" = "upgrade"
    then
        do_update "${2:-"HEAD"}" --defaults
    elif test "$SKELETON_COMMAND" = "patch"
    then
        # shellcheck disable=SC2068
        do_update "$LAST_REF" ${@:3}
    else
        error 1 "Unknown update algorithm: '$1'"
    fi
    determine_new_ref
    determine_project_path
}

after_update_algorithm() {
    # Run post-update hooks, auto-commit changes
    declare -a CONFLICTED_FILES
    declare -a UNMERGED_FILES
    local REVISION_PARAGRAPH
    cd "$PROJECT_PATH"
    info "${GREY}Previous skeleton revision:$NC $LAST_REF"
    info "${GREY}Current skeleton revision:$NC ${NEW_REF:-"N/A"}"
    REVISION_PARAGRAPH="Skeleton revision: $SKELETON_URL/tree/${NEW_REF:-"HEAD"}"
    echo
    note "Checking for conflicts..."
    echo
    readarray -t UNMERGED_FILES <<< "$(git diff --name-only --diff-filter=U)"
    for UNMERGED_FILE in "${UNMERGED_FILES[@]}"
    do
        if test "$(git diff --check "$UNMERGED_FILE")"
        then
            CONFLICTED_FILES+=("$UNMERGED_FILE")
        else
            git add "$UNMERGED_FILE"
        fi
    done
    # shellcheck disable=SC2128
    while test "${CONFLICTED_FILES:-""}"
    do
        error 0 "There are conflicts in the following files:"
        for CONFLICTED_FILE in "${CONFLICTED_FILES[@]}"
        do
            error 0 "- $CONFLICTED_FILE"
        done
        error 0 "Resolve them and press Enter."
        read -r
        readarray -t CONFLICTED_FILES <<< "$(git diff --name-only --diff-filter=U)"
        echo
    done
    success "No conflicts, proceeding."
    note "Locking Poetry dependencies..."
    poetry lock
    echo
    if test "$(git status --porcelain)"
    then
        silent git add .
        silent git rm -f ./setup-local.bash
        if test "$LAST_REF" = "$NEW_REF"
        then
            info "The version of the skeleton has not changed."
            local COMMIT_MSG="Mechanized patch at $SKELETON@$NEW_REF"
        else
            if test "$NEW_REF"
            then
                local COMMIT_MSG="Upgrade to $SKELETON@$NEW_REF"
            else
                local COMMIT_MSG="Upgrade to $SKELETON of unknown revision"
            fi
        fi
        silent redis-cli del "$PROJECT_PATH_KEY"
        silent redis-cli del "$NEW_REF_KEY"
        note "Committing changes..."
        silent git commit --no-verify -m "$COMMIT_MSG" -m "$REVISION_PARAGRAPH"
    else
        info "No changes to commit."
    fi
    setup_gh && echo
}

update_entrypoint() {
    cd "${PROJECT_PATH:=$(git rev-parse --show-toplevel)}" || exit 1
    echo
    info "${GREY}Last skeleton revision:$NC $LAST_REF"
    echo
    note "UPGRADE ROUTINE [1/3]: Running pre-update hooks."
    before_update_algorithm
    success "UPGRADE ROUTINE [1/3] COMPLETE."
    echo
    note "UPGRADE ROUTINE [2/3]: Running the underlying update algorithm."
    run_update_algorithm "$@"
    success "UPGRADE ROUTINE [2/3] COMPLETE."
    echo
    info "${GREY}Project path:$NC $PROJECT_PATH"
    echo
    note "UPGRADE ROUTINE [3/3]: Running post-update hooks."
    after_update_algorithm
    success "UPGRADE ROUTINE [3/3] COMPLETE."
    echo
    success "Done! 🎉"
    echo
    info "Your repository is now up to date with this $SKELETON revision:"
    echo -e "  ${BOLD}$SKELETON_URL/tree/${NEW_REF:-"HEAD"}$NC"
}
