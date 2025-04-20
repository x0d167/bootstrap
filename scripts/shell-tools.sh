#!/bin/bash

# ==========================
# 🎀 shell-tools.sh
# zoxide and oh-my-posh
# ==========================

# ZOXIDE
if ! command -v zoxide &>/dev/null; then
  echo "📦 Installing zoxide..."
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
else
  echo "✅ zoxide already installed"
fi

# OH-MY-POSH
if ! command -v oh-my-posh &>/dev/null; then
  echo "🎀 Installing oh-my-posh..."
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
else
  echo "✅ oh-my-posh already installed"
fi
