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

install_system_package () {
  local PACKAGE_NAME="${1}"

  echo "Installing ${PACKAGE_NAME}..."
  case ${DISTRO} in
    "debian")
      sudo DEBIAN_FRONTEND="noninteractive" apt install -y "${PACKAGE_NAME}"
      ;;
    "redhat")
      sudo yum install -y "${PACKAGE_NAME}"
      ;;
  esac
}

disable_service () {
  local SERVICE_NAME="${1}"

  echo "Disabling service '${SERVICE_NAME}'..."
  case ${DISTRO} in
    "debian")
      sudo systemctl disable "${SERVICE_NAME}"
      ;;
    "redhat")
      sudo chkconfig "${SERVICE_NAME}" off
      ;;
  esac
}

enable_service () {
  local SERVICE_NAME="${1}"

  echo "Enabling service '${SERVICE_NAME}'..."
  case ${DISTRO} in
    "debian")
      sudo systemctl enable "${SERVICE_NAME}"
      ;;
    "redhat")
      sudo chkconfig "${SERVICE_NAME}" on
      ;;
  esac
}

stop_service () {
  local SERVICE_NAME="${1}"

  echo "Stopping service '${SERVICE_NAME}'..."
  case ${DISTRO} in
    "debian")
      sudo systemctl start "${SERVICE_NAME}"
      ;;
    "redhat")
      sudo service "${SERVICE_NAME}" stop
      ;;
  esac
}

install_docker () {
  echo "Installing Docker..."

  if [ "${DISTRO}" != "debian" ]; then
    echo "Docker can only be installed on Debian family distributions."
    exit 1
  fi

  install_system_package "apt-transport-https"
  install_system_package "ca-certificates"
  install_system_package "curl"
  install_system_package "software-properties-common"

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo apt-key add -
  sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
  install_system_package "docker-ce"
}

remove_docker_data () {
  local DATA_DIR="${1}"

  stop_service "docker"
  echo "Removing Docker data in '${DATA_DIR}'..."
  verify_variable_exists "DATA_DIR"
  sudo rm -rf ${DATA_DIR}/*
}

main () {
  local DOCKER_DATA_DIR="/var/lib/docker"

  determine_linux_distribution
  install_docker
  disable_service "docker"
  remove_docker_data "${DOCKER_DATA_DIR}"
}

main
