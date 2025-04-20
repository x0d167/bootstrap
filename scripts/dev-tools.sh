#!/bin/bash

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
  pylsp
  pytest
  pyright
  debugpy
)

echo "🐍 Installing Python tools with uv..."
for tool in "${UV_TOOLS[@]}"; do
  uv tool install "$tool"
done

# CARGO TOOLS
CARGO_TOOLS=(
  yazi
  ya
  hx
  markdown-oxide
  alacritty
  eza
  tealdeer
)

echo "🦀 Installing CLI tools with cargo..."
for tool in "${CARGO_TOOLS[@]}"; do
  if cargo install --list | grep -q "^$tool v"; then
    echo "✅ $tool already installed"
  else
    echo "📦 Installing $tool..."
    cargo install "$tool"
  fi
  echo ""
done

# ==========================
# 📝 GUI Code Editors
# ==========================

if ! command -v zed &>/dev/null; then
  echo "📝 Installing Zed editor..."
  curl -f https://zed.dev/install.sh | sh
else
  echo "✅ Zed already installed"
fi
