FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

#SRC_URI += "file://mpfs-disco-kit.dts"

#do_configure:append() {
#    cp ${WORKDIR}/mpfs-disco-kit.dts ${S}/arch/riscv/boot/dts/microchip/
#}

#KERNEL_DEVICETREE:mpfs-disco-kit = "microchip/mpfs-disco-kit.dtb"


SRC_URI += "file://fpga.cfg"
SRC_URI += "file://kernel.cfg"

KERNEL_CONFIG_FRAGMENTS += "fpga.cfg"
KERNEL_CONFIG_FRAGMENTS += "kernel.cfg"

