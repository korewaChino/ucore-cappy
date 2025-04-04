#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1
dnf5 install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release terra-release-extras "dnf5-command(config-manager)"
# this installs a package from fedora repos
# get version
VERSION_ID=$(grep -oP '(?<=VERSION_ID=)[^"]*' /etc/os-release)
# rpm --import https://repos.fyralabs.com/terra${VERSION_ID}/key.asc
# HACK: workaround for dnf5#2134
dnf5 config-manager setopt terra-nvidia.enabled=1 terra-nvidia.repo_gpgcheck=0 terra.repo_gpgcheck=0
dnf5 install -y --nogpgcheck \
    nano \
    btop \
    micro \
    fastfetch \
    zellij \
    btrfsd \
    btrfs-heatmap
    
systemctl disable firewalld
systemctl enable cockpit
    
# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File
