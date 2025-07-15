#!/bin/bash

set -eo pipefail

# === Argument validation ===
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <WORK_DIR> <MPFS_DISCOVERY_KIT_LINUX_DIR> <MPFS_DISCOVERY_KIT_YOCTO_DIR> <MPFS_DISCOVERY_KIT_LAYER_DIR>"
    exit 1
fi

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
    cp -r "$YOCTO_DIR" "$TARGET_LINUX_DIR"
else
    echo "✅ Yocto directory already copied"
fi



# === Step 3: repo init ===
if [ ! -d "$YOCTO_DEV_DIR/.repo/repo" ]; then
    echo "➡️  Initializing repo in $YOCTO_DEV_DIR"
    mkdir -p "$YOCTO_DEV_DIR"
    cd "$YOCTO_DEV_DIR" || exit 1
    repo init -u https://github.com/polarfire-soc/polarfire-soc-yocto-manifests.git -b main -m default.xml
else
    echo "✅ repo already initialized in $YOCTO_DEV_DIR"
fi



# === Step 4: repo sync ===
cd "$YOCTO_DEV_DIR" || exit 1
echo "➡️  Syncing repo"
repo sync



# === Step 5: repo rebase ===
echo "➡️  Rebasing repo"
repo rebase



# === Step 6: Source Yocto setup script ===
SETUP_SCRIPT="./meta-polarfire-soc-yocto-bsp/polarfire-soc_yocto_setup.sh"
if [ -f "$SETUP_SCRIPT" ]; then
    echo "➡️  Running Yocto setup script"
    # shellcheck disable=SC1090
    bash "$SETUP_SCRIPT"
else
    echo "❌ Script $SETUP_SCRIPT not found"
    exit 1
fi



# === Step 7: Copy custom meta-layer ===
echo "➡️  Copying custom meta-layer"
rm -rf "$LAYER_DIR"
cp -r "$ROOT_DIR/$LAYER_DIR" .



# === Step 8: Add custom layer and build in same environment ===
echo "➡️  Adding custom layer and launching build in same Yocto environment"

(
    cd "$YOCTO_DEV_DIR" || exit 1

    # Source within a subshell
    source ./meta-polarfire-soc-yocto-bsp/polarfire-soc_yocto_setup.sh || { echo "❌ Sourcing failed"; exit 1; }

    # Add the custom layer if not already added
    if ! bitbake-layers show-layers | awk '{print $1}' | grep -qx "$(basename "$LAYER_DIR")"; then
        echo "➡️  Adding layer: ../$(basename "$LAYER_DIR")"
        bitbake-layers add-layer "../$(basename "$LAYER_DIR")"
    else
        echo "✅ Layer already present"
    fi

    # Launch the build
    echo "➡️  Cleaning build: MACHINE=mpfs-disco-kit bitbake -c cleansstate core-image-custom ${RECIPES[*]}"
    MACHINE=mpfs-disco-kit bitbake -c cleansstate core-image-custom "${RECIPES[@]}"

    echo "➡️  Starting build: MACHINE=mpfs-disco-kit bitbake core-image-custom"
    MACHINE=mpfs-disco-kit bitbake core-image-custom
)

echo "🎉 Build completed successfully."
