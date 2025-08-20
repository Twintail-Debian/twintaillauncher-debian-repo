#!/bin/bash

# Helper script to generate GPG keys and show the values needed for GitHub secrets
# This script helps you set up the GitHub secrets required for automatic updates

set -e

echo "=== GitHub Secrets Setup Helper ==="
echo ""

# Check if GPG key exists
if ! gpg --list-secret-keys | grep -q "TwintailLauncher Repository"; then
    echo "No GPG key found for TwintailLauncher Repository."
    echo "Please run './scripts/init-repo.sh' first to generate the GPG key."
    exit 1
fi

echo "Found GPG key for TwintailLauncher Repository"
echo ""

# Get the key ID
KEY_ID=$(gpg --list-secret-keys --with-colons | grep "TwintailLauncher Repository" -B 5 | grep "^sec" | cut -d: -f5)
echo "GPG Key ID: $KEY_ID"
echo ""

# Export private key
echo "=== GPG_PRIVATE_KEY Secret ==="
echo "Copy the following content (including the BEGIN and END lines) to your GitHub secret 'GPG_PRIVATE_KEY':"
echo ""
echo "----------------------------------------"
gpg --armor --export-secret-keys $KEY_ID
echo "----------------------------------------"
echo ""

# Check for passphrase
echo "=== GPG_PASSPHRASE Secret ==="
echo "If you set a passphrase when creating the GPG key, add it as the 'GPG_PASSPHRASE' secret."
echo "If you didn't set a passphrase, you can leave this secret empty or set it to an empty string."
echo ""

echo "=== Next Steps ==="
echo "1. Go to your GitHub repository: https://github.com/Twintail-Debian/twintaillauncher-debian-repo"
echo "2. Navigate to Settings → Secrets and variables → Actions"
echo "3. Add the following secrets:"
echo "   - GPG_PRIVATE_KEY: (the content shown above)"
echo "   - GPG_PASSPHRASE: (your GPG passphrase, if any)"
echo "4. Enable GitHub Pages in Settings → Pages → Source: GitHub Actions"
echo "5. The first workflow run will be triggered automatically when you push changes"
echo ""
echo "Repository will be available at: https://twintail-debian.github.io/twintaillauncher-debian-repo"
