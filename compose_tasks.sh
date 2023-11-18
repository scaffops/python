echo "Running copier+poetry task composer! 🚀"
echo "Working directory: "$(pwd)

TMP=$(pwd | grep "^/tmp/")
if test "$TMP"; then
    echo "Operation: new/old copy for smart comparison"$(pwd)
    export OPERATION=smartcopy
    echo
    echo "Invoking copier hook..."
    {% include "tasks/copier_hook.sh" %}
    exit 0
fi

REMOTE=$(git ls-remote https://github.com/{{github_username}}/{{repo_name}} HEAD)
if [ $REMOTE -eq 0 ]; then
    echo "Operation: update"
    export OPERATION=update
else
    echo "Operation: copy"
    export OPERATION=copy
fi

echo "----"
echo

if test "$OPERATION" = "copy"; then
    echo "Setting up virtual environment..."
    {% include "tasks/poetry_setup.sh" %}
    echo "Invoking copier hook..."
    {% include "tasks/copier_hook.sh" %}

    if test "$(git rev-parse --show-toplevel)" != "$(pwd)"; then
        echo "Initializing git repository..."
        git init .
        git add .
        git branch -M {{main_branch}}
        echo "Main branch: {{main_branch}}"
        gh repo create {{repo_name}} --{{visibility}} --source=./ --remote=upstream
        git remote add origin https://github.com/{{github_username}}/{{repo_name}}.git
    fi

    poetry run pre-commit install --hook-type pre-commit --hook-type pre-push
    git commit --no-verify -m "Copy https://github.com/bswck/skeleton/tree/{{_copier_answers['_commit']}}"
    git push --no-verify -u origin {{main_branch}}

else  # $OPERATION=update
    if test "$(git diff --name-only HEAD)"; then
        echo "Stashing changes..."
        git stash
        STASHED=true
    fi

    echo "Re-setting up virtual environment..."
    {% include "tasks/poetry_setup.sh" %}
    echo "Re-invoking copier hook..."
    {% include "tasks/copier_hook.sh" %}

    git add .
    git commit --no-verify -m "Incorporate skeleton until bswck/skeleton@{{_copier_answers['_commit']}}"
    git push --no-verify

    if test "$STASHED"; then
        echo "Unstashing changes..."
        git stash pop
    fi
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