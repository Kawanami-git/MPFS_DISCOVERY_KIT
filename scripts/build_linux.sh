#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# /*!
# ********************************************************************************
# \file       build_linux.sh
# \brief      Yocto-based Linux build helper for the MPFS Discovery Kit.
# \author     Kawanami
# \version    1.0
# \date       26/10/2025
#
# \details
#   Prepares a working tree, clones/syncs PolarFire SoC Yocto manifests with
#   `repo`, sources the BSP setup, copies a custom meta-layer, adds it to the build,
#    and kicks off a deterministic build of `core-image-custom` for `mpfs-disco-kit`.
#    Also cleans sstate for a few custom recipes before the build.
#
# \remarks
#   - Requires: apt-get install gawk wget git-core git-lfs diffstat unzip texinfo gcc-multilib \
#               build-essential chrpath socat cpio python3 python3-pip python3-pexpect \
#               xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev \
#               pylint3 xterm repo
#   - Arguments:
#       1) WORK_DIR
#       2) MPFS_DISCOVERY_KIT_LINUX_DIR
#       3) MPFS_DISCOVERY_KIT_YOCTO_DIR
#       4) MPFS_DISCOVERY_KIT_LAYER_DIR
#
# \section build_linux_sh_version_history Version history
# | Version | Date       | Author     | Description      |
# |:-------:|:----------:|:-----------|:-----------------|
# | 1.0     | 26/10/2025 | Kawanami   | Initial version. |
# ********************************************************************************
# */

set -eo pipefail

# === Argument validation ===
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <WORK_DIR> <MPFS_DISCOVERY_KIT_LINUX_DIR> <MPFS_DISCOVERY_KIT_YOCTO_DIR> <MPFS_DISCOVERY_KIT_LAYER_DIR>"
    exit 1
fi

# == Temporarily disable AppArmor restriction on unprivileged user namespaces ==
orig_aa="$(cat /proc/sys/kernel/apparmor_restrict_unprivileged_userns 2>/dev/null || true)"
echo 0 | sudo tee /proc/sys/kernel/apparmor_restrict_unprivileged_userns >/dev/null

trap '
  if [ -n "$orig_aa" ]; then
    echo "$orig_aa" | sudo tee /proc/sys/kernel/apparmor_restrict_unprivileged_userns >/dev/null
  fi
' EXIT

# === Variables ===
WORK_DIR="$1"
LINUX_DIR="$2"
YOCTO_DIR="$3"
LAYER_DIR="$4"
RECIPES=(ip-config dropbear-keygen-service fpga-tools dnsmasq)

# === Resolve absolute path to avoid relative path issues ===
ROOT_DIR=$(pwd)
TARGET_LINUX_DIR="$WORK_DIR/$LINUX_DIR"
TARGET_YOCTO_DIR="$TARGET_LINUX_DIR/$(basename "$YOCTO_DIR")"
YOCTO_DEV_DIR="$TARGET_YOCTO_DIR/yocto-dev"

# === Step 1: Create Linux directory if it doesn't exist ===
if [ ! -d "$TARGET_LINUX_DIR" ]; then
    echo "➡️  Creating directory $TARGET_LINUX_DIR"
    mkdir -p "$TARGET_LINUX_DIR"
else
    echo "✅ Directory $TARGET_LINUX_DIR already exists"
fi

# === Step 2: Copy Yocto directory if not already present ===
if [ ! -d "$TARGET_YOCTO_DIR" ]; then
    echo "➡️  Copying $YOCTO_DIR into $TARGET_LINUX_DIR"
    rsync -a --exclude='.git' --exclude='.repo' "$YOCTO_DIR/" "$TARGET_YOCTO_DIR/"
else
    echo "✅ Yocto directory already copied"
fi

# === Step 3: repo init ===
if [ ! -d "$YOCTO_DEV_DIR/.repo/repo" ]; then
    echo "➡️  Initializing repo in $YOCTO_DEV_DIR"
    mkdir -p "$YOCTO_DEV_DIR"
    cd "$YOCTO_DEV_DIR" || exit 1
    repo init -u https://github.com/linux4microchip/meta-mchp-manifest.git -b refs/tags/linux4microchip+fpga-2025.07 -m polarfire-soc/default.xml
else
    echo "✅ repo already initialized in $YOCTO_DEV_DIR"
fi

# === Step 4: repo sync ===
cd "$YOCTO_DEV_DIR" || exit 1
echo "➡️  Syncing repo"
repo sync

# === Step 5: export template config ===
export TEMPLATECONF=${TEMPLATECONF:-../meta-mchp/meta-mchp-polarfire-soc/meta-mchp-polarfire-soc-bsp/conf/templates/default}

# === Step 6: Copy custom meta-layer ===
echo "➡️  Copying custom meta-layer"
rm -rf "$LAYER_DIR"
cp -r "$ROOT_DIR/$LAYER_DIR" ../

# === Step 7: Source Yocto setup script ===
set +u

BUILD_DIR="build"
SETUP_SCRIPT="$YOCTO_DEV_DIR/openembedded-core/oe-init-build-env"
BITBAKEDIR="$YOCTO_DEV_DIR/bitbake"

if [ ! -f "$SETUP_SCRIPT" ]; then
  echo "❌ Unable to find: $SETUP_SCRIPT"
  exit 1
fi
if [ -z "$BITBAKEDIR" ]; then
  echo "❌ Unable to find: $BITBAKEDIR"
  exit 1
fi

. "$SETUP_SCRIPT" "$BUILD_DIR" "$BITBAKEDIR"

set -u


# === Step 8: Add custom layer and build in same environment ===
echo "➡️  Adding custom layer and launching build in same Yocto environment"

(
    cd "$YOCTO_DEV_DIR" || exit 1

    if ! bitbake-layers show-layers | awk '{print $1}' | grep -qx "$(basename "$LAYER_DIR")"; then
        echo "➡️  Adding layer: ../$(basename "$LAYER_DIR")"
        bitbake-layers add-layer "../$(basename "$LAYER_DIR")"
    else
        echo "✅ Layer already present"
    fi

    echo "➡️  Cleaning build: MACHINE=mpfs-disco-kit bitbake -c cleansstate core-image-custom ${RECIPES[*]}"
    MACHINE=mpfs-disco-kit bitbake -c cleansstate core-image-custom "${RECIPES[@]}"

    echo "➡️  Starting build: MACHINE=mpfs-disco-kit bitbake core-image-custom core-image-custom -c populate_sdk"
    MACHINE=mpfs-disco-kit bitbake core-image-custom core-image-custom -c populate_sdk
    # echo "➡️  Starting build: MACHINE=mpfs-disco-kit bitbake core-image-custom -c populate_sdk"
    # MACHINE=mpfs-disco-kit bitbake core-image-custom -c populate_sdk
    cp $YOCTO_DEV_DIR/build/tmp-glibc/deploy/images/mpfs-disco-kit/core-image-custom-mpfs-disco-kit.rootfs-*.wic $TARGET_LINUX_DIR
    sh $YOCTO_DEV_DIR/build/tmp-glibc/deploy/sdk/oecore-core-image-custom-x86_64-riscv64-mpfs-disco-kit-toolchain-nodistro.0.sh -d $TARGET_LINUX_DIR/sdk -y
)

echo "🎉 Build completed successfully."
