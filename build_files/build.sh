#!/bin/bash

set -ouex pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")"
source ./pkg_setup.sh
source ./svc.sh

# Source package setup script and call function
setup_packages

# Setup systemd
svcs



mkdir -p /etc/rancher/k3s /var/lib/rancher/k3s /var/lib/rancher/k3s

# HACK: Set SELinux to permissive mode
# This shouldn't be necessary since we install k3s-selinux, but for some reason some services just don't like
# it anyways.

if [ -f /etc/sysconfig/selinux ]; then
    sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/sysconfig/selinux || echo "Failed to update SELinux configuration file."
fi
