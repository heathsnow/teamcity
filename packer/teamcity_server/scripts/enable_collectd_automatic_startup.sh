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

echo "Enabling collectd..."
case $DISTRO in
  "debian")
    sudo systemctl enable collectd
    ;;
  "redhat")
    sudo chkconfig collectd on
    ;;
esac
