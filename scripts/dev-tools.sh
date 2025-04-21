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
  python-lsp-server
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
  hx
  eza
  tealdeer
  rioterm
  typos-cli
  cargo-expand
  cargo-edit
  cargo-watch
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

# Special-case install: markdown-oxide
if ! command -v markdown-oxide &>/dev/null; then
  echo "📦 Installing markdown-oxide from GitHub..."
  cargo install --locked --git https://github.com/Feel-ix-343/markdown-oxide.git markdown-oxide
else
  echo "✅ markdown-oxide already installed"
fi

# ==========================
# 📝 GUI Code Editors
# ==========================

if ! command -v zed &>/dev/null; then
  echo "📝 Installing Zed editor..."
  curl -f https://zed.dev/install.sh | sh
else
  echo "✅ Zed already installed"
fi
