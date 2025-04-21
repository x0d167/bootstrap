#!/bin/bash
set -euo pipefail

# =============================
# 📦 dev-base.sh
# Core tools + build essentials
# =============================

echo "🧱 Installing core utilities and build tools..."

# 🔌 Enable Yazi COPR before package install
echo "🔌 Enabling COPR repo for yazi..."
sudo dnf copr enable -y lihaohong/yazi

PACKAGES=(
  git curl wget gnupg unzip gzip tar rsync
  make cmake gcc gcc-c++ clang lldb
  btop jq fzf bat fd-find ripgrep
  neovim nano vim
  python3 python3-pip
  p7zip fastfetch ufw fuse3
  trash-cli multitail
  stow
  yazi
)

FAILED=()
SUCCEEDED=()

for pkg in "${PACKAGES[@]}"; do
  echo "🔧 Installing $pkg..."
  if sudo dnf install -y "$pkg"; then
    SUCCEEDED+=("$pkg")
  else
    echo "❌ Failed to install: $pkg"
    FAILED+=("$pkg")
  fi
done

echo "✅ Installation complete!"
echo "----------------------------"

if [ ${#FAILED[@]} -eq 0 ]; then
  echo "🎉 All packages installed successfully."
else
  echo "⚠️ Some packages failed to install and may need to be installed manually:"
  for pkg in "${FAILED[@]}"; do
    echo " - $pkg"
  done
fi
