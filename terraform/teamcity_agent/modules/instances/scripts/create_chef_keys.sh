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

DESTINATION_DIR="/home/teamcity/.chef/"
DESTINATION_OWNER="teamcity"
DESTINATION_GROUP="teamcity"

verify_variable () {
  if [ -z "${2}" ]; then
    echo "Unable to set ${1}."
    exit 1
  fi
}

echo "Setting AWS_DEFAULT_REGION..."
METADATA_URL="http://169.254.169.254/latest/dynamic/instance-identity/document"
export AWS_DEFAULT_REGION="$(curl -s "${METADATA_URL}" | jq -r .region)"
verify_variable 'AWS_DEFAULT_REGION' "${AWS_DEFAULT_REGION}"

echo "Creating Chef key: deploysvc.pem..."
KEY_NAME="deploysvc"
FILE_NAME="deploysvc.pem"

mkdir "${HOME}/.chef/" 2>/dev/null
aws ssm get-parameter \
  --name "/chef/keys/${KEY_NAME}" \
  --query "Parameter.Value" \
  --with-decryption > "${HOME}/.chef/${FILE_NAME}"

chmod 600 "${HOME}/.chef/${FILE_NAME}"
sudo mv "${HOME}/.chef/${FILE_NAME}" "${DESTINATION_DIR}/"
sudo chown "${DESTINATION_OWNER}":"${DESTINATION_GROUP}" \
  "${DESTINATION_DIR}/${FILE_NAME}"

echo "Creating Chef key: encrypted_data_bag_secret..."
KEY_NAME="dev-encrypted-data-bag-secret"
FILE_NAME="encrypted_data_bag_secret"

mkdir "${HOME}/.chef/" 2>/dev/null
aws ssm get-parameter \
  --name "/chef/keys/${KEY_NAME}" \
  --query "Parameter.Value" \
  --with-decryption > "${HOME}/.chef/${FILE_NAME}"

chmod 600 "${HOME}/.chef/${FILE_NAME}"
sudo mv "${HOME}/.chef/${FILE_NAME}" "${DESTINATION_DIR}/"
sudo chown "${DESTINATION_OWNER}":"${DESTINATION_GROUP}" \
  "${DESTINATION_DIR}/${FILE_NAME}"
