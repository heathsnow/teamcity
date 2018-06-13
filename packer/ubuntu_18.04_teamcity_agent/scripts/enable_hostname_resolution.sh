#!/usr/bin/env bash
set -e

# Some programs fail or throw warnings if the hostname cannot be resolved.
#
# An example of a program that may fail is 'collectd'.
# An example of a program that may throw warnings is 'sudo'.
#
# This script enables hostname resolution by adding the hostname as an alias
# for the loopback interface (127.0.0.1) in /etc/hosts.
#
# Always run this script first in sequence to ensure smooth execution of
# subsequent Packer provisioning scripts on Linux.
#
# Always run 'disable_hostname_resolution.sh' last in sequence to remove the
# modifications to /etc/hosts since they will not be valid for any machines
# built from the resultant Packer image.

echo "Adding hostname to /etc/hosts..."
sudo sed -i "/127.0.0.1.*/s/$/ $HOSTNAME/" /etc/hosts &>/dev/null
