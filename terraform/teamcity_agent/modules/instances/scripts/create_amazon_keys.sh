#!/usr/bin/env bash
set -e

DESTINATION_DIR="/home/teamcity/.ssh/"
DESTINATION_OWNER="teamcity"
DESTINATION_GROUP="teamcity"

verify_variable () {
  if [ -z "${2}" ]; then
    printf "Unable to set ${1}.\n"
    exit 1
  fi
}

determine_linux_distribution () {
  printf "Determining Linux distribution...\n"
  if [ -x "$(command -v apt-get)" ]; then
    printf "Found apt-get, assuming Debian family...\n"
    DISTRO="debian"
  elif [ -x "$(command -v yum)" ]; then
    printf "Found yum, assuming Red Hat family...\n"
    DISTRO="redhat"
  else
    printf "Unable to determine Linux distribution.\n"
    exit 1
  fi
}

set_aws_default_region () {
  printf "Setting AWS_DEFAULT_REGION...\n"
  local METADATA_URL="http://169.254.169.254/latest/dynamic/instance-identity/document"
  export AWS_DEFAULT_REGION="$(curl -s "${METADATA_URL}" | jq -r .region)"
  verify_variable 'AWS_DEFAULT_REGION' "${AWS_DEFAULT_REGION}"
}

create_amazon_keys () {
  printf "Creating Amazon keys...\n"
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

    NEXT_TOKEN="$(printf "${AMAZON_KEYS}" | jq -r '.NextToken')"

    KEY_NAME_ARR=( $(printf "${AMAZON_KEYS}" | jq -r '.Parameters[].Name') )
    for n in "${KEY_NAME_ARR[@]}"
    do
      printf "Creating key '${KEY_NAME}.pem' in '${DESTINATION_DIR}'...\n"
      KEY_NAME="${n##*/}"
      chmod 600 "${HOME}/.ssh/${KEY_NAME}.pem" \
        >> "${HOME}/.ssh/${KEY_NAME}.pem"
      printf "${AMAZON_KEYS}" | jq -r \
        ".Parameters[] | select(.Name == \"/amazon/keys/${KEY_NAME}\") \
        | .Value" > "${HOME}/.ssh/${KEY_NAME}.pem"
      sudo mv "${HOME}/.ssh/${KEY_NAME}.pem" "${DESTINATION_DIR}/"
      sudo chown "${DESTINATION_OWNER}":"${DESTINATION_GROUP}" \
        "${DESTINATION_DIR}/${KEY_NAME}.pem"
    done
  done
}

main () {
  determine_linux_distribution
  set_aws_default_region
  create_amazon_keys
}

main
