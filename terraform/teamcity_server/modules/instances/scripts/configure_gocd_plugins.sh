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

export GOCD_CUSTOM_PLUGINS_DIR="/opt/gocd-plugins/"
export GOCD_DATA_DIR="/var/lib/go-server/"
export GOCD_PLUGINS_DIR="${GOCD_DATA_DIR}plugins/"
export GOCD_EXTERNAL_PLUGINS_DIR="${GOCD_PLUGINS_DIR}external/"

echo "Creating GoCD data directory..."
if sudo [ -d "${GOCD_DATA_DIR}" ]; then
  echo "Directory '${GOCD_DATA_DIR}' already exists."
else
  sudo mkdir "${GOCD_DATA_DIR}"
  sudo chown go:go "${GOCD_DATA_DIR}"
  sudo chmod 750 "${GOCD_DATA_DIR}"
fi

echo "Creating GoCD plugins directory..."
if sudo [ -d "${GOCD_PLUGINS_DIR}" ]; then
  echo "Directory '${GOCD_PLUGINS_DIR}' already exists."
else
  sudo mkdir "${GOCD_PLUGINS_DIR}"
  sudo chown go:go "${GOCD_PLUGINS_DIR}"
  sudo chmod 775 "${GOCD_PLUGINS_DIR}"
fi

echo "Creating GoCD external plugins directory..."
if sudo [ -d "${GOCD_EXTERNAL_PLUGINS_DIR}" ]; then
  echo "Directory '${GOCD_EXTERNAL_PLUGINS_DIR}' already exists."
else
  sudo mkdir "${GOCD_EXTERNAL_PLUGINS_DIR}"
  sudo chown go:go "${GOCD_EXTERNAL_PLUGINS_DIR}"
  sudo chmod 775 "${GOCD_EXTERNAL_PLUGINS_DIR}"
fi

echo "Removing links to nonexistent GoCD plugins..."
sudo find "${GOCD_EXTERNAL_PLUGINS_DIR}" -xtype l -exec rm -f {} \;

echo "Creating links to current GoCD plugins..."
sudo find "${GOCD_CUSTOM_PLUGINS_DIR}" -name *.jar \
  -exec ln -fs {} "${GOCD_EXTERNAL_PLUGINS_DIR}" \;
sudo find "${GOCD_EXTERNAL_PLUGINS_DIR}" -name *.jar -exec chown -h go:go {} \;
