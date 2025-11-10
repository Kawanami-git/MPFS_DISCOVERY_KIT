#!/bin/bash
# SPDX-License-Identifier: MIT
# /*!
# ********************************************************************************
# \file       run_license_daemon.sh
# \brief      License daemon launcher for Microchip Libero/SoftConsole toolchain.
# \author     Kawanami
# \version    1.0
# \date       11/11/2025
#
# \details
#   Starts the FlexNet (Flexera) license manager daemon (lmgrd) used by
#   Microchip Libero SoC and related tools. The daemon reads a license file
#   and spawns vendor daemons (e.g., snpslmd) as needed.
#
#   Typical usage:
#     $ ./run_license_daemon.sh
#
#   To run in background:
#     $ nohup ./run_license_daemon.sh >/tmp/lmgrd.out 2>&1 &
#
#   To stop the daemon:
#     - Prefer the vendor-provided tools if available (lmutil lmdown),
#       otherwise as a last resort:
#         $ pkill -f lmgrd
#
# \remarks
#   - Tested on Ubuntu 20.04.6 and 24.04.
#   - Adjust the directories below to match your installation paths.
#
# \section setup_microchip_tools_sh_version_history Version history
# | Version | Date       | Author     | Description      |
# |:-------:|:----------:|:-----------|:-----------------|
# | 1.0     | 11/11/2025 | Kawanami   | Initial version. |
# ********************************************************************************
# */

# ------------------------------------------------------------------------------
# Configuration: paths to the FlexNet binaries and license file directory.
#  - LICENSE_DAEMON_DIR: directory containing lmgrd (and vendor daemons like snpslmd)
#  - LICENSE_FILE_DIR  : directory where License.dat and license.log reside
# ------------------------------------------------------------------------------
export LICENSE_DAEMON_DIR="/opt/microchip/Libero_SoC_2025.1/Libero_SoC/Designer/bin64"
export LICENSE_FILE_DIR="/opt/microchip/"

# ------------------------------------------------------------------------------
# Launch the license manager daemon:
#  - -c <file> : license file to read (FEATURE lines, DAEMON/VENDOR path, port)
#  - -l <file> : daemon log file (diagnostics, check here if startup fails)
# Notes:
#  - If lmgrd is already running, this will typically fail with a "port in use".
#  - Ensure License.dat contains a DAEMON / VENDOR line pointing to snpslmd
#    (or that snpslmd is discoverable in $LICENSE_DAEMON_DIR).
# ------------------------------------------------------------------------------
$LICENSE_DAEMON_DIR/lmgrd -c $LICENSE_FILE_DIR/License.dat -l $LICENSE_FILE_DIR/license.log

