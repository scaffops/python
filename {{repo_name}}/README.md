# {{repo_name}} [![Package version](https://img.shields.io/pypi/v/{{pypi_project_name}}?label=PyPI)](https://pypi.org/project/{{pypi_project_name}}) [![Supported Python versions](https://img.shields.io/pypi/pyversions/{{pypi_project_name}}.svg?logo=python&label=Python)](https://pypi.org/project/{{pypi_project_name}})
[![Tests](https://github.com/{{github_username}}/{{repo_name}}/actions/workflows/test.yml/badge.svg)](https://github.com/{{github_username}}/{{repo_name}}/actions/workflows/test.yml)
[![Coverage](https://coverage-badge.samuelcolvin.workers.dev/{{github_username}}/{{repo_name}}.svg)](https://coverage-badge.samuelcolvin.workers.dev/redirect/{{github_username}}/{{repo_name}})
[![Ruff](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/ruff/main/assets/badge/v2.json)](https://github.com/astral-sh/ruff)
[![Code style](https://img.shields.io/badge/code%20style-black-000000.svg?label=Code%20style)](https://github.com/psf/black)
[![License](https://img.shields.io/github/license/{{github_username}}/{{repo_name}}.svg?label=License)](https://github.com/{{github_username}}/{{repo_name}}/blob/main/LICENSE)

# Installation

## For the users 💻
```bash
pip install {{pypi_project_name}}
```

## For the contributors ❤️
> [!Note]
> If you use Windows, it is highly recommended to complete the installation in the way presented below through [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install).

First, [install Poetry](https://python-poetry.org/docs/#installation).<br/>
Poetry is an amazing tool for managing dependencies & virtual environments, building packages and publishing them.

```bash
pipx install poetry
```
<sub>If you encounter any problems, refer to [the official documentation](https://python-poetry.org/docs/#installation) for the most up-to-date installation instructions.</sub>

Be sure to have Python {{python_version}} installed—if you use [pyenv](https://github.com/pyenv/pyenv#readme), simply run:
```bash
pyenv install {{python_version}}
```

Then, run:
```bash
git clone https://github.com/{{github_username}}/{{repo_name}}
cd {{repo_name}}
poetry install
pre-commit install --hook-type pre-commit --hook-type pre-push
poetry env use $(cat .python-version)
poetry shell
```

# Legal info
© Copyright by {{author_full_name}} ([@{{github_username}}](https://github.com/{{github_username}})).{% if license_name != "None" %}<br />This software is licensed under the [{{license_name}} License](https://github.com/{{github_username}}/{{repo_name}}/blob/main/LICENSE).
{% endif %}