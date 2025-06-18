import_files -hdl_source {../../../work/hdl/packages.sv}
import_files -hdl_source {../../../work/hdl/GPR.sv}
import_files -hdl_source {../../../work/hdl/CSR.sv}
import_files -hdl_source {../../../work/hdl/fetch.sv}
import_files -hdl_source {../../../work/hdl/decode.sv}
import_files -hdl_source {../../../work/hdl/exe.sv}
import_files -hdl_source {../../../work/hdl/commit.sv}
import_files -hdl_source {../../../work/hdl/scholar_riscv_core.sv}

import_files -hdl_source {../../../work/hdl/instr_dpram.sv}
import_files -hdl_source {../../../work/hdl/data_dpram.sv}
import_files -hdl_source {../../../work/hdl/ctp_dpram.sv}
import_files -hdl_source {../../../work/hdl/ptc_dpram.sv}
import_files -hdl_source {../../../work/hdl/bus_fabric.sv}
import_files -hdl_source {../../../work/hdl/riscv_env.sv}

build_design_hierarchy

create_hdl_core -file hdl/riscv_env.sv -module {riscv_env} -library {work} -package {}

hdl_core_add_bif -hdl_core_name {riscv_env} -bif_definition {AXI4:AMBA:AMBA4:slave} -bif_name {AXI4_TARGET} -signal_map {\
"AWID:S_AXI_AWID" \
"AWADDR:S_AXI_AWADDR" \
"AWLEN:S_AXI_AWLEN" \
"AWSIZE:S_AXI_AWSIZE" \
"AWBURST:S_AXI_AWBURST" \
"AWLOCK:S_AXI_AWLOCK" \
"AWCACHE:S_AXI_AWCACHE" \
"AWPROT:S_AXI_AWPROT" \
"AWVALID:S_AXI_AWVALID" \
"AWREADY:S_AXI_AWREADY" \
"WDATA:S_AXI_WDATA" \
"WSTRB:S_AXI_WSTRB" \
"WLAST:S_AXI_WLAST" \
"WVALID:S_AXI_WVALID" \
"WREADY:S_AXI_WREADY" \
"BID:S_AXI_BID" \
"BRESP:S_AXI_BRESP" \
"BVALID:S_AXI_BVALID" \
"BREADY:S_AXI_BREADY" \
"ARID:S_AXI_ARID" \
"ARADDR:S_AXI_ARADDR" \
"ARLEN:S_AXI_ARLEN" \
"ARSIZE:S_AXI_ARSIZE" \
"ARBURST:S_AXI_ARBURST" \
"ARLOCK:S_AXI_ARLOCK" \
"ARCACHE:S_AXI_ARCACHE" \
"ARPROT:S_AXI_ARPROT" \
"ARVALID:S_AXI_ARVALID" \
"ARREADY:S_AXI_ARREADY" \
"RID:S_AXI_RID" \
"RDATA:S_AXI_RDATA" \
"RRESP:S_AXI_RRESP" \
"RLAST:S_AXI_RLAST" \
"RVALID:S_AXI_RVALID" \
"RREADY:S_AXI_RREADY" }