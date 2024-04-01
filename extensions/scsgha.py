from __future__ import annotations

from itertools import chain
import re
from subprocess import check_output
from typing import Any

import tomli  # type: ignore[import-untyped]
import yaml  # type: ignore[import-untyped]
from copier_templates_extensions import ContextHook
from jinja2.environment import Environment, Context
from jinja2.ext import Extension
from jinja2.utils import pass_context


# Gonna fix this when I rewrite the Cleo command-line arguments parser...
POETRY_VERSION_DEFAULT = "1.8.2"
POETRY_VERSION_PAT = re.compile(rb"version (^\))")
POETRY_VERSION_MATCH = POETRY_VERSION_PAT.match(check_output(["poetry", "--version"]))
POETRY_VERSION = POETRY_VERSION_MATCH and POETRY_VERSION_MATCH.group(1).decode()
POETRY_VERSION = POETRY_VERSION or POETRY_VERSION_DEFAULT


def get_action_key(action: str) -> str:
    # https://docs.github.com/en/actions/using-workflows/
    #   workflow-syntax-for-github-actions#jobsjob_idstepsuses
    if action.startswith("docker://"):
        return action.rsplit(":", 1)[0]
    return action.partition("@")[0]


class ActionsDict(dict):
    __slots__ = ()  # Prevent from creating __weakref__ and __dict__ slots.

    def __missing__(self, key: str) -> str:
        return key + "@HEAD"


@pass_context
def use_actions(ctx: Context, action_string: str) -> str:
    actions = ActionsDict()
    declared_actions = yaml.safe_load(action_string)
    for declared_action in declared_actions:
        if "uses" in declared_action:
            action = declared_action["uses"]
            actions[get_action_key(action)] = action
    ctx.vars["actions"] = actions
    ctx.exported_vars.add("actions")
    return action_string


@pass_context
def use_dev_dependencies(ctx: Context, deps_string: str) -> str:
    metadata_chunk = tomli.loads(deps_string)
    declared_dev_dependencies = metadata_chunk.get("dev-dependencies") or {}
    if not declared_dev_dependencies:
        try:
            dependency_groups = metadata_chunk["tool"]["poetry"]["group"]
        except KeyError:
            pass
        else:
            declared_dev_dependencies.update(
                {  # fmt: off
                    dep: version
                    for dep, version in chain.from_iterable(
                        map(
                            lambda group: (group.get("dependencies") or {}).items(),
                            dependency_groups.values(),
                        )
                    )
                }
            )  # fmt: on
    dev_dependencies = ctx.vars["dev_dependencies"] = {
        **(ctx.vars.get("dev_dependencies") or {}),
        **declared_dev_dependencies,
    }
    ctx.exported_vars.add("dev_dependencies")
    return str(dev_dependencies)


class SCSGHAExtension(Extension):  # Pronounced as scassgah ex*cough*sion
    def __init__(self, environment: Environment) -> None:
        super().__init__(environment)
        environment.filters["use_actions"] = use_actions
        environment.filters["use_dev_dependencies"] = use_dev_dependencies


class PoetryVersionContextHook(ContextHook):
    def hook(self, context: dict[str, Any]) -> dict[str, Any]:
        bash = context["make_context"]
        context[bash["poetry_version"]] = POETRY_VERSION
        return context
