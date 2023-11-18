# skeleton
My [copier](https://github.com/copier-org/copier) project template.

# How to use it

## Configure [GitHub CLI](https://cli.github.com/)
```bash
gh auth login
```
Ensure the `workflows` scope is in your authorized scopes:
```bash
gh auth refresh -h github.com -s workflows
```

## Install pipx and copier
```bash
python3 -m pip install --user pipx
pipx install copier
```

## Create a new project
Please make sure that you trust me before running this command.
```bash
copier copy --trust --vcs-ref HEAD gh:bswck/skeleton <project_name>
# Answer questions
```

## Update your existing project
```bash
copier update --trust --vcs-ref HEAD
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
