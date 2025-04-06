#!/bin/bash

# Define packages to install outside function scope
package_list=(
    nano
    btop
    micro
    fastfetch
    zellij
    btrfsd
    cockpit-ostree
    cockpit-packagekit
    cockpit-selinux
    cockpit-system
    cockpit-storaged
    pv
    https://github.com/k3s-io/k3s-selinux/releases/download/v1.6.latest.1/k3s-selinux-1.6-1.coreos.noarch.rpm
    btrfs-heatmap
    mailx
    postfix
    vim
    git
    curl
    htop
    smartmontools
    smartmontools-selinux
    zoxide
    jq
    bat
    bat-extras
    catimg
)

# Function to install packages and setup repositories
setup_packages() {
    set -ouex pipefail

    ### Install packages

    # Packages can be installed from any enabled yum repo on the image.
    # RPMfusion repos are available by default in ublue main images
    # List of rpmfusion packages can be found here:
    # https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1
    dnf5 install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release terra-release-extras "dnf5-command(config-manager)"

    # Get version
    VERSION_ID=$(grep -oP '(?<=VERSION_ID=)[^"]*' /etc/os-release)
    # rpm --import https://repos.fyralabs.com/terra${VERSION_ID}/key.asc

    # HACK: workaround for dnf5#2134
    dnf5 config-manager setopt terra-nvidia.enabled=1 terra-nvidia.repo_gpgcheck=0 terra.repo_gpgcheck=0

    # Install packages
    dnf5 install -y --nogpgcheck "${package_list[@]}"
}

# If this script is being executed directly, run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_packages
fi