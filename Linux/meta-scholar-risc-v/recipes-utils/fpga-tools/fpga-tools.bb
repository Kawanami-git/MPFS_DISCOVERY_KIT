SUMMARY = "Simple FPGA load script"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://load-fpga.sh"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/load-fpga.sh ${D}${bindir}/load-fpga.sh
}