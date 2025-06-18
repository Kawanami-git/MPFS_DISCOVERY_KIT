puts "TCL_BEGIN: [info script]"


#################################### PATH LENGTH CHECK (WINDOWS) ###################################
if { [lindex $tcl_platform(os) 0]  == "Windows" } {
    if {[string length [pwd]] < 90} {
        puts "Project path length ok."
    } else {
        error "Path to project is too long, please reduce the path and try again."
    }
}
#################################### 							 ###################################

#################################### ARGUMENTS PROCESSING ###################################
if { $::argc > 0 } {
    set i 1
    foreach arg $::argv 
	{
        if {[string match "*:*" $arg]} 
		{
            set var [string range $arg 0 [string first ":" $arg]-1]
            set val [string range $arg [string first ":" $arg]+1 end]
            puts "Setting parameter $var to $val"
            set $var "$val"
        } 
		else 
		{
            set $arg 1
            puts "set $arg to 1"
        }
        incr i
    }
} else {
    puts "no command line argument passed"
}
#################################### 					  ###################################

#################################### VARIABLE SETTING ###################################
set libero_release [split [get_libero_version] .]
set install_loc [defvar_get -name ACTEL_SW_DIR]
set mss_config_loc "$install_loc/bin64/pfsoc_mss"
set local_dir [pwd]
set constraint_path ./script_support/constraints

set project_name "SCHOLAR_RISC-V"
set project_dir "../../work/SCHOLAR_RISC-V_MPFS_DISCO_KIT_support/FPGA"

set jobPath "$project_dir/bitstream"
set components "FABRIC"
#################################### 				  ###################################


#################################### CREATING or OPENING LIBERO PROJECT ###################################
if { [file exists $project_dir/$project_name.prjx] } {
    puts "Open existing project"
    open_project -file $project_dir/$project_name.prjx
    open_smartdesign -sd_name {MPFS_DISCOVERY_KIT}
    set isNewProject 0
} else {
    puts "Creating a new project"
    set isNewProject 1
    new_project \
        -location $project_dir \
        -name $project_name \
        -project_description {} \
        -block_mode 0 \
        -standalone_peripheral_initialization 0 \
        -instantiate_in_smartdesign 1 \
        -ondemand_build_dh 1 \
        -use_relative_path 0 \
        -linked_files_root_dir_env {} \
        -hdl {VERILOG} \
        -family {PolarFireSoC} \
        -die {MPFS095T} \
        -package {FCSG325} \
        -speed {-1} \
        -die_voltage {1.0} \
        -part_range {EXT} \
        -adv_options {IO_DEFT_STD:LVCMOS 1.8V} \
        -adv_options {RESTRICTPROBEPINS:1} \
        -adv_options {RESTRICTSPIPINS:0} \
        -adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0} \
        -adv_options {TEMPR:EXT} \
        -adv_options {VCCI_1.2_VOLTR:EXT} \
        -adv_options {VCCI_1.5_VOLTR:EXT} \
        -adv_options {VCCI_1.8_VOLTR:EXT} \
        -adv_options {VCCI_2.5_VOLTR:EXT} \
        -adv_options {VCCI_3.3_VOLTR:EXT} \
        -adv_options {VOLTR:EXT}

    smartdesign \
        -memory_map_drc_change_error_to_warning 1 \
        -bus_interface_data_width_drc_change_error_to_warning 1 \
        -bus_interface_id_width_drc_change_error_to_warning 1 
    
	
	####################################
	# Download required cores
	####################################
	try {
		download_core -vlnv {Actel:SgCore:PF_CCC:*} -location {www.microchip-ip.com/repositories/SgCore}
		download_core -vlnv {Actel:DirectCore:CORERESET_PF:*} -location {www.microchip-ip.com/repositories/DirectCore}
		download_core -vlnv {Microsemi:SgCore:PFSOC_INIT_MONITOR:*} -location {www.microchip-ip.com/repositories/SgCore}
		download_core -vlnv {Actel:DirectCore:COREAXI4INTERCONNECT:2.9.100} -location {www.microchip-ip.com/repositories/DirectCore}
		download_core -vlnv {Actel:SgCore:PF_DPSRAM:1.1.110} -location {www.microchip-ip.com/repositories/SgCore}
	} on error err {
		puts "Downloading cores failed, the script will continute but will fail if all of the required cores aren't present in the vault."
	}

	
	####################################
	# Generate and import MSS component
	####################################	
	if {[file isdirectory $project_dir/MSS]} {
		file delete -force $project_dir/MSS
	}
	file mkdir $project_dir/MSS
	exec $mss_config_loc -GENERATE -CONFIGURATION_FILE:$local_dir/script_support/MPFS_DISCOVERY_KIT_MSS.cfg -OUTPUT_DIR:$project_dir/MSS

	import_mss_component -file "$project_dir/MSS/MPFS_DISCOVERY_KIT_MSS.cxz"


	####################################
	# Generate base design
	####################################	
	cd ./script_support/
	source MPFS_DISCOVERY_KIT_recursive.tcl
	cd ../
	set_root -module {MPFS_DISCOVERY_KIT::work} 


	####################################
	# Import I/O constraints
	####################################
	import_files \
		-convert_EDN_to_HDL 0 \
		-io_pdc "${constraint_path}/MPFS_DISCOVERY_KIT_BANK_SETTINGS.pdc" \
		-io_pdc "${constraint_path}/MPFS_DISCOVERY_KIT_BOARD_MISC.pdc" \
		-io_pdc "${constraint_path}/MPFS_DISCOVERY_MAC.pdc" \
		-io_pdc "${constraint_path}/MPFS_DISCOVERY_mikroBUS.pdc" \
		-io_pdc "${constraint_path}/MPFS_DISCOVERY_RPi.pdc" \
		-io_pdc "${constraint_path}/MPFS_DISCOVERY_UARTS.pdc" \
		-io_pdc "${constraint_path}/MPFS_DISCOVERY_7_SEG.pdc" \
		-io_pdc "${constraint_path}/MPFS_DISCOVERY_I2C_LOOPBACK.pdc" 
	
	organize_tool_files \
		-tool {PLACEROUTE} \
		-file "${project_dir}/constraint/io/MPFS_DISCOVERY_KIT_BANK_SETTINGS.pdc" \
		-file "${project_dir}/constraint/io/MPFS_DISCOVERY_KIT_BOARD_MISC.pdc" \
		-file "${project_dir}/constraint/io/MPFS_DISCOVERY_MAC.pdc" \
		-file "${project_dir}/constraint/io/MPFS_DISCOVERY_mikroBUS.pdc" \
		-file "${project_dir}/constraint/io/MPFS_DISCOVERY_RPi.pdc" \
		-file "${project_dir}/constraint/io/MPFS_DISCOVERY_UARTS.pdc" \
		-file "${project_dir}/constraint/io/MPFS_DISCOVERY_7_SEG.pdc" \
		-module {MPFS_DISCOVERY_KIT::work} \
		-input_type {constraint}        
			

	####################################
	# Build hierarchy before progressing
	####################################
	build_design_hierarchy
	
	####################################
	# Derive timing constraints
	####################################
	derive_constraints_sdc 


	####################################
	# Auto layout SmartDesigns
	####################################		
	save_project 
	sd_reset_layout -sd_name {CLOCKS_AND_RESETS}
	save_smartdesign -sd_name {CLOCKS_AND_RESETS}
	sd_reset_layout -sd_name {MSS_WRAPPER}
	save_smartdesign -sd_name {MSS_WRAPPER}
	sd_reset_layout -sd_name {MPFS_DISCOVERY_KIT}
	save_smartdesign -sd_name {MPFS_DISCOVERY_KIT}
	

	####################################
	# Derive timing constraints
	####################################	
	build_design_hierarchy
	derive_constraints_sdc 

}	
####################################									###################################

#################################### Run the design flow ###################################


####################################
# Enabling minimum delay repair and multi pass max delay
####################################
configure_tool -name {PLACEROUTE} -params {DELAY_ANALYSIS:MAX} -params {EFFORT_LEVEL:true} -params {GB_DEMOTION:true} -params {INCRPLACEANDROUTE:false} -params {IOREG_COMBINING:false} -params {MULTI_PASS_CRITERIA:VIOLATIONS} -params {MULTI_PASS_LAYOUT:true} -params {NUM_MULTI_PASSES:2} -params {PDPR:false} -params {RANDOM_SEED:0} -params {REPAIR_MIN_DELAY:true} -params {REPLICATION:false} -params {SLACK_CRITERIA:WORST_SLACK} -params {SPECIFIC_CLOCK:} -params {START_SEED_INDEX:1} -params {STOP_ON_FIRST_PASS:true} -params {TDPR:true} 


####################################
# Generating and exporting flash pro express job
####################################
run_tool -name {SYNTHESIZE}
run_tool -name {PLACEROUTE}
run_tool -name {VERIFYTIMING}

if {[info exists env(PROGRAM)]} {
    run_tool -name {PROGRAMDEVICE}
}

# if {[file isdirectory $jobPath]} {
# 	file delete -force $jobPath
# }
# file mkdir $jobPath



# puts "export_prog_job -job_file_name ${project_name} -export_dir ${jobPath} -bitstream_file_components ${components}"
# Exporting flash pro express job automatically includes the synthesize, place/route and timing verification.
# export_prog_job -job_file_name ${project_name} -export_dir ${jobPath} -bitstream_file_components ${components}
####################################					 ###################################


save_project
puts "TCL_END: [info script]"
