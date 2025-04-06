#!/bin/bash

# Set up systemd services

set -ouex pipefail


svcs() {
    local preset_file="homelab.preset"

    # Ensure the target directory exists
    mkdir -p /usr/lib/systemd/system-preset/

    # Copy the preset file to the systemd preset directory
    cp $preset_file /usr/lib/systemd/system-preset/


    # Install some systemd dropin files
    mkdir -p /usr/lib/systemd/system

    cp -av systemd/. /usr/lib/systemd/system/
}
