#!/bin/bash
set -euo pipefail

# =============================
# 🛠 bootstrap.sh
# Runs all setup scripts and logs output
# =============================

# === Logging setup ===
START_TIME=$(date +%s)
LOG_DIR="logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/bootstrap-$(date +%Y%m%d-%H%M%S).log"
exec &> >(tee -a "$LOG_FILE")

echo "📋 Logging bootstrap output to: $LOG_FILE"

# === Get script directory (so we can run from anywhere) ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================
# 🔐 Sudo Keepalive
# =============================
echo "🔐 Requesting sudo password..."
sudo -v

# Keep sudo alive
(while true; do
  sudo -n true
  sleep 60
done) 2>/dev/null &
SUDO_PID=$!
trap 'kill "$SUDO_PID"' EXIT

echo "🌱 Starting system bootstrap..."

SCRIPTS=(
  system-prep.sh
  multimedia.sh
  dev-base.sh
  dev-tools.sh
  cargo-tools.sh
  shell-tools.sh
  vpn.sh
  fonts.sh
  kitty.sh
  zen.sh
  tuxedo-setup.sh
  1password.sh
  security.sh
  dotfiles.sh
)

for script in "${SCRIPTS[@]}"; do
  SCRIPT_PATH="$SCRIPT_DIR/scripts/$script"
  if [ -f "$SCRIPT_PATH" ]; then
    echo ""
    echo "========================================"
    echo "🔧 Running $script..."
    echo "========================================"
    (
      bash "$SCRIPT_PATH"
    )
  else
    echo "❌ Missing script: $script"
    exit 1
  fi
done

echo ""
echo "✅ Bootstrap complete! Enjoy your polished setup."

# === Audit mode summary (optional) ===
if [[ "${AUDIT_MODE:-false}" == true ]]; then
  echo ""
  echo "📋 Running post-bootstrap log summary..."
  "$SCRIPT_DIR/log-summary.sh"
fi

# === Runtime summary ===
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
echo ""
echo "⏱️ Total runtime: $((DURATION / 60)) min $((DURATION % 60)) sec"
