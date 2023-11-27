from jinja2.environment import Environment
from jinja2.ext import Extension


def kebabify(value: str) -> str:
    return value.lower().replace('_', '-')


class KebabifyExtension(Extension):
    def __init__(self, environment: Environment) -> None:
        super().__init__(environment)
        environment.filters["kebabify"] = self.kebabify
