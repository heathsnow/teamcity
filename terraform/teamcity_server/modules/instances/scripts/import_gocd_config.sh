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

export GOCD_CONFIG_SOURCE_DIR="/tmp/"
export GOCD_CONFIG_SOURCE_FILE="${GOCD_CONFIG_SOURCE_DIR}cruise-config.xml"
export GOCD_CONFIG_DESTINATION_DIR="/etc/go/"

echo "Importing GoCD configuration file..."
if [ ! -e "${GOCD_CONFIG_SOURCE_FILE}" ]; then
  echo "Unable to locate GoCD configuration file."
  exit 1
else
  sudo chown go:go "${GOCD_CONFIG_SOURCE_FILE}"
  sudo chmod 664 "${GOCD_CONFIG_SOURCE_FILE}"
  sudo mv -f "${GOCD_CONFIG_SOURCE_FILE}" "${GOCD_CONFIG_DESTINATION_DIR}"
fi
