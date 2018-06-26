#!/usr/bin/env bash
set -e

DESTINATION_DIR="/home/teamcity/.ssh/"
DESTINATION_OWNER="teamcity"
DESTINATION_GROUP="teamcity"

verify_variable () {
  if [ -z "${2}" ]; then
    echo "Unable to set ${1}."
    exit 1
  fi
}

print_script_name () {
  echo "Running 'create_amazon_keys.sh'..."
}

set_aws_default_region () {
  echo "Setting AWS_DEFAULT_REGION..."
  local METADATA_URL="http://169.254.169.254/latest/dynamic/instance-identity/document"
  export AWS_DEFAULT_REGION="$(curl -s "${METADATA_URL}" | jq -r .region)"
  verify_variable 'AWS_DEFAULT_REGION' "${AWS_DEFAULT_REGION}"
}

create_amazon_keys () {
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

    NEXT_TOKEN="$(echo "${AMAZON_KEYS}" | jq -r '.NextToken')"

    KEY_NAME_ARR=( $(echo "${AMAZON_KEYS}" | jq -r '.Parameters[].Name') )
    for n in "${KEY_NAME_ARR[@]}"
    do
      KEY_NAME="${n##*/}"
      echo "Creating key '${KEY_NAME}.pem' in '${DESTINATION_DIR}'..."
      chmod 600 "${HOME}/.ssh/${KEY_NAME}.pem" \
        >> "${HOME}/.ssh/${KEY_NAME}.pem"
      echo "${AMAZON_KEYS}" | jq -r \
        ".Parameters[] | select(.Name == \"/amazon/keys/${KEY_NAME}\") \
        | .Value" > "${HOME}/.ssh/${KEY_NAME}.pem"
      sudo mv "${HOME}/.ssh/${KEY_NAME}.pem" "${DESTINATION_DIR}/"
      sudo chown "${DESTINATION_OWNER}":"${DESTINATION_GROUP}" \
        "${DESTINATION_DIR}/${KEY_NAME}.pem"
    done
  done
}

main () {
  print_script_name
  set_aws_default_region
  create_amazon_keys
}

main
