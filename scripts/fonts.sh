#!/bin/bash
set -euo pipefail

echo "🔤 Installing fonts..."

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

echo "✨ Fonts installed. You may need to rebuild font cache: fc-cache -fv"
