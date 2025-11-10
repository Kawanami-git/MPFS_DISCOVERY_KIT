#!/bin/bash
# SPDX-License-Identifier: MIT
# /*!
# ********************************************************************************
# \file       setup_microchip_tools.sh
# \brief      Environment setup for Microchip toolchain (SoftConsole, Libero).
# \author     Kawanami
# \version    1.1
# \date       11/11/2025
#
# \details
#   Exports PATH and environment variables for:
#   - SoftConsole (RISC-V GCC toolchain)
#   - Libero SoC (Designer, Synplify, ModelSim OEM)
#
# \remarks
#   - Tested on Ubuntu 20.04.6 and 24.04.
#   - Adjust the directories below to match your installation paths.
#   - The environment variables LM_LICENSE_FILE and SNPSLMD_LICENSE_FILE
#     point tools to the running license server (port@host) or to a
#     license file path. Here we use a local server on port 1702.
#
# \section setup_microchip_tools_sh_version_history Version history
# | Version | Date       | Author     | Description      |
# |:-------:|:----------:|:-----------|:-----------------|
# | 1.0     | 26/10/2025 | Kawanami   | Initial version. |
# | 1.1     | 11/11/2025 | Kawanami   | Remove Licensing daemon. |
# ********************************************************************************
# */

#===============================================================================
# Edit the following section with the location where the following tools are
# installed:
#   - SoftConsole (SC_INSTALL_DIR)
#   - Libero (LIBERO_INSTALL_DIR)
#===============================================================================
export SC_INSTALL_DIR=/opt/microchip/SoftConsole/
export LIBERO_INSTALL_DIR=/opt/microchip/Libero_SoC_2025.1/

#
# SoftConsole
#
export PATH=$PATH:$SC_INSTALL_DIR/riscv-unknown-elf-gcc/bin
export FPGENPROG=$LIBERO_INSTALL_DIR/Libero_SoC/Designer/bin64/fpgenprog

#
# Libero
#
export PATH=$PATH:$LIBERO_INSTALL_DIR/Libero_SoC/Designer/bin:$LIBERO_INSTALL_DIR/Libero_SoC/Designer/bin64
export PATH=$PATH:$LIBERO_INSTALL_DIR/Synplify/bin
export PATH=$PATH:$LIBERO_INSTALL_DIR/Model/modeltech/linuxacoem
export LOCALE=C
export LD_LIBRARY_PATH=/usr/lib/i386-linux-gnu:$LD_LIBRARY_PATH

# ------------------------------------------------------------------------------
# FlexNet environment:
#  - LM_LICENSE_FILE / SNPSLMD_LICENSE_FILE can be either:
#      * port@host (e.g., 1702@localhost) to contact a license server, OR
#      * an absolute path to a license file (License.dat).
#    Here we point to a local server that this script will start.
# ------------------------------------------------------------------------------
export LM_LICENSE_FILE=1702@localhost
export SNPSLMD_LICENSE_FILE=1702@localhost
