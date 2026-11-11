#!/bin/bash

# Define packages to install outside function scope
package_list=(
    nano
    btop
    micro
    fastfetch
    zellij
    btrfsd
    cockpit
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
    containernetworking-plugins
    ceph-common
    cephfs-shell
    cephfs-top
    ceph-selinux
    ceph-volume
    ceph-test
    samba-vfs-cephfs
    libcephsqlite
    nfs-ganesha-ceph
    tuned
    tuned-profiles-atomic
    tuned-profiles-realtime
    tuned-switcher
    tuned-utils
    # Upstream Kubernetes, for the kubeadm migration. These come from
    # pkgs.k8s.io via the repo copied in below, not from Fedora.
    #
    # kubelet.service is deliberately NOT enabled -- see 00-homelab.preset. Both
    # it and k3s's kubelet bind 10250, so they cannot run at once; until the
    # migration cuts over these are just binaries on disk.
    kubelet
    kubeadm
    kubectl
    # CNI plugins to /opt/cni/bin and crictl. Fedora does not carry
    # kubernetes-cni, and its containernetworking-plugins land in
    # /usr/libexec/cni, so the two do not collide.
    kubernetes-cni
    cri-tools
    # Hypervisors. cloud-hypervisor is the point here, and the only reason
    # this block exists: it comes from terra (54.1, matching upstream v54.1)
    # because Fedora ships only libvirt's cloud-hypervisor *driver*, never the
    # VMM. The package carries cloud-hypervisor, ch-remote and the vhost-user
    # backends (vhost_user_block, vhost_user_net), which is the full surface for
    # driving VMs through its own API rather than through libvirt.
    #
    # edk2-cloud-hypervisor-bin is CLOUDHV.fd. cloud-hypervisor has no legacy
    # BIOS path, so a UEFI firmware is mandatory for any guest that boots.
    #
    # The libvirt and qemu packages listed after it are ALREADY IN THE BASE
    # IMAGE (checked against ucore-hci's own rpm list, which carries
    # libvirt-daemon-kvm, qemu-kvm-core, virt-install, swtpm, edk2-ovmf and
    # virtiofsd). They are named anyway so a base-image change cannot silently
    # take them away, but do not read this block as what adds weight -- the
    # only genuinely new entries here are cloud-hypervisor,
    # edk2-cloud-hypervisor-bin and libvirt-daemon-driver-ch.
    #
    # libvirt-daemon-config-network is also in the base already, so the default
    # 192.168.122.0/24 NAT network is defined whether or not it is named here;
    # it is left out of this list rather than removed, which would mean deleting
    # it from the base image.
    cloud-hypervisor
    edk2-cloud-hypervisor-bin
    libvirt
    libvirt-client
    libvirt-daemon-kvm
    libvirt-daemon-driver-ch
    virt-install
    qemu-kvm-core
    swtpm
    edk2-ovmf
    virtiofsd
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
    mkdir -p /tmp/k3s-systemd/
    # Don't actually install anything
    export INSTALL_K3S_SYSTEMD_DIR="/tmp/k3s-systemd"
    export INSTALL_K3S_SKIP_ENABLE=true
    export INSTALL_K3S_SKIP_START=true
    export INSTALL_K3S_CHANNEL=latest
    curl -sfL https://get.k3s.io | sh - 
    rm -rf /tmp/k3s-systemd
    
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

    # The kubernetes.repo that ships in the image is staged into /ctx by the
    # Containerfile and only copied into / by the svc stage, which runs after
    # this one. Put it in place here so the install below can resolve it.
    # Keep the version in sync with that file.
    mkdir -p /etc/yum.repos.d
    cp /ctx/root/etc/yum.repos.d/kubernetes.repo /etc/yum.repos.d/kubernetes.repo

    # Get version
    VERSION_ID=$(grep -oP '(?<=VERSION_ID=)[^"]*' /etc/os-release)
    
    # remove cockpit quadlet from ucore
    # UCore comes with the Quadlet version of Cockpit which... does not work well
    rm -f /usr/lib/systemd/system/cockpit.service

    # Install packages
    dnf5 install -y --nogpgcheck "${package_list[@]}"
    install_kompose
    install_k3s
}

# If this script is being executed directly, run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_packages
fi