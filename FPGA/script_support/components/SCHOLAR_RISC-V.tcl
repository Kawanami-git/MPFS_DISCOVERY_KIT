import_files -hdl_source {../../../hardware/core/gpr/gpr.sv}
import_files -hdl_source {../../../hardware/core/csr/csr.sv}
import_files -hdl_source {../../../hardware/core/fetch/fetch.sv}
import_files -hdl_source {../../../hardware/core/decode/decode.sv}
import_files -hdl_source {../../../hardware/core/exe/exe.sv}
import_files -hdl_source {../../../hardware/core/writeback/writeback.sv}
import_files -hdl_source {../../../hardware/core/scholar_riscv_core.sv}

import_files -hdl_source {../../../hardware/env/raxi_dpram.sv}
import_files -hdl_source {../../../hardware/env/waxi_dpram.sv}
import_files -hdl_source {../../../hardware/env/microchip/dpram_20x1024.sv}
import_files -hdl_source {../../../hardware/env/microchip/dpram_40x1024.sv}
import_files -hdl_source {../../../hardware/env/dpram_32w.sv}
import_files -hdl_source {../../../hardware/env/dpram_64w.sv}
import_files -hdl_source {../../../hardware/env/dpram.sv}
import_files -hdl_source {../../../hardware/env/bus_fabric.sv}
import_files -hdl_source {../../../hardware/env/riscv_env.sv}

build_design_hierarchy

create_hdl_core -file hdl/riscv_env.sv -module {riscv_env} -library {work} -package {}

hdl_core_add_bif -hdl_core_name {riscv_env} -bif_definition {AXI4:AMBA:AMBA4:slave} -bif_name {INSTR_AXI4_TARGET} -signal_map {\
"AWID:s_instr_axi_awid_i" \
"AWADDR:s_instr_axi_awaddr_i" \
"AWLEN:s_instr_axi_awlen_i" \
"AWSIZE:s_instr_axi_awsize_i" \
"AWBURST:s_instr_axi_awburst_i" \
"AWLOCK:s_instr_axi_awlock_i" \
"AWCACHE:s_instr_axi_awcache_i" \
"AWPROT:s_instr_axi_awprot_i" \
"AWVALID:s_instr_axi_awvalid_i" \
"AWREADY:s_instr_axi_awready_o" \
"WDATA:s_instr_axi_wdata_i" \
"WSTRB:s_instr_axi_wstrb_i" \
"WLAST:s_instr_axi_wlast_i" \
"WVALID:s_instr_axi_wvalid_i" \
"WREADY:s_instr_axi_wready_o" \
"BID:s_instr_axi_bid_o" \
"BRESP:s_instr_axi_bresp_o" \
"BVALID:s_instr_axi_bvalid_o" \
"BREADY:s_instr_axi_bready_i" }

hdl_core_add_bif -hdl_core_name {riscv_env} -bif_definition {AXI4:AMBA:AMBA4:slave} -bif_name {AXI4_TARGET} -signal_map {\
"AWID:s_axi_awid_i" \
"AWADDR:s_axi_awaddr_i" \
"AWLEN:s_axi_awlen_i" \
"AWSIZE:s_axi_awsize_i" \
"AWBURST:s_axi_awburst_i" \
"AWLOCK:s_axi_awlock_i" \
"AWCACHE:s_axi_awcache_i" \
"AWPROT:s_axi_awprot_i" \
"AWVALID:s_axi_awvalid_i" \
"AWREADY:s_axi_awready_o" \
"WDATA:s_axi_wdata_i" \
"WSTRB:s_axi_wstrb_i" \
"WLAST:s_axi_wlast_i" \
"WVALID:s_axi_wvalid_i" \
"WREADY:s_axi_wready_o" \
"BID:s_axi_bid_o" \
"BRESP:s_axi_bresp_o" \
"BVALID:s_axi_bvalid_o" \
"BREADY:s_axi_bready_i" \
"ARID:s_axi_arid_i" \
"ARADDR:s_axi_araddr_i" \
"ARLEN:s_axi_arlen_i" \
"ARSIZE:s_axi_arsize_i" \
"ARBURST:s_axi_arburst_i" \
"ARLOCK:s_axi_arlock_i" \
"ARCACHE:s_axi_arcache_i" \
"ARPROT:s_axi_arprot_i" \
"ARVALID:s_axi_arvalid_i" \
"ARREADY:s_axi_arready_o" \
"RID:s_axi_rid_o" \
"RDATA:s_axi_rdata_o" \
"RRESP:s_axi_rresp_o" \
"RLAST:s_axi_rlast_o" \
"RVALID:s_axi_rvalid_o" \
"RREADY:s_axi_rready_i" }
