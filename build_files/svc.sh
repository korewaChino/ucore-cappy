#!/bin/bash

# Set up systemd services

set -ouex pipefail


svcs() {
    local preset_file="/ctx/00-homelab.preset"

    # Ensure the target directory exists
    mkdir -p /usr/lib/systemd/system-preset/

    # Copy the preset file to the systemd preset directory
    cp $preset_file /usr/lib/systemd/system-preset/

    # Install some systemd dropin files
    mkdir -p /usr/lib/systemd/system

    cp -av /ctx/systemd/. /usr/lib/systemd/system/


    cp -av /ctx/root/. /.
    systemctl preset-all
    systemctl enable vt-blank.service
    systemctl enable vt-blank.timer
    systemctl mask zincati.service
    systemctl disable firewalld.service
    systemctl mask setroubleshootd
    systemctl enable avahi-daemon.socket
}
