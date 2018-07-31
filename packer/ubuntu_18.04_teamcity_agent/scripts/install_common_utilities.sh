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

install_pip_package () {
  local PACKAGE_NAME="${1}"

  echo "Installing ${PACKAGE_NAME}..."
  sudo pip install --upgrade "${PACKAGE_NAME}"
}

install_yarn () {
  echo "Installing yarn..."
  case $DISTRO in
    "debian")
      sudo apt-key adv --fetch-keys http://dl.yarnpkg.com/debian/pubkey.gpg
      echo "deb http://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
      sudo apt-get -y update
      sudo apt-get -y install yarn
      ;;
    "redhat")
      curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
      curl --silent --location https://rpm.nodesource.com/setup_6.x | bash -
      sudo yum install -y yarn
      ;;
  esac
}

main () {
  determine_linux_distribution
  install_system_package "curl"
  install_system_package "jq"
  install_system_package "pry"
  install_system_package "python-pip"
  install_system_package "screen"
  install_pip_package "awscli"
  install_yarn
}

main
