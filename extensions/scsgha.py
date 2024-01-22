from __future__ import annotations

import re
from subprocess import check_output
from typing import Any

from copier_templates_extensions import ContextHook
from jinja2.environment import Environment, Context
from jinja2.ext import Extension
from jinja2.utils import pass_context
from yaml import safe_load  # type: ignore[import-untyped]


# Gonna fix this when I rewrite the Cleo command-line argument parser...
POETRY_VERSION_DEFAULT = "1.7.1"  # Last known version of Poetry while writing this
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
def use_actions(ctx: Context, action_string: str) -> None:
    actions = ActionsDict()
    steps = safe_load(action_string)
    for step in steps:
        if "uses" in step:
            action = step["uses"]
            actions[get_action_key(action)] = action
    ctx.vars["actions"] = actions
    ctx.exported_vars.add("actions")


class SCSGHAExtension(Extension):  # Pronounced as scassgah ex*cough*sion
    def __init__(self, environment: Environment) -> None:
        super().__init__(environment)
        environment.filters["use_actions"] = use_actions


class PoetryVersionContextHook(ContextHook):
    def hook(self, context: dict[str, Any]) -> dict[str, Any]:
        context["poetry_version"] = POETRY_VERSION
        return context
