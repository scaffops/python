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

# How to use it
You might use this template or fork it and modify it to your needs.

## Configure [GitHub CLI](https://cli.github.com/)
```bash
gh auth login
```
Ensure the `workflows` scope is in your authorized scopes:
```bash
gh auth refresh -h github.com -s workflows
```

## Install [Redis](https://github.com/redis/redis), [pipx](https://github.com/pypa/pipx) and [Copier](https://github.com/copier-org/copier)
```bash
sudo apt install redis
python3 -m pip install --user pipx
pipx install copier
```

## Create a new project
1. Make sure that you trust me.
2. Run the following command:
```bash
copier copy --trust --vcs-ref HEAD gh:bswck/skeleton path/to/project
```
3. Answer questions.
4. Change directory to your project:
```bash
cd path/to/project
```
5. Happy coding!
Your repository is on GitHub and has:
- release drafter (`$ poe release`),
- skeleton synchronizer (`$ poe sync`),
- pre-configured CI suite (including coverage report) and pre-commit hooks,
- badges in README.md,
- auto-generated LICENSE file.


## Incorporate to an existing project
Almost the same as above.

1. Run the following command:
```bash
copier copy --trust --vcs-ref HEAD gh:bswck/skeleton path/to/project
```
2. Answer questions.
3. Allow copier to overwrite all files.
4. Change directory to your project:
```bash
cd path/to/project
```
5. Patch your files (changes were locally reverted for your convenience).
Be sure that the codebase is not lost but files maintained by skeleton are updated.
6. Run the following command:
```bash
poe sync
```
7. Happy coding!


## Update your project
```bash
poe sync
```
For more verbosity:
```bash
poe sync HEAD
```

You might use some other ref than HEAD, up to you.

More information about copier [here](https://copier.readthedocs.io/en/stable/).

# License
This project is licensed under the terms of the [MIT License](/LICENSE).

# Credits
[@pawamoy](https://github.com/pawamoy), for creating copier and a sample poetry project template.<br/>
[@jaraco](https://github.com/jaraco), for inspiring me to create my own skeleton, like [the one he has](https://github.com/jaraco/skeleton).

[Read more about copier.](https://copier.readthedocs.io/en/stable/)<br/>
[Read more about jaraco/skeleton.](https://blog.jaraco.com/skeleton)

# Documentation
Coming soon.


(C) 2023–present Bartosz Sławecki ([@bswck](https://github.com/bswck)).
