#!/bin/bash
set -euo pipefail

LOGFILE="$HOME/.local/share/kitty-update.log"
exec > >(tee -a "$LOGFILE") 2>&1
echo "========== $(date) Starting kitty update =========="

DRY_RUN=false
if [ "${1:-}" == "--dry-run" ]; then
  DRY_RUN=true
fi

KITTY_BIN="$HOME/.local/kitty.app/bin/kitty"
KITTY_DIR="$HOME/.local/kitty.app"

# Get latest version from GitHub
LATEST_VERSION=$(curl -s https://api.github.com/repos/kovidgoyal/kitty/releases/latest | grep '"tag_name":' | cut -d '"' -f 4 | sed 's/^v//')

# Get current installed version (if any)
if [ -x "$KITTY_BIN" ]; then
  CURRENT_VERSION=$("$KITTY_BIN" --version 2>/dev/null | cut -d ' ' -f 2)
else
  CURRENT_VERSION="none"
fi

if [ "$LATEST_VERSION" = "$CURRENT_VERSION" ]; then
  echo "✅ Kitty is already up-to-date (v$CURRENT_VERSION)."
  exit 0
else
  echo "⬆️ Updating kitty from v$CURRENT_VERSION to v$LATEST_VERSION..."

  if [ "$DRY_RUN" = true ]; then
    echo "ℹ️ Dry run enabled — skipping actual update steps."
    exit 0
  fi

  mkdir -p ~/.local/bin ~/.local/share/applications

  echo "📥 Downloading and installing kitty..."
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

  echo "🔗 Linking binaries..."
  ln -sf "$KITTY_DIR/bin/kitty" "$KITTY_DIR/bin/kitten" ~/.local/bin/

  echo "🗂 Updating .desktop files..."
  cp "$KITTY_DIR/share/applications/kitty.desktop" ~/.local/share/applications/
  cp "$KITTY_DIR/share/applications/kitty-open.desktop" ~/.local/share/applications/

  sed -i "s|Icon=kitty|Icon=$KITTY_DIR/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
  sed -i "s|Exec=kitty|Exec=$KITTY_DIR/bin/kitty|g" ~/.local/share/applications/kitty*.desktop

  echo "📦 Setting as default terminal (for xdg-terminal-exec)..."
  echo 'kitty.desktop' >~/.config/xdg-terminals.list

  echo "✅ Kitty update complete!"
fi
