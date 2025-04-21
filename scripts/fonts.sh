#!/bin/bash
set -euo pipefail

# =============================
# 🔤 fonts.sh
# Installs UI fonts, Nerd Fonts, and Terminus TTY fonts
# =============================

echo "🔤 Installing system UI and mono fonts..."

sudo dnf install -y \
  fira-code-fonts \
  mozilla-fira-sans-fonts \
  fontawesome-fonts \
  jetbrains-mono-fonts \
  google-noto-sans-fonts \
  google-noto-serif-fonts \
  google-noto-mono-fonts \
  google-noto-emoji-color-fonts \
  google-roboto-slab-fonts

echo "✅ UI and system fonts installed."

# ─────────────────────────────
# 💾 Nerd Fonts
# ─────────────────────────────
echo "💾 Installing selected Nerd Fonts..."

FONT_DIR="$HOME/.local/share/fonts/NerdFonts"
mkdir -p "$FONT_DIR"

echo "🧹 Cleaning old Nerd Fonts from $FONT_DIR..."
rm -rf "$FONT_DIR"/*

# Fonts and their download URLs
declare -A fonts
fonts=(
  [0xProto]="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/0xProto.zip"
  [CascadiaMono]="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono.zip"
  [CascadiaCode]="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/CascadiaCode.zip"
  [FiraCode]="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip"
  [FiraMono]="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraMono.zip"
  [GeistMono]="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/GeistMono.zip"
  [JetBrainsMono]="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip"
  [Meslo]="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Meslo.zip"
)

for name in "${!fonts[@]}"; do
  echo "📥 Downloading $name..."
  zip_file="/tmp/${name}.zip"
  curl -fLo "$zip_file" "${fonts[$name]}"
  unzip -o "$zip_file" -d "$FONT_DIR"
done

echo "✅ Nerd Fonts installed in $FONT_DIR"

# ─────────────────────────────
# 🖋 Terminus Console Font
# ─────────────────────────────
echo "🖋 Installing Terminus console font..."

if [ -f "/usr/lib/kbd/consolefonts/ter-v32b.psf.gz" ]; then
  echo "✅ Terminus font already installed."
else
  sudo dnf install -y terminus-fonts-console
fi

echo "🛠 Setting Terminus font in /etc/vconsole.conf..."
sudo sed -i 's/^FONT=.*/FONT=ter-v32b/' /etc/vconsole.conf || echo "FONT=ter-v32b" | sudo tee -a /etc/vconsole.conf

if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
  echo "📺 Applying Terminus font to TTY..."
  sudo setfont -C /dev/tty1 ter-v32b || echo "⚠️ Could not apply font (likely not on TTY1)"
fi

# ─────────────────────────────
# 🔄 Rebuild Font Cache
# ─────────────────────────────
echo "🔄 Rebuilding font cache..."
fc-cache -fv

echo "🎉 All fonts installed and configured!"
