#!/bin/bash

# Initialize APT Repository for TwintailLauncher
# This script sets up the initial repository structure and downloads the latest package

set -e

echo "Initializing TwintailLauncher APT Repository..."

# Create necessary directories
mkdir -p dists/stable/main/binary-amd64
mkdir -p pool/main/t/twintaillauncher

# Check if GPG key exists
if ! gpg --list-secret-keys | grep -q "TwintailLauncher Repository"; then
    echo "Generating GPG key for repository signing..."
    cat > /tmp/gpg-gen-key << EOF
%echo Generating a basic OpenPGP key
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: TwintailLauncher Repository
Name-Email: repo@twintail-debian.github.io
Expire-Date: 0
Passphrase: 
%commit
%echo done
EOF
    
    gpg --batch --generate-key /tmp/gpg-gen-key
    rm /tmp/gpg-gen-key
fi

# Get latest release info
echo "Fetching latest TwintailLauncher release..."
LATEST_RELEASE=$(curl -s https://api.github.com/repos/TwintailTeam/TwintailLauncher/releases/latest)
LATEST_VERSION=$(echo "$LATEST_RELEASE" | jq -r '.tag_name')
DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | jq -r '.assets[] | select(.name | endswith("_amd64.deb")) | .browser_download_url')

echo "Latest version: $LATEST_VERSION"
echo "Download URL: $DOWNLOAD_URL"

# Download the package
echo "Downloading package..."
curl -L -o "pool/main/t/twintaillauncher/twintaillauncher_${LATEST_VERSION#ttl-v}_amd64.deb" "$DOWNLOAD_URL"

# Save version info
echo "$LATEST_VERSION" > pool/main/t/twintaillauncher/current_version.txt

# Generate Packages file
echo "Generating repository metadata..."
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

echo "Repository initialization complete!"
echo ""
echo "Next steps:"
echo "1. Commit and push these files to your GitHub repository"
echo "2. Enable GitHub Pages in your repository settings"
echo "3. Set up the following GitHub secrets:"
echo "   - GPG_PRIVATE_KEY: Your GPG private key (gpg --armor --export-secret-keys)"
echo "   - GPG_PASSPHRASE: Your GPG key passphrase (if any)"
echo ""
echo "The repository will be available at: https://twintail-debian.github.io/twintaillauncher-debian-repo"
