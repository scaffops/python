from __future__ import annotations
from string import Template

from copier_templates_extensions import ContextHook

from extensions.kebabify import kebabify


COVERAGE_URL: Template = Template(
    "https://coverage-badge.samuelcolvin.workers.dev/"
    "redirect/${github_username}/${repo_name}",
)

REPO_URL: Template = Template(
    "https://github.com/${github_username}/${repo_name}",
)

DOCS_URL: Template = Template(
    "https://${project_name}.readthedocs.io/en/latest/",
)

PYPI_URL: Template = Template(
    "https://pypi.org/project/${pypi_project_name}/",
)


class ProjectURLContextHook(ContextHook):
    update = False

    def hook(self, context: dict[str, object]) -> None:
        context["repo_url"] = REPO_URL.substitute(context)
        context["coverage_url"] = COVERAGE_URL.substitute(context)
        context["docs_url"] = DOCS_URL.substitute(
            project_name=kebabify(context["repo_name"])
        )
        context["pypi_url"] = PYPI_URL.substitute(context)
