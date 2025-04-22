#!/bin/bash
set -euo pipefail

# =============================
# 🛠 bootstrap.sh
# Runs all setup scripts and logs output
# =============================

START_TIME=$(date +%s)
LOG_DIR="logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/bootstrap-$(date +%Y%m%d-%H%M%S).log"
exec &> >(tee -a "$LOG_FILE")

echo "📋 Logging bootstrap output to: $LOG_FILE"
echo "🕒 Started at: $(date)"

# === Get script directory ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================
# 🔐 Sudo Keepalive
# =============================
echo "🔐 Requesting sudo password..."
sudo -v

(while true; do
  sudo -n true
  sleep 60
done) 2>/dev/null &
SUDO_PID=$!

# === Cleanup + Runtime on exit ===
cleanup() {
  kill "$SUDO_PID"
  END_TIME=$(date +%s)
  DURATION=$((END_TIME - START_TIME))
  echo ""
  echo "⏱️ Total runtime: $((DURATION / 60)) min $((DURATION % 60)) sec"
}
trap cleanup EXIT

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

FAILED_SCRIPTS=()

for script in "${SCRIPTS[@]}"; do
  SCRIPT_PATH="$SCRIPT_DIR/scripts/$script"
  if [ -f "$SCRIPT_PATH" ]; then
    echo ""
    echo "========================================"
    echo "🔧 Running $script..."
    echo "========================================"
    if ! bash "$SCRIPT_PATH"; then
      echo "❌ Script failed: $script"
      FAILED_SCRIPTS+=("$script")
    fi
  else
    echo "❌ Missing script: $script"
    FAILED_SCRIPTS+=("$script")
  fi
done

echo ""
echo "========================================"
if [ ${#FAILED_SCRIPTS[@]} -eq 0 ]; then
  echo "✅ Bootstrap complete with no script failures!"
else
  echo "⚠️ Bootstrap completed with failures:"
  for failed in "${FAILED_SCRIPTS[@]}"; do
    echo " - $failed"
  done
  echo "📝 Check the log file for details: $LOG_FILE"
fi

echo "✅ Bootstrap complete! Enjoy your polished setup."

# === Audit summary if enabled ===
if [[ "${AUDIT_MODE:-false}" == true ]]; then
  echo ""
  echo "📋 Running post-bootstrap log summary..."
  "$SCRIPT_DIR/log-summary.sh"
fi
