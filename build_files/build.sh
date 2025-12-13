#!/bin/bash

set -ouex pipefail

pushd "$(dirname "${BASH_SOURCE[0]}")"
source ./pkg_setup.sh
source ./svc.sh

# Source package setup script and call function
setup_packages

# Setup systemd
svcs



