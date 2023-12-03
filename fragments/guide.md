#% if doc_mode %#
!!! Note
    If you use Windows, it is highly recommended to complete the installation in the way presented below through [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install).
#% else %#
> [!Note]
> If you use Windows, it is highly recommended to complete the installation in the way presented below through [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install).
#% endif %#

#% if public %#
1.  Fork the [{{repo_name}} repository]({{repo_url}}) on GitHub.
#%- endif %#

1.  [Install Poetry](https://python-poetry.org/docs/#installation).<br/>
    Poetry is an amazing tool for managing dependencies & virtual environments, building packages and publishing them.
    You might use [pipx](https://github.com/pypa/pipx#readme) to install it globally (recommended):

    ```shell
    pipx install poetry
    ```

    <sub>If you encounter any problems, refer to [the official documentation](https://python-poetry.org/docs/#installation) for the most up-to-date installation instructions.</sub>

    Be sure to have Python {{python_version}} installed—if you use [pyenv](https://github.com/pyenv/pyenv#readme), simply run:

    ```shell
    pyenv install {{python_version}}
    ```
#% if public %#
1.  Clone your fork locally and install dependencies.

    ```shell
    git clone https://github.com/your-username/{{repo_name}} path/to/{{repo_name}}
#%- else %#
1.  Make sure you have the contributor access.

1.  Clone this repository locally and install dependencies.

    ```shell
    git clone {{repo_url}} path/to/{{repo_name}}
#%- endif %#
    cd path/to/{{repo_name}}
    poetry env use $(cat .python-version)
    ```

    Now, if you use pipx and are greedy for disk space:
    ```shell
    poetry install --without=dev && pipx install $(poetry export --only=dev)
    ```

    Otherwise:
    ```shell
    poetry install
    ```

    ```shell
    poetry install
    poetry shell
    pre-commit install --hook-type pre-commit --hook-type pre-push
    ```
#% if development_guide %#

1.  Create a branch for local development:

    ```shell
    git checkout -b name-of-your-bugfix-or-feature
    ```

    Now you can make your changes locally.

1.  When you're done making changes, check that your changes pass all tests:

    ```shell
    poe check
    ```

1.  Commit your changes and push your branch to GitHub:

    ```shell
    git add .
    git commit -m "Short description of changes (50 chars max)" -m "Optional extended description"
    git push origin name-of-your-bugfix-or-feature
    ```

1.  Submit a pull request through the GitHub website.
#%- endif -%#