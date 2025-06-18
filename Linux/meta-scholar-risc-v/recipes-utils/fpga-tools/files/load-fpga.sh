#!/bin/sh

BITSTREAM="/etc/fpga/mybitstream.bit"

if [ ! -f "$BITSTREAM" ]; then
    echo "❌ Bitstream not found: $BITSTREAM"
    exit 1
fi

echo "✅ Loading FPGA from $BITSTREAM..."
fpga-load-fw 0 "$BITSTREAM"
