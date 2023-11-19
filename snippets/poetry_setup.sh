echo "Running poetry installation routine..."
poetry install
if [ $? -eq 0 ]; then
    echo "Successfully installed dependencies."
else
    echo "Failed to install dependencies."
    exit 1
fi
PYTHON_VERSION="$(cat .python-version)"
echo "Using Python version $PYTHON_VERSION"
poetry env use $PYTHON_VERSION
echo "Updating poetry lock..."
poetry run poe lock