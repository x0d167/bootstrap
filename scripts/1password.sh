#!/bin/bash
set -euo pipefail

# =============================
# 🔐 1password.sh
# Add 1Password repo and install
# =============================

echo "🔐 Setting up 1Password..."

# Import the GPG key
echo "📥 Importing GPG key..."
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc

# Create the 1Password YUM repo
echo "📦 Adding 1Password YUM repository..."
sudo bash -c 'cat > /etc/yum.repos.d/1password.repo <<EOF
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
EOF'

# Install the desktop app
echo "💻 Installing 1Password..."
if sudo dnf install -y 1password; then
  echo "✅ 1Password desktop installed."
else
  echo "❌ Failed to install 1Password desktop."
fi

# Try installing the CLI as well, if available via DNF
echo "💡 Checking for 1Password CLI..."
if dnf list --available 1password-cli &>/dev/null; then
  echo "📦 Installing 1Password CLI..."
  if sudo dnf install -y 1password-cli; then
    echo "✅ 1Password CLI installed."
  else
    echo "❌ Failed to install 1Password CLI."
  fi
else
  echo "🚫 1Password CLI not available via dnf repository."
fi

echo "🔐 1Password setup complete."
