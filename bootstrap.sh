#!/bin/bash
set -euo pipefail

# Usage: AUDIT_MODE=true ./bootstrap.sh

# Auto-log all output (stdout + stderr)
LOG_DIR="logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/bootstrap-$(date +%Y%m%d-%H%M%S).log"
exec &> >(tee -a "$LOG_FILE")

echo "📋 Logging bootstrap output to: $LOG_FILE"

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
  multimedia.sh
  dev-base.sh
  fonts.sh
  dev-tools.sh
  shell-tools.sh
  vpn.sh
  kitty.sh
  zen.sh
  tuxedo-setup.sh
  1password.sh
  security.sh
  dotfiles.sh
  final-touches.sh
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

# Optional: Run audit summary
if [[ "${AUDIT_MODE:-false}" == true ]]; then
  echo "📋 Running post-bootstrap log summary..."
  ./log-summary.sh
fi
