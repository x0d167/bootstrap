#!/bin/bash
set -euo pipefail

# =============================
# 🧼 system-prep.sh
# Optimizes DNF, adds RPM Fusion, updates system
# =============================

echo "⚙️ Optimizing DNF settings..."

sudo sed -i '/^max_parallel_downloads=/c\max_parallel_downloads=10' /etc/dnf/dnf.conf || echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf >/dev/null
sudo grep -q '^fastestmirror=' /etc/dnf/dnf.conf || echo 'fastestmirror=True' | sudo tee -a /etc/dnf/dnf.conf >/dev/null
sudo grep -q '^defaultyes=' /etc/dnf/dnf.conf || echo 'defaultyes=True' | sudo tee -a /etc/dnf/dnf.conf >/dev/null

echo "📦 Installing DNF plugins..."
sudo dnf install -y dnf-plugins-core

# =========================================
# Adds RPM Fusion, updates system, cleans DNF cache
# =========================================

echo "📦 Preparing Fedora system with RPM Fusion and latest updates..."

# ─────────────────────────────
# Add RPM Fusion Repos
# ─────────────────────────────
if [ ! -f /etc/yum.repos.d/rpmfusion-free.repo ] || [ ! -f /etc/yum.repos.d/rpmfusion-nonfree.repo ]; then
  echo "➕ Adding RPM Fusion (free & nonfree)..."
  sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
else
  echo "✅ RPM Fusion already installed."
fi

# ─────────────────────────────
# Enable openh264 codec (Cisco)
# ─────────────────────────────
if ! sudo dnf repolist enabled | grep -q "fedora-cisco-openh264"; then
  echo "📡 Enabling fedora-cisco-openh264 repo..."
  sudo dnf config-manager --enable fedora-cisco-openh264 || true
fi

# ─────────────────────────────
# Full System Update
# ─────────────────────────────
echo "🔄 Updating and upgrading system packages..."
sudo dnf upgrade --refresh -y

# ─────────────────────────────
# Cleanup
# ─────────────────────────────
echo "🧹 Cleaning up DNF cache..."
sudo dnf autoremove -y
sudo dnf clean all

echo "✅ System preparation complete."
