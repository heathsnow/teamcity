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

echo "Setting AWS_DEFAULT_REGION..."
METADATA_URL="http://169.254.169.254/latest/dynamic/instance-identity/document"
export AWS_DEFAULT_REGION="$(curl -s "${METADATA_URL}" | jq -r .region)"
if [ -z "${AWS_DEFAULT_REGION}" ]; then
  echo "Unable to set AWS_DEFAULT_REGION."
  exit 1
fi

echo "Setting GOCD_ADMIN_USER..."
GOCD_ADMIN_USER="$(aws ssm get-parameter \
  --query Parameter.Value --with-decryption --output text \
  --name /gocd/admin/user)"
if [ -z "${GOCD_ADMIN_USER}" ]; then
  echo "Unable to set GOCD_ADMIN_USER."
  exit 1
fi

echo "Setting GOCD_ADMIN_PASSWORD..."
GOCD_ADMIN_PASSWORD="$(aws ssm get-parameter \
  --name /gocd/admin/password \
  --query Parameter.Value --with-decryption --output text)"
if [ -z "${GOCD_ADMIN_PASSWORD}" ]; then
  echo "Unable to set GOCD_ADMIN_PASSWORD."
  exit 1
fi

echo "Setting GOCD_READ_USER..."
GOCD_READ_USER="$(aws ssm get-parameter \
  --name /gocd/read/user \
  --query Parameter.Value --with-decryption --output text)"
if [ -z "${GOCD_READ_USER}" ]; then
  echo "Unable to set GOCD_READ_USER."
  exit 1
fi

echo "Setting GOCD_READ_PASSWORD..."
GOCD_READ_PASSWORD="$(aws ssm get-parameter \
  --name /gocd/read/password \
  --query Parameter.Value --with-decryption --output text)"
if [ -z "${GOCD_READ_PASSWORD}" ]; then
  echo "Unable to set GOCD_READ_PASSWORD."
  exit 1
fi

echo "Adding GoCD local administrative account..."
sudo -u go htpasswd -B -c -i \
  /etc/go/.htpasswd ${GOCD_ADMIN_USER} <<< ${GOCD_ADMIN_PASSWORD}
sudo chmod 664 /etc/go/.htpasswd

echo "Adding GoCD local read only account..."
sudo -u go htpasswd -B -i \
  /etc/go/.htpasswd ${GOCD_READ_USER} <<< ${GOCD_READ_PASSWORD}
