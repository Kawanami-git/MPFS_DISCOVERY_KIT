#This Tcl file sources other Tcl files to build the design(on which recursive export is run) in a bottom-up fashion

#Sourcing the Tcl files for creating individual components under the top level
source components/CORERESET.tcl 
source components/INIT_MONITOR.tcl 
source components/PF_CCC_C0.tcl 
source components/CLOCKS_AND_RESETS.tcl 
source components/MSS_WRAPPER.tcl 

source components/AXI4_INTERCONNECT.tcl
source components/DP_LSRAM_1K.tcl
source components/DP_LSRAM_2K.tcl
source components/DP_LSRAM_4K.tcl
source components/DP_LSRAM_6K.tcl
source components/DP_LSRAM_8K.tcl
source components/DP_LSRAM_12K.tcl
source components/DP_LSRAM_16K.tcl

source components/CORES_CLOCKS.tcl
source components/SCHOLAR_RISC-V.tcl

source components/MPFS_DISCOVERY_KIT.tcl 
build_design_hierarchy

