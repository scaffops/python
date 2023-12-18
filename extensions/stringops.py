from jinja2.environment import Environment
from jinja2.ext import Extension


def kebabify(value: str) -> str:
    return value.lower().replace("_", "-")


def indent(value: str, prefix: str, *, with_first: bool = False) -> str:
    return (prefix if with_first else "") + value.replace("\n", "\n" + prefix)


class StringOpsExtension(Extension):
    def __init__(self, environment: Environment) -> None:
        super().__init__(environment)
        environment.filters["kebabify"] = kebabify
        environment.filters["indent"] = indent
