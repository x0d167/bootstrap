#!/bin/bash
set -euo pipefail

# =============================
# 📋 log-summary.sh
# Summarizes the latest logs from the security setup
# Flags: --log-only | --no-color
# =============================

LOG_DIR="logs"
mkdir -p "$LOG_DIR"
SUMMARY_FILE="$LOG_DIR/log-summary-$(date +%Y%m%d-%H%M%S).txt"

# -----------------------------
# 🔧 Flags
# -----------------------------
LOG_ONLY=false
USE_COLOR=true

for arg in "$@"; do
  case "$arg" in
  --log-only) LOG_ONLY=true ;;
  --no-color) USE_COLOR=false ;;
  esac
done

# -----------------------------
# 🎨 Colors
# -----------------------------
if $USE_COLOR; then
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  YELLOW='\033[1;33m'
  NC='\033[0m'
else
  GREEN='' RED='' YELLOW='' NC=''
fi

# -----------------------------
# 📤 Logging Function
# -----------------------------
log() {
  echo -e "$1" >>"$SUMMARY_FILE"
  if ! $LOG_ONLY; then
    echo -e "$1"
  fi
}

# -----------------------------
# 🧠 Begin Summary
# -----------------------------
log "${YELLOW}📋 Log Summary - $(date)${NC}"
log "────────────────────────────────────────────"

# 🔐 UFW
log "\n${YELLOW}🔐 UFW Status:${NC}"
sudo ufw status verbose 2>&1 | tee -a "$SUMMARY_FILE" | { $LOG_ONLY || cat; }

# 🛡️ Fail2Ban
log "\n${YELLOW}🛡️ Fail2Ban Status:${NC}"
if sudo systemctl status fail2ban --no-pager &>/dev/null; then
  sudo systemctl status fail2ban --no-pager | grep -E "Active|Loaded" >>"$SUMMARY_FILE"
  $LOG_ONLY || sudo systemctl status fail2ban --no-pager | grep -E "Active|Loaded"
else
  log "${RED}❌ Fail2Ban not found or inactive.${NC}"
fi

# 🦠 RKHunter
log "\n${YELLOW}🦠 RKHunter Findings:${NC}"
RKHUNTER_LOG="$LOG_DIR/rkhunter.log"
if [[ -f "$RKHUNTER_LOG" ]]; then
  grep -E "Warning|Possible|Rootkit" "$RKHUNTER_LOG" >>"$SUMMARY_FILE" || log "${GREEN}✅ No suspicious findings.${NC}"
else
  log "${YELLOW}⚠️ RKHunter log not found.${NC}"
fi

# 🧠 Lynis
log "\n${YELLOW}🧠 Lynis Audit Summary:${NC}"
LYNIS_LOG="$LOG_DIR/lynis.log"
if [[ -f "$LYNIS_LOG" ]]; then
  grep -A3 "Hardening index" "$LYNIS_LOG" >>"$SUMMARY_FILE"
  grep -A1 "\[WARNING\]" "$LYNIS_LOG" >>"$SUMMARY_FILE" || log "${GREEN}✅ No major warnings.${NC}"
else
  log "${YELLOW}⚠️ Lynis log not found.${NC}"
fi

# 👀 Portmaster
log "\n${YELLOW}👀 Portmaster:${NC}"
if systemctl --user is-active portmaster &>/dev/null || systemctl is-active portmaster &>/dev/null; then
  log "${GREEN}✅ Portmaster is running.${NC}"
elif rpm -q portmaster &>/dev/null; then
  log "${YELLOW}⚠️ Portmaster is installed but not running.${NC}"
else
  log "${NC}ℹ️ Portmaster not installed.${NC}"
fi

log "\n${GREEN}🎯 Log summary complete.${NC} Saved to $SUMMARY_FILE"
