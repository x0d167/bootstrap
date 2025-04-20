#!/bin/bash
set -euo pipefail

echo "🦀 Installing Rust toolchain..."

if ! command -v rustc &>/dev/null; then
  echo "📥 Downloading rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  export PATH="$HOME/.cargo/bin:$PATH"
else
  echo "✅ Rust is already installed"
fi

echo "🛠️ Cargo available at: $(command -v cargo)"
