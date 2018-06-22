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

echo "Creating Amazon keys..."
until [ "${NEXT_TOKEN}" == null ]
do
  if [ "${NEXT_TOKEN}" ]; then
    AMAZON_KEYS="$(aws ssm get-parameters-by-path \
      --with-decryption \
      --path /amazon/keys/ \
      --next-token ${NEXT_TOKEN})"
  else
    AMAZON_KEYS="$(aws ssm get-parameters-by-path \
      --with-decryption \
      --path /amazon/keys/)"
  fi

  NEXT_TOKEN=$(echo ${AMAZON_KEYS} | jq -r '.NextToken')

  KEY_NAME_ARR=( $(echo ${AMAZON_KEYS} | jq -r '.Parameters[].Name') )
  for n in "${KEY_NAME_ARR[@]}"
  do
    KEY_NAME="${n##*/}"
    chmod 600 "${HOME}/.ssh/${KEY_NAME}.pem" >> "${HOME}/.ssh/${KEY_NAME}.pem"
    echo ${AMAZON_KEYS} | jq -r \
      ".Parameters[] | select(.Name == \"/amazon/keys/${KEY_NAME}\") | .Value" > \
      ${HOME}/.ssh/${KEY_NAME}.pem
  done
done
