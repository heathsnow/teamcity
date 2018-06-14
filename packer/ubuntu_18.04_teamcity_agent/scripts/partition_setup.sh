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

echo "Installing rsync..."
case $DISTRO in
  "redhat")
    sudo yum install -y rsync
    ;;
esac

#
# Create a swap partition:
#

echo "Creating LINUX_SWAP partition /dev/xvdf1 on disk /dev/xvdf..."
echo ',,S' | sudo sfdisk --label gpt /dev/xvdf

echo "Formatting /dev/xvdf1 as swap..."
sudo mkswap /dev/xvdf1

echo "Adding fstab entry to mount /dev/xvdf1 as swap..."
echo '/dev/xvdf1 none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null

echo "Enabling swap..."
sudo swapon /dev/xvdf1

#
# Create a partition for /var/log:
#

echo "Creating LINUX_NATIVE partition /dev/xvdg1 on disk /dev/xvdg..."
echo ';' | sudo sfdisk --label gpt /dev/xvdg

echo "Formatting /dev/xvdg1 as ext4..."
sudo mkfs.ext4 /dev/xvdg1

echo "Adding fstab entry to mount /dev/xvdg1 as /var/log..."
echo '/dev/xvdg1 /var/log ext4 defaults,nofail 0 1' | \
  sudo tee -a /etc/fstab > /dev/null

echo "Mounting /dev/xvdg1 as /mnt/log..."
sudo mkdir /mnt/log
sudo mount /dev/xvdg1 /mnt/log

echo "Migrating data from /var/log to /mnt/log..."
sudo rsync -aXS /var/log/. /mnt/log/.

echo "Dismounting /mnt/log..."
sudo umount /mnt/log
sudo rmdir /mnt/log

#
# Create a partition for /home:
#

echo "Creating LINUX_NATIVE partition /dev/xvdh1 on disk /dev/xvdh..."
echo ';' | sudo sfdisk --label gpt /dev/xvdh

echo "Formatting /dev/xvdh1 as ext4..."
sudo mkfs.ext4 /dev/xvdh1

echo "Adding fstab entry to mount /dev/xvdh1 as /home..."
echo '/dev/xvdh1 /home ext4 defaults,nofail 0 2' | \
  sudo tee -a /etc/fstab > /dev/null

echo "Mounting /dev/xvdh1 as /mnt/home..."
sudo mkdir /mnt/home
sudo mount /dev/xvdh1 /mnt/home

echo "Migrating data from /home to /mnt/home..."
sudo rsync -aXS /home/. /mnt/home/.

echo "Dismounting /mnt/home..."
sudo umount /mnt/home
sudo rmdir /mnt/home

#
# Remount all file systems to complete partition setup:
#

echo "Remounting all filesystems..."
sudo mount -a
