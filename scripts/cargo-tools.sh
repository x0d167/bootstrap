#!/bin/bash
set -euo pipefail

echo "🦀 Installing tools via Cargo..."

# Ensure cargo is available
if ! command -v cargo &>/dev/null; then
  echo "❌ Cargo not found. Please run scripts/rust.sh first."
  exit 1
fi

tools=(
  yazi
  ya
  hx # Helix editor
  markdown-oxide
  alacritty
  eza
)

for tool in "${tools[@]}"; do
  if cargo install --list | grep -q "^$tool v"; then
    echo "✅ $tool already installed"
  else
    echo "📦 Installing $tool..."
    cargo install "$tool"
  fi
done
