echo "Running copier+poetry task composer! 🚀"
echo "Working directory: "$(pwd)

TMP=$(pwd | grep "^/tmp/")
if test "$TMP"; then
    echo "Operation: new/old copy for smart comparison"
    echo
    export OPERATION=smartcopy
    {% include "tasks/copier_hook.sh" %}
    OLD=$(pwd | grep "old_copy")
    if test "$OLD"; then
        OLD_COMMIT="{{_copier_answers['_commit']}}"
        echo "Old skeleton revision: https://github.com/bswck/skeleton/tree/$OLD_COMMIT"
        redis-cli set {{repo_name}}_skeleton_old_commit $OLD_COMMIT
    fi
    exit 0
fi

git ls-remote https://github.com/{{github_username}}/{{repo_name}} HEAD
if [ $? -eq 0 ]; then
    echo "Operation: update"
    export OPERATION=update
else
    echo "Operation: copy"
    export OPERATION=copy
fi

echo "----"
echo

if test "$OPERATION" = "copy"; then
    echo "Setting up the project..."
    {% include "tasks/poetry_setup.sh" %}
    {% include "tasks/copier_hook.sh" %}

    if test "$(git rev-parse --show-toplevel)" != "$(pwd)"; then
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
else  # $OPERATION=update
    echo "Re-setting up the project..."
    {% include "tasks/poetry_setup.sh" %}
    {% include "tasks/copier_hook.sh" %}

    git add .
    OLD_COMMIT=$(redis-cli get {{repo_name}}_skeleton_old_commit)
    echo "Previous skeleton revision: $OLD_COMMIT"
    echo "Current skeleton revision: {{_copier_answers['_commit']}}"
    if test "$OLD_COMMIT" = "{{_copier_answers['_commit']}}"; then
        echo "The version of the skeleton has not changed."
        git commit --no-verify -m "Patch copier answers and keep bswck/skeleton@$OLD_COMMIT" -m "Skeleton revision: https://github.com/bswck/skeleton/tree/$OLD_COMMIT"
    else
        git commit --no-verify -m "Upgrade to bswck/skeleton@{{_copier_answers['_commit']}}" -m "Skeleton revision: https://github.com/bswck/skeleton/tree/{{_copier_answers['_commit']}}"
    fi
    git push --no-verify
fi

sleep 3

echo "Toggling workflows..."
{% if visibility == "public" -%}
{% include "tasks/supply_smokeshow_key.sh" %}
gh workflow enable smokeshow.yml || :
{% else -%}
gh workflow disable smokeshow.yml || :
{% endif -%}
{% if publish_on_pypi -%}
gh workflow enable release.yml || :
{% else -%}
gh workflow disable release.yml || :
{% endif -%}

echo "----"
echo "Done! 🎉"
echo "Your repository: https://github.com/{{github_username}}/{{repo_name}}"