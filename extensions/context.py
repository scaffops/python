from __future__ import annotations
from string import Template

from copier_templates_extensions import ContextHook

COVERAGE_URL: Template = Template(
    "https://coverage-badge.samuelcolvin.workers.dev/"
    "redirect/${github_username}/${repo_name}",
)

REPO_URL: Template = Template(
    "https://github.com/${github_username}/${repo_name}",
)


class ProjectURLContextHook(ContextHook):
    update = False

    def hook(self, context: dict[str, object]) -> None:
        context["repo_url"] = REPO_URL.substitute(context)
        context["coverage_url"] = COVERAGE_URL.substitute(context)
