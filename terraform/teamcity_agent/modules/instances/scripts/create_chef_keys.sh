#!/usr/bin/env bash
set -e

DESTINATION_DIR="/etc/chef/"
DESTINATION_OWNER="root"
DESTINATION_GROUP="root"

verify_variable () {
  if [ -z "${2}" ]; then
    echo "Unable to set ${1}."
    exit 1
  fi
}

get_ssm_parameter_value () {
  local NAME="${1}"

  aws ssm get-parameter \
    --name "${NAME}" \
    --query "Parameter.Value" \
    --output "text" \
    --with-decryption
}

print_script_name () {
  echo "Running '${0##*/}'..."
}

set_aws_default_region () {
  echo "Setting AWS_DEFAULT_REGION..."
  local METADATA_URL="http://169.254.169.254/latest/dynamic/instance-identity/document"
  export AWS_DEFAULT_REGION="$(curl -s "${METADATA_URL}" | jq -r .region)"
  verify_variable 'AWS_DEFAULT_REGION' "${AWS_DEFAULT_REGION}"
}

create_key () {
  local PARAMETER_NAME="${1}"
  local FILE_NAME="${2}"

  echo "Creating key '${FILE_NAME}' in '${DESTINATION_DIR}'..."
  local VALUE="$(get_ssm_parameter_value "${PARAMETER_NAME}")"

  sudo mkdir -p "${DESTINATION_DIR}/" &>/dev/null
  sudo chown "${DESTINATION_OWNER}":"${DESTINATION_GROUP}" "${DESTINATION_DIR}/"
  sudo chmod 700 "${DESTINATION_DIR}/"
  printf "%s" "${VALUE}" | \
    sudo -u "${DESTINATION_OWNER}" \
    tee "${DESTINATION_DIR}/${FILE_NAME}" &>/dev/null
  sudo chmod 600 "${DESTINATION_DIR}/${FILE_NAME}"
}

main () {
  print_script_name
  set_aws_default_region
  create_key "/chef/keys/deploysvc" "deploysvc.pem"
  create_key "/chef/keys/dev-encrypted-data-bag-secret" "encrypted_data_bag_secret"
}

main
