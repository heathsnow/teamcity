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

echo "Installing curl..."
case $DISTRO in
  "debian")
    sudo apt-get install -y curl
    ;;
  "redhat")
    sudo yum install -y curl
    ;;
esac

echo "Installing jq..."
case $DISTRO in
  "debian")
    sudo apt-get install -y jq
    ;;
  "redhat")
    sudo yum install -y jq
    ;;
esac

echo "Installing pry..."
case $DISTRO in
  "debian")
    sudo apt-get install -y pry
    ;;
  "redhat")
    sudo yum install -y pry
    ;;
esac

echo "Installing python-pip..."
case $DISTRO in
  "debian")
    sudo apt-get install -y python-pip
    ;;
  "redhat")
    sudo yum install -y python-pip
    ;;
esac

echo "Installing screen..."
case $DISTRO in
  "debian")
    sudo apt-get install -y screen
    ;;
  "redhat")
    sudo yum install -y screen
    ;;
esac

echo "Installing aws-cli..."
sudo pip install --upgrade awscli
