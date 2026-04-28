#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# /*!
# ********************************************************************************
# \file       build_hss.sh
# \brief      Build helper for Microchip Hart Software Services (HSS).
# \author     Kawanami
# \version    1.0
# \date       28/04/2026
#
# \details
#   Prepares the Microchip toolchain environment, copies the HSS sources into a
#   working area, selects the mpfs-disco-kit default configuration, and builds
#   HSS. If a 5th argument is provided, it runs `make program BOARD=...`, otherwise
#   just `make BOARD=...`.
#
# \remarks
#   - Requires Microchip tools and helper script `setup_microchip_tools.sh`.
#   - Arguments:
#       1) WORK_DIR                     — Workspace root (destination prefix)
#       2) MPFS_DISCOVERY_KIT_HSS_DIR   — Path to HSS sources
#       3) MPFS_DISCOVERY_KIT_ROOT_DIR  — Target subdirectory under WORK_DIR
#       4) MPFS_DISCOVERY_KIT_SCRIPTS_DIR — Path to scripts/ with setup script
#       5) PROGRAM (optional)           — If set, runs `make program`
#
# \section build_hss_sh_version_history Version history
# | Version | Date       | Author     | Description        |
# |:-------:|:----------:|:-----------|:-------------------|
# | 1.0     | 28/04/2026 | Kawanami   | Initial version.   |
# ********************************************************************************
# */

set -eo pipefail

# Arguments
WORK_DIR="$1"
HSS_SRC_DIR="$2"
SCRIPTS_DIR="$3"
PROGRAM="${4:-}"

echo "➡️  Preparing Microchip environment"
if [ -f "${SCRIPTS_DIR}/setup_microchip_tools.sh" ]; then
    source "${SCRIPTS_DIR}/setup_microchip_tools.sh"
else
    err "Script setup_microchip_tools.sh not found in ${SCRIPTS_DIR}"
fi

DEST_DIR="${WORK_DIR}"
SRC_DIR="${HSS_SRC_DIR}"

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
    echo "➡️  Programming with: make program BOARD=$BOARD"
    make program BOARD="$BOARD"
    echo "🎉 Program completed successfully"
else
    echo "➡️  Building with: make BOARD=$BOARD"
    make BOARD="$BOARD"
    echo "🎉 Build completed successfully"
fi


