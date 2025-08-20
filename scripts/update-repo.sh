#!/bin/bash

# Update APT Repository with latest TwintailLauncher release
# This script checks for new releases and updates the repository

set -e

echo "Checking for TwintailLauncher updates..."

# Get latest release info
LATEST_RELEASE=$(curl -s https://api.github.com/repos/TwintailTeam/TwintailLauncher/releases/latest)
LATEST_VERSION=$(echo "$LATEST_RELEASE" | jq -r '.tag_name')
DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | jq -r '.assets[] | select(.name | endswith("_amd64.deb")) | .browser_download_url')

echo "Latest version: $LATEST_VERSION"

# Check current version
if [ -f "pool/main/t/twintaillauncher/current_version.txt" ]; then
    CURRENT_VERSION=$(cat pool/main/t/twintaillauncher/current_version.txt)
    echo "Current version: $CURRENT_VERSION"
    
    if [ "$LATEST_VERSION" = "$CURRENT_VERSION" ]; then
        echo "Repository is already up to date!"
        exit 0
    fi
else
    echo "No current version found, this appears to be a fresh repository"
fi

echo "Updating to version: $LATEST_VERSION"

# Create directories if they don't exist
mkdir -p pool/main/t/twintaillauncher
mkdir -p dists/stable/main/binary-amd64

# Download the new package
echo "Downloading package..."
curl -L -o "pool/main/t/twintaillauncher/twintaillauncher_${LATEST_VERSION#ttl-v}_amd64.deb" "$DOWNLOAD_URL"

# Update version tracking
echo "$LATEST_VERSION" > pool/main/t/twintaillauncher/current_version.txt

# Remove old .deb files (keep only the latest)
find pool/main/t/twintaillauncher -name "*.deb" -not -name "*${LATEST_VERSION#ttl-v}*" -delete

# Generate Packages file
echo "Updating repository metadata..."
cd pool/main/t/twintaillauncher
dpkg-scanpackages . /dev/null > ../../../../dists/stable/main/binary-amd64/Packages

# Compress Packages file
cd ../../../../dists/stable/main/binary-amd64
gzip -k Packages

# Create Release file
cd ../../
cat > Release << EOF
Origin: Twintail-Debian TwintailLauncher Repository
Label: TwintailLauncher
Suite: stable
Codename: stable
Version: 1.0
Architectures: amd64
Components: main
Description: APT repository for TwintailLauncher
Date: $(date -Ru)
EOF

# Add checksums to Release file
echo "MD5Sum:" >> Release
find . -name "Packages*" -exec md5sum {} \; | sed 's/\.\///g' | awk '{print " " $1 " " $2}' >> Release

echo "SHA1:" >> Release
find . -name "Packages*" -exec sha1sum {} \; | sed 's/\.\///g' | awk '{print " " $1 " " $2}' >> Release

echo "SHA256:" >> Release
find . -name "Packages*" -exec sha256sum {} \; | sed 's/\.\///g' | awk '{print " " $1 " " $2}' >> Release

# Sign Release file
echo "Signing Release file..."
gpg --armor --detach-sign --sign Release
gpg --clearsign --output InRelease Release

# Export public key
cd ../../
gpg --armor --export > KEY.gpg

echo "Repository updated successfully to version $LATEST_VERSION!"
echo "Don't forget to commit and push the changes."
