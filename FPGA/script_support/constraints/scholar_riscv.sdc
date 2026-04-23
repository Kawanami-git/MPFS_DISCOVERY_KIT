set_clock_groups -asynchronous \
  -group [get_clocks CLOCKS_AND_RESETS_0/CCC_FIC_x_CLK/PF_CCC_C0_0/pll_inst_0/OUT0] \
  -group [get_clocks CORES_CLOCKS_0/CORES_CLOCKS_0/pll_inst_0/OUT0]

# 1GHz
create_clock -name CORE_CLK -period 1.000 [get_pins {CORES_CLOCKS_0/CORES_CLOCKS_0/pll_inst_0/OUT0}]
