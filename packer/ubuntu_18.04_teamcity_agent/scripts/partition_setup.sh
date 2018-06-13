#!/usr/bin/env bash
set -e

echo "Creating LINUX_SWAP partition /dev/xvdf1 on disk /dev/xvdf..."
echo ',,S' | sudo sfdisk --label gpt /dev/xvdf

echo "Formatting /dev/xvdf1 as swap..."
sudo mkswap /dev/xvdf1

echo "Adding fstab entry to mount /dev/xvdf1 as swap..."
echo '/dev/xvdf1 none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null

echo "Enabling swap..."
sudo swapon /dev/xvdf1

echo "Creating LINUX_NATIVE partition /dev/xvdg1 on disk /dev/xvdg..."
echo ';' | sudo sfdisk --label gpt /dev/xvdg

echo "Formatting /dev/xvdg1 as ext4..."
sudo mkfs.ext4 /dev/xvdg1

echo "Adding fstab entry to mount /dev/xvdg1 as /var/log..."
echo '/dev/xvdg1 /var/log ext4 defaults,nofail 0 1' | sudo tee -a /etc/fstab > /dev/null

echo "Mounting /var/log..."
sudo mount /var/log

echo "Creating LINUX_NATIVE partition /dev/xvdh1 on disk /dev/xvdh..."
echo ';' | sudo sfdisk --label gpt /dev/xvdh

echo "Formatting /dev/xvdh1 as ext4..."
sudo mkfs.ext4 /dev/xvdh1

echo "Adding fstab entry to mount /dev/xvdh1 as /home..."
echo '/dev/xvdh1 /home ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab > /dev/null

echo "Mounting /home..."
sudo mount /home
