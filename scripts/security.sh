#!/bin/bash
set -euo pipefail

# =============================
# 🛡️ security.sh
# Full security stack for Fedora laptop
# Includes: UFW, sysctl hardening, fail2ban, rkhunter, lynis, portmaster
# =============================

LOG_DIR="logs"
mkdir -p "$LOG_DIR"

log() {
  echo -e "\n📌 $1" | tee -a "$LOG_DIR/security.log"
}

# ─────────────────────────────
# 1. UFW Firewall Setup
# ─────────────────────────────
log "Installing and configuring UFW..."

if ! command -v ufw &>/dev/null; then
  sudo dnf install -y ufw | tee -a "$LOG_DIR/security.log"
else
  echo "✅ UFW already installed." | tee -a "$LOG_DIR/security.log"
fi

sudo ufw disable || true

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw limit ssh

# Uncomment and edit if running local dev servers:
# sudo ufw allow 3000/tcp
# sudo ufw allow 8000/tcp

sudo ufw --force enable
sudo ufw status verbose | tee -a "$LOG_DIR/security.log"

# ─────────────────────────────
# 2. Kernel Network Hardening (sysctl)
# ─────────────────────────────
log "Applying sysctl hardening settings..."

SYSCTL_FILE="/etc/sysctl.d/99-laptop-hardening.conf"

sudo bash -c "cat > $SYSCTL_FILE" <<EOF
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.log_martians = 1
EOF

sudo sysctl --system | tee -a "$LOG_DIR/security.log"

# ─────────────────────────────
# 3. Security Tools: fail2ban, rkhunter, lynis
# ─────────────────────────────
log "Installing security tools..."

sudo dnf install -y fail2ban rkhunter lynis | tee -a "$LOG_DIR/security.log"

log "Enabling and starting Fail2Ban..."
sudo systemctl enable --now fail2ban
sudo systemctl status fail2ban --no-pager | tee -a "$LOG_DIR/security.log"

log "Running rkhunter check..."
sudo rkhunter --update | tee -a "$LOG_DIR/rkhunter-update.log"
sudo rkhunter --check --sk | tee -a "$LOG_DIR/rkhunter.log"

log "Running Lynis audit..."
sudo lynis audit system | tee -a "$LOG_DIR/lynis.log"

# ─────────────────────────────
# 4. Optional: Portmaster Install
# ─────────────────────────────
log "Checking if Portmaster should be installed..."

read -rp "❓ Do you want to install Portmaster (app firewall)? [y/N]: " install_pm
if [[ "${install_pm,,}" == "y" ]]; then
  log "Installing Portmaster..."

  TMP_PM_RPM="/tmp/portmaster.rpm"
  curl -L "https://updates.safing.io/latest/linux_amd64/packages/portmaster-fedora-install.rpm" -o "$TMP_PM_RPM"

  sudo dnf install -y "$TMP_PM_RPM" | tee -a "$LOG_DIR/security.log"
  rm -f "$TMP_PM_RPM"

  log "Portmaster installed. It will start on boot and be available in your system tray."
else
  log "Skipped Portmaster installation."
fi

log "✅ All security tools are installed and configured. Check the logs/ folder for audit results and status."
