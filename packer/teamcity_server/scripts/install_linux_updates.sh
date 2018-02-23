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

echo "Restarting system..."
sudo reboot
