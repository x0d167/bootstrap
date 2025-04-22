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

MULLVAD_REPO_PATH="/etc/yum.repos.d/mullvad.repo"

if [ ! -f "$MULLVAD_REPO_PATH" ]; then
  echo "🔐 Adding Mullvad repo manually..."
  sudo tee "$MULLVAD_REPO_PATH" >/dev/null <<EOF
[mullvad]
name=Mullvad VPN
baseurl=https://repository.mullvad.net/rpm/stable
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://repository.mullvad.net/rpm/stable/mullvad.asc
EOF
else
  echo "✅ Mullvad repo already exists."
fi

echo "📦 Installing Mullvad browser and VPN..."
if ! sudo dnf install -y mullvad-browser mullvad-vpn; then
  echo "⚠️ Failed to install Mullvad browser or VPN. Continuing anyway..."
fi

# ─────────────────────────────
# ProtonVPN Repo + Installation
# ─────────────────────────────
PROTON_RPM="protonvpn-stable-release-1.0.3-1.noarch.rpm"
PROTON_URL="https://repo.protonvpn.com/fedora-${FEDORA_VERSION}-stable/protonvpn-stable-release/${PROTON_RPM}"
PROTON_RPM_PATH="/tmp/${PROTON_RPM}"

if ! rpm -q protonvpn-stable-release &>/dev/null; then
  echo "🌐 Downloading ProtonVPN repo RPM..."
  if curl -fLo "$PROTON_RPM_PATH" "$PROTON_URL"; then
    sudo dnf install -y "$PROTON_RPM_PATH"
  else
    echo "⚠️ Failed to download ProtonVPN repo RPM. Skipping ProtonVPN install..."
    PROTONVPN_FAILED=true
  fi
else
  echo "✅ ProtonVPN repo already installed"
fi

if [ -z "${PROTONVPN_FAILED:-}" ]; then
  echo "📦 Installing ProtonVPN desktop client..."
  if ! sudo dnf install -y proton-vpn-gnome-desktop; then
    echo "⚠️ ProtonVPN install failed. Skipping..."
  fi
fi

# ─────────────────────────────
# GNOME Tray Integration
# ─────────────────────────────
echo "🧩 Installing AppIndicator support for GNOME..."
sudo dnf install -y libappindicator-gtk3 gnome-shell-extension-appindicator gnome-extensions-app

echo "⚠️  After reboot, enable 'AppIndicator and KStatusNotifierItem Support' in the Extensions app."
