import urllib.request
import json
import pprint
import sys
from datetime import datetime
from pathlib import Path


def generate_license_file() -> None:
    license_name = "{{cookiecutter.license_name}}"
    if license_name == "None":
        return

    license_text: str | None
    try:
        license_response = json.loads(
            urllib.request.urlopen(
                f"https://api.github.com/licenses/{license_name}"
            ).read(),
        )
    except urllib.error.HTTPError as exc:
        print(f"Error finding license {license_name}: {exc}", file=sys.stderr)
        license_text = None
    else:
        try:
            license_text = license_response["body"]
        except KeyError:
            print(f"Incorrect license output for {license_name}", file=sys.stderr)
            pprint.pprint(license_response, stream=sys.stderr)
            license_text = None

    if license_text:
        final_license_text = license_text.replace(
            "[year]",
            f"{datetime.now().year}–present",
        ).replace(
            "[fullname]",
            "{{cookiecutter.full_name}} ({{cookiecutter.github_username}})",
        )
        Path("LICENSE").write_text(final_license_text)


if __name__ == "__main__":
    generate_license_file()
