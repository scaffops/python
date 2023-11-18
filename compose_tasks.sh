echo "Working directory: "$(pwd)
echo

OLD_COPY=$(pwd | grep "^/tmp/")
if test "$OLD_COPY"; then
    echo "This directory is an old copy."
    echo "Copier is copying from bswck/skeleton@{{_vcs_ref['commit']}} for comparison with this repository."
    {% include "tasks/poetry_setup.sh" %}
    {% include "tasks/copier_hook.sh" %}
    exit 0
fi
echo "Checking if this directory is on remote..."
git ls-remote https://github.com/{{github_username}}/{{repo_name}} HEAD
if [ $? -eq 0 ]; then
    echo "This directory is on remote."
    OPERATION=update
else
    echo "This directory is not on remote."
    OPERATION=copy
fi

if test "$OPERATION" = "copy"; then
    {% include "tasks/poetry_setup.sh" %}
    {% include "tasks/copier_hook.sh" %}
    if test "$(git rev-parse --show-toplevel)" != "$(pwd)"; then
        echo "This directory is not a git repositroy. Initializing."
        git init .
        git add .
        git branch -M {{main_branch}}
        gh repo create {{repo_name}} --{{visibility}} --source=./ --remote=upstream
        git remote add origin https://github.com/{{github_username}}/{{repo_name}}.git
    fi
    poetry run pre-commit install --hook-type pre-commit --hook-type pre-push
    git commit --no-verify -m "Copy bswck/skeleton@{{_copier_answers['_commit']}}"
    git push --no-verify -u origin {{main_branch}}
else  # $OPERATION=update
    if test "$(git status --porcelain)"; then
        echo This directory is a git repository with uncommitted changes.
        echo Stashing changes...
        git stash
        STASHED=true
    fi
    echo "This directory is assumed to be a git repository (available on remote)."
    {% include "tasks/poetry_setup.sh" %}
    {% include "tasks/copier_hook.sh" %}
    git add .
    git commit --no-verify -m "Incorporate bswck/skeleton@{{_copier_answers['_commit']}}"
    git push --no-verify
    if test "$STASHED"; then
        echo "Unstashing changes..."
        git stash pop
    fi
fi

sleep 5

{% if visibility == "public" -%}
{% include "tasks/supply_smokeshow_key.sh" %}
gh workflow enable smokeshow.yml
{% else -%}
gh workflow disable smokeshow.yml
{% endif -%}
{% if publish_on_pypi -%}
gh workflow enable release.yml
{% else -%}
gh workflow disable release.yml
{% endif -%}
