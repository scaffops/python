setup-task-stage() {
    OLD_REF_KEY=$PPID"_skeleton_old_commit"
    PROJECT_PATH_KEY=$PPID"_skeleton_project_path"

    if test $(pwd | grep "^/tmp/")
    then
        if test $(pwd | grep "old_copy")
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
}

toggle-workflows() {
    echo "Toggling workflows..."
    {% if visibility == "public" -%}
    {% include "snippets/supply_smokeshow_key.sh" %}
    gh workflow enable smokeshow.yml || :
    {% else -%}
    gh workflow disable smokeshow.yml || :
    {% endif -%}
    {% if publish_on_pypi -%}
    gh workflow enable release.yml || :
    {% else -%}
    gh workflow disable release.yml || :
    {% endif -%}
    echo "Done! 🎉"
}

project-path() {
    return $(redis-cli get $PROJECT_PATH_KEY)
}

on-copy() {
    echo "Setting up the project..."
    {% include "snippets/poetry_setup.sh" %}
    {% include "snippets/copier_hook.sh" %}
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
    toggle-workflows
    echo
    echo "----"
    echo "Done! 🎉"
    echo "Your repository is now set up at https://github.com/{{github_username}}/{{repo_name}}"
    echo "$ cd "$(project-path)
    echo "Happy coding!"
}

on-checkout-current-skeleton() {
    echo "TASK STAGE 1: Checking out the current skeleton and hiding local files."
    echo "-----------------------------------------------------------------------"
    {% include "snippets/copier_hook.sh" %}
    echo "-----------------------------------------------------------------------"
    echo "STAGE 1 COMPLETE. ✅"
}

on-update() {
    echo "TASK STAGE 2: Updating the project with the latest skeleton."
    echo "------------------------------------------------------------"
    echo "Re-setting up the project..."
    {% include "snippets/poetry_setup.sh" %}
    {% include "snippets/copier_hook.sh" %}
    echo "------------------------------------------------------------"
}

on-checkout-new-skeleton() {
    echo "TASK STAGE 3: Bringing back the local files and committing the changes."
    echo "-----------------------------------------------------------------------"
    {% include "snippets/copier_hook.sh" %}
    cd $(project-path)
    OLD_REF=$(redis-cli get $OLD_REF_KEY)
    echo "Previous skeleton revision: $OLD_REF"
    echo "Current skeleton revision: {{_copier_answers['_commit']}}"
    REVISION_PARAGRAPH="Skeleton revision: https://github.com/bswck/skeleton/tree/{{_copier_answers['_commit']}}"
    git add .
    if test "$OLD_REF" = "{{_copier_answers['_commit']}}"; then
        echo "The version of the skeleton has not changed."
        git commit --no-verify -m "Patch {{_copier_conf.answers_file}} at bswck/skeleton@$OLD_REF" -m $REVISION_PARAGRAPH
    else
        git commit --no-verify -m "Upgrade to bswck/skeleton@{{_copier_answers['_commit']}}" -m $REVISION_PARAGRAPH
    fi
    git push --no-verify
    sleep 3
    toggle-workflows
    cd --
    echo "-----------------------------------------------------------------------"
    echo "Done! 🎉"
    echo
    echo "Your repository is now up to date with this bswck/skeleton revision:"
    echo "https://github.com/bswck/skeleton/tree/{{_copier_answers['_commit']}}"
    echo
}

handle-task-stage() {
    if test "$TASK_STAGE" = "COPY"
    then
        on-copy
    elif test "$TASK_STAGE" = "CHECKOUT_CURRENT_SKELETON"
    then
        on-checkout-current-skeleton
    elif test "$TASK_STAGE" = "UPDATE"
    then
        on-update
    elif test "$TASK_STAGE" = "CHECKOUT_NEW_SKELETON"
    then
        on-checkout-new-skeleton
    fi
}

setup-task-stage
handle-task-stage
