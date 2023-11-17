#!/usr/bin/env python
# (C) 2023–present Bartosz Sławecki (bswck)
#
# Note:
# If you want to change this file, you might want to do it at the infrastructure
# level. See https://github.com/bswck/skeleton.
"""
Automate the release process by updating local files, creating and pushing a new tag.

The complete the release process, create a GitHub release.
GitHub Actions workflow will publish the package to PyPI via Trusted Publisher.

Usage:
$ poe release [major|minor|patch|<major>.<minor>.<patch>]
"""
from __future__ import annotations

import argparse
import functools
import logging
import os
import pathlib
import subprocess
import sys

_LOGGER = logging.getLogger("release")
_EDITOR = os.environ.get("EDITOR", "vim")


def abort(msg: str, /) -> None:
    """Display an error message and exit the script process with status code -1."""
    _LOGGER.critical(msg)
    sys.exit(-1)


def release(version: str, /) -> None:
    """Release a semver version."""
    cmd, shell = str.split, functools.partial(subprocess.run, check=True)

    changed_files = shell(
        cmd("git diff --name-only HEAD"),
        capture_output=True,
    ).stdout

    if changed_files:
        msg = (
            "There are uncommitted changes in the working tree in these files:\n"
            f"{changed_files}\n"
            "Continue? They will be included in the release commit. (y/n) [n]: "
        )
        continue_confirm = (input(msg).casefold().strip() or "n")[0] == "y"
        if not continue_confirm:
            abort("Uncommitted changes in the working tree.")

    # If we get here, we should be good to go
    # Let's do a final check for safety
    msg = f"You are about to release {version!r} version. Are you sure? (y/n) [y]: "

    do_release = ((input(msg).casefold().strip()) or "y") == "y"

    if do_release:
        abort(f"You said no when prompted to bump the {version!r} version.")

    shell(cmd("poetry self add poetry-bumpversion@latest"))

    _LOGGER.info("Bumping the %r version", version)

    shell([*cmd("poetry version"), version])

    new_version = "v" + (
        shell(cmd("poetry version --short"), capture_output=True)
        .stdout
        .strip()
    )

    changed_for_release = shell(
        cmd("git diff --name-only HEAD"),
        capture_output=True,
    ).stdout

    if changed_for_release:
        shell(cmd("git diff"))
        msg = (
            "You are about to commit and push auto-changed files due "
            "to version upgrade, see the diff view above. "
            "Are you sure? (y/n) [y]: "
        )
        do_commit = ((input(msg).casefold().strip()) or "y")[0] == "y"

        if do_commit:
            shell([*cmd("git commit -am"), f"Release {new_version}"])
            shell(cmd("git push"))
        else:
            abort(
                "Changes made uncommitted. "
                "Commit your unrelated changes and try again.",
            )

    _LOGGER.info("Creating %s tag...", new_version)

    try:
        shell([*cmd("git tag -a"), new_version, "-m", f"Release {new_version}"])
    except subprocess.CalledProcessError:
        abort(f"Failed to create {new_version} tag, probably already exists.")
    else:
        _LOGGER.info("Pushing local tags...")
        shell(cmd("git push --tags"))

    do_release = (
        input("Create a GitHub release now? GitHub CLI required. (y/n) [y]: ").strip()
        or "y"
    ) == "y"

    if do_release:
        do_write_notes = (
            input("Do you want to write release notes? (y/n) [y]").strip()[0] == "y"
        )

        if do_write_notes:
            notes_complete = False
            while not notes_complete:
                tmp_file = pathlib.Path(f".release-notes-{new_version}.txt")
                shell(cmd(f"{_EDITOR} {tmp_file}"))
                release_notes = tmp_file.read_text()
                print("Release notes:")
                print(release_notes)
                print()
                notes_complete = (
                    input(
                        "Do you confirm the release notes? (y/n) [y]",
                    ).strip()[0] == "y"
                )

            shell(
                cmd(
                    f"gh release create {new_version} --generate-notes"
                    f"--notes-file {tmp_file}",
                )
            )
        else:
            shell(cmd(f"gh release create {new_version} --generate-notes"))


def main(argv: list[str] | None = None) -> None:
    """Run the script."""
    _LOGGER.setLevel(logging.INFO)
    (_logger_handler := logging.StreamHandler()).setFormatter(
        logging.Formatter("%(levelname)s: %(message)s"),
    )
    _LOGGER.addHandler(_logger_handler)

    parser = argparse.ArgumentParser(description="Release a semver version.")
    parser.add_argument(
        "version",
        type=str,
        nargs=1,
    )
    args: argparse.Namespace = parser.parse_args(argv)
    release(args.version.pop())


if __name__ == "__main__":
    main()
