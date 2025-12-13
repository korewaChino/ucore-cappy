# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/ucore-hci:stable-nvidia

RUN mkdir -p /etc/rancher/k3s /var/lib/rancher/k3s /var/lib/rancher/k3s
RUN if [ -f /etc/sysconfig/selinux ]; then \
        sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/sysconfig/selinux || echo "Failed to update SELinux configuration file."; \
    fi

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    pushd /ctx && \
    source ./pkg_setup.sh && \
    setup_packages

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    pushd /ctx && \
    source ./svc.sh && \
    svcs

RUN ostree container commit

### LINTING
## Verify final image and contents are correct.
# RUN bootc container lint
