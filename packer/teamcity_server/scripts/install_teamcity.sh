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

echo "Installing TeamCity server..."
case $DISTRO in
  "debian")
    sudo apt-get install -y openjdk-8-jre
    wget -P /tmp https://download.jetbrains.com/teamcity/TeamCity-${TEAMCITY_VERSION}.tar.gz
    sudo tar xzvf "/tmp/TeamCity-${TEAMCITY_VERSION}.tar.gz" -C /opt
    sudo mv /opt/TeamCity/ /opt/teamcity/
    rm -f "/tmp/TeamCity-${TEAMCITY_VERSION}.tar.gz"
    sudo adduser --disabled-login --no-create-home --shell /bin/false --gecos '' teamcity
    sudo chown -R root:teamcity /opt/teamcity/
    sudo mkdir /var/run/teamcity/
    sudo chown root:teamcity /var/run/teamcity/
    sudo chmod 775 /var/run/teamcity/
    sudo systemctl disable teamcity-server
    ;;
  "redhat")
    sudo yum install -y java-1.8.0-openjdk wget
    wget -P /tmp https://download.jetbrains.com/teamcity/TeamCity-${TEAMCITY_VERSION}.tar.gz
    sudo tar xzvf "/tmp/TeamCity-${TEAMCITY_VERSION}.tar.gz" -C /opt
    sudo mv /opt/TeamCity/ /opt/teamcity/
    rm -f "/tmp/TeamCity-${TEAMCITY_VERSION}.tar.gz"
    sudo adduser --disabled-login --no-create-home --shell /bin/false --gecos '' teamcity
    sudo chown -R root:teamcity /opt/teamcity/
    sudo mkdir /var/run/teamcity/
    sudo chown root:teamcity /var/run/teamcity/
    sudo chmod 775 /var/run/teamcity/
    sudo chkconfig teamcity-server off
    ;;
esac

echo "Installing TeamCity server init script..."
sudo chmod 644 /tmp/teamcity-server.service
sudo chown root:root /tmp/teamcity-server.service
sudo mv -f /tmp/teamcity-server.service /lib/systemd/system/

echo "Installing NGINX..."
case $DISTRO in
  "debian")
    sudo apt-get install -y nginx
    ;;
  "redhat")
    sudo yum install -y nginx
    ;;
esac

echo "Updating NGINX configuration..."
sudo chmod 644 /tmp/default
sudo chown root:root /tmp/default
sudo mv -f /tmp/default /etc/nginx/sites-available/
