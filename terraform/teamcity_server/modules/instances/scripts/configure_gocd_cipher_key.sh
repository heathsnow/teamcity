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

GOCD_CIPHER_FILE="/etc/go/cipher"

echo "Setting AWS_DEFAULT_REGION..."
METADATA_URL="http://169.254.169.254/latest/dynamic/instance-identity/document"
export AWS_DEFAULT_REGION="$(curl -s "${METADATA_URL}" | jq -r .region)"
if [ -z "${AWS_DEFAULT_REGION}" ]; then
  echo "Unable to set AWS_DEFAULT_REGION."
  exit 1
fi

echo "Setting GOCD_CIPHER_KEY..."
GOCD_CIPHER_KEY="$(aws ssm get-parameter \
  --name /gocd/cipher/key \
  --query Parameter.Value --with-decryption --output text)"
if [ -z "${GOCD_CIPHER_KEY}" ]; then
  echo "Unable to set GOCD_CIPHER_KEY."
  exit 1
fi

echo "Setting GoCD server encryption cipher key..."
sudo -u go tee "${GOCD_CIPHER_FILE}" &>/dev/null <<< ${GOCD_CIPHER_KEY}
sudo chmod 664 "${GOCD_CIPHER_FILE}"
