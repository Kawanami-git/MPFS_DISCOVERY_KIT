#This Tcl file sources other Tcl files to build the design(on which recursive export is run) in a bottom-up fashion

#Sourcing the Tcl files for creating individual components under the top level
source components/CORERESET.tcl 
source components/INIT_MONITOR.tcl 
source components/PF_CCC_C0.tcl 
source components/CLOCKS_AND_RESETS.tcl 
source components/MSS_WRAPPER.tcl 

if {$ARCHI == 64} {
    source components/AXI4_INTERCONNECT_64.tcl
} else {
    source components/AXI4_INTERCONNECT_32.tcl
}
source components/DP_LSRAM_20x1024.tcl

source components/CORES_CLOCKS.tcl
source components/SCHOLAR_RISC-V.tcl

source components/MPFS_DISCOVERY_KIT.tcl 
build_design_hierarchy

