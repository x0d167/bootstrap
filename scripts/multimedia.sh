#!/bin/bash
set -euo pipefail

# =============================
# 🎬 multimedia.sh
# Enables nonfree ffmpeg and full media codec support
# =============================

echo "🎥 Checking multimedia codec support..."

# Check for RPM Fusion
if [[ -f /etc/yum.repos.d/rpmfusion-free.repo && -f /etc/yum.repos.d/rpmfusion-nonfree.repo ]]; then
  echo "🎬 Swapping ffmpeg-free for full ffmpeg with codec support..."
  if sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y; then
    echo "✅ Full multimedia codec support installed."
  else
    echo "⚠️ FFmpeg swap failed. Maybe 'ffmpeg-free' isn't installed or swap already done."
  fi
else
  echo "❌ RPM Fusion repos not found. Please run system-prep.sh first."
  exit 1
fi
