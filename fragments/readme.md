# {{repo_name}} ![skeleton](https://img.shields.io/badge/{{sref}}-skeleton?label=%F0%9F%92%80%20{{skeleton|urlencode}}&labelColor=black&color=grey&link={{skeleton_url|urlencode}})
#%- if publish_on_pypi %#
[![Package version](https://img.shields.io/pypi/v/{{pypi_project_name}}?label=PyPI)]({{pypi_url}})
[![Supported Python versions](https://img.shields.io/pypi/pyversions/{{pypi_project_name}}.svg?logo=python&label=Python)]({{pypi_url}})
#% endif %#
#%- if tests %#
[![Tests]({{repo_url}}/actions/workflows/test.yml/badge.svg)]({{repo_url}}/actions/workflows/test.yml)
#%- endif %#
#%- if public %#
[![Coverage](https://coverage-badge.samuelcolvin.workers.dev/{{github_username}}/{{repo_name}}.svg)]({{coverage_url}})
#%- endif %#
[![Poetry](https://img.shields.io/endpoint?url=https://python-poetry.org/badge/v0.json)](https://python-poetry.org/)
[![Ruff](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/ruff/main/assets/badge/v2.json)](https://github.com/astral-sh/ruff)
[![Code style](https://img.shields.io/badge/code%20style-black-000000.svg?label=Code%20style)](https://github.com/psf/black)
#%- if public %#
[![License](https://img.shields.io/github/license/{{github_username}}/{{repo_name}}.svg?label=License)]({{repo_url}}/blob/HEAD/LICENSE)
#%- endif %#
#%- if use_precommit %#
[![Pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
#%- endif %#
#% if project_description %#
{{project_description}}
#% endif %#
#%- if publish_on_pypi %#
# Installation
#% else %#
# Installation for contributors
#%- endif %#

#% if publish_on_pypi %#
#%- if is_cli_tool %#
To use this globally as a CLI tool, simply install it with [pipx](https://github.com/pypa/pipx)

```shell
pipx install {{pypi_project_name}}
```

You might also simply install it with pip:

```shell
pip install {{pypi_project_name}}
```

#%- else %#
You might simply install it with pip:

```shell
pip install {{pypi_project_name}}
```

#%- endif %#

If you use [Poetry](https://python-poetry.org/), then run:

```shell
poetry add {{pypi_project_name}}
```

## For contributors
#% endif %#
#% include "fragments/guide.md" %#

#%- if public %#
For more information on how to contribute, check out [CONTRIBUTING.md]({{repo_url}}/blob/HEAD/CONTRIBUTING.md).<br/>
Always happy to accept contributions! ❤️
#% endif %#

# Legal info
© Copyright by {{org_full_name}} ([@{{author_username}}](https://github.com/{{author_username}})).
#%- if license_name != "Custom" %#
<br />This software is licensed under the terms of [{{license_name}} License]({{repo_url}}/blob/HEAD/LICENSE).
#%- elif private %#
<br />This software is closed-source. You are not allowed to share any of its contents to anyone under any circumstances.
#% endif %#
