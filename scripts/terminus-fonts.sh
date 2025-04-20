#!/bin/bash
set -euo pipefail

# =============================
# 🖋 terminus-fonts.sh
# Installs and sets Terminus console fonts
# =============================

echo "🖋 Installing Terminus console fonts..."

# Check if font is already installed
if [ -f "/usr/lib/kbd/consolefonts/ter-v32b.psf.gz" ]; then
  echo "✅ Terminus font already installed."
else
  echo "📦 Installing terminus-fonts-console..."
  sudo dnf install -y terminus-fonts-console
fi

# Set the font in vconsole.conf
echo "🛠 Setting Terminus font as default console font..."
sudo sed -i 's/^FONT=.*/FONT=ter-v32b/' /etc/vconsole.conf || echo "FONT=ter-v32b" | sudo tee -a /etc/vconsole.conf

# Apply it if not in graphical session
if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
  echo "📺 Applying font now (TTY detected)..."
  sudo setfont -C /dev/tty1 ter-v32b || echo "⚠️ Failed to set font (may not be on TTY1)"
fi

echo "✅ Terminus font installed and configured."
