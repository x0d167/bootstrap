#!/bin/bash
set -euo pipefail

echo "🖥 Checking for TUXEDO hardware..."

# Check system manufacturer using DMI data
if ! sudo dmidecode -s system-manufacturer | grep -qi "TUXEDO"; then
  echo "🚫 Not a TUXEDO machine. Skipping TUXEDO setup."
  exit 0
fi

echo "✅ TUXEDO hardware detected. Proceeding with installation..."

# Update the system
sudo dnf update -y

# Create the TUXEDO repo file
sudo bash -c 'cat > /etc/yum.repos.d/tuxedo.repo <<EOF
[tuxedo]
name=tuxedo
baseurl=https://rpm.tuxedocomputers.com/fedora/41/x86_64/base
enabled=1
gpgcheck=1
gpgkey=https://rpm.tuxedocomputers.com/fedora/40/0x54840598.pub.asc
skip_if_unavailable=False
EOF'

# Download and import the GPG key
curl -o /tmp/0x54840598.pub.asc https://rpm.tuxedocomputers.com/fedora/40/0x54840598.pub.asc
sudo rpm --import /tmp/0x54840598.pub.asc

# Install the TUXEDO Control Center
sudo dnf install -y tuxedo-control-center

echo "🎉 TUXEDO Control Center and drivers installed!"
