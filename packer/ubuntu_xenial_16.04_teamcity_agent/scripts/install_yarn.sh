#!/bin/bash -eux

echo "==> Adding yarn to repositories"

sudo apt-key adv --fetch-keys http://dl.yarnpkg.com/debian/pubkey.gpg
echo "deb http://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

echo "==> Updating list of repository packages"
# apt-get update does not actually perform updates, it just downloads and indexes the list of packages
sudo apt-get -y update

echo "==> Performing install of nodejs and dependencies"
sudo apt-get -y install yarn
