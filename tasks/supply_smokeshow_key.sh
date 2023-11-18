echo "Checking if smokeshow secret needs to be created..."
if test "$(gh secret list -e Smokeshow | grep -o SMOKESHOW_AUTH_KEY)"; then
  echo "Smokeshow secret already exists, aborting."
  exit 0
fi
echo "Smokeshow secret does not exist, creating..."
SMOKESHOW_AUTH_KEY=$(smokeshow generate-key | grep SMOKESHOW_AUTH_KEY | grep -oP "='\K[^']+")
gh secret set SMOKESHOW_AUTH_KEY --env Smokeshow --body "$SMOKESHOW_AUTH_KEY"
[$? -eq 0] && echo "Smokeshow secret created." || echo "Failed to create smokeshow secret."