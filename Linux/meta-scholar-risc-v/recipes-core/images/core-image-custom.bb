SUMMARY = "Custom dev image with SSH and build tools"
LICENSE = "MIT"

inherit core-image

FILESEXTRAPATHS:prepend := "${THISDIR}:"

IMAGE_INSTALL += "ip-config"
IMAGE_INSTALL += "dropbear-keygen-service"
IMAGE_INSTALL += "fpga-tools"
IMAGE_INSTALL += "dnsmasq"

IMAGE_FEATURES += "tools-debug"
IMAGE_FEATURES += "ssh-server-dropbear"

IMAGE_INSTALL += " \
    gcc \
    packagegroup-core-buildessential \
    g++ \
    make \
    binutils \
    libc-dev \
    pkgconfig \
    autoconf \
    automake \
    devmem2 \
    nano \
    kernel-modules \
    net-tools \
    iproute2 \
    iputils \
    ethtool \
    curl \
    wget \
    traceroute \
    parted \
    e2fsprogs \
    nmap \
    netcat \
    gzip \
    bzip2 \
    tar \
    strace \
    gdb \
    lsof \
    sudo \
    htop \
    iotop \
    sysstat \
    iw \
    usbutils \
"
