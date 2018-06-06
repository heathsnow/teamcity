# Packer Scripts for Visual Studio

## delete-cached-installation-packages.ps1

Deletes installation packages from the Chef cache.

## install-build-tools-via-offline-installer.ps1

Installs the Build Tools for VS using the latest offline installer available in Artifactory.

### Notes
- Use parameter `-InstallerArchiveFilePath` to specify a local file path to the
installer. This avoids continually downloading the large installer during
development and debugging.
- The script supports both `-Verbose` and `-WhatIf` for debugging.

## create-build-tools-offline-installer.ps1

Creates a new offline installer of the Build Tools for VS and uploads it to Artifactory.

### Notes
- The workloads added to the offline installer are documented in the script.
- While the script can be used locally, it is primarily intended to be run in a TeamCity build. Use the `-TeamCity` switch to specify logging in TeamCity format.
- Only the output of this script is used by Packer; the above script does the actual installing.
- The script supports `-Verbose` for debugging.
