#!/bin/bash
set -euo pipefail

# =============================
# 📦 dev-base.sh
# Core tools + build essentials
# =============================

echo "🧱 Installing core utilities and build tools..."

sudo dnf install -y \
  git curl wget gnupg unzip gzip tar rsync \
  make cmake gcc gcc-c++ clang lldb \
  btop jq fzf bat fd-find ripgrep \
  neovim nano vim \
  libfuse \
  python3 python3-pip \
  7zip fastfetch ufw
