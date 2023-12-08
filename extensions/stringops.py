from jinja2.environment import Environment
from jinja2.ext import Extension


def kebabify(value: str) -> str:
    return value.lower().replace("_", "-")


def line_prefix(value: str, prefix: str, *, prepend: bool = False) -> str:
    return (prefix if prepend else "") + value.replace("\n", "\n" + prefix)


class StringOpsExtension(Extension):
    def __init__(self, environment: Environment) -> None:
        super().__init__(environment)
        environment.filters["kebabify"] = kebabify
        environment.filters["line_prefix"] = line_prefix
