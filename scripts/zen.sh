#!/bin/bash

set -euo pipefail

# === LOGGING SETUP ===
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
LOGDIR="$HOME/.local/share/zen-logs"
mkdir -p "$LOGDIR"

LOGFILE="$LOGDIR/zen-install-$TIMESTAMP.log"
ln -sf "$LOGFILE" "$LOGDIR/latest.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >>"$LOGFILE"
}

echo "🌿 Starting Zen Browser install/update..."

# === FLAGS ===
DRY_RUN=false
BACKUP_ONLY=false
FORCE=false
SHOW_HELP=false

# === ARG PARSER ===
for arg in "$@"; do
  case "$arg" in
  --dry-run) DRY_RUN=true ;;
  --backup-only) BACKUP_ONLY=true ;;
  --force) FORCE=true ;;
  --help | -h) SHOW_HELP=true ;;
  *) echo "❌ Unknown option: $arg" && exit 1 ;;
  esac
done

# === HELP ===
if [ "$SHOW_HELP" = true ]; then
  cat <<EOF
Zen Browser Installer & Updater 🧘

Usage:
  ./zen-install.sh [options]

Options:
  --dry-run        Simulate the installation without making any changes
  --backup-only    Only back up existing profiles, do not install or update
  --force          Skip version check and reinstall/update regardless
  --help, -h       Show this help message and exit

Examples:
  ./zen-install.sh
  ./zen-install.sh --dry-run
  ./zen-install.sh --backup-only --dry-run
  ./zen-install.sh --force

EOF
  exit 0
fi

# === EARLY LOGGING ===
log "▶️  Zen installer started"
$DRY_RUN && log "🧪 Dry-run mode enabled"
$BACKUP_ONLY && log "📦 Backup-only mode enabled"
$FORCE && log "💥 Force mode enabled"

# === START ===
echo "🌿 Starting Zen Browser script..."
$DRY_RUN && echo "🧪 Running in dry-run mode — no changes will be made."
$BACKUP_ONLY && echo "📦 Running in backup-only mode — no install will occur."
$FORCE && echo "💥 Force mode enabled — skipping version check."

# === VARS ===
APP_NAME="zen"
INSTALL_DIR="$HOME/.tarball-installations/$APP_NAME"
TARBALL_URL="https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz"
TARBALL_TMP=$(mktemp /tmp/zen.XXXXXX.tar.xz)
EXTRACTED_DIR_NAME="zen"
BIN_PATH="$HOME/.local/bin/$APP_NAME"
DESKTOP_FILE="$HOME/.local/share/applications/$APP_NAME.desktop"
ICON_PATH="$INSTALL_DIR/browser/chrome/icons/default/default128.png"
EXECUTABLE="$INSTALL_DIR/zen"
VERSION_FILE="$INSTALL_DIR/VERSION"
BACKUP_ROOT="$HOME/.zen-backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# === VERSION CHECK ===
if [ "$FORCE" = false ] && [ "$BACKUP_ONLY" = false ]; then
  LATEST_VERSION=$(curl -s https://api.github.com/repos/zen-browser/desktop/releases/latest | grep '"tag_name":' | cut -d '"' -f 4)
  CURRENT_VERSION="none"
  [ -f "$VERSION_FILE" ] && CURRENT_VERSION=$(cat "$VERSION_FILE")

  echo "📦 Current version: $CURRENT_VERSION"
  echo "🌐 Latest version: $LATEST_VERSION"
  log "📦 Current version: $CURRENT_VERSION"
  log "🌐 Latest version: $LATEST_VERSION"

  if [ "$LATEST_VERSION" == "$CURRENT_VERSION" ]; then
    echo "✅ Zen is already up to date (v$CURRENT_VERSION)."
    log "✅ Already up-to-date at $CURRENT_VERSION"
    exit 0
  else
    echo "🔄 Updating Zen from $CURRENT_VERSION to $LATEST_VERSION..."
    log "🔄 Updating from $CURRENT_VERSION to $LATEST_VERSION"
  fi
elif [ "$FORCE" = true ]; then
  echo "💥 Force mode: skipping version check"
  LATEST_VERSION="forced-install-$(date +%Y%m%d-%H%M)"
else
  # fallback if backup-only is set
  LATEST_VERSION="backup-only-mode"
fi

# === PROFILE BACKUP & PRUNE ===
echo "🧷 Checking for existing Zen profiles to back up..."

backup_and_prune() {
  local source_dir="$1"
  local type="$2"
  local backup_dir="$BACKUP_ROOT/$type"
  local backup_name="zen-${type}-backup-$TIMESTAMP"
  local full_backup_path="$backup_dir/$backup_name"

  if [ -d "$source_dir" ]; then
    if [ "$DRY_RUN" = true ]; then
      echo "💡 Would create backup directory: $backup_dir"
      log "💡 Would create backup directory: $backup_dir"
    else
      mkdir -p "$backup_dir"
    fi

    if [ "$DRY_RUN" = true ]; then
      echo "💡 Would back up $type profile to: $full_backup_path"
      log "💡 Would back up $type profile to: $full_backup_path"
    else
      cp -r "$source_dir" "$full_backup_path"
      echo "📦 $type profile backed up to: $full_backup_path"
      log "📦 $type profile backed up to: $full_backup_path"
    fi

    # Prune backups
    shopt -s nullglob
    backups=("$backup_dir"/zen-${type}-backup-*)
    shopt -u nullglob

    if [ "${#backups[@]}" -gt 3 ]; then
      num_to_delete=$((${#backups[@]} - 3))
      to_delete=($(ls -1dt "${backups[@]}" | tail -n $num_to_delete))
      for old_backup in "${to_delete[@]}"; do
        if [ "$DRY_RUN" = true ]; then
          echo "💡 Would delete old $type backup: $old_backup"
          log "💡 Would delete old $type backup: $old_backup"
        else
          rm -rf "$old_backup"
          echo "🗑️  Deleted old $type backup: $old_backup"
          log "🗑️  Deleted old $type backup: $old_backup"
        fi
      done
    fi
  fi

}

backup_and_prune "$HOME/.var/app/app.zen_browser.Zen" "flatpak"
backup_and_prune "$HOME/.zen" "native"
if [ "$BACKUP_ONLY" = true ]; then
  echo "✅ Backup complete. Exiting due to --backup-only mode."
  exit 0
fi

# === OPTIONAL FLATPAK UNINSTALL PROMPT ===
if flatpak list | grep -q app.zen_browser.Zen; then
  echo "👀 Flatpak version of Zen is currently installed."

  if [ "$DRY_RUN" = true ]; then
    echo "💡 Would ask whether to uninstall Flatpak version of Zen"
  else
    read -rp "🧼 Do you want to uninstall the Flatpak version of Zen? [y/N]: " RESPONSE
    case "$RESPONSE" in
    [yY][eE][sS] | [yY])
      echo "🗑️  Uninstalling Flatpak Zen..."
      flatpak uninstall -y app.zen_browser.Zen
      ;;
    *)
      echo "🙃 Leaving Flatpak Zen alone for now."
      ;;
    esac
  fi
fi

# === PREP ===
$DRY_RUN || mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications" "$HOME/.tarball-installations"

# === CLEAN OLD INSTALL ===
if [ -f "$BIN_PATH" ]; then
  echo "Removing old bin at $BIN_PATH..."
  if [ "$DRY_RUN" = true ]; then
    echo "💡 Would remove: $BIN_PATH"
  else
    rm "$BIN_PATH"
  fi
fi

if [ -d "$INSTALL_DIR" ]; then
  echo "Removing old install directory at $INSTALL_DIR..."
  if [ "$DRY_RUN" = true ]; then
    echo "💡 Would remove: $INSTALL_DIR"
  else
    rm -rf "$INSTALL_DIR"
  fi
fi

if [ -f "$DESKTOP_FILE" ]; then
  echo "Removing old desktop entry at $DESKTOP_FILE..."
  if [ "$DRY_RUN" = true ]; then
    echo "💡 Would remove: $DESKTOP_FILE"
  else
    rm "$DESKTOP_FILE"
  fi
fi

# === DOWNLOAD & INSTALL ===
if [ "$DRY_RUN" = true ]; then
  echo "💡 Would download tarball from: $TARBALL_URL"
  echo "💡 Would extract and move to: $INSTALL_DIR"
else
  echo "📥 Downloading Zen tarball..."
  curl -L "$TARBALL_URL" -o "$TARBALL_TMP"
  echo "📦 Extracting..."
  tar -xJf "$TARBALL_TMP"
  mv "$EXTRACTED_DIR_NAME" "$INSTALL_DIR"
  rm "$TARBALL_TMP"
fi

# === BIN LAUNCHER ===
if [ "$DRY_RUN" = true ]; then
  echo "💡 Would create bin launcher at: $BIN_PATH"
else
  echo "#!/bin/bash
\"$EXECUTABLE\" \"\$@\"" >"$BIN_PATH"
  chmod +x "$BIN_PATH"
  echo "🛠️  Created bin launcher at $BIN_PATH"
fi

# === DESKTOP FILE ===
if [ "$DRY_RUN" = true ]; then
  echo "💡 Would create desktop entry at: $DESKTOP_FILE"
else
  cat <<EOF >"$DESKTOP_FILE"
[Desktop Entry]
Name=Zen Browser
Comment=Experience tranquillity while browsing the web without people tracking you!
Keywords=web;browser;internet
Exec=$EXECUTABLE %u
Icon=$ICON_PATH
Terminal=false
StartupNotify=true
StartupWMClass=zen
NoDisplay=false
Type=Application
MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;
Categories=Network;WebBrowser;
Actions=new-window;new-private-window;profile-manager-window;

[Desktop Action new-window]
Name=Open a New Window
Exec=$EXECUTABLE --new-window %u

[Desktop Action new-private-window]
Name=Open a New Private Window
Exec=$EXECUTABLE --private-window %u

[Desktop Action profile-manager-window]
Name=Open the Profile Manager
Exec=$EXECUTABLE --ProfileManager
EOF
  echo "📁 Created desktop entry at $DESKTOP_FILE"
fi

# === SAVE VERSION ===
if [ "$DRY_RUN" = true ]; then
  echo "💡 Would save version info to $VERSION_FILE"
else
  echo "$LATEST_VERSION" >"$VERSION_FILE"
fi

echo "🎉 Zen Browser update complete"
[ "$DRY_RUN" = true ] && echo "🧪 (Dry run — no files were changed)"
