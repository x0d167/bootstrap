#!/bin/bash
set -euo pipefail

echo "🌱 Starting system bootstrap..."

SCRIPTS=(
  dev-base.sh
  dev-tools.sh
  shell-tools.sh
  vpn.sh
  fonts.sh
)

for script in "${SCRIPTS[@]}"; do
  if [ -f "scripts/$script" ]; then
    echo "🔧 Running $script..."
    bash "scripts/$script"
  else
    echo "❌ Missing script: $script"
    exit 1
  fi
done

echo "✅ Bootstrap complete! Enjoy your polished setup."
