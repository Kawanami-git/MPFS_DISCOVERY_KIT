# Exporting Component Description of FIFO_64x128 to TCL
# Family: PolarFireSoC
# Part Number: MPFS095T-1FCSG325E
# Create and Configure the core component FIFO_64x128
create_and_configure_core -core_vlnv {Actel:DirectCore:COREFIFO:3.1.101} -component_name {FIFO_64x128} -params {\
"AE_STATIC_EN:false"  \
"AEVAL:4"  \
"AF_STATIC_EN:false"  \
"AFVAL:1020"  \
"CTRL_TYPE:2"  \
"DIE_SIZE:10"  \
"ECC:0"  \
"ESTOP:true"  \
"FSTOP:true"  \
"FWFT:false"  \
"NUM_STAGES:2"  \
"OVERFLOW_EN:false"  \
"PIPE:1"  \
"PREFETCH:true"  \
"RAM_OPT:0"  \
"RDCNT_EN:true"  \
"RDEPTH:128"  \
"RE_POLARITY:0"  \
"READ_DVALID:false"  \
"RWIDTH:64"  \
"SYNC:0"  \
"SYNC_RESET:1"  \
"UNDERFLOW_EN:false"  \
"WDEPTH:128"  \
"WE_POLARITY:0"  \
"WRCNT_EN:true"  \
"WRITE_ACK:false"  \
"WWIDTH:64"   }
# Exporting Component Description of FIFO_64x128 to TCL done
