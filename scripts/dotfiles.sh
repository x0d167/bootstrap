#!/bin/bash
set -euo pipefail

# ==========================
# 🛠️ dotfiles.sh
# Clone and deploy dotfiles
# ==========================

REPO="https://github.com/x0d167/.dotfiles.git"
TARGET="$HOME/.dotfiles"
DEPLOY_LOG="$TARGET/.dotfiles-deploy.log"

if ! command -v stow &>/dev/null; then
  echo "❌ 'stow' is not installed. Please add it to your base packages or install it manually."
  exit 1
fi

echo "📦 Preparing dotfiles..."

if [ -d "$TARGET/.git" ]; then
  echo "✅ Dotfiles already exist at $TARGET"
else
  echo "📥 Cloning dotfiles from: $REPO"
  git clone "$REPO" "$TARGET"
fi

cd "$TARGET"

# === Backup existing configs ===
BACKUP_TIME=$(date +%Y%m%d-%H%M%S)
BACKUP_ROOT="$HOME/.dotfiles-backup"
BACKUP_DIR="$BACKUP_ROOT/$BACKUP_TIME"

echo "📁 Backing up existing dotfiles to $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR/.config"

# Backup matching ~/.config/* items
for dir in "$TARGET/config/.config/"*; do
  name=$(basename "$dir")
  target_path="$HOME/.config/$name"
  if [ -e "$target_path" ]; then
    echo "💾 Backing up $target_path"
    cp -r "$target_path" "$BACKUP_DIR/.config/" || true
  fi
done

# Backup top-level files (if present)
TOP_LEVEL_FILES=(
  .bashrc
  .bash_profile
  .zshrc
)

for item in "${TOP_LEVEL_FILES[@]}"; do
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
  mapfile -t to_delete < <(ls -1dt "$BACKUP_ROOT"/* | tail -n +$((MAX_BACKUPS + 1)))
  for dir in "${to_delete[@]}"; do
    echo "🗑️  Deleting old backup: $dir"
    rm -rf "$dir"
  done
else
  echo "✅ No pruning needed."
fi

# === Stow ===
echo "🔗 Linking dotfiles into place with stow..."
{
  echo ""
  echo "===== $(date): Stow operation ====="
  stow -R bash config
  echo "✅ Dotfiles deployed."
} | tee -a "$DEPLOY_LOG"

echo "📝 Deployment recorded in $DEPLOY_LOG"
