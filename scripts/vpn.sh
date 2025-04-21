#!/bin/bash
set -euo pipefail

# ==========================
# 🔐 vpn.sh
# Mullvad + ProtonVPN setup
# ==========================

FEDORA_VERSION=$(rpm -E %fedora)

# ─────────────────────────────
# Mullvad Repo + Installation
# ─────────────────────────────
if ! dnf repolist | grep -q mullvad; then
  echo "🔐 Adding Mullvad repo..."
  sudo dnf config-manager --add-repo https://repository.mullvad.net/rpm/stable/mullvad.repo
else
  echo "✅ Mullvad repo already exists"
fi

echo "📦 Installing Mullvad browser and VPN..."
sudo dnf install -y mullvad-browser mullvad-vpn

# ─────────────────────────────
# ProtonVPN Repo + Installation
# ─────────────────────────────
PROTON_RPM="protonvpn-stable-release-1.0.3-1.noarch.rpm"
PROTON_URL="https://repo.protonvpn.com/fedora-${FEDORA_VERSION}-stable/protonvpn-stable-release/${PROTON_RPM}"
PROTON_RPM_PATH="/tmp/${PROTON_RPM}"

if ! rpm -q protonvpn-stable-release &>/dev/null; then
  echo "🌐 Downloading ProtonVPN repo RPM..."
  curl -Lo "$PROTON_RPM_PATH" "$PROTON_URL"
  sudo dnf install -y "$PROTON_RPM_PATH"
else
  echo "✅ ProtonVPN repo already installed"
fi

echo "📦 Installing ProtonVPN desktop client..."
sudo dnf install -y proton-vpn-gnome-desktop

# ─────────────────────────────
# GNOME Tray Integration
# ─────────────────────────────
echo "🧩 Installing AppIndicator support for GNOME..."
sudo dnf install -y libappindicator-gtk3 gnome-shell-extension-appindicator gnome-extensions-app

echo "⚠️  After reboot, enable 'AppIndicator and KStatusNotifierItem Support' in the Extensions app."
