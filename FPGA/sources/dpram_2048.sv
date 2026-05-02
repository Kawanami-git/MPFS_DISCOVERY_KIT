// SPDX-License-Identifier: MIT
/*!
********************************************************************************
\file       dpram_2048.sv
\brief      32-bit or 64-bit dual-port RAM backed by Microchip 32-bit DPSRAM blocks

\author     Kawanami
\date       02/05/2026
\version    1.0

\details
  This module implements a 2048-word true dual-port RAM for the MPFS Discovery
  Kit target.

  The logical data width can be either:
  - 32 bits, implemented with one DPSRAM_32x2048 macro.
  - 64 bits, implemented with two DPSRAM_32x2048 macros.

  The Microchip DPSRAM_32x2048 macro exposes a 32-bit data bus and 4 byte-enable
  bits. Therefore, this wrapper keeps a direct and natural mapping between the
  logical RISC-V byte-enable bits and the physical Microchip byte-enable bits.

  For 64-bit memories, the logical word is split into two 32-bit halves:
  - lower DPSRAM_32x2048: data[31:0], controlled by be[3:0]
  - upper DPSRAM_32x2048: data[63:32], controlled by be[7:4]

\section dpram_2048_scope Scope and limitations
  - Depth is fixed to 2048 words.
  - Read and write latency follows the generated Microchip DPSRAM macro.
  - Byte-enable writes are supported on both ports.
  - DataWidth values other than 32 and 64 are not supported.

\remarks
  - This wrapper assumes that the generated Microchip macro is named
    DPSRAM_32x2048 and exposes the same flat port names used below.
  - For 64-bit operation, both 32-bit macros are read together so that a complete
    64-bit word is returned.
  - For 64-bit writes, each 32-bit half is written only when at least one byte
    lane of that half is enabled.

\section dpram_2048_version_history Version history
| Version | Date       | Author   | Description                    |
|:-------:|:----------:|:---------|:-------------------------------|
| 1.0     | 02/05/2026 | Kawanami | Initial version of the module. |
********************************************************************************
*/

module dpram_2048 #(
    /// External data width in bits. Supported values are 32 and 64.
    parameter int unsigned DataWidth = 32,
    /// Total number of words. This wrapper only supports 2048.
    parameter int unsigned Depth     = 2048,
    /// Address width in bits.
    parameter int unsigned AddrWidth = $clog2(Depth)
) (
    /// Port A clock.
    input  logic                       a_clk_i,
    /// Port A word address.
    input  logic [AddrWidth   - 1 : 0] a_addr_i,
    /// Port A write data.
    input  logic [DataWidth   - 1 : 0] a_wdata_i,
    /// Port A byte-enable, one bit per logical 8-bit byte.
    input  logic [DataWidth/8 - 1 : 0] a_be_i,
    /// Port A write enable.
    input  logic                       a_wren_i,
    /// Port A read enable.
    input  logic                       a_rden_i,
    /// Port A read data.
    output logic [DataWidth   - 1 : 0] a_rdata_o,

    /// Port B clock.
    input  logic                       b_clk_i,
    /// Port B word address.
    input  logic [AddrWidth   - 1 : 0] b_addr_i,
    /// Port B write data.
    input  logic [DataWidth   - 1 : 0] b_wdata_i,
    /// Port B byte-enable, one bit per logical 8-bit byte.
    input  logic [DataWidth/8 - 1 : 0] b_be_i,
    /// Port B write enable.
    input  logic                       b_wren_i,
    /// Port B read enable.
    input  logic                       b_rden_i,
    /// Port B read data.
    output logic [DataWidth   - 1 : 0] b_rdata_o
);

  // ---------------------------------------------------------------------------
  // Elaboration checks
  // ---------------------------------------------------------------------------

  // synthesis translate_off
  initial begin
    if (Depth != 2048) begin
      $fatal(1, "dpram_2048: Depth must be exactly 2048");
    end

    if (DataWidth != 32 && DataWidth != 64) begin
      $fatal(1, "dpram_2048: DataWidth must be either 32 or 64");
    end

    if (AddrWidth != 11) begin
      $fatal(1, "dpram_2048: AddrWidth must be 11 for Depth=2048");
    end
  end
  // synthesis translate_on

  generate
    if (DataWidth == 32) begin : gen_dpram_32

      /// 32-bit logical DPRAM implemented with one 32-bit Microchip DPSRAM macro.
      DPSRAM_32x2048 ram (
          .A_CLK     (a_clk_i),
          .A_ADDR    (a_addr_i),
          .A_DIN     (a_wdata_i),
          .A_WBYTE_EN(a_be_i),
          .A_WEN     (a_wren_i),
          .A_REN     (a_rden_i),
          .A_DOUT    (a_rdata_o),

          .B_CLK     (b_clk_i),
          .B_ADDR    (b_addr_i),
          .B_DIN     (b_wdata_i),
          .B_WBYTE_EN(b_be_i),
          .B_WEN     (b_wren_i),
          .B_REN     (b_rden_i),
          .B_DOUT    (b_rdata_o)
      );

    end else if (DataWidth == 64) begin : gen_dpram_64

      /// Lower 32-bit logical half of the 64-bit DPRAM.
      DPSRAM_32x2048 ram_lo (
          .A_CLK     (a_clk_i),
          .A_ADDR    (a_addr_i),
          .A_DIN     (a_wdata_i[31:0]),
          .A_WBYTE_EN(a_be_i[3:0]),
          .A_WEN     (a_wren_i),
          .A_REN     (a_rden_i),
          .A_DOUT    (a_rdata_o[31:0]),

          .B_CLK     (b_clk_i),
          .B_ADDR    (b_addr_i),
          .B_DIN     (b_wdata_i[31:0]),
          .B_WBYTE_EN(b_be_i[3:0]),
          .B_WEN     (b_wren_i),
          .B_REN     (b_rden_i),
          .B_DOUT    (b_rdata_o[31:0])
      );

      /// Upper 32-bit logical half of the 64-bit DPRAM.
      DPSRAM_32x2048 ram_hi (
          .A_CLK     (a_clk_i),
          .A_ADDR    (a_addr_i),
          .A_DIN     (a_wdata_i[63:32]),
          .A_WBYTE_EN(a_be_i[7:4]),
          .A_WEN     (a_wren_i),
          .A_REN     (a_rden_i),
          .A_DOUT    (a_rdata_o[63:32]),

          .B_CLK     (b_clk_i),
          .B_ADDR    (b_addr_i),
          .B_DIN     (b_wdata_i[63:32]),
          .B_WBYTE_EN(b_be_i[7:4]),
          .B_WEN     (b_wren_i),
          .B_REN     (b_rden_i),
          .B_DOUT    (b_rdata_o[63:32])
      );

    end else begin : gen_error

      // synthesis translate_off
      initial begin
        $fatal(1, "dpram_2048: Unsupported DataWidth");
      end
      // synthesis translate_on

    end
  endgenerate

endmodule
