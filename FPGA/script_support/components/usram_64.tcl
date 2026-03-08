# Exporting Component Description of usram_64 to TCL
# Family: PolarFireSoC
# Part Number: MPFS095T-1FCSG325E
# Create and Configure the core component usram_64
create_and_configure_core -core_vlnv {Actel:SgCore:PF_URAM:1.1.107} -component_name {usram_64} -params {\
"BLK_PN:BLK_EN"  \
"BLK_POLARITY:2"  \
"BUSY_FLAG:0"  \
"CASCADE:0"  \
"CLKS:1"  \
"CLOCK_PN:CLK"  \
"IMPORT_FILE:"  \
"INIT_RAM:F"  \
"LPMTYPE:LPM_URAM"  \
"R_ADDR_ARST_PN:R_ADDR_ARST_N"  \
"R_ADDR_ARST_POLARITY:2"  \
"R_ADDR_EN_PN:R_ADDR_EN"  \
"R_ADDR_EN_POLARITY:2"  \
"R_ADDR_LAT:1"  \
"R_ADDR_PN:R_ADDR"  \
"R_ADDR_SRST_PN:R_ADDR_SRST_N"  \
"R_ADDR_SRST_POLARITY:2"  \
"R_CLK_EDGE:RISE"  \
"R_CLK_PN:R_CLK"  \
"R_DATA_ARST_PN:R_DATA_ARST_N"  \
"R_DATA_ARST_POLARITY:2"  \
"R_DATA_EN_PN:R_DATA_EN"  \
"R_DATA_EN_POLARITY:2"  \
"R_DATA_LAT:1"  \
"R_DATA_PN:R_DATA"  \
"R_DATA_SRST_PN:R_DATA_SRST_N"  \
"R_DATA_SRST_POLARITY:2"  \
"RDEPTH:32"  \
"RESET_POLARITY:2"  \
"RWIDTH:64"  \
"SII_LOCK:0"  \
"W_ADDR_PN:W_ADDR"  \
"W_CLK_EDGE:RISE"  \
"W_CLK_PN:W_CLK"  \
"W_DATA_PN:W_DATA"  \
"W_EN_PN:W_EN"  \
"W_EN_POLARITY:1"  \
"WDEPTH:32"  \
"WWIDTH:64"   }
# Exporting Component Description of usram_64 to TCL done
