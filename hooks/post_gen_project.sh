#!/usr/bin/env bash
# (C) 2023–present Bartosz Sławecki (bswck)
#
# Setup a new project with Poetry and GitHub.
# This script is run automatically by cookiecutter.
# https://cookiecutter.readthedocs.io/en/2.4.0/advanced/hooks.html#types-of-hooks
git init .
poetry check
poetry install
if [ $? -eq 0 ]; then
    echo "Successfully installed dependencies."
else
    echo "Failed to install dependencies."
    exit 1
fi
PYTHON_VERSION="$(cat .python-version)"
poetry env use $PYTHON_VERSION
poetry run poe lock
git add .
git commit -m "Initial commit"
poetry run pre-commit install --hook-type pre-commit --hook-type pre-push
gh repo create {{ cookiecutter.repo_name }} --{{ cookiecutter.visibility }} --source=./ --remote=upstream
git remote add origin https://github.com/{{ cookiecutter.github_username }}/{{ cookiecutter.repo_name }}.git
git push -u origin master
