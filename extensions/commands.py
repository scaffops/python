from __future__ import annotations

from typing import TYPE_CHECKING

from copier_templates_extensions import ContextHook

if TYPE_CHECKING:
    from extensions.mkcontext import MkContextDict


class CommandsContextHook(ContextHook):
    update = False

    def hook(self, context: dict[str, object]) -> None:  # type: ignore[override]
        bash: MkContextDict = context["mkcontext"]  # type: ignore[assignment]
        context[bash["gh_repo_args"]] = (
            '"{github}/{repo}" '
            "--{visibility} --source=./ --remote=upstream"
            ' --description="{description}"'
        ).format(**context)
        context[bash["gh_ensure_env"]] = (
            """jq -n '{{"deployment_branch_policy": {{"protected_branches": false,"""
            """"custom_branch_policies": true}}}}' | gh api -H "Accept: application"""
            """/vnd.github+json" -X PUT "/repos/{github}/{repo}/"""
            """environments/$1" --input -"""
        ).format(**context)
