from __future__ import annotations
from types import SimpleNamespace

# from jinja2.environment import Environment
# from jinja2.ext import Extension
from copier_templates_extensions import ContextHook


class CommandsContextHook(ContextHook):
    update = False

    def hook(self, context: dict[str, object]) -> None:  # type: ignore[override]
        context["gh"] = SimpleNamespace(
            repo_args=(
                '"{github_username}/{repo_name}" '
                "--{visibility} --source=./ --remote=upstream"
                ' --description="{project_description}"'.format(**context)
            ),
            ensure_env=(
                """$(jq -n '{{"deployment_branch_policy": {{"protected_branches": false,"""
                """"custom_branch_policies": true}}}}' | gh api -H "Accept: application"""
                """/vnd.github+json" -X PUT "/repos/{github_username}/{repo_name}/"""
                """environments/$1" --input -)""".format(**context)
            ),
        )
