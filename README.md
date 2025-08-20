# TwintailLauncher Debian Repository

This repository provides an APT repository for TwintailLauncher, automatically updated when new releases are available.

## Installation

### Add the repository

```bash
# Add the GPG key
curl -fsSL https://twintail-debian.github.io/twintaillauncher-debian-repo/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/twintaillauncher.gpg

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/twintaillauncher.gpg] https://twintail-debian.github.io/twintaillauncher-debian-repo stable main" | sudo tee /etc/apt/sources.list.d/twintaillauncher.list

# Update package list
sudo apt update
```

### Install TwintailLauncher

```bash
sudo apt install twintaillauncher
```

### Update TwintailLauncher

```bash
sudo apt update && sudo apt upgrade twintaillauncher
```

## Repository Information

- **Repository URL**: https://twintail-debian.github.io/twintaillauncher-debian-repo
- **Distribution**: stable
- **Component**: main
- **Architecture**: amd64
- **Automatic Updates**: Yes, checks for new releases every 6 hours

## Source

This repository automatically tracks releases from: https://github.com/TwintailTeam/TwintailLauncher


