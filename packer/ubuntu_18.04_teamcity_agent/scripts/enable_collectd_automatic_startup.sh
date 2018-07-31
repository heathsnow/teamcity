#!/usr/bin/env bash
set -e

determine_linux_distribution () {
  echo "Determining Linux distribution..."
  if [ -x "$(command -v apt-get)" ]; then
    echo "Found apt-get, assuming Debian family..."
    DISTRO="debian"
  elif [ -x "$(command -v yum)" ]; then
    echo "Found yum, assuming Red Hat family..."
    DISTRO="redhat"
  else
    echo "Unable to determine Linux distribution."
    exit 1
  fi
}

enable_service () {
  SERVICE_NAME="${1}"

  echo "Enabling ${SERVICE_NAME}..."
  case $DISTRO in
    "debian")
      sudo systemctl enable "${SERVICE_NAME}"
      ;;
    "redhat")
      sudo chkconfig "${SERVICE_NAME}" on
      ;;
  esac
}

main () {
  determine_linux_distribution
  enable_service "collectd"
}

main
