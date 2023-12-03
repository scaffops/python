# Contributing to [{{repo_name}}]({{repo_url}}) 🎉
Contributions are very welcome. 🚀

There are many ways to contribute, ranging from **writing tutorials and improving the documentation**, to **submitting bug reports and feature requests** or **writing code** which can be incorporated into {{repo_name}}.

## Report bugs and request features 🐛
Report these in the [issue tracker]({{repo_url}}/issues).
Relevant forms provide guidance on how to write a good bug report or feature request.

## Implement new features ⭐
[Look here]({{repo_url}}/issues?q=is%3Aopen+label%3Aenhancement+sort%3Aupdated-desc).
Anything tagged with "enhancement" is open to whoever wants to implement it.

## Write documentation 📖
The project could always use more documentation, whether as part of the official project
docs. If you're interested in helping out, check the [docs/]({{repo_url}}/tree/HEAD/docs) folder in the repository.

## Share your feedback 🌍
The best way to send feedback is to file an issue in the [issue tracker]({{repo_url}}).

If you are proposing a feature:

-   Explain in detail how it would work.
-   Keep the scope as narrow as possible, to make it easier to implement.
-   Remember that this is a volunteer-driven project, and that contributions are
    welcome! ✨

## Get started! 🕹️

Ready to contribute? Here's a quick guide on how to set up {{repo_name}} and make a change.

#% with development_guide=True %#
#% include "fragments/guide.md" %#
#% endwith %#

## Pull Request guidelines 📝
1. Initially mark the PR as a draft, so that the maintainers know that you are making final touches.

1. Ensure that the [test coverage]({{coverage_url}}) is not decreased. If you add a new feature, please add tests for it. [Read more about coverage](https://coverage.readthedocs.io/en/latest/index.html).

1. Ensure that all GitHub checks pass. If they are disabled in your PR, ping the maintainers to request enabling them.

1. Don't forget to link the relevant issue(s) in the PR description and describe the changes you made.
