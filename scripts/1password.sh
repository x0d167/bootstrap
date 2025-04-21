#!/bin/bash
set -euo pipefail

# =============================
# 🔐 1password.sh
# Sets up the 1Password app and CLI on Fedora
# =============================

echo "🔐 Setting up 1Password for Fedora..."

# Check for curl (used for repo validation)
if ! command -v curl &>/dev/null; then
  echo "❌ 'curl' is not installed. Please run dev-base.sh first."
  exit 1
fi

# Import GPG key if needed
echo "🔑 Importing GPG key..."
if rpm -q gpg-pubkey --qf '%{summary}\n' | grep -qi 1password; then
  echo "✅ GPG key already imported."
else
  sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
fi

# Write the yum repo if not already present
REPO_FILE="/etc/yum.repos.d/1password.repo"
if [ ! -f "$REPO_FILE" ]; then
  echo "📝 Creating 1Password yum repo..."
  sudo tee "$REPO_FILE" >/dev/null <<EOF
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
EOF
else
  echo "✅ 1Password repo already exists."
fi

# Refresh repo metadata (avoids curl errors)
echo "🔄 Refreshing DNF metadata..."
sudo dnf clean all
sudo dnf makecache

# Install 1Password desktop + CLI
echo "📦 Installing 1Password desktop + CLI..."
for pkg in 1password 1password-cli; do
  if rpm -q "$pkg" &>/dev/null; then
    echo "✅ $pkg already installed."
  else
    sudo dnf install -y "$pkg"
  fi
done

echo "🎉 1Password (desktop + CLI) setup complete!"
