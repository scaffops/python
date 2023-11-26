# skeleton
My [copier](https://github.com/copier-org/copier) Python project template.

# Motivation
I was inspired by https://blog.jaraco.com/skeleton.

The goal of this project is to provide a skeleton for my Python projects,
simultaneously trying to take on the following [jaraco/skeleton](https://github.com/jaraco/skeleton) challenges:
- Solve the [History is Forever](https://blog.jaraco.com/skeleton/#history-is-forever) problem.
  - [x] The true history is not obscured.
  - [ ] Existing histories are broken until the handoff commit is pulled.
  - [ ] Attribution is not lost.
- Solve the [Continuous Integration Mismatch](https://blog.jaraco.com/skeleton/#continuous-integration-mismatch) problem.
  - [x] Downstream projects and the skeleton itself can have different CI configurations.
- Solve the [Commit Integrations Mismatch](https://blog.jaraco.com/skeleton/#commit-integrations-mismatch) problem.
  - [x] Downstream projects and the skeleton itself can reference different issues and pull requests in their commit histories.

Because the project does not copy the whole history from skeleton, many of the problems are solved by design.

# How to use it
You might use this template or fork it and modify it to your needs.

## Configure [GitHub CLI](https://cli.github.com/)
    gh auth login
Ensure the `workflows` scope is in your authorized scopes:

    gh auth refresh -h github.com -s workflows

## Install [Redis](https://github.com/redis/redis), [pipx](https://github.com/pypa/pipx) and [Copier](https://github.com/copier-org/copier)

    sudo apt install redis
    python3 -m pip install --user pipx
    pipx install copier
    python3 -m pip install copier-templates-extensions

## Create a new project
1. Make sure that you trust me.
2. Run the following command:

       copier copy --trust --vcs-ref HEAD gh:bswck/skeleton path/to/project

3. Answer the questions.
4. Change directory to your project:

       cd path/to/project

5. Happy coding!
Your repository is on GitHub and has:
- a release maker (`$ poe release`),
- a skeleton bump tool (`$ poe bump`),
- aesthetic badges in README.md,
- an auto-generated LICENSE file,
- a pre-configured `pyproject.toml` file,
- a ready-to-use [Poetry](https://python-poetry.org/) virtual environment with all the necessary dev dependencies installed, including [poethepoet](https://github.com/nat-n/poethepoet/#readme), [pre-commit](https://pre-commit.com/),
[mypy](https://github.com/python/mypy#readme), [Ruff](https://github.com/astral-sh/ruff#readme), etc.
- a pre-configured CI suite for GitHub Actions (including coverage report) and pre-commit.

## Incorporate to an existing project
Almost the same as above.

1. Change directory to your project:

       cd path/to/project

2. Run the following command:

       copier copy --trust --vcs-ref HEAD gh:bswck/skeleton .

3. Answer the questions.
4. Allow copier to overwrite all files.
5. Patch your files (changes were locally reverted for your convenience).
   Be sure that the codebase is not lost but files maintained by skeleton are updated.
6. Run the following command:

       poe bump

7. Happy coding!


## Bump the version of skeleton in your project

    poe bump

Or, for more verbosity:

    poe bump HEAD

You might use a [ref](https://www.atlassian.com/git/tutorials/refs-and-the-reflog) different than HEAD, up to you.

# License
This project is licensed under the terms of the [MIT License](/LICENSE).

# Credits
[@jpsca](https://github.com/jpsca), for creating Copier.</br>
[@pawamoy](https://github.com/pawamoy), for creating a sample poetry project template.<br/>
[@jaraco](https://github.com/jaraco), for inspiring me to create my own skeleton, like [the one he has](https://github.com/jaraco/skeleton).

[Read more about copier.](https://copier.readthedocs.io/en/stable/)<br/>
[Read more about jaraco/skeleton.](https://blog.jaraco.com/skeleton)

# Documentation
Coming soon.


(C) 2023–present Bartosz Sławecki ([@bswck](https://github.com/bswck)).
