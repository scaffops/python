echo "Running copier hook..."
python copier_hook.py
echo "Copier hook exited with code $?."
echo "Removing copier hook..."
rm copier_hook.py || echo "Failed to remove copier hook." && exit 1
