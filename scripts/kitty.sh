#!/bin/bash
LOGFILE="$HOME/.local/share/kitty-update.log"
exec > >(tee -a "$LOGFILE") 2>&1
echo "========== $(date) Starting kitty update =========="

DRY_RUN=false
if [ "$1" == "--dry-run" ]; then
  DRY_RUN=true
fi

# Check current and latest version
LATEST_VERSION=$(curl -s https://api.github.com/repos/kovidgoyal/kitty/releases/latest | grep '"tag_name":' | cut -d '"' -f 4 | sed 's/^v//')
CURRENT_VERSION=$(~/.local/kitty.app/bin/kitty --version 2>/dev/null | cut -d ' ' -f 2)

if [ "$LATEST_VERSION" = "$CURRENT_VERSION" ]; then
  echo "Kitty is already up-to-date (v$CURRENT_VERSION)."
  exit 0
else
  echo "Updating kitty from v$CURRENT_VERSION to v$LATEST_VERSION..."

  if [ "$DRY_RUN" = true ]; then
    echo "Dry run enabled — skipping actual update steps."
    exit 0
  fi

  # --- Start of the update steps ---

  # Make sure required dirs exist
  mkdir -p ~/.local/bin
  mkdir -p ~/.local/share/applications

  # Re-run the installer
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

  # Create symbolic links to add kitty and kitten to PATH
  ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/

  # Place .desktop files where the OS can find them
  cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
  cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/

  # Update icon and exec paths in the .desktop files
  sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
  sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop

  # Make kitty the default terminal for environments using xdg-terminal-exec
  echo 'kitty.desktop' >~/.config/xdg-terminals.list

  echo "Kitty update complete!"
fi
