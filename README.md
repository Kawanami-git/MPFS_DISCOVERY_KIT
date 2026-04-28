# riscv-core-harness MPFS Discovery Kit support

This repository contains the necessary files to configure and use the [MPFS Discovery Kit](https://www.microchip.com/en-us/development-tool/mpfs-disco-kit) from Microchip with the [riscv-core-harness](https://github.com/Kawanami-git/riscv-core-harness) project.

If you haven’t already, please refer to the [**simulation README**](https://github.com/Kawanami-git/riscv-core-harness/tree/main/simulation), which contains useful information about the tests that can be executed to validate a **RISC-V**.

This repository is intended to be used as a submodule of the **riscv-core-harness** GitHub repository, and cannot be used independently.

> 📝
> If your Microchip install directory is not **/opt/microchip**, the following values in the [**setup_microchip_tools.sh**](./scripts/setup_microchip_tools.sh) script should be updated:
>- **SC_INSTALL_DIR**	    : Path to the SoftConsole directory.
>- **LIBERO_INSTALL_DIR**	: Path to the Libero directory.
>
> The following values in the [**run_license_daemon.sh**](./scripts/run_license_daemon.sh) should also be updated:
>- **LICENSE_DAEMON_DIR** : Path to the License daemon.
>- **LICENSE_FILE_DIR**   : Path to the License.

<br>
<br>

---

<br>
<br>
<br>
<br>
<br>

## 📚 Table of Contents

- [License](#license)
- [Overview](#overview)
- [Project Organization](#project-organization)
- [Structure](#structure)
- [Dependencies](#dependencies)
- [Retrieving or Building the Linux Image and Programming it](#retrieving-or-building-the-linux-image-and-programming-it)
- [Building and Programming the FPGA Bitstream](#building-and-programming-the-fpga-bitstream)
- [Running Tests on the Board](#running-tests-on-the-board)
- [Running Your Own Tests](#running-your-own-tests)
- [Known Bugs](#known-bugs)

<br>
<br>

---

<br>
<br>
<br>
<br>
<br>

## License

This project is licensed under the **MIT License** – see the [LICENSE](LICENSE) file for details.

Some files, generated artifacts, or external components used during the build process may come from Microchip, Yocto, or other third-party projects, and therefore remain subject to their respective licenses.

<br>
<br>

---

<br>
<br>
<br>
<br>
<br>

## Overview

The **riscv-core-harness** project is a reusable validation platform for RISC-V cores.

It provides both simulation support and board-level integration flows, allowing a RISC-V core to be tested in software simulation and on real FPGA hardware.

This repository contains the **Microchip MPFS Discovery Kit** support files for **riscv-core-harness**. It provides everything needed to:
- Prepare the MPFS Discovery Kit software environment, including the bootloader and Linux image.
- Build a **riscv-core-harness** FPGA bitstream containing the RISC-V core under test.
- Program and run the generated design on the MPFS Discovery Kit FPGA.

<br>
<br>

---

<br>
<br>
<br>
<br>
<br>

## Project Organization

This repository is a Git submodule used by the **riscv-core-harness** project.<br>
It is updated as needed to support the evolution of the project.

<br>
<br>

---

<br>
<br>
<br>
<br>
<br>

## Structure

- **[`HSS/`](./HSS/)**  
  Contains the [Microchip Hart Software Services](https://github.com/polarfire-soc/hart-software-services), including the source files for the FSBL (First Stage Bootloader).

- **[`Linux/meta-mchp/`](./Linux/meta-mchp/)**  
  Contains the [Microchip Yocto layers](https://github.com/linux4microchip/meta-mchp), which provide the source files for building the SSBL (Second Stage Bootloader) and the Linux system.

- **[`Linux/meta-scholar-risc-v/`](./Linux/meta-scholar-risc-v/)**  
  Contains overlay files that add specific features to the base Yocto build for the MPFS Discovery Kit.

- **[`FPGA/`](./FPGA/)**  
  FPGA implementation files for the **Microchip PolarFire SoC Discovery Kit**, enabling the **riscv-core-harness** to be synthesized and run on hardware.

- **[`scripts/`](./scripts/)**  
  A set of useful scripts to build and load the HSS, the Linux system, and to communicate with the Discovery Kit board.

<br>
<br>

---

<br>
<br>
<br>
<br>
<br>

## Dependencies

All dependencies are explicitly described in the [riscv-core-harness project – board_support](https://github.com/Kawanami-git/riscv-core-harness/tree/main/docs/board_support/MPFS_DISCOVERY_KIT/) directory.

<br>
<br>

---

<br>
<br>
<br>
<br>
<br>

## Retrieving or Building the Linux Image and Programming It

The **MPFS Discovery Kit** contains the **Polarfire SoC/FPGA** from **Microchip**. This chip is a Linux-capable SoC with an FPGA.<br>
To avoid running baremetal applications, a Linux image can be installed on the board using a microSD card.

<br>
<br>

### Retrieving the Linux Image
The custom Linux image and the SDK can be found [here](https://github.com/Kawanami-git/MPFS_DISCOVERY_KIT/releases/tag/2025-11-04).

They can be retrieved with the following command:
```bash
make mpfs_disco_kit_get_linux
```

<br>
<br>

### Building the Linux image 
Alternatively, to build the custom Linux image and the SDK, simply run the following command in your terminal:

```bash
make mpfs_disco_kit_linux
```

This command will build the custom Linux (and its SDK) developed in this project for the **MPFS Discovery Kit**.

> 📝 
>
> Please note that this build can take several hours and requires at least 75GB of available storage on your computer.
>
> During the build, several packages installation may be required by Yocto. Please, install all of these packages.
>
> Issues can occur during the build. Please, see the [**Known Bugs**](#🐞-known-bugs) section.


<br>
<br>

### Programming the Linux Image onto the SD Card

Once the SD card is plugged into your computer, you can flash the Linux image using one of the following commands:
```bash
make mpfs_disco_kit_program_linux
```

<br>
<br>

---

<br>
<br>
<br>
<br>
<br>

## Building and Programming the FPGA Bitstream

The FPGA bitstream can be built using the following command:

```bash
make mpfs_disco_kit_bitstream
```

If the **MPFS Discovery Kit** board is connected to your computer via the USB-C cable, you can program the bitstream with:

```bash
make mpfs_disco_kit_program_bitstream
```

<br>
<br>

---

<br>
<br>
<br>
<br>
<br>

## Running Tests on the Board

Except for the ISA tests, all other tests can be executed directly on the **MPFS Discovery Kit** board.<br>  
To do so, make sure the board is connected to your computer via **USB-C** and eventually **Ethernet**.

<br>
<br>

### Setup the board

Use one of the following commands to set up the board with either the USB or the Ethernet:

```bash
make mpfs_disco_kit_ssh_setup
```

```bash
make mpfs_disco_kit_usb_setup
```

These commands will compile all the firmware (loader, echo, cyclemark) and the software allowing to load firmware in the RISC-V softcore and to communicate with them.<br>
It will also copy the built binaries to the board and a Makefile.

> 📝
>
> For the software to be built, the board SDK must be available. It can be retreived with 'make mpfs_disco_kit_get_linux' or built with 'make mpfs_disco_kit_linux'.
>
> Please note that setting up the boad using usb requires root access for ttyUSBx.<br>
> Default ttyUSB used is ttyUSB0. It can be changed in the branch Makefile through the variable **TTYUSB**.

<br>
<br>

### Connect to the Board via USB or SSH
To interact with the board through an SSH session (Ethernet required):
```bash
make mpfs_disco_kit_ssh
```

Through a USB session:
```bash
make mpfs_disco_kit_minicom
```

> 📝
>
> Please note that establishing a session through usb requires root access for ttyUSBx.<br>
> Default ttyUSB used is ttyUSB0. It can be changed in the branch Makefile through the variable **TTYUSB**.

<br>
<br>

### Run the Tests

Once connected, run one of the following commands to execute a test:
```bash
make loader
make echo
make cyclemark
```

<br>
<br>

---

<br>
<br>
<br>
<br>
<br>

## Running Your Own Tests
If you haven’t already, please refer to the [**Running Your Own Firmwares**](https://github.com/Kawanami-git/riscv-core-harness/tree/main/simulation) section of the simulation environment README — it contains mandatory steps required before running your own tests on the boards.<br>

Please, also refer to the [Running Tests on the Board](#running-tests-on-the-board) section for detailed instructions on how to run a test on the board.

<br>
<br>

### Modify mpfs_disco_kit.mk

Once your firmware is running correctly in the simulation environment, you can modify the **mpfs_disco_kit.mk** to build and send your custom firmware to the board.

Locate the target:
```
# Build the firmware and platform utility, then deploy them through UART
.PHONY: mpfs_disco_kit_usb_setup
mpfs_disco_kit_usb_setup: MPFS_DISCO_KIT_FIRMWARE_DIR:=$(patsubst $(WORK_DIR)%,%,$(FIRMWARE_BUILD_DIR))
mpfs_disco_kit_usb_setup: CXX_FLAGS := -O3 -D$(XLEN) -I$(VERILATOR_BUILD_DIR) -I$(SOFTWARE_DIR) -I$(PLATFORM_DIR) -I$(SIM_FILES_DIR)
mpfs_disco_kit_usb_setup: mpfs_disco_kit_work
	@$(MAKE) --no-print-directory loader_firmware
	@$(MAKE) --no-print-directory echo_firmware
	@$(MAKE) --no-print-directory cyclemark_firmware
	@$(call SDK_RUN,$$CXX $(CXX_FLAGS) $(PLATFORM_FILES) -o $(MPFS_DISCO_KIT_BOARD)platform)

	@for f in $(FIRMWARE_BUILD_DIR)*.hex; do \
	  $(MAKE) --no-print-directory uart_ft TTY=$(MPFS_DISCO_KIT_TTY) TTY_BAUDRATE=$(MPFS_DISCO_KIT_TTY_BAUDRATE) UART_FILE="$$f" \
	  UART_DEST_DIR="./$(MPFS_DISCO_KIT_FIRMWARE_DIR)"; \
	done

	@$(MAKE) --no-print-directory uart_ft TTY=$(MPFS_DISCO_KIT_TTY) TTY_BAUDRATE=$(MPFS_DISCO_KIT_TTY_BAUDRATE) UART_FILE=$(MPFS_DISCO_KIT_BOARD)platform \
	UART_DEST_DIR="./"

	@$(MAKE) --no-print-directory uart_ft TTY=$(MPFS_DISCO_KIT_TTY) TTY_BAUDRATE=$(MPFS_DISCO_KIT_TTY_BAUDRATE) UART_FILE=$(PLATFORM_DIR)Makefile \
	UART_DEST_DIR="./"
```

And add it your firmware build command (**@$(MAKE) --no-print-directory custom_firmware**):
```
# Build the firmware and platform utility, then deploy them through UART
.PHONY: mpfs_disco_kit_usb_setup
mpfs_disco_kit_usb_setup: MPFS_DISCO_KIT_FIRMWARE_DIR:=$(patsubst $(WORK_DIR)%,%,$(FIRMWARE_BUILD_DIR))
mpfs_disco_kit_usb_setup: CXX_FLAGS := -O3 -D$(XLEN) -I$(VERILATOR_BUILD_DIR) -I$(SOFTWARE_DIR) -I$(PLATFORM_DIR) -I$(SIM_FILES_DIR)
mpfs_disco_kit_usb_setup: mpfs_disco_kit_work
	@$(MAKE) --no-print-directory loader_firmware
	@$(MAKE) --no-print-directory echo_firmware
	@$(MAKE) --no-print-directory cyclemark_firmware
->@$(MAKE) --no-print-directory custom_firmware
	@$(call SDK_RUN,$$CXX $(CXX_FLAGS) $(PLATFORM_FILES) -o $(MPFS_DISCO_KIT_BOARD)platform)

	@for f in $(FIRMWARE_BUILD_DIR)*.hex; do \
	  $(MAKE) --no-print-directory uart_ft TTY=$(MPFS_DISCO_KIT_TTY) TTY_BAUDRATE=$(MPFS_DISCO_KIT_TTY_BAUDRATE) UART_FILE="$$f" \
	  UART_DEST_DIR="./$(MPFS_DISCO_KIT_FIRMWARE_DIR)"; \
	done

	@$(MAKE) --no-print-directory uart_ft TTY=$(MPFS_DISCO_KIT_TTY) TTY_BAUDRATE=$(MPFS_DISCO_KIT_TTY_BAUDRATE) UART_FILE=$(MPFS_DISCO_KIT_BOARD)platform \
	UART_DEST_DIR="./"

	@$(MAKE) --no-print-directory uart_ft TTY=$(MPFS_DISCO_KIT_TTY) TTY_BAUDRATE=$(MPFS_DISCO_KIT_TTY_BAUDRATE) UART_FILE=$(PLATFORM_DIR)Makefile \
	UART_DEST_DIR="./"
```

This will build your firmware along the others and send it to the board. If you work with ssh, you can apply the same process to **mpfs_disco_kit_ssh_setup**.

<br>
<br>

### Modify the platform Makefile

The [**platform makefile**](https://github.com/Kawanami-git/riscv-core-harness/tree/main/software/platform/Makefile) is meant to be used on a development board supporting Linux.<br>
Its purpose is to make the use of the built binaries easier.

To add your firmware, just add the following variables:
```
CUSTOM_FIRMWARE = $(FIRMWARE_DIR)custom.hex
CUSTOM_LOG      = $(LOG_DIR)custom.log
```

And add the following target:
```
.PHONY: custom
custom:
  ./platform --firmware $(CUSTOM_FIRMWARE) --log $(CUSTOM_LOG)
```

You can now run your test on the board by running the following command on the board:
```bash
make custom
```

<br>
<br>

---

<br>
<br>
<br>
<br>
<br>

## Known Bugs

- **Yocto Build Failures**

Yocto may occasionally fail to fetch some external dependencies, leading to a Linux build failure.  
If this happens, simply rerun the build process **without cleaning** it:

```bash
make mpfs_disco_kit_linux
```

Yocto will resume from where it left off and attempt to fetch the missing files again.

<br>
<br>

- **CycleMark firmware invalid seeds**

CycleMark may print the following warning:

```text
Cannot validate operation for these seed values, please compare with results on a known platform.
```

This warning means that the selected seed values are not part of the benchmark reference validation set. <br>
It does not necessarily mean that the core is failing.

It think it is an harness issue. I will fix it as soon as possible.

<br>
<br>


