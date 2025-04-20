#!/bin/bash
# NOTE: Most fonts are pinned to v3.3.0 for consistency.
# To get newer fonts in the future, check for updated release URLs:
# https://github.com/ryanoasis/nerd-fonts/releases/latest

set -euo pipefail

echo "🔤 Installing selected Nerd Fonts..."

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

# Fonts and their exact download URLs
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

echo "🔄 Rebuilding font cache..."
fc-cache -fv

echo "✅ Nerd Fonts installed in $FONT_DIR"
