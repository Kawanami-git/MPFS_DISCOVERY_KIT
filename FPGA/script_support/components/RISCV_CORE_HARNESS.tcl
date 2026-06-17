# -----------------------------------------------------------------------------
# Recursively collect files matching a given pattern
# -----------------------------------------------------------------------------
proc collect_files_recursive {root_dir pattern} {
  set files {}

  foreach file [glob -nocomplain -types f -directory $root_dir $pattern] {
    lappend files [file normalize $file]
  }

  foreach dir [glob -nocomplain -types d -directory $root_dir *] {
    set files [concat $files [collect_files_recursive $dir $pattern]]
  }

  return [lsort -dictionary $files]
}

# -----------------------------------------------------------------------------
# Recursively collect files matching several patterns
# -----------------------------------------------------------------------------
proc collect_files_recursive_multi {root_dir patterns} {
  set files {}

  foreach pattern $patterns {
    set files [concat $files [collect_files_recursive $root_dir $pattern]]
  }

  return [lsort -unique -dictionary $files]
}

# -----------------------------------------------------------------------------
# Sort HDL files by compilation/import priority
#
# Order:
#   1. Headers       (*.svh, *.vh)
#   2. Packages      (*_pkg.sv)
#   3. Interfaces    (*_if.sv)
#   4. Other sources (*.sv, *.v)
# -----------------------------------------------------------------------------
proc order_hdl_files {files} {
  set headers    {}
  set packages   {}
  set interfaces {}
  set modules    {}

  foreach file $files {
    set name [file tail $file]

    if {[string match "*.svh" $name] || [string match "*.vh" $name]} {
      lappend headers $file
    } elseif {[string match "*_pkg.sv" $name]} {
      lappend packages $file
    } elseif {[string match "*_if.sv" $name]} {
      lappend interfaces $file
    } else {
      lappend modules $file
    }
  }

  return [concat \
    [lsort -dictionary $headers] \
    [lsort -dictionary $packages] \
    [lsort -dictionary $interfaces] \
    [lsort -dictionary $modules]]
}

# -----------------------------------------------------------------------------
# Import HDL sources into Libero
# -----------------------------------------------------------------------------
proc libero_import_hdl_sources {files} {
  foreach file $files {
    puts "Import HDL source: $file"
    import_files -hdl_source $file
  }
}

# -----------------------------------------------------------------------------
# Import one HDL source into Libero
# -----------------------------------------------------------------------------
proc libero_import_hdl_source {file} {
  set normalized_file [file normalize $file]

  puts "Import HDL source: $normalized_file"
  import_files -hdl_source $normalized_file
}

# -----------------------------------------------------------------------------
# Organize source files for Libero synthesis
# -----------------------------------------------------------------------------
proc libero_organize_synthesis_sources {top_module files} {
  set cmd [list organize_sources]

  foreach file $files {
    lappend cmd -file $file
  }

  lappend cmd -mode new
  lappend cmd -module "${top_module}::work"
  lappend cmd -tool synthesis
  lappend cmd -use_default false

  puts "Organize synthesis sources for module: ${top_module}::work"
  {*}$cmd
}

# -----------------------------------------------------------------------------
# Add an AXI4 slave BIF to a HDL core
#
# port_prefix examples:
#   sys_reset -> s_sys_reset_awid_i, s_sys_reset_awaddr_i, ...
#   instr     -> s_instr_awid_i,     s_instr_awaddr_i,     ...
#   data      -> s_data_awid_i,      s_data_awaddr_i,      ...
#   ptc       -> s_ptc_awid_i,       s_ptc_awaddr_i,       ...
#   ctp       -> s_ctp_awid_i,       s_ctp_awaddr_i,       ...
# -----------------------------------------------------------------------------
proc add_axi4_slave_bif {hdl_core_name bif_name port_prefix} {
  set signal_map [list \
    "AWID:s_${port_prefix}_awid_i" \
    "AWADDR:s_${port_prefix}_awaddr_i" \
    "AWLEN:s_${port_prefix}_awlen_i" \
    "AWSIZE:s_${port_prefix}_awsize_i" \
    "AWBURST:s_${port_prefix}_awburst_i" \
    "AWLOCK:s_${port_prefix}_awlock_i" \
    "AWCACHE:s_${port_prefix}_awcache_i" \
    "AWPROT:s_${port_prefix}_awprot_i" \
    "AWVALID:s_${port_prefix}_awvalid_i" \
    "AWREADY:s_${port_prefix}_awready_o" \
    "WDATA:s_${port_prefix}_wdata_i" \
    "WSTRB:s_${port_prefix}_wstrb_i" \
    "WLAST:s_${port_prefix}_wlast_i" \
    "WVALID:s_${port_prefix}_wvalid_i" \
    "WREADY:s_${port_prefix}_wready_o" \
    "BID:s_${port_prefix}_bid_o" \
    "BRESP:s_${port_prefix}_bresp_o" \
    "BVALID:s_${port_prefix}_bvalid_o" \
    "BREADY:s_${port_prefix}_bready_i" \
    "ARID:s_${port_prefix}_arid_i" \
    "ARADDR:s_${port_prefix}_araddr_i" \
    "ARLEN:s_${port_prefix}_arlen_i" \
    "ARSIZE:s_${port_prefix}_arsize_i" \
    "ARBURST:s_${port_prefix}_arburst_i" \
    "ARLOCK:s_${port_prefix}_arlock_i" \
    "ARCACHE:s_${port_prefix}_arcache_i" \
    "ARPROT:s_${port_prefix}_arprot_i" \
    "ARVALID:s_${port_prefix}_arvalid_i" \
    "ARREADY:s_${port_prefix}_arready_o" \
    "RID:s_${port_prefix}_rid_o" \
    "RDATA:s_${port_prefix}_rdata_o" \
    "RRESP:s_${port_prefix}_rresp_o" \
    "RLAST:s_${port_prefix}_rlast_o" \
    "RVALID:s_${port_prefix}_rvalid_o" \
    "RREADY:s_${port_prefix}_rready_i"]

  puts "Add AXI4 slave BIF '$bif_name' to HDL core '$hdl_core_name'"

  hdl_core_add_bif \
    -hdl_core_name $hdl_core_name \
    -bif_definition {AXI4:AMBA:AMBA4:slave} \
    -bif_name $bif_name \
    -signal_map $signal_map
}

# -----------------------------------------------------------------------------
# Paths
# -----------------------------------------------------------------------------
set component_script_dir [file normalize [file dirname [info script]]]

# This file is located in:
#   riscv-core-harness/MPFS_DISCOVERY_KIT/FPGA/script_support/components
set fpga_dir [file normalize [file join $component_script_dir "../.."]]

# From:
#   riscv-core-harness/MPFS_DISCOVERY_KIT/FPGA
# go back to:
#   riscv-core-harness
set harness_root [file normalize [file join $fpga_dir "../.."]]

# Parent project using the harness.
set project_root [file normalize [file join $harness_root ".."]]

# DUT_DIR is expected to be passed by the Makefile:
#   SCRIPT_ARGS:DUT_DIR:<absolute path>
#
# Fallback:
#   <project_root>/core
if {![info exists DUT_DIR]} {
  set DUT_DIR ""
}

set DUT_DIR [string trim $DUT_DIR]

if {$DUT_DIR eq ""} {
  set DUT_DIR [file join $project_root "risc-v"]
}

set dut_dir      [file normalize $DUT_DIR]
set hardware_dir [file normalize [file join $harness_root "hardware"]]
set sources_dir  [file normalize [file join $fpga_dir "sources"]]

puts "Component script directory : $component_script_dir"
puts "FPGA directory             : $fpga_dir"
puts "Harness root               : $harness_root"
puts "Project root               : $project_root"
puts "DUT directory              : $dut_dir"
puts "Hardware directory         : $hardware_dir"
puts "MPFS sources directory     : $sources_dir"

if {![file isdirectory $dut_dir]} {
  error "DUT directory does not exist: $dut_dir"
}

if {![file isdirectory $hardware_dir]} {
  error "Hardware directory does not exist: $hardware_dir"
}

if {![file isdirectory $sources_dir]} {
  error "MPFS sources directory does not exist: $sources_dir"
}

set top_module "riscv_core_harness"

# -----------------------------------------------------------------------------
# Collect, order and import DUT sources
# -----------------------------------------------------------------------------
set dut_files [collect_files_recursive_multi $dut_dir [list "*.sv" "*.svh" "*.v" "*.vh"]]
set ordered_dut_files [order_hdl_files $dut_files]

puts "DUT HDL files found: [llength $dut_files]"

foreach file $ordered_dut_files {
  puts "  DUT HDL: $file"
}

if {[llength $dut_files] == 0} {
  error "No HDL files found in DUT directory: $dut_dir"
}

libero_import_hdl_sources $ordered_dut_files

# -----------------------------------------------------------------------------
# Import riscv-core-harness common sources
# -----------------------------------------------------------------------------
libero_import_hdl_source [file join $hardware_dir "common/target_pkg.sv"]
libero_import_hdl_source [file join $hardware_dir "common/axi_if.sv"]

# -----------------------------------------------------------------------------
# Import MPFS-specific memory wrappers
# -----------------------------------------------------------------------------
libero_import_hdl_source [file join $sources_dir "dpram_2048.sv"]
libero_import_hdl_source [file join $sources_dir "dpram_4096.sv"]

# -----------------------------------------------------------------------------
# Import riscv-core-harness hardware harness sources
# -----------------------------------------------------------------------------
libero_import_hdl_source [file join $hardware_dir "harness/axi2obi.sv"]
libero_import_hdl_source [file join $hardware_dir "harness/async_fifo.sv"]
libero_import_hdl_source [file join $hardware_dir "harness/dpram.sv"]
libero_import_hdl_source [file join $hardware_dir "harness/sys_reset.sv"]
libero_import_hdl_source [file join $hardware_dir "harness/xbar.sv"]
libero_import_hdl_source [file join $hardware_dir "harness/riscv_core_harness.sv"]

# -----------------------------------------------------------------------------
# Build hierarchy and create HDL core
# -----------------------------------------------------------------------------
build_design_hierarchy

create_hdl_core \
  -file hdl/riscv_core_harness.sv \
  -module {riscv_core_harness} \
  -library {work} \
  -package {}

# -----------------------------------------------------------------------------
# Add AXI4 slave bus interfaces to the HDL core
# -----------------------------------------------------------------------------
add_axi4_slave_bif $top_module {SYS_RESET_AXI4_TARGET} {sys_reset}
add_axi4_slave_bif $top_module {INSTR_AXI4_TARGET}     {instr}
add_axi4_slave_bif $top_module {DATA_AXI4_TARGET}      {data}
add_axi4_slave_bif $top_module {PTC_AXI4_TARGET}       {ptc}
add_axi4_slave_bif $top_module {CTP_AXI4_TARGET}       {ctp}
