from __future__ import annotations

from jinja2.environment import Environment
from jinja2.ext import Extension


def kebabify(value: str) -> str:
    return value.lower().replace("_", "-")


class StringOpsExtension(Extension):
    def __init__(self, environment: Environment) -> None:
        super().__init__(environment)
        environment.filters.update(
            kebabify=kebabify,
        )
