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

CA_CERT_SOURCE_DIR="/tmp/"

case $DISTRO in
  "debian")
    CA_CERT_DESTINATION_DIR="/usr/local/share/ca-certificates/"
    ;;
  "redhat")
    CA_CERT_DESTINATION_DIR="/etc/pki/ca-trust/source/anchors/"
    ;;
esac

echo "Importing CA certificate files..."
CA_CERT_FILES="$(ls "${CA_CERT_SOURCE_DIR}"*.crt 2>/dev/null)"
if [ -z "${CA_CERT_FILES}" ]; then
  echo "Unable to locate CA certificate files."
  exit 1
else
  sudo chmod 644 "${CA_CERT_SOURCE_DIR}"*.crt
  sudo chown root:root "${CA_CERT_SOURCE_DIR}"*.crt
  sudo mv -f "${CA_CERT_SOURCE_DIR}"*.crt "${CA_CERT_DESTINATION_DIR}"
fi

echo "Updating CA certificate stores..."
case $DISTRO in
  "debian")
    sudo update-ca-certificates
    ;;
  "redhat")
    sudo update-ca-trust
    ;;
esac
