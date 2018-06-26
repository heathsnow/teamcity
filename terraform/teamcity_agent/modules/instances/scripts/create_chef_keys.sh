#!/usr/bin/env bash
set -e

DESTINATION_DIR="/home/teamcity/.chef/"
DESTINATION_OWNER="teamcity"
DESTINATION_GROUP="teamcity"

verify_variable () {
  if [ -z "${2}" ]; then
    printf "Unable to set ${1}.\n"
    exit 1
  fi
}

get_ssm_parameter_value () {
  local NAME="${1}"

  aws ssm get-parameter \
    --name "${NAME}" \
    --query "Parameter.Value" \
    --with-decryption
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

create_key () {
  local PARAMETER_NAME="${1}"
  local FILE_NAME="${2}"

  printf "Creating key '${FILE_NAME}' in '${DESTINATION_DIR}'...\n"
  local VALUE="$(get_ssm_parameter_value "${PARAMETER_NAME}")"

  sudo mkdir "${DESTINATION_DIR}/" &>/dev/null
  sudo chown "${DESTINATION_OWNER}":"${DESTINATION_GROUP}" "${DESTINATION_DIR}/"
  sudo chmod 700 "${DESTINATION_DIR}/"
  printf "${VALUE}" | \
    sudo -u "${DESTINATION_OWNER}" \
    tee "${DESTINATION_DIR}/${FILE_NAME}" &>/dev/null
  sudo chmod 600 "${DESTINATION_DIR}/${FILE_NAME}"
}

main () {
  determine_linux_distribution
  set_aws_default_region
  create_key "/chef/keys/deploysvc" "deploysvc.pem"
  create_key "/chef/keys/dev-encrypted-data-bag-secret" "encrypted_data_bag_secret"
}

main
