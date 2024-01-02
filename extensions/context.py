from __future__ import annotations
from abc import ABCMeta, abstractmethod
from pathlib import Path
from string import Template
from subprocess import getoutput
from typing import TYPE_CHECKING, Any
from urllib.parse import quote

from jinja2.environment import Environment
from jinja2.ext import Extension
from copier_templates_extensions import ContextHook

if TYPE_CHECKING:
    from collections.abc import Iterable


LATEST_PYTHON_VERSION: tuple[int, int] = (3, 12)
PYTHON_VERSION_AHEAD: tuple[int, int] = (3, LATEST_PYTHON_VERSION[1] + 1)


COVERAGE_URL: Template = Template(
    "https://coverage-badge.samuelcolvin.workers.dev/"
    "redirect/${github_username}/${repo_name}",
)

REPO_URL: Template = Template(
    "https://github.com/${github_username}/${repo_name}",
)

DOCS_URL: Template = Template(
    "https://${docs_slug}.readthedocs.io/en/latest/",
)

PYPI_URL: Template = Template(
    "https://pypi.org/project/${pypi_project_name}/",
)

SKELETON_URL: Template = Template(
    "https://github.com/${skeleton}",
)

SKELETON_REV: Template = Template(
    "https://github.com/${skeleton}/tree/${skeleton_ref}",
)

SKELETON_NOTICE: Template = Template(
    "This ${scope} was generated from ${snref}.\n"
    "Instead of changing this particular file, you might want to alter the template:\n"
    "${srev}/${path}"
)

SKELETON_NOTICE_PATHLESS: Template = Template(
    "This ${scope} was generated from a template file.\n"
    "Instead of changing this particular file, you might want to alter the template "
    "somewhere in:\n"
    "${srev}"
)


def skeleton_notice(
    path: str | None, snref: str, srev: str, scope: str = "file"
) -> str:
    if path is None:
        return SKELETON_NOTICE_PATHLESS.substitute(
            scope=scope,
            srev=srev,
        )
    return SKELETON_NOTICE.substitute(
        scope=scope,
        snref=snref,
        srev=srev,
        path=quote(path),
    )


class InplaceContextHook(ContextHook, metaclass=ABCMeta):
    update = False

    def hook(self, context: dict[str, Any]) -> dict[str, Any]:
        return self._hook(context) or context

    @abstractmethod
    def _hook(self, context: dict[str, Any]) -> None:
        ...


class SkeletonContextHook(InplaceContextHook):
    def _hook(self, context: dict[str, Any]) -> None:
        context["skeleton"] = context["_src_path"].lstrip("gh:")
        context["skeleton_url"] = SKELETON_URL.substitute(context)
        context["skeleton_ref"] = context["sref"] = context["_copier_answers"][
            "_commit"
        ]
        context["skeleton_rev"] = context["srev"] = SKELETON_REV.substitute(context)
        context["skeleton_and_ref"] = context["snref"] = "@".join(
            (context["skeleton"], context["skeleton_ref"])
        )


class SkeletonExtension(Extension):
    def __init__(self, environment: Environment) -> None:
        super().__init__(environment)
        # Usage: {{path...|skeleton_notice(snref=snref, srev=srev)}}
        environment.filters["skeleton_notice"] = skeleton_notice


class ProjectURLContextHook(InplaceContextHook):
    def _hook(self, context: dict[str, Any]) -> None:
        context["repo_url"] = REPO_URL.substitute(context)
        context["coverage_url"] = COVERAGE_URL.substitute(context)
        context["docs_url"] = DOCS_URL.substitute(context)
        context["pypi_url"] = PYPI_URL.substitute(context)


def _generate_python_versions(python_version_string: str) -> Iterable[tuple[int, int]]:
    (major, minor) = tuple(map(int, python_version_string.split(".")))
    yield (major, minor)
    while (major, minor) < LATEST_PYTHON_VERSION:
        minor += 1
        yield (major, minor)


class PythonVersionsContextHook(InplaceContextHook):
    def _hook(self, context: dict[str, Any]) -> None:
        context["latest_python_version"] = ".".join(map(str, LATEST_PYTHON_VERSION))
        context["python_version_ahead"] = ".".join(map(str, PYTHON_VERSION_AHEAD))
        context["python_versions"] = ", ".join(
            f"{major}.{minor}".join('""')
            for major, minor in _generate_python_versions(context["python_version"])
        )


class VisibilityContextHook(InplaceContextHook):
    def _hook(self, context: dict[str, Any]) -> None:
        context["public"] = context["visibility"] == "public"
        context["private"] = not context["public"]


class TemplateContextHook(InplaceContextHook):
    def preprocess(
        self,
        source: str,
        name: str | None,
        filename: str | None = None,
    ) -> str:
        self.filename = filename and Path(*Path(filename).parts[3:]).as_posix()
        return source

    def _hook(self, context: dict[str, Any]) -> None:
        context["_origin"] = self.filename


class GitContextHook(InplaceContextHook):
    def _hook(self, context: dict[str, Any]) -> None:
        context["git_username"] = getoutput("git config user.name")
        context["git_email"] = getoutput("git config user.email")
