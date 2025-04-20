#!/bin/bash
set -euo pipefail

# =============================
# 🔐 Sudo Keepalive
# =============================

echo "🔐 Requesting sudo password..."
sudo -v

# Keep sudo alive until the script ends
(while true; do
  sudo -n true
  sleep 60
done) 2>/dev/null &
SUDO_PID=$!

# Kill the background process on exit
trap 'kill "$SUDO_PID"' EXIT

echo "🌱 Starting system bootstrap..."

SCRIPTS=(
  system-prep.sh
  dev-base.sh
  dev-tools.sh
  shell-tools.sh
  vpn.sh
  fonts.sh
  tuxedo-setup.sh
  1password.sh
  security.sh
  multimedia.sh
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
