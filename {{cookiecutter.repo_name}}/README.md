# {{cookiecutter.repo_name}} [![Package version](https://img.shields.io/pypi/v/{{cookiecutter.pypi_project_name}}?label=PyPI)](https://pypi.org/project/{{cookiecutter.pypi_project_name}}) [![Supported Python versions](https://img.shields.io/pypi/pyversions/{{cookiecutter.pypi_project_name}}.svg?logo=python&label=Python)](https://pypi.org/project/{{cookiecutter.pypi_project_name}})
[![Tests](https://github.com/{{cookiecutter.github_username}}/{{cookiecutter.repo_name}}/actions/workflows/test.yml/badge.svg)](https://github.com/{{cookiecutter.github_username}}/{{cookiecutter.repo_name}}/actions/workflows/test.yml)
[![Coverage](https://coverage-badge.samuelcolvin.workers.dev/{{cookiecutter.github_username}}/{{cookiecutter.repo_name}}.svg)](https://coverage-badge.samuelcolvin.workers.dev/redirect/{{cookiecutter.github_username}}/{{cookiecutter.repo_name}})
[![Ruff](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/ruff/main/assets/badge/v2.json)](https://github.com/astral-sh/ruff)
[![Code style](https://img.shields.io/badge/code%20style-black-000000.svg?label=Code%20style)](https://github.com/psf/black)
[![License](https://img.shields.io/github/license/{{cookiecutter.github_username}}/{{cookiecutter.repo_name}}.svg?label=License)](https://github.com/{{cookiecutter.github_username}}/{{cookiecutter.repo_name}}/blob/main/LICENSE)

# Installation

## For the users 💻
```bash
pip install {{cookiecutter.pypi_project_name}}
```

## For the contributors ❤️
_Note: If you use Windows, it is highly recommended to complete the installation in the way presented below through [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install)._

First, [install Poetry](https://python-poetry.org/docs/#installation).<br/>
Poetry is an amazing tool for managing dependencies & virtual environments, building packages and publishing them.

```bash
curl -sSL https://install.python-poetry.org | python3 -
```
<sub>If you encounter any problems, refer to [the official documentation](https://python-poetry.org/docs/#installation) for the most up-to-date installation instructions.</sub>

Be sure to have Python {{cookiecutter.python_version}} installed—if you use [pyenv](https://github.com/pyenv/pyenv#readme), simply run:
```bash
pyenv install {{cookiecutter.python_version}}
```

Then, run:
```bash
git clone https://github.com/{{cookiecutter.github_username}}/{{cookiecutter.repo_name}} && cd {{cookiecutter.repo_name}} && ./install && poetry shell
```

# Legal info
© Copyright by {{cookiecutter.author_full_name}} ([@{{cookiecutter.github_username}}](https://github.com/{{cookiecutter.github_username}})).
{% if cookiecutter.license_name != "None" %}
<br />This software is licensed under the [{{cookiecutter.license_name}} License](https://github.com/{{cookiecutter.github_username}}/{{cookiecutter.repo_name}}/blob/main/LICENSE).
{% endif %}
