#!/bin/bash
set -euo pipefail

# =============================
# 🦀 cargo-tools.sh
# Installs Rust-based CLI tools using binstall if available
# =============================

echo "🚀 Installing Rust-based CLI tools..."

# Ensure ~/.cargo/bin is in PATH for this session
export PATH="$HOME/.cargo/bin:$PATH"

# Ensure cargo-binstall is available
if ! command -v cargo-binstall &>/dev/null; then
  echo "📦 Installing cargo-binstall..."
  cargo install cargo-binstall
fi

CARGO_TOOLS=(
  hx
  eza
  tealdeer
  rioterm
  typos-cli
  cargo-expand
  cargo-edit
  cargo-watch
)

for tool in "${CARGO_TOOLS[@]}"; do
  echo "🦀 Installing $tool..."
  if cargo binstall -y "$tool"; then
    echo "✅ $tool installed via binstall"
  elif cargo install "$tool"; then
    echo "✅ $tool installed via cargo"
  else
    echo "❌ Failed to install $tool"
  fi
  echo ""
done

# Special-case install: markdown-oxide
if ! command -v markdown-oxide &>/dev/null; then
  echo "📦 Installing markdown-oxide from GitHub..."
  cargo install --locked --git https://github.com/Feel-ix-343/markdown-oxide.git markdown-oxide
else
  echo "✅ markdown-oxide already installed"
fi
