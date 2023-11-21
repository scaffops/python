# skeleton
My [copier](https://github.com/copier-org/copier) project template.

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
copier copy --trust --vcs-ref HEAD gh:bswck/skeleton <project_name>
```
3. Answer questions.
4. Change directory to your project:
```bash
cd <project_name>
```
5. Happy coding!
Your repository is on GitHub and has:
- release drafter (`$ poe release`),
- skeleton synchronizer (`$ poe sync`),
- pre-configured CI suite (including coverage report) and pre-commit hooks,
- badges in README.md,
- auto-generated LICENSE file.


## Incorporate to an existing project
Same as when copying.

1. Run the following command:
```bash
copier copy --trust --vcs-ref HEAD gh:bswck/skeleton <project_name>
```
2. Answer questions.
3. Allow copier to overwrite all files.
4. Patch your files (changes were locally reverted for your convenience).
5. Run the following command:
```bash
poe sync
```
6. Happy coding!


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
