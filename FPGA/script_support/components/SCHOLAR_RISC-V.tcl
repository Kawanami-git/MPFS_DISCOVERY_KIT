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
# Sort SystemVerilog files by compilation priority
#
# Order:
#   1. Packages      (*_pkg.sv)
#   2. Interfaces    (*_if.sv)
#   3. Other modules (*.sv)
# -----------------------------------------------------------------------------
proc order_systemverilog_files {files} {
  set packages   {}
  set interfaces {}
  set modules    {}

  foreach file $files {
    set name [file tail $file]

    if {[string match "*_pkg.sv" $name]} {
      lappend packages $file
    } elseif {[string match "*_if.sv" $name]} {
      lappend interfaces $file
    } else {
      lappend modules $file
    }
  }

  return [concat \
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
# Paths
# -----------------------------------------------------------------------------
set component_script_dir [file normalize [file dirname [info script]]]

# This file is located in:
#   FPGA/script_support/components
# Therefore, go back to the FPGA directory first.
set fpga_dir [file normalize [file join $component_script_dir "../.."]]

# From:
#   SCHOLAR_RISC-V/riscv-core-harness/MPFS_DISCOVERY_KIT/FPGA
# go back to:
#   SCHOLAR_RISC-V
set project_root [file normalize [file join $fpga_dir "../../.."]]

set riscv_dir     [file normalize [file join $project_root "risc-v"]]

puts "Component script directory : $component_script_dir"
puts "FPGA directory             : $fpga_dir"
puts "Project root               : $project_root"
puts "Core directory             : $riscv_dir"

if {![file isdirectory $riscv_dir]} {
  error "Core directory does not exist: $riscv_dir"
}

set top_module "riscv_core_harness"

# -----------------------------------------------------------------------------
# Collect, order, import and organize sources
# -----------------------------------------------------------------------------
set sv_files [collect_files_recursive $riscv_dir "*.sv"]
set ordered_sv_files [order_systemverilog_files $sv_files]

puts "SV files found   : [llength $sv_files]"

foreach file $ordered_sv_files {
  puts "  HDL: $file"
}

if {[llength $sv_files] == 0} {
  error "No SystemVerilog files found in core directory: $riscv_dir"
}

libero_import_hdl_sources $ordered_sv_files
# libero_organize_synthesis_sources $ordered_sv_files

import_files -hdl_source {../../../hardware/common/target_pkg.sv}
import_files -hdl_source {../../../hardware/common/axi_if.sv}

import_files -hdl_source {../sources/dpram_20x1024.sv}
import_files -hdl_source {../sources/dpram_40x1024.sv}
import_files -hdl_source {../sources/dpram_32w.sv}
import_files -hdl_source {../sources/dpram_64w.sv}
import_files -hdl_source {../../../hardware/harness/axi2ram.sv}
import_files -hdl_source {../../../hardware/harness/async_fifo.sv}
import_files -hdl_source {../../../hardware/harness/dpram.sv}
import_files -hdl_source {../../../hardware/harness/sys_reset.sv}
import_files -hdl_source {../../../hardware/harness/xbar.sv}
import_files -hdl_source {../../../hardware/harness/riscv_core_harness.sv}

build_design_hierarchy

create_hdl_core -file hdl/riscv_core_harness.sv -module {riscv_core_harness} -library {work} -package {}

hdl_core_add_bif -hdl_core_name {riscv_core_harness} -bif_definition {AXI4:AMBA:AMBA4:slave} -bif_name {SYS_RESET_AXI4_TARGET} -signal_map {\
"AWID:s_sys_reset_awid_i" \
"AWADDR:s_sys_reset_awaddr_i" \
"AWLEN:s_sys_reset_awlen_i" \
"AWSIZE:s_sys_reset_awsize_i" \
"AWBURST:s_sys_reset_awburst_i" \
"AWLOCK:s_sys_reset_awlock_i" \
"AWCACHE:s_sys_reset_awcache_i" \
"AWPROT:s_sys_reset_awprot_i" \
"AWVALID:s_sys_reset_awvalid_i" \
"AWREADY:s_sys_reset_awready_o" \
"WDATA:s_sys_reset_wdata_i" \
"WSTRB:s_sys_reset_wstrb_i" \
"WLAST:s_sys_reset_wlast_i" \
"WVALID:s_sys_reset_wvalid_i" \
"WREADY:s_sys_reset_wready_o" \
"BID:s_sys_reset_bid_o" \
"BRESP:s_sys_reset_bresp_o" \
"BVALID:s_sys_reset_bvalid_o" \
"BREADY:s_sys_reset_bready_i" \
"ARID:s_sys_reset_arid_i" \
"ARADDR:s_sys_reset_araddr_i" \
"ARLEN:s_sys_reset_arlen_i" \
"ARSIZE:s_sys_reset_arsize_i" \
"ARBURST:s_sys_reset_arburst_i" \
"ARLOCK:s_sys_reset_arlock_i" \
"ARCACHE:s_sys_reset_arcache_i" \
"ARPROT:s_sys_reset_arprot_i" \
"ARVALID:s_sys_reset_arvalid_i" \
"ARREADY:s_sys_reset_arready_o" \
"RID:s_sys_reset_rid_o" \
"RDATA:s_sys_reset_rdata_o" \
"RRESP:s_sys_reset_rresp_o" \
"RLAST:s_sys_reset_rlast_o" \
"RVALID:s_sys_reset_rvalid_o" \
"RREADY:s_sys_reset_rready_i" }


hdl_core_add_bif -hdl_core_name {riscv_core_harness} -bif_definition {AXI4:AMBA:AMBA4:slave} -bif_name {INSTR_AXI4_TARGET} -signal_map {\
"AWID:s_instr_awid_i" \
"AWADDR:s_instr_awaddr_i" \
"AWLEN:s_instr_awlen_i" \
"AWSIZE:s_instr_awsize_i" \
"AWBURST:s_instr_awburst_i" \
"AWLOCK:s_instr_awlock_i" \
"AWCACHE:s_instr_awcache_i" \
"AWPROT:s_instr_awprot_i" \
"AWVALID:s_instr_awvalid_i" \
"AWREADY:s_instr_awready_o" \
"WDATA:s_instr_wdata_i" \
"WSTRB:s_instr_wstrb_i" \
"WLAST:s_instr_wlast_i" \
"WVALID:s_instr_wvalid_i" \
"WREADY:s_instr_wready_o" \
"BID:s_instr_bid_o" \
"BRESP:s_instr_bresp_o" \
"BVALID:s_instr_bvalid_o" \
"BREADY:s_instr_bready_i" \
"ARID:s_instr_arid_i" \
"ARADDR:s_instr_araddr_i" \
"ARLEN:s_instr_arlen_i" \
"ARSIZE:s_instr_arsize_i" \
"ARBURST:s_instr_arburst_i" \
"ARLOCK:s_instr_arlock_i" \
"ARCACHE:s_instr_arcache_i" \
"ARPROT:s_instr_arprot_i" \
"ARVALID:s_instr_arvalid_i" \
"ARREADY:s_instr_arready_o" \
"RID:s_instr_rid_o" \
"RDATA:s_instr_rdata_o" \
"RRESP:s_instr_rresp_o" \
"RLAST:s_instr_rlast_o" \
"RVALID:s_instr_rvalid_o" \
"RREADY:s_instr_rready_i" }

hdl_core_add_bif -hdl_core_name {riscv_core_harness} -bif_definition {AXI4:AMBA:AMBA4:slave} -bif_name {DATA_AXI4_TARGET} -signal_map {\
"AWID:s_data_awid_i" \
"AWADDR:s_data_awaddr_i" \
"AWLEN:s_data_awlen_i" \
"AWSIZE:s_data_awsize_i" \
"AWBURST:s_data_awburst_i" \
"AWLOCK:s_data_awlock_i" \
"AWCACHE:s_data_awcache_i" \
"AWPROT:s_data_awprot_i" \
"AWVALID:s_data_awvalid_i" \
"AWREADY:s_data_awready_o" \
"WDATA:s_data_wdata_i" \
"WSTRB:s_data_wstrb_i" \
"WLAST:s_data_wlast_i" \
"WVALID:s_data_wvalid_i" \
"WREADY:s_data_wready_o" \
"BID:s_data_bid_o" \
"BRESP:s_data_bresp_o" \
"BVALID:s_data_bvalid_o" \
"BREADY:s_data_bready_i" \
"ARID:s_data_arid_i" \
"ARADDR:s_data_araddr_i" \
"ARLEN:s_data_arlen_i" \
"ARSIZE:s_data_arsize_i" \
"ARBURST:s_data_arburst_i" \
"ARLOCK:s_data_arlock_i" \
"ARCACHE:s_data_arcache_i" \
"ARPROT:s_data_arprot_i" \
"ARVALID:s_data_arvalid_i" \
"ARREADY:s_data_arready_o" \
"RID:s_data_rid_o" \
"RDATA:s_data_rdata_o" \
"RRESP:s_data_rresp_o" \
"RLAST:s_data_rlast_o" \
"RVALID:s_data_rvalid_o" \
"RREADY:s_data_rready_i" }

hdl_core_add_bif -hdl_core_name {riscv_core_harness} -bif_definition {AXI4:AMBA:AMBA4:slave} -bif_name {PTC_AXI4_TARGET} -signal_map {\
"AWID:s_ptc_awid_i" \
"AWADDR:s_ptc_awaddr_i" \
"AWLEN:s_ptc_awlen_i" \
"AWSIZE:s_ptc_awsize_i" \
"AWBURST:s_ptc_awburst_i" \
"AWLOCK:s_ptc_awlock_i" \
"AWCACHE:s_ptc_awcache_i" \
"AWPROT:s_ptc_awprot_i" \
"AWVALID:s_ptc_awvalid_i" \
"AWREADY:s_ptc_awready_o" \
"WDATA:s_ptc_wdata_i" \
"WSTRB:s_ptc_wstrb_i" \
"WLAST:s_ptc_wlast_i" \
"WVALID:s_ptc_wvalid_i" \
"WREADY:s_ptc_wready_o" \
"BID:s_ptc_bid_o" \
"BRESP:s_ptc_bresp_o" \
"BVALID:s_ptc_bvalid_o" \
"BREADY:s_ptc_bready_i" \
"ARID:s_ptc_arid_i" \
"ARADDR:s_ptc_araddr_i" \
"ARLEN:s_ptc_arlen_i" \
"ARSIZE:s_ptc_arsize_i" \
"ARBURST:s_ptc_arburst_i" \
"ARLOCK:s_ptc_arlock_i" \
"ARCACHE:s_ptc_arcache_i" \
"ARPROT:s_ptc_arprot_i" \
"ARVALID:s_ptc_arvalid_i" \
"ARREADY:s_ptc_arready_o" \
"RID:s_ptc_rid_o" \
"RDATA:s_ptc_rdata_o" \
"RRESP:s_ptc_rresp_o" \
"RLAST:s_ptc_rlast_o" \
"RVALID:s_ptc_rvalid_o" \
"RREADY:s_ptc_rready_i" }

hdl_core_add_bif -hdl_core_name {riscv_core_harness} -bif_definition {AXI4:AMBA:AMBA4:slave} -bif_name {CTP_AXI4_TARGET} -signal_map {\
"AWID:s_ctp_awid_i" \
"AWADDR:s_ctp_awaddr_i" \
"AWLEN:s_ctp_awlen_i" \
"AWSIZE:s_ctp_awsize_i" \
"AWBURST:s_ctp_awburst_i" \
"AWLOCK:s_ctp_awlock_i" \
"AWCACHE:s_ctp_awcache_i" \
"AWPROT:s_ctp_awprot_i" \
"AWVALID:s_ctp_awvalid_i" \
"AWREADY:s_ctp_awready_o" \
"WDATA:s_ctp_wdata_i" \
"WSTRB:s_ctp_wstrb_i" \
"WLAST:s_ctp_wlast_i" \
"WVALID:s_ctp_wvalid_i" \
"WREADY:s_ctp_wready_o" \
"BID:s_ctp_bid_o" \
"BRESP:s_ctp_bresp_o" \
"BVALID:s_ctp_bvalid_o" \
"BREADY:s_ctp_bready_i" \
"ARID:s_ctp_arid_i" \
"ARADDR:s_ctp_araddr_i" \
"ARLEN:s_ctp_arlen_i" \
"ARSIZE:s_ctp_arsize_i" \
"ARBURST:s_ctp_arburst_i" \
"ARLOCK:s_ctp_arlock_i" \
"ARCACHE:s_ctp_arcache_i" \
"ARPROT:s_ctp_arprot_i" \
"ARVALID:s_ctp_arvalid_i" \
"ARREADY:s_ctp_arready_o" \
"RID:s_ctp_rid_o" \
"RDATA:s_ctp_rdata_o" \
"RRESP:s_ctp_rresp_o" \
"RLAST:s_ctp_rlast_o" \
"RVALID:s_ctp_rvalid_o" \
"RREADY:s_ctp_rready_i" }
