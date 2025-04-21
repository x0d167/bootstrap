#!/bin/bash
set -euo pipefail

# =============================
# 🔐 1password.sh
# Sets up the 1Password app and CLI on Fedora
# =============================

echo "🔐 Setting up 1Password for Fedora..."

# Import the GPG key
echo "🔑 Importing GPG key..."
if rpm -q gpg-pubkey --qf '%{summary}\n' | grep -qi 1password; then
  echo "✅ GPG key already imported."
else
  sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
fi

# Write repo file
echo "📝 Creating 1Password yum repo..."
sudo tee /etc/yum.repos.d/1password.repo >/dev/null <<EOF
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
EOF

# Install the package
echo "📦 Installing 1Password..."
if rpm -q 1password &>/dev/null; then
  echo "✅ 1Password already installed."
else
  sudo dnf install -y 1password
fi

echo "🎉 1Password setup complete!"
