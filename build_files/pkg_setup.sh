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
    ncdu
    cyrus-sasl
    cyrus-sasl-plain
    bees
    borgbackup
    glances
    netcat
    nss-mdns
    avahi
    etcd
    cri-o
)

install_kompose() {
    KOMPOSE_VERSION="v1.37.0"
    TMP_DIR=$(mktemp -d)
    pushd "$TMP_DIR" || exit 1
    curl -L https://github.com/kubernetes/kompose/releases/download/${KOMPOSE_VERSION}/kompose-linux-amd64 -o kompose
    chmod +x kompose
    mv kompose /usr/bin/kompose
}

install_k3s() {
    # We already install k3s-selinux above, so skip that step here
    export INSTALL_K3S_SKIP_SELINUX_RPM=true
    export INSTALL_K3S_BIN_DIR="/usr/bin"
    # Don't actually install anything
    export INSTALL_K3S_SYSTEMD_DIR="/tmp/k3s-systemd"
    
}

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

    # Install packages
    dnf5 install -y --nogpgcheck "${package_list[@]}"
    install_kompose
}

# If this script is being executed directly, run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_packages
fi