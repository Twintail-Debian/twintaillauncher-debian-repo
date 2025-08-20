# APT Repository Setup Guide

This guide will help you set up the TwintailLauncher APT repository with automatic updates.

## Prerequisites

- A GitHub account (https://github.com/Twintail-Debian)
- Git installed on your local machine
- GPG installed for package signing
- `jq` and `curl` for API interactions

## Initial Setup

### 1. Clone and Initialize Repository

```bash
git clone https://github.com/Twintail-Debian/twintaillauncher-debian-repo.git
cd twintaillauncher-debian-repo
```

### 2. Install Required Dependencies

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y dpkg-dev apt-utils gnupg2 curl jq
```

**macOS:**
```bash
brew install dpkg gnupg curl jq
```

### 3. Initialize the Repository

Run the initialization script:
```bash
./scripts/init-repo.sh
```

This script will:
- Create the necessary directory structure
- Generate a GPG key for signing packages
- Download the latest TwintailLauncher release
- Generate repository metadata
- Sign the Release file

### 4. Configure GitHub Repository

1. **Push the initial repository:**
   ```bash
   git add .
   git commit -m "Initial APT repository setup"
   git push origin main
   ```

2. **Enable GitHub Pages:**
   - Go to your repository settings on GitHub
   - Navigate to "Pages" in the left sidebar
   - Under "Source", select "GitHub Actions"
   - The repository will be available at: `https://twintail-debian.github.io/twintaillauncher-debian-repo`

3. **Set up GitHub Secrets:**
   
   You need to add these secrets in your GitHub repository settings (Settings → Secrets and variables → Actions):

   **GPG_PRIVATE_KEY:**
   ```bash
   gpg --armor --export-secret-keys > private-key.asc
   # Copy the contents of private-key.asc to this secret
   ```

   **GPG_PASSPHRASE:**
   - If you set a passphrase when creating the GPG key, add it here
   - If you didn't set a passphrase, leave this secret empty

### 5. Test the Automatic Updates

The GitHub Action will:
- Run every 6 hours to check for new releases
- Can be manually triggered from the Actions tab
- Automatically update the repository when new versions are found

To manually trigger an update:
1. Go to the "Actions" tab in your GitHub repository
2. Select "Update APT Repository"
3. Click "Run workflow"

## Manual Updates

You can also manually update the repository:

```bash
./scripts/update-repo.sh
git add .
git commit -m "Update TwintailLauncher to [version]"
git push
```

## Repository Structure

```
twintaillauncher-debian-repo/
├── dists/
│   └── stable/
│       ├── Release
│       ├── Release.gpg
│       ├── InRelease
│       └── main/
│           └── binary-amd64/
│               ├── Packages
│               └── Packages.gz
├── pool/
│   └── main/
│       └── t/
│           └── twintaillauncher/
│               ├── twintaillauncher_1.0.8_amd64.deb
│               └── current_version.txt
├── KEY.gpg
├── scripts/
│   ├── init-repo.sh
│   └── update-repo.sh
└── .github/
    └── workflows/
        └── update-repo.yml
```

## Troubleshooting

### GPG Issues
If you encounter GPG signing issues:
```bash
# List your GPG keys
gpg --list-secret-keys

# If no keys exist, run the init script again
./scripts/init-repo.sh
```

### GitHub Actions Failing
1. Check that your GitHub secrets are properly set
2. Ensure GitHub Pages is enabled
3. Verify the GPG key format in the secret (should include the full armor)

### Repository Not Updating
1. Check the GitHub Actions logs
2. Verify the TwintailLauncher repository is accessible
3. Ensure the .deb file URL pattern hasn't changed

## Usage by End Users

Once set up, users can install TwintailLauncher with:

```bash
# Add the GPG key
curl -fsSL https://twintail-debian.github.io/twintaillauncher-debian-repo/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/twintaillauncher.gpg

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/twintaillauncher.gpg] https://twintail-debian.github.io/twintaillauncher-debian-repo stable main" | sudo tee /etc/apt/sources.list.d/twintaillauncher.list

# Update and install
sudo apt update
sudo apt install twintaillauncher
```
