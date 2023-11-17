#!/usr/bin/env bash
# (C) 2023–present Bartosz Sławecki (bswck)
#
# Setup a new project with Poetry and GitHub.
# This script is run automatically by copier.
# As of 17.11.2023, https://github.com/copier-org/copier/issues/240 is not resolved.
echo "Checking if this directory is a git repository..."
git rev-parse --is-inside-work-tree
if [ $? -ne 0 ]; then
    git init .
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
    gh repo create {{ repo_name }} --{{ visibility }} --source=./ --remote=upstream
    git remote add origin https://github.com/{{ github_username }}/{{ repo_name }}.git
    git push -u origin master
    poetry run pre-commit install --hook-type pre-commit --hook-type pre-push
else
    echo "This directory is a git repository."
    echo "Initial commit and remote setup skipped."
fi
