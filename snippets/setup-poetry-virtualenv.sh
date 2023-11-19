echo "Running poetry installation routines..."
poetry lock
poetry install || echo "Failed to install dependencies." && exit 1
PYTHON_VERSION="$(cat .python-version)"
echo "Using Python version $PYTHON_VERSION"
poetry env use $PYTHON_VERSION
echo "Updating poetry lock..."
poetry run poe lock