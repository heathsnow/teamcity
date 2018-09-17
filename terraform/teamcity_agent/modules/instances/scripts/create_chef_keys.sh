#!/usr/bin/env bash
set -e

print_script_name () {
  local NAME="${1}"

  if [ -z "${NAME}" ]; then
    echo "Running '${0##*/}'..."
  else
    echo "Running '${NAME}'..."
  fi
}

verify_bash_version () {
  local REQUIRED_VERSION="${1}"

  local REQUIRED_MAJOR="$(printf "${REQUIRED_VERSION}" | cut -d '.' -f 1)"
  local REQUIRED_MINOR="$(printf "${REQUIRED_VERSION}" | cut -d '.' -f 2)"
  local ACTUAL_MAJOR="${BASH_VERSINFO[0]}"
  local ACTUAL_MINOR="${BASH_VERSINFO[1]}"

  if [ "${ACTUAL_MAJOR}" -lt "${REQUIRED_MAJOR}" ]; then
    printf "Bash ${REQUIRED_VERSION} is required, "
    printf "but ${BASH_VERSION} is installed.\n"
    exit 1
  elif [ "${ACTUAL_MINOR}" -lt "${REQUIRED_MINOR}" ]; then
    printf "Bash ${REQUIRED_VERSION} is required, "
    printf "but ${BASH_VERSION} is installed.\n"
    exit 1
  fi
}

verify_variable_exists () {
  # Note: This function uses 'nameref' variables, introduced in bash 4.3.
  verify_bash_version "4.3"

  local VARIABLE_NAME="${1}"
  local -n VARIABLE_VALUE="${1}"

  if [ -z "${VARIABLE_VALUE}" ]; then
    echo "Variable '${VARIABLE_NAME}' is empty."
    exit 1
  fi
}

verify_network_connectivity () {
  local RETRY_DELAY_SEC="10"
  local RETRY_COUNT="60"

  echo "Verifying network connectivity..."
  local DNS_SERVER="$(systemd-resolve --status \
    | grep -i -m 1 -o 'DNS Servers.*' \
    | cut -d ' ' -f 3)"

  if [ -z "${DNS_SERVER}" ]; then
    echo "Unable to determine DNS server address."
    exit 1
  fi

  until ping -c 1 -q -w 1 "${DNS_SERVER}" > /dev/null
  do
    if [ "${RETRY_COUNT}" -ge "1" ]; then
      echo "Unable to ping DNS server ${DNS_SERVER}, pausing ${RETRY_DELAY_SEC}sec..."
      echo "Retries remaining: ${RETRY_COUNT}"
      sleep "${RETRY_DELAY_SEC}"
      ((RETRY_COUNT--))
    else
      echo "Network is still unavailable, aborting..."
      exit 1
    fi
  done
}

get_ssm_parameter_value () {
  local NAME="${1}"

  aws ssm get-parameter \
    --name "${NAME}" \
    --query "Parameter.Value" \
    --output "text" \
    --with-decryption
}

set_aws_default_region () {
  echo "Setting AWS_DEFAULT_REGION..."
  local METADATA_URL="http://169.254.169.254/latest/dynamic/instance-identity/document"
  export AWS_DEFAULT_REGION="$(curl -s "${METADATA_URL}" | jq -r .region)"
  verify_variable_exists "AWS_DEFAULT_REGION"
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
    sed 's/- /-\n/g' | \
    sed 's/ -/\n-/g' | \
    sed '/^-/! s/ /\n/g' | \
    sudo -u "${DESTINATION_OWNER}" \
    tee "${DESTINATION_DIR}/${FILE_NAME}" &>/dev/null
  sudo chmod "${DESTINATION_FILE_PERMISSIONS}" "${DESTINATION_DIR}/${FILE_NAME}"
}

main () {
  DESTINATION_DIR="/etc/chef/"
  DESTINATION_DIR_PERMISSIONS="755"
  DESTINATION_FILE_PERMISSIONS="644"
  DESTINATION_OWNER="root"
  DESTINATION_GROUP="root"

  print_script_name "create_chef_keys.sh"
  set_aws_default_region
  create_key "/chef/keys/deploysvc" "deploysvc.pem"
  create_key "/chef/keys/dev-encrypted-data-bag-secret" "encrypted_data_bag_secret"
  create_key "/chef/keys/ops-encrypted-data-bag-secret" "ops_encrypted_data_bag_secret"
}

main
