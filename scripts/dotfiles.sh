#!/bin/bash
set -euo pipefail

# ==========================
# 🛠️ dotfiles.sh
# Clone and deploy dotfiles
# ==========================

REPO="https://github.com/x0d167/.dotfiles.git"
TARGET="$HOME/.dotfiles"

echo "📦 Preparing dotfiles..."

if [ -d "$TARGET/.git" ]; then
  echo "✅ Dotfiles already exist at $TARGET"
else
  echo "📥 Cloning dotfiles from: $REPO"
  git clone "$REPO" "$TARGET"
fi

cd "$TARGET"

# === Optional backup step ===
BACKUP_TIME=$(date +%Y%m%d-%H%M%S)
BACKUP_ROOT="$HOME/.dotfiles-backup"
BACKUP_DIR="$BACKUP_ROOT/$BACKUP_TIME"

echo "📁 Backing up existing config files to $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"

for item in .bashrc .gitconfig .config/starship.toml .config/kitty .config/nvim .config/zellij; do
  if [ -e "$HOME/$item" ]; then
    echo "💾 Backing up $item"
    cp -r "$HOME/$item" "$BACKUP_DIR/" || true
  fi
done

# === Prune old backups ===
MAX_BACKUPS=5

echo "🧹 Pruning old dotfile backups (keeping latest $MAX_BACKUPS)..."
shopt -s nullglob
backups=("$BACKUP_ROOT"/*)
shopt -u nullglob

if [ "${#backups[@]}" -gt "$MAX_BACKUPS" ]; then
  to_delete=($(ls -1dt "$BACKUP_ROOT"/* | tail -n +$((MAX_BACKUPS + 1))))
  for dir in "${to_delete[@]}"; do
    echo "🗑️  Deleting old backup: $dir"
    rm -rf "$dir"
  done
else
  echo "✅ No pruning needed."
fi

# === Stow ===
echo "🔗 Running stow from $TARGET..."
stow bash config

echo "✅ Dotfiles deployed!"
