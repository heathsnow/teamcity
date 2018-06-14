#!/usr/bin/env bash
set -e

# Some programs fail or throw warnings if the hostname cannot be resolved.
#
# An example of a program that may fail is 'collectd'.
# An example of a program that may throw warnings is 'sudo'.
#
# This script disables hostname resolution by removing the hostname as an alias
# for the loopback interface (127.0.0.1) in /etc/hosts.
#
# Always run 'enable_hostname_resolution.sh' first in sequence to ensure smooth
# execution of subsequent Packer provisioning scripts on Linux.
#
# Always run this script last in sequence to remove the modifications to
# /etc/hosts since they will not be valid for any machines built from the
# resultant Packer image.

echo "Removing hostname from /etc/hosts..."
sudo sed -i "s/ ${HOSTNAME}//g" /etc/hosts
