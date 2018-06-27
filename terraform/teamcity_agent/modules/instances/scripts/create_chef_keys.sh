#!/usr/bin/env bash
set -e

DESTINATION_DIR="/etc/chef/"
DESTINATION_DIR_PERMISSIONS="755"
DESTINATION_FILE_PERMISSIONS="644"
DESTINATION_OWNER="root"
DESTINATION_GROUP="root"
SYMLINK_NAME="/home/teamcity/.chef"
SYMLINK_OWNER="teamcity"

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
  local NAME="${1}"

  if [ -z "${NAME}" ]; then
    echo "Running '${0##*/}'..."
  else
    echo "Running '${NAME}'..."
  fi
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
  sudo chmod "${DESTINATION_DIR_PERMISSIONS}" "${DESTINATION_DIR}/"
  printf "%s" "${VALUE}" | \
    sudo -u "${DESTINATION_OWNER}" \
    tee "${DESTINATION_DIR}/${FILE_NAME}" &>/dev/null
  sudo chmod "${DESTINATION_FILE_PERMISSIONS}" "${DESTINATION_DIR}/${FILE_NAME}"
}

create_symlink_to_destination_dir () {
  echo "Creating symlink '${SYMLINK_NAME}' to location '${DESTINATION_DIR}'..."
  sudo -u "${SYMLINK_OWNER}" ln -fns "${DESTINATION_DIR}" "${SYMLINK_NAME}"
}

main () {
  print_script_name "create_chef_keys.sh"
  set_aws_default_region
  create_key "/chef/keys/deploysvc" "deploysvc.pem"
  create_key "/chef/keys/dev-encrypted-data-bag-secret" "encrypted_data_bag_secret"
  create_symlink_to_destination_dir
}

main
