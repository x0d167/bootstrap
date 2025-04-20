#!/bin/bash

# ==========================
# 🔐 vpn.sh
# Mullvad + ProtonVPN setup
# ==========================

FEDORA_VERSION=$(rpm -E %fedora)

# MULLVAD
if ! dnf repolist | grep -q mullvad; then
  echo "🔐 Adding Mullvad repo..."
  sudo dnf config-manager --add-repo https://repository.mullvad.net/rpm/stable/mullvad.repo
else
  echo "✅ Mullvad repo already added"
fi

echo "📥 Installing Mullvad browser and VPN..."
sudo dnf install -y mullvad-browser mullvad-vpn

# PROTONVPN
PROTON_RPM="protonvpn-stable-release-1.0.3-1.noarch.rpm"
PROTON_URL="https://repo.protonvpn.com/fedora-${FEDORA_VERSION}-stable/protonvpn-stable-release/${PROTON_RPM}"

wget -N "$PROTON_URL"
sudo dnf install -y ./$PROTON_RPM && sudo dnf check-update --refresh
sudo dnf install -y proton-vpn-gnome-desktop

# GNOME TRAY
sudo dnf install -y libappindicator-gtk3 gnome-shell-extension-appindicator gnome-extensions-app

echo "⚠️  After reboot, enable 'AppIndicator and KStatusNotifierItem Support' in Extensions app."
