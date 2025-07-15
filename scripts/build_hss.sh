#!/bin/bash
set -eo pipefail

# Arguments
WORK_DIR="$1"
MPFS_DISCOVERY_KIT_HSS_DIR="$2"
MPFS_DISCOVERY_KIT_ROOT_DIR="$3"
MPFS_DISCOVERY_KIT_SCRIPTS_DIR="$4"
PROGRAM="${5:-}"  # Optional 5th argument, empty if not provided

function err() {
    echo "❌ Error: $*" >&2
    exit 1
}

echo "➡️  Preparing Microchip environment"
if [ -f "${MPFS_DISCOVERY_KIT_SCRIPTS_DIR}setup_microchip_tools.sh" ]; then
    source "${MPFS_DISCOVERY_KIT_SCRIPTS_DIR}setup_microchip_tools.sh"
else
    err "Script setup_microchip_tools.sh not found in ${MPFS_DISCOVERY_KIT_SCRIPTS_DIR}"
fi

DEST_DIR="${WORK_DIR}${MPFS_DISCOVERY_KIT_ROOT_DIR}"
SRC_DIR="${MPFS_DISCOVERY_KIT_HSS_DIR}"

echo "➡️  Creating destination directory: $DEST_DIR"
mkdir -p "$DEST_DIR"

if [ ! -d "${DEST_DIR}/$(basename "$SRC_DIR")" ]; then
    echo "➡️  Copying ${SRC_DIR} to ${DEST_DIR}"
    cp -r "$SRC_DIR" "$DEST_DIR"
else
    echo "✅ Directory $(basename "$SRC_DIR") already copied to ${DEST_DIR}"
fi

cd "${DEST_DIR}/$(basename "$SRC_DIR")" || err "Failed to cd into ${DEST_DIR}/$(basename "$SRC_DIR")"

CONFIG_FILE=".config"
BOARD="mpfs-disco-kit"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "➡️  Copying boards/mpfs-disco-kit/def_config to .config"
    cp "boards/mpfs-disco-kit/def_config" "$CONFIG_FILE"
else
    echo "✅ Config file $CONFIG_FILE already exists"
fi

if [ -n "$PROGRAM" ]; then
    echo "➡️  Building with: make program BOARD=$BOARD"
    make program BOARD="$BOARD"
else
    echo "➡️  Building with: make BOARD=$BOARD"
    make BOARD="$BOARD"
fi

echo "🎉 Build completed successfully"
