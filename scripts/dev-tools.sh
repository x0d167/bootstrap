#!/bin/bash
set -euo pipefail

# ==========================
# 🦀🧪 dev-tools.sh
# Installs rust + uv + tools
# ==========================

# RUST
if ! command -v rustc &>/dev/null; then
  echo "🦀 Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  export PATH="$HOME/.cargo/bin:$PATH"
else
  echo "✅ Rust already installed"
fi

# UV
if ! command -v uv &>/dev/null; then
  echo "🐍 Installing uv (Python toolchain manager)..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.cargo/bin:$PATH"
else
  echo "✅ uv already installed"
fi

# UV TOOLS
UV_TOOLS=(
  ruff
  python-lsp-server
  pytest
  pyright
  debugpy
)

echo "🐍 Installing Python tools with uv..."
for tool in "${UV_TOOLS[@]}"; do
  uv tool install "$tool"
done

echo "✅ Python development tools installed!"
