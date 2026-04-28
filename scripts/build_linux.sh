#!/bin/bash
# SPDX-License-Identifier: MIT
# /*!
# ********************************************************************************
# \file       build_linux.sh
# \brief      Build the MPFS Discovery Kit Linux image and SDK.
# \author     Kawanami
# \version    1.0
# \date       28/04/2026
#
# \details
#   This script prepares and builds the Linux environment for the MPFS Discovery
#   Kit support flow.
#
#   It:
#     - validates input directories,
#     - copies the Microchip Yocto metadata into the work directory,
#     - initializes and synchronizes the linux4microchip Yocto repository,
#     - copies the project-specific Yocto layer,
#     - adds the custom layer to the Yocto build,
#     - builds the custom Linux image,
#     - builds the matching SDK,
#     - copies the generated WIC image into the Linux work directory,
#     - installs the generated SDK into the Linux work directory.
#
# \remarks
#   - This script expects four arguments:
#       1. WORK_ROOT
#       2. LINUX_WORK_DIR
#       3. YOCTO_SRC_DIR
#       4. LAYER_SRC_DIR
#   - The script refuses to continue when critical paths are empty, invalid, or
#     resolve to `/`.
#   - The AppArmor unprivileged user namespace restriction is temporarily disabled
#     during the build and restored on exit.
#   - Yocto fetch failures may happen occasionally; rerunning the script without
#     cleaning usually resumes the build.
#
# \section build_linux_sh_version_history Version history
# | Version | Date       | Author   | Description      |
# |:-------:|:----------:|:---------|:-----------------|
# | 1.0     | 28/04/2026 | Kawanami | Initial version. |
# ********************************************************************************
# */

set -euo pipefail

function err() {
  echo "❌ Error: $*" >&2
  exit 1
}

function require_non_empty() {
  local name="$1"
  local value="$2"

  if [ -z "$value" ]; then
    err "$name is empty"
  fi
}

function require_directory() {
  local name="$1"
  local path="$2"

  require_non_empty "$name" "$path"

  if [ "$path" = "/" ]; then
    err "$name resolves to '/', refusing to continue"
  fi

  if [ ! -d "$path" ]; then
    err "$name does not exist or is not a directory: $path"
  fi
}

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <WORK_ROOT> <LINUX_WORK_DIR> <YOCTO_SRC_DIR> <LAYER_SRC_DIR>"
  exit 1
fi

WORK_ROOT="$1"
LINUX_WORK_DIR="$2"
YOCTO_SRC_DIR="$3"
LAYER_SRC_DIR="$4"

RECIPES=(ip-config dropbear-keygen-service fpga-tools dnsmasq)

require_non_empty "WORK_ROOT" "$WORK_ROOT"
require_non_empty "LINUX_WORK_DIR" "$LINUX_WORK_DIR"
require_directory "YOCTO_SRC_DIR" "$YOCTO_SRC_DIR"
require_directory "LAYER_SRC_DIR" "$LAYER_SRC_DIR"

TARGET_LINUX_DIR="$LINUX_WORK_DIR"
TARGET_YOCTO_DIR="$TARGET_LINUX_DIR/$(basename "$YOCTO_SRC_DIR")"
YOCTO_DEV_DIR="$TARGET_YOCTO_DIR/yocto-dev"
TARGET_LAYER_DIR="$TARGET_YOCTO_DIR/$(basename "$LAYER_SRC_DIR")"

if [ "$TARGET_LINUX_DIR" = "/" ] || [ "$TARGET_YOCTO_DIR" = "/" ] || [ "$TARGET_LAYER_DIR" = "/" ]; then
  err "A target directory resolved to '/', refusing to continue"
fi

echo "WORK_ROOT        = $WORK_ROOT"
echo "LINUX_WORK_DIR   = $LINUX_WORK_DIR"
echo "YOCTO_SRC_DIR    = $YOCTO_SRC_DIR"
echo "LAYER_SRC_DIR    = $LAYER_SRC_DIR"
echo "TARGET_LINUX_DIR = $TARGET_LINUX_DIR"
echo "TARGET_YOCTO_DIR = $TARGET_YOCTO_DIR"
echo "TARGET_LAYER_DIR = $TARGET_LAYER_DIR"

# Temporarily disable AppArmor restriction on unprivileged user namespaces.
orig_aa="$(cat /proc/sys/kernel/apparmor_restrict_unprivileged_userns 2>/dev/null || true)"
echo 0 | sudo tee /proc/sys/kernel/apparmor_restrict_unprivileged_userns >/dev/null

trap '
  if [ -n "${orig_aa:-}" ]; then
    echo "$orig_aa" | sudo tee /proc/sys/kernel/apparmor_restrict_unprivileged_userns >/dev/null
  fi
' EXIT

mkdir -p "$TARGET_LINUX_DIR"

if [ ! -d "$TARGET_YOCTO_DIR" ]; then
  echo "➡️  Copying $YOCTO_SRC_DIR into $TARGET_LINUX_DIR"
  rsync -a \
    --exclude='.git' \
    --exclude='.repo' \
    "$YOCTO_SRC_DIR/" "$TARGET_YOCTO_DIR/"
else
  echo "✅ Yocto directory already copied: $TARGET_YOCTO_DIR"
fi

if [ ! -d "$YOCTO_DEV_DIR/.repo/repo" ]; then
  echo "➡️  Initializing repo in $YOCTO_DEV_DIR"
  mkdir -p "$YOCTO_DEV_DIR"
  cd "$YOCTO_DEV_DIR"
  repo init \
    -u https://github.com/linux4microchip/meta-mchp-manifest.git \
    -b refs/tags/linux4microchip+fpga-2025.07 \
    -m polarfire-soc/default.xml
else
  echo "✅ repo already initialized in $YOCTO_DEV_DIR"
fi

cd "$YOCTO_DEV_DIR"
echo "➡️  Syncing repo"
repo sync

export TEMPLATECONF=${TEMPLATECONF:-../meta-mchp/meta-mchp-polarfire-soc/meta-mchp-polarfire-soc-bsp/conf/templates/default}

echo "➡️  Copying custom meta-layer"
rm -rf "$TARGET_LAYER_DIR"
cp -r "$LAYER_SRC_DIR" "$TARGET_LAYER_DIR"

set +u

BUILD_DIR="build"
SETUP_SCRIPT="$YOCTO_DEV_DIR/openembedded-core/oe-init-build-env"
BITBAKEDIR="$YOCTO_DEV_DIR/bitbake"

if [ ! -f "$SETUP_SCRIPT" ]; then
  err "Unable to find: $SETUP_SCRIPT"
fi

if [ ! -d "$BITBAKEDIR" ]; then
  err "Unable to find: $BITBAKEDIR"
fi

. "$SETUP_SCRIPT" "$BUILD_DIR" "$BITBAKEDIR"

set -u

echo "➡️  Adding custom layer and launching build"

cd "$YOCTO_DEV_DIR"

if ! bitbake-layers show-layers | awk '{print $1}' | grep -qx "$(basename "$LAYER_SRC_DIR")"; then
  echo "➡️  Adding layer: ../$(basename "$LAYER_SRC_DIR")"
  bitbake-layers add-layer "../$(basename "$LAYER_SRC_DIR")"
else
  echo "✅ Layer already present"
fi

echo "➡️  Cleaning build"
MACHINE=mpfs-disco-kit bitbake -c cleansstate core-image-custom "${RECIPES[@]}"

echo "➡️  Building Linux image"
MACHINE=mpfs-disco-kit bitbake core-image-custom

echo "➡️  Building SDK"
MACHINE=mpfs-disco-kit bitbake core-image-custom -c populate_sdk

cp "$YOCTO_DEV_DIR"/build/tmp-glibc/deploy/images/mpfs-disco-kit/core-image-custom-mpfs-disco-kit.rootfs-*.wic "$TARGET_LINUX_DIR"

sh "$YOCTO_DEV_DIR"/build/tmp-glibc/deploy/sdk/oecore-core-image-custom-x86_64-riscv64-mpfs-disco-kit-toolchain-nodistro.0.sh \
  -d "$TARGET_LINUX_DIR/sdk" \
  -y

echo "🎉 Build completed successfully."
