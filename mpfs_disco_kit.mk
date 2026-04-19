# SPDX-License-Identifier: MIT
# /*!
# ********************************************************************************
# \file       mpfs_disco_kit.mk
# \brief      MPFS Discovery Kit build and deployment targets for SCHOLAR RISC-V.
# \author     Kawanami
# \version    1.0
# \date       08/04/2026
#
# \details
#   This Makefile fragment contains all targets and variables specific to the
#   Microchip PolarFire SoC Discovery Kit flow.
#
#   It provides:
#     - FPGA bitstream build and programming targets
#     - Hart Software Services (HSS) build and programming targets
#     - Linux build, download, and SD-card programming targets
#     - helper targets to deploy firmware and host utilities through SSH or UART
#     - a helper target to launch Libero in the configured Microchip environment
#
#   This file is intended to be included by the top-level Makefile and relies on
#   shared variables and helper targets defined in the common project Makefiles.
#
# \remarks
#   - Requires the Microchip toolchain environment for Libero- and HSS-related flows.
#   - Linux-related targets rely on the repository build scripts and Yocto layers.
#   - Deployment helpers rely on SSH, SCP, UART utilities, and the MPFS SDK.
#   - See `make help` for a summary of available targets and variables.
#
# \section mpfs_disco_kit_mk_version_history Version history
# | Version | Date       | Author   | Description                                |
# |:-------:|:----------:|:---------|:-------------------------------------------|
# | 1.0     | 08/04/2026 | Kawanami | Initial split from the top-level Makefile. |
# ********************************************************************************
# */

#################################### Directories ####################################
# Root directory of the MPFS Discovery Kit support repository
MPFS_DISCO_KIT_ROOT_DIR 	= MPFS_DISCOVERY_KIT/

# Directory containing MPFS Discovery Kit helper scripts
MPFS_DISCO_KIT_SCRIPTS_DIR  = $(MPFS_DISCO_KIT_ROOT_DIR)scripts/

# Directory containing the HSS sources
MPFS_DISCO_KIT_HSS_DIR  	= $(MPFS_DISCO_KIT_ROOT_DIR)HSS/

# Directory containing the FPGA design sources
MPFS_DISCO_KIT_FPGA_DIR 	= $(MPFS_DISCO_KIT_ROOT_DIR)FPGA/

# Directory containing the Linux support files and layers
MPFS_DISCO_KIT_LINUX_DIR	= $(MPFS_DISCO_KIT_ROOT_DIR)Linux/

# Directory containing the Microchip Yocto layer
MPFS_DISCO_KIT_YOCTO_DIR	= $(MPFS_DISCO_KIT_LINUX_DIR)meta-mchp/

# Directory containing the SCHOLAR RISC-V Yocto layer
MPFS_DISCO_KIT_LAYER_DIR	= $(MPFS_DISCO_KIT_LINUX_DIR)meta-scholar-risc-v/

# Working directory used for MPFS Discovery Kit board-side utilities
MPFS_DISCO_KIT_BOARD		= $(WORK_DIR)$(MPFS_DISCO_KIT_ROOT_DIR)board/
#################################### 			 ####################################

#################################### Linux & SDK ####################################
# Prebuilt MPFS Linux image download link
MPFS_DISCO_KIT_LINUX_LINK   = https://github.com/Kawanami-git/MPFS_DISCOVERY_KIT/releases/download/2025-11-04/core-image-custom-mpfs-disco-kit.rootfs-20251104145941.wic

# Prebuilt MPFS SDK download link
MPFS_DISCO_KIT_SDK_LINK     = https://github.com/Kawanami-git/MPFS_DISCOVERY_KIT/releases/download/2025-11-04/oecore-core-image-custom-x86_64-riscv64-mpfs-disco-kit-toolchain-nodistro.0.sh

# Environment setup script used for MPFS cross-compilation
MPFS_DISCO_KIT_SDK_ENV      = $(WORK_DIR)$(MPFS_DISCO_KIT_LINUX_DIR)sdk/environment-setup-riscv64-oe-linux

# Directory containing MPFS cross-compilation binaries
MPFS_DISCO_KIT_SDK_BIN      = $(WORK_DIR)$(MPFS_DISCO_KIT_LINUX_DIR)sdk/sysroots/x86_64-oesdk-linux/usr/bin/riscv64-oe-linux/

# Helper used to activate the MPFS SDK environment before running a command
define SDK_RUN
bash -lc 'source "$(MPFS_DISCO_KIT_SDK_ENV)"; export PATH="$$PATH:$(MPFS_DISCO_KIT_SDK_BIN)"; $(1)'
endef
####################################					####################################

#################################### Misc ####################################
# Default IP address of the MPFS DISCO KIT board
MPFS_DISCO_KIT_IP           ?= 192.168.7.2

# Default SSH user of the MPFS DISCO KIT board
MPFS_DISCO_KIT_USER         ?= root

# Default serial device of the MPFS DISCO KIT board
MPFS_DISCO_KIT_TTY          ?= /dev/ttyUSB0

# Default serial baud rate of the MPFS DISCO KIT board
MPFS_DISCO_KIT_TTY_BAUDRATE ?= 115200
####################################		  ####################################


# Display help for mpfs_discovery_kit-related targets
.PHONY: mpfs_disco_kit_help
mpfs_disco_kit_help:
	@echo
	@echo "SCHOLAR RISC-V — MPFS DISCOVERY KIT Makefile helper"
	@echo "Usage: make <target> [XLEN=XLEN32|XLEN64]"
	@echo
	@printf "Targets:\n"
	@printf "  %-35s %s\n" "mpfs_disco_kit_license"				"Activate Microchip License"
	@printf "  %-35s %s\n" "mpfs_disco_kit_bitstream"   		"Build the bitstream for the MPFS DISCO KIT"
	@printf "  %-35s %s\n" "mpfs_disco_kit_program_bitstream"   "Program the bitstream in the MPFS DISCO KIT"
	@printf "  %-35s %s\n" "mpfs_disco_kit_hss"   				"Build the First Stage Bootoader for the MPFS DISCO KIT"
	@printf "  %-35s %s\n" "mpfs_disco_kit_program_hss"   		"Program the HSS in the MPFS DISCO KIT"
	@printf "  %-35s %s\n" "mpfs_disco_kit_linux"   			"Build the Linux (and sdk) for the MPFS DISCO KIT"
	@printf "  %-35s %s\n" "mpfs_disco_kit_get_linux"   		"Retreive the Linux (and sdk) for the MPFS DISCO KIT"
	@printf "  %-35s %s\n" "mpfs_disco_kit_program_linux"   	"Program the Linux in an SD card"
	@printf "  %-35s %s\n" "mpfs_disco_kit_ssh"   			    "Establish an ssh connection with the MPFS DISCO KIT"
	@printf "  %-35s %s\n" "mpfs_disco_kit_ssh_setup"   		"Setup the MPFS DISCO KIT with all the necessary files to run 'loader', 'echo' & 'cyclemark' on the board through ssh"
	@printf "  %-35s %s\n" "mpfs_disco_kit_minicom"   			 "Open a serial console on the MPFS DISCO KIT"
	@printf "  %-35s %s\n" "mpfs_disco_kit_usb_setup"   		 "Setup the MPFS DISCO KIT with all the necessary files to run 'loader', 'echo' & 'cyclemark' on the board through usb (uart)"
	@printf "  %-35s %s\n" "clean_mpfs_disco_kit_bitstream"      "Clean the MPFS DISCO KIT FPGA work directory"
	@printf "  %-35s %s\n" "clean_mpfs_disco_kit_hss"            "Clean the MPFS DISCO KIT HSS work directory"
	@printf "  %-35s %s\n" "clean_mpfs_disco_kit_linux"   		 "Clean the MPFS DISCO KIT Linux work directory"
	@printf "  %-35s %s\n" "clean_mpfs_disco_kit_board"   		 "Clean the MPFS DISCO KIT board work directory"
	@printf "  %-35s %s\n" "clean_all_mpfs_disco_kit"   		 "Clean the MPFS DISCO KIT work directory"
	@printf "  %-35s %s\n" "libero"               				 "Launch Libero in the MPFS environment"
	@echo
	@printf "Key variables:\n"
	@printf "  %-35s %s\n" "XLEN"                                "Architecture (32-bit or 64-bit). Default is 32."
	@echo
	@echo "Examples:"
	@echo "  make isa XLEN=XLEN32"
	@echo "  make mpfs_disco_kit_usb_setup"
	@echo
	@echo





# Create the working directories required by the MPFS Discovery Kit flow
mpfs_disco_kit_work:
	@mkdir -p $(WORK_DIR)$(MPFS_DISCO_KIT_ROOT_DIR)
	@mkdir -p $(WORK_DIR)$(MPFS_DISCO_KIT_LINUX_DIR)
	@mkdir -p $(MPFS_DISCO_KIT_BOARD)

# Start the Microchip license daemon
.PHONY: mpfs_disco_kit_license
mpfs_disco_kit_license: mpfs_disco_kit_work
	@cd $(WORK_DIR)$(MPFS_DISCO_KIT_ROOT_DIR) && $(ROOT_DIR)$(MPFS_DISCO_KIT_ROOT_DIR)/scripts/run_license_daemon.sh





# Build the FPGA bitstream for the MPFS Discovery Kit
.PHONY: mpfs_disco_kit_bitstream
mpfs_disco_kit_bitstream: mpfs_disco_kit_work
	@echo "➡️  Running bitstream building script..."
	@echo
	@bash -c "source $(MPFS_DISCO_KIT_ROOT_DIR)/scripts/setup_microchip_tools.sh && \
	cd $(MPFS_DISCO_KIT_FPGA_DIR) && \
	libero SCRIPT:MPFS_DISCOVERY_KIT_DESIGN.tcl SCRIPT_ARGS:ARCHI:$(CPU_XLEN)"
	@echo "✅ Done."

# Build and program the FPGA bitstream for the MPFS Discovery Kit
.PHONY: mpfs_disco_kit_program_bitstream
mpfs_disco_kit_program_bitstream: mpfs_disco_kit_work
	@echo "➡️  Running bitstream building and programming script..."
	@echo
	@bash -lc 'export program=1; \
		source "$(MPFS_DISCO_KIT_ROOT_DIR)/scripts/setup_microchip_tools.sh"; \
		cd "$(MPFS_DISCO_KIT_FPGA_DIR)"; \
		libero SCRIPT:MPFS_DISCOVERY_KIT_DESIGN.tcl SCRIPT_ARGS:ARCHI:$(CPU_XLEN)'
	@echo "✅ Done."

# Clean MPFS Discovery Kit FPGA build artifacts
.PHONY: clean_mpfs_disco_kit_bitstream
clean_mpfs_disco_kit_bitstream:
	@echo "➡️  Cleaning bitstream directories..."
	@cd $(WORK_DIR) && rm -rf $(MPFS_DISCO_KIT_FPGA_DIR)
	@echo "✅ Done."





# Build the Hart Software Services (HSS) image
.PHONY: mpfs_disco_kit_hss
mpfs_disco_kit_hss: mpfs_disco_kit_work
	@echo "➡️  Running HSS building script..."
	@echo
	@bash $(MPFS_DISCO_KIT_SCRIPTS_DIR)build_hss.sh $(WORK_DIR) $(MPFS_DISCO_KIT_HSS_DIR) $(MPFS_DISCO_KIT_ROOT_DIR) $(MPFS_DISCO_KIT_SCRIPTS_DIR)
	@echo "✅ Done."

# Build and program the Hart Software Services (HSS) image
.PHONY: mpfs_disco_kit_program_hss
mpfs_disco_kit_program_hss: mpfs_disco_kit_work
	@echo "➡️  Running HSS building and programming script..."
	@echo
	@bash $(MPFS_DISCO_KIT_SCRIPTS_DIR)build_hss.sh $(WORK_DIR) $(MPFS_DISCO_KIT_HSS_DIR) $(MPFS_DISCO_KIT_ROOT_DIR) $(MPFS_DISCO_KIT_SCRIPTS_DIR) program=1
	@echo "✅ Done."

# Clean MPFS Discovery Kit HSS build artifacts
.PHONY: clean_mpfs_disco_kit_hss
clean_mpfs_disco_kit_hss:
	@echo "➡️  Cleaning HSS directories..."
	@cd $(WORK_DIR) && rm -rf $(MPFS_DISCO_KIT_HSS_DIR)
	@echo "✅ Done."





# Build the Linux system for the MPFS Discovery Kit
.PHONY: mpfs_disco_kit_linux
mpfs_disco_kit_linux: mpfs_disco_kit_work
	@echo "➡️  Running Linux building script..."
	@echo
	@bash $(MPFS_DISCO_KIT_SCRIPTS_DIR)build_linux.sh $(WORK_DIR) $(MPFS_DISCO_KIT_LINUX_DIR) $(MPFS_DISCO_KIT_YOCTO_DIR) $(MPFS_DISCO_KIT_LAYER_DIR)

	@cp $(WORK_DIR)$(MPFS_DISCO_KIT_YOCTO_DIR)/build/tmp-glibc/deploy/images/mpfs-disco-kit/core-image-custom-mpfs-disco-kit.rootfs-*.wic $(WORK_DIR)$(MPFS_DISCO_KIT_LINUX_DIR)

	@if [ -d $(WORK_DIR)$(MPFS_DISCO_KIT_LINUX_DIR)/sdk/ ]; \
  then rm -rf $(WORK_DIR)$(MPFS_DISCO_KIT_LINUX_DIR)/sdk/; \
  fi
	@sh $(WORK_DIR)$(MPFS_DISCO_KIT_YOCTO_DIR)/build/tmp-glibc/deploy/sdk/oecore-core-image-custom-x86_64-riscv64-mpfs-disco-kit-toolchain-nodistro.0.sh -d $(WORK_DIR)$(MPFS_DISCO_KIT_LINUX_DIR)sdk -y
	@echo "✅ Done."

# Download the prebuilt Linux image and SDK for the MPFS Discovery Kit
.PHONY: mpfs_disco_kit_get_linux
mpfs_disco_kit_get_linux: mpfs_disco_kit_work
	@wget -P $(WORK_DIR)$(MPFS_DISCO_KIT_LINUX_DIR) $(MPFS_DISCO_KIT_LINUX_LINK)
	@wget -P $(WORK_DIR)$(MPFS_DISCO_KIT_LINUX_DIR) $(MPFS_DISCO_KIT_SDK_LINK)

	@chmod +x $(WORK_DIR)$(MPFS_DISCO_KIT_LINUX_DIR)oecore-core-image-custom-x86_64-riscv64-mpfs-disco-kit-toolchain-nodistro.0.sh
	@if [ -d $(WORK_DIR)$(MPFS_DISCO_KIT_LINUX_DIR)/sdk/ ]; \
  then rm -rf $(WORK_DIR)$(MPFS_DISCO_KIT_LINUX_DIR)/sdk/; \
  fi
	@$(WORK_DIR)$(MPFS_DISCO_KIT_LINUX_DIR)oecore-core-image-custom-x86_64-riscv64-mpfs-disco-kit-toolchain-nodistro.0.sh -y -d "$(WORK_DIR)$(MPFS_DISCO_KIT_LINUX_DIR)/sdk/"

# Program the Linux image onto the target SD card
.PHONY: mpfs_disco_kit_program_linux
mpfs_disco_kit_program_linux:
	@echo "➡️  Running Linux programming script..."
	@echo
ifdef path
	@bash $(MPFS_DISCO_KIT_SCRIPTS_DIR)program_linux.sh $(path)
else
	@bash $(MPFS_DISCO_KIT_SCRIPTS_DIR)program_linux.sh $(WORK_DIR)$(MPFS_DISCO_KIT_LINUX_DIR)core-image-custom-mpfs-disco-kit.rootfs-*.wic
endif
	@echo "✅ Done."

# Clean the Linux working directory
.PHONY: clean_mpfs_disco_kit_linux
clean_mpfs_disco_kit_linux:
	@echo "➡️  Cleaning Linux directories..."
	@cd $(WORK_DIR) && rm -rf $(MPFS_DISCO_KIT_YOCTO_DIR)
	@echo "✅ Done."





# Establish an SSH connection
.PHONY: mpfs_disco_kit_ssh
mpfs_disco_kit_ssh:
	@ssh $(MPFS_DISCO_KIT_USER)@$(MPFS_DISCO_KIT_IP)

# Build the firmware and platform utility, then deploy them through SSH
.PHONY: mpfs_disco_kit_ssh_setup
mpfs_disco_kit_ssh_setup: MPFS_DISCO_KIT_FIRMWARE_DIR:=$(patsubst $(WORK_DIR)%,%,$(FIRMWARE_BUILD_DIR))
mpfs_disco_kit_ssh_setup: CXX_FLAGS := -O3 -D$(XLEN) -I$(VERILATOR_BUILD_DIR) -I$(SOFTWARE_DIR) -I$(PLATFORM_DIR) -I$(SIM_FILES_DIR)
mpfs_disco_kit_ssh_setup: mpfs_disco_kit_work
	@$(MAKE) --no-print-directory loader_firmware
	@$(MAKE) --no-print-directory echo_firmware
	@$(MAKE) --no-print-directory cyclemark_firmware
	@ssh -T $(MPFS_DISCO_KIT_USER)@$(MPFS_DISCO_KIT_IP) "mkdir -p $(MPFS_DISCO_KIT_FIRMWARE_DIR)"
	@scp -T -r $(FIRMWARE_BUILD_DIR)/*.hex $(MPFS_DISCO_KIT_USER)@$(MPFS_DISCO_KIT_IP):./$(MPFS_DISCO_KIT_FIRMWARE_DIR)
	@$(SDK_ACTIVATE) $$CXX $(CXX_FLAGS) $(PLATFORM_FILES) -o $(MPFS_DISCO_KIT_BOARD)platform
	@scp -T -r $(MPFS_DISCO_KIT_BOARD)platform $(MPFS_DISCO_KIT_USER)@$(MPFS_DISCO_KIT_IP):./
	@scp -T -r $(PLATFORM_DIR)Makefile $(MPFS_DISCO_KIT_USER)@$(MPFS_DISCO_KIT_IP):./





# Open a serial console on the selected TTY device
.PHONY: mpfs_disco_kit_minicom
mpfs_disco_kit_minicom:
	@sudo minicom -D $(MPFS_DISCO_KIT_TTY) -b $(MPFS_DISCO_KIT_TTY_BAUDRATE)

# Build the firmware and platform utility, then deploy them through UART
.PHONY: mpfs_disco_kit_usb_setup
mpfs_disco_kit_usb_setup: MPFS_DISCO_KIT_FIRMWARE_DIR:=$(patsubst $(WORK_DIR)%,%,$(FIRMWARE_BUILD_DIR))
mpfs_disco_kit_usb_setup: CXX_FLAGS := -O3 -D$(XLEN) -I$(VERILATOR_BUILD_DIR) -I$(SOFTWARE_DIR) -I$(PLATFORM_DIR) -I$(SIM_FILES_DIR)
mpfs_disco_kit_usb_setup: mpfs_disco_kit_work
	@$(MAKE) --no-print-directory loader_firmware
	@$(MAKE) --no-print-directory echo_firmware
	@$(MAKE) --no-print-directory cyclemark_firmware
	@$(call SDK_RUN,$$CXX $(CXX_FLAGS) $(PLATFORM_FILES) -o $(MPFS_DISCO_KIT_BOARD)platform)

	@for f in $(FIRMWARE_BUILD_DIR)/*.hex; do \
	  $(MAKE) --no-print-directory uart_ft TTY=$(MPFS_DISCO_KIT_TTY) TTY_BAUDRATE=$(MPFS_DISCO_KIT_TTY_BAUDRATE) UART_FILE="$$f" \
	  UART_DEST_DIR="./$(MPFS_DISCO_KIT_FIRMWARE_DIR)"; \
	done

	@$(MAKE) --no-print-directory uart_ft TTY=$(MPFS_DISCO_KIT_TTY) TTY_BAUDRATE=$(MPFS_DISCO_KIT_TTY_BAUDRATE) UART_FILE=$(MPFS_DISCO_KIT_BOARD)platform \
	UART_DEST_DIR="./"

	@$(MAKE) --no-print-directory uart_ft TTY=$(MPFS_DISCO_KIT_TTY) TTY_BAUDRATE=$(MPFS_DISCO_KIT_TTY_BAUDRATE) UART_FILE=$(PLATFORM_DIR)Makefile \
	UART_DEST_DIR="./"

# Clean the board directory
.PHONY: clean_mpfs_disco_kit_board
clean_mpfs_disco_kit_board:
	@echo "➡️  Cleaning board directory..."
	@rm -rf $(MPFS_DISCO_KIT_BOARD)
	@echo "✅ Done."


# Clean the MPFS disco kit working directory
.PHONY: clean_all_mpfs_disco_kit
clean_all_mpfs_disco_kit:
	@echo "➡️  Cleaning working directory..."
	@rm -rf $(WORK_DIR)$(MPFS_DISCO_KIT_ROOT_DIR)
	@echo "✅ Done."


# Launch Libero in the configured Microchip environment
.PHONY: libero
libero:
	@echo "➡️  Running Libero..."
	@echo
	@bash -c "source $(MPFS_DISCO_KIT_SCRIPTS_DIR)setup_microchip_tools.sh && libero"
	@echo "✅ Done."
