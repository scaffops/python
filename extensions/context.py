from __future__ import annotations
from string import Template
from sys import path
from pathlib import Path
from typing import TYPE_CHECKING

from copier_templates_extensions import ContextHook

path.insert(0, str(Path(__file__).parent.parent))

from extensions.kebabify import kebabify  # noqa: E402

if TYPE_CHECKING:
    from collections.abc import Iterable


LATEST_PYTHON_VERSION: tuple[int, int] = (3, 12)

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


def _generate_python_versions(python_version: str) -> Iterable[tuple[int, int]]:
    python_version = (major, minor) = tuple(map(int, python_version.split(".")))
    yield python_version
    while (major, minor) < LATEST_PYTHON_VERSION:
        minor += 1
        yield (major, minor)


class PythonVersionsContextHook(ContextHook):
    update = False

    def hook(self, context: dict[str, object]) -> None:
        context["python_versions"] = ", ".join(
            f"{major}.{minor}".join('""')
            for major, minor in _generate_python_versions(context["python_version"])
        ).join("[]")


class VisibilityContextHook(ContextHook):
    update = False

    def hook(self, context: dict[str, object]) -> None:
        context["public"] = context["visibility"] == "public"
        context["private"] = not context["public"]
