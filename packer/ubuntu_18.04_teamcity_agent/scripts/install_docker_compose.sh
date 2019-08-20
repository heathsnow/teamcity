#!/usr/bin/env bash
set -e

determine_linux_distribution () {
  echo "Determining Linux distribution..."
  if [ -x "$(command -v apt-get)" ]; then
    echo "Found apt-get, assuming Debian family..."
    DISTRO="debian"
  elif [ -x "$(command -v yum)" ]; then
    echo "Found yum, assuming Red Hat family..."
    DISTRO="redhat"
  else
    echo "Unable to determine Linux distribution."
    exit 1
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

install_docker_compose () {
  local VERSION="${1}"
  local INSTALLATION_DIR="${2}"

  echo "Installing Docker Compose ${VERSION}..."

  if [ "${DISTRO}" != "debian" ]; then
    echo "Docker Compose can only be installed on Debian family distributions."
    exit 1
  fi

  local URL="https://github.com/docker/compose/releases/download/${VERSION}/"
  URL+="docker-compose-Linux-x86_64"

  sudo curl -L "${URL}" -o "${INSTALLATION_DIR}/docker-compose"
  sudo chmod 755 "${INSTALLATION_DIR}/docker-compose"
}

main () {
  local DOCKER_COMPOSE_INSTALLATION_DIR="/usr/local/bin"

  determine_linux_distribution
  verify_variable_exists "DOCKER_COMPOSE_VERSION"
  install_docker_compose "${DOCKER_COMPOSE_VERSION}" "${DOCKER_COMPOSE_INSTALLATION_DIR}"
}

main
