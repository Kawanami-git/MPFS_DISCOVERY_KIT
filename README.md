# SCHOLAR_RISC-V MPFS_DISCOVERY_KIT support

This repository contains the necessary files to configure and use the [MPFS_DISCOVERY_KIT](https://www.microchip.com/en-us/development-tool/mpfs-disco-kit) from Microchip with the [SCHOLAR RISC-V](https://github.com/Kawanami-git/SCHOLAR_RISC-V) processor.

It is intended to be used as a submodule of the SCHOLAR RISC-V GitHub repository, and cannot be used independently.

<br>

## 📚 Table of Contents

- [License](#license)
- [Overview](#overview)
- [Project Organization](#project-organization)
- [Documentation](#documentation)
- [Dependencies](#dependencies)
- [Known Bugs](#known-bugs)

<br>

## License

This project is licensed under the **MIT License** – see the [LICENSE](LICENSE) file for details.

However, parts of this repository are derived from or based on Microchip and Yocto components, which fall under their own licenses:

- **HSS (Hart Software Services)** is published under the [Microchip License](https://github.com/polarfire-soc/hart-software-services/blob/master/LICENSE.md).
- **meta-mchp** is under both the [Microchip license](https://github.com/linux4microchip/meta-mchp/blob/scarthgap/meta-mchp-polarfire-soc/COPYING.MIT).
- **FPGA** is derived from the Microchip reference design for MPFS_DISCOVERY_KIT and is subject to both [Microchip’s original license](https://github.com/polarfire-soc/polarfire-soc-discovery-kit-reference-design/blob/main/LICENSE.md) **and** the MIT License.

<br>

## Overview

**SCHOLAR_RISC-V** is a learning-oriented project designed to guide you step-by-step through the inner workings of a processor, using the RISC-V architecture as a foundation.

In addition to simulation, SCHOLAR_RISC-V aims to be usable on several development boards, including the **MPFS_DISCOVERY_KIT** from Microchip.

This repository provides all the necessary files to:
- Configure the MPFS_DISCOVERY_KIT (bootloader, Linux).
- Build a valid SCHOLAR_RISC-V bitstream and load it on the FPGA.

<br>

## Project Organization

This repository is a Git submodule used by the **SCHOLAR_RISC-V** project.<br>
It is updated as needed to support the evolution of the core.

Branches in this repository are aligned with the parent repository branches.<br>
For example:
- `Single-Cycle` ↔ used by `SCHOLAR_RISC-V/Single-Cycle`
- `pipeline`     ↔ used by `SCHOLAR_RISC-V/pipeline`

Each parent branch pins this submodule to the matching branch/commit.

<br>

## Documentation

Full documentation is available in the [SCHOLAR RISC-V project repository](https://github.com/Kawanami-git/SCHOLAR_RISC-V/tree/main/docs/hardware_integration/MPFS_DISCOVERY_KIT/).

<br>

## Dependencies

All dependencies are explicitly described in the [SCHOLAR_RISC-V project – Hardware Integration](https://github.com/Kawanami-git/SCHOLAR_RISC-V/tree/main/docs/hardware_integration/MPFS_DISCOVERY_KIT/) directory.

<br>

## Known Issues

Yocto may occasionally fail to fetch some external dependencies, which can lead to a build failure. <br>
If this happens, simply rerun the build process **without cleaning** it. <br>
Yocto will resume from where it left off and attempt to fetch the missing files again.


