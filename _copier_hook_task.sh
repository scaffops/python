echo Running copier hook...
poetry run python copier_hook.py
echo Copier hook exited with code $?.
echo Removing copier hook...
poetry run rm copier_hook.py
ls
if [ $? -eq 0 ]; then
    echo Copier hook removed.
else
    echo Failed to remove copier hook.
    exit 1
fi