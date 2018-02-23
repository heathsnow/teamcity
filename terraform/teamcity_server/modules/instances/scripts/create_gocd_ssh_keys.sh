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

export GOCD_SSH_PROFILE_DIR="/var/go/.ssh/"

echo "Setting AWS_DEFAULT_REGION..."
METADATA_URL="http://169.254.169.254/latest/dynamic/instance-identity/document"
export AWS_DEFAULT_REGION="$(curl -s "${METADATA_URL}" | jq -r .region)"
if [ -z "${AWS_DEFAULT_REGION}" ]; then
  echo "Unable to set AWS_DEFAULT_REGION."
  exit 1
fi

echo "Setting GOCD_GITHUB_USER..."
GOCD_GITHUB_USER="$(aws ssm get-parameter \
  --name /github/read/user \
  --query Parameter.Value --with-decryption --output text)"
if [ -z "${GOCD_GITHUB_USER}" ]; then
  echo "Unable to set GOCD_GITHUB_USER."
  exit 1
fi

echo "Setting GOCD_GITHUB_PASSWORD..."
GOCD_GITHUB_PASSWORD="$(aws ssm get-parameter \
  --name /github/read/password \
  --query Parameter.Value --with-decryption --output text)"
if [ -z "${GOCD_GITHUB_PASSWORD}" ]; then
  echo "Unable to set GOCD_GITHUB_PASSWORD."
  exit 1
fi

echo "Generating SSH key pair for 'go' user..."
if sudo [ -e "${GOCD_SSH_PROFILE_DIR}id_rsa" ]; then
  echo "Key pair already exists."
else
  sudo -u go \
    ssh-keygen -t rsa -b 4096 -f "${GOCD_SSH_PROFILE_DIR}id_rsa" -q -N ''
fi

echo "Configuring SSH profile for 'go' user..."
if sudo [ -e "${GOCD_SSH_PROFILE_DIR}config" ]; then
  echo "SSH config already exists."
  rm -f /tmp/config
else
  sudo chown go:go /tmp/config
  sudo chmod 600 /tmp/config
  sudo mv -f /tmp/config "${GOCD_SSH_PROFILE_DIR}"
fi

echo "Adding GitHub SSH public key to known_hosts..."
sudo -u go touch "${GOCD_SSH_PROFILE_DIR}known_hosts"
sudo -u go ssh-keygen -R github.com &>/dev/null
ssh-keyscan -H github.com 2>/dev/null | \
  sudo tee --append "${GOCD_SSH_PROFILE_DIR}"known_hosts &>/dev/null

echo "Registering SSH key with GitHub..."
SSH_PUBLIC_KEY="$(sudo -u go \
  sed 's/\s\S*$//' "${GOCD_SSH_PROFILE_DIR}id_rsa.pub")"

AUTHORIZED_KEYS="$(curl -s -S \
  -u "${GOCD_GITHUB_USER}:${GOCD_GITHUB_PASSWORD}" \
  "https://api.github.com/user/keys")"

if [ "${AUTHORIZED_KEYS}" != "${AUTHORIZED_KEYS/$SSH_PUBLIC_KEY}" ]; then
  echo "SSH key has already been registered."
else
  POST_DATA="$(jq -n \
    --arg hostname "${HOSTNAME}" \
    --arg ssh_public_key "${SSH_PUBLIC_KEY}" \
    '{
       "title": $hostname,
       "key": $ssh_public_key
     }')"

  curl -s -S \
    -H "Content-Type: application/json" \
    -d "$POST_DATA" \
    -u "${GOCD_GITHUB_USER}:${GOCD_GITHUB_PASSWORD}" \
    "https://api.github.com/user/keys" &>/dev/null
fi
