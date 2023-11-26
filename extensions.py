from string import Template

from jinja2 import Environment
from jinja2.ext import Extension

COVERAGE_URL: Template = Template(
    "https://coverage-badge.samuelcolvin.workers.dev/"
    "redirect/${github_username}/${repo_name}",
)

REPO_URL: Template = Template(
    "https://github.com/${github_username}/${repo_name}",
)


class URLTemplateExtension(Extension):
    def __init__(self, environment: Environment) -> None:
        super().__init__(environment)
        environment_globals = environment.globals

        if not {"github_username", "repo_name"} - environment_globals.keys():
            environment_globals["repo_url"] = REPO_URL.substitute(environment.globals)

        if "coverage_url" in environment_globals:
            environment_globals["github_username"] = COVERAGE_URL.substitute(
                environment.globals
            )
