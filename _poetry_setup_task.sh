poetry install
if [ $? -eq 0 ]; then
    echo "Successfully installed dependencies."
else
    echo "Failed to install dependencies."
    exit 1
fi
PYTHON_VERSION="$(cat .python-version)"
poetry env use $PYTHON_VERSION
poetry run poe lock
