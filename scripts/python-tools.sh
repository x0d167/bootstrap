#!/bin/bash
set -euo pipefail

echo "🐍 Setting up Python tools with uv..."

# Ensure uv is installed
if ! command -v uv &>/dev/null; then
  echo "📥 Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.cargo/bin:$PATH"
else
  echo "✅ uv already installed"
fi

# Install Python tools via uv
tools=(
  ruff
  pylsp
  pytest
  debugpy
)

for tool in "${tools[@]}"; do
  echo "🧪 Installing Python tool: $tool"
  uv tool install "$tool"
done
