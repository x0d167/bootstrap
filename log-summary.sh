#!/bin/bash
set -euo pipefail

# =============================
# 📋 log-summary.sh
# Summarizes the latest logs from the security setup
# =============================

LOG_DIR="logs"

echo "📁 Summarizing logs from: $LOG_DIR"
echo "────────────────────────────────────────────"

# ─────────────────────────────
# 🔥 UFW Status
# ─────────────────────────────
echo -e "\n🔐 UFW Status:"
if sudo ufw status verbose; then
  echo "✅ UFW is active and configured."
else
  echo "❌ UFW not active or misconfigured!"
fi

# ─────────────────────────────
# 🛡️ Fail2Ban
# ─────────────────────────────
echo -e "\n🛡️ Fail2Ban Status:"
sudo systemctl status fail2ban --no-pager | grep -E "Active|Loaded"

# ─────────────────────────────
# 🦠 RKHunter Summary
# ─────────────────────────────
RKHUNTER_LOG="$LOG_DIR/rkhunter.log"
echo -e "\n🦠 RKHunter Findings:"
if [[ -f "$RKHUNTER_LOG" ]]; then
  grep -E "Warning|Possible|Rootkit" "$RKHUNTER_LOG" || echo "✅ No suspicious findings."
else
  echo "⚠️ RKHunter log not found."
fi

# ─────────────────────────────
# 🧠 Lynis Audit Summary
# ─────────────────────────────
LYNIS_LOG="$LOG_DIR/lynis.log"
echo -e "\n🧠 Lynis Audit Summary:"
if [[ -f "$LYNIS_LOG" ]]; then
  grep -A3 "Hardening index" "$LYNIS_LOG"
  echo
  grep -A1 "\[WARNING\]" "$LYNIS_LOG" || echo "✅ No major warnings."
else
  echo "⚠️ Lynis log not found."
fi

# ─────────────────────────────
# 👀 Portmaster Check
# ─────────────────────────────
echo -e "\n👀 Portmaster:"
if systemctl --user is-active portmaster &>/dev/null || systemctl is-active portmaster &>/dev/null; then
  echo "✅ Portmaster is running."
elif rpm -q portmaster &>/dev/null; then
  echo "⚠️ Portmaster is installed but not running."
else
  echo "ℹ️ Portmaster not installed."
fi

echo -e "\n🎯 Log summary complete."
