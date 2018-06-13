#!/usr/bin/env bash
set -e

echo "Determining Linux distribution..."
if [ -x "$(command -v apt-get)" ]; then
  echo "Found apt-get, assuming Debian family..."
  export DISTRO="debian"
elif [ -x "$(command -v yum)" ]; then
  echo "Found yum, assuming Red Hat family..."
  export DISTRO="redhat"
else
  echo "Unable to determine Linux distribution."
  exit 1
fi

# Note: Running apt-get dist-upgrade with --force-confdef --force-confold causes
# it to to overwrite any unmodified default configuration files that it finds.
# Modified configuration files will be left alone, and .dpkg-dist files
# contianing the new default configuration values will be created instead.
#
# This means that all custom configuration is preserved during upgrades, but may
# cause application errors on startup if initialization options have changed
# substantially between versions.
#
# Always check for .dpkg-dist files after running this script!

echo "Updating installed packages..."
case $DISTRO in
  "debian")
    sudo apt-get update
    sudo DEBIAN_FRONTEND="noninteractive" apt-get dist-upgrade -y \
      -o Dpkg::Options::="--force-confdef" \
      -o Dpkg::Options::="--force-confold"
    sudo apt-get autoremove -yq
    ;;
  "redhat")
    sudo yum update -y
    ;;
esac

# Note: Snap is a universal package format used by many Linux distributions.
# Snap packages, known as "snaps", are updated daily by the snapd service.
# Amazon distributes the EC2 SSM Agent via snap, and it comes preinstalled
# in many of their AMIs.

echo "Determining if snap is installed..."
if [ -x "$(command -v snap)" ]; then
  echo "Found snap, updating snaps..."
  sudo snap refresh
else
  echo "Snap is not installed."
fi

# Note: Always set expect_disconnect=true when calling this script from Packer!
#
# Disabling eth0 (below) has the effect of disconnecting Packer's SSH session in
# the middle of script execution.  If this script was called from a provisioner
# with expect_disconnect=true, Packer will wait until it is able to reconnect to
# the host before executing the next script in sequence.  However, the currently
# executing script--this script--will complete normally on the host.  It will
# reboot the host which, as it starts up again, will automatically enable eth0
# and allow Packer to reconnect.
#
# This prevents race conditions that would otherwise occur when this script
# initiates a reboot and exits.  Packer would begin executing the next script in
# sequence, which would be interrupted at some point by the pending reboot, and
# cause the currently executing script--one subsequent to this script--to fail.

echo "Restarting system..."
sudo ip link set down eth0
sudo reboot
