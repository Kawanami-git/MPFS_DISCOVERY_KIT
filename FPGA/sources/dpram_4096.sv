// SPDX-License-Identifier: MIT
/*!
********************************************************************************
\file       dpram_4096.sv
\brief      32-bit or 64-bit dual-port RAM built from 2048-word DPRAM banks

\author     Kawanami
\date       02/05/2026
\version    1.0

\details
  This module implements a 4096-word true dual-port RAM by composing two
  2048-word DPRAM banks.

  The logical data width can be either:
  - 32 bits, using two 32-bit dpram_2048 banks.
  - 64 bits, using two 64-bit dpram_2048 banks.

  Address bit AddrWidth-1 selects the 2048-word bank:
  - 0: lower bank, addresses 0 to 2047
  - 1: upper bank, addresses 2048 to 4095

  The lower address bits select the word inside the selected 2048-word bank.

  Because the underlying DPRAM has registered read data, the bank select used
  for the read-data mux is also registered on each port when a read request is
  issued. This keeps the returned data aligned with the bank that accepted the
  read access.

\section dpram_4096_scope Scope and limitations
  - Depth is fixed to 4096 words.
  - Read and write latency follows the underlying dpram_2048 implementation.
  - Byte-enable writes are supported on both ports.
  - DataWidth values other than 32 and 64 are not supported.
  - No arbitration is performed between ports; each dpram_2048 bank remains a
    true dual-port memory.

\remarks
  - This wrapper assumes that dpram_2048 is available in the compilation flow.
  - The wrapper preserves the same external interface style as dpram_2048.
  - The read-data mux uses registered bank selection to account for the one-cycle
    read latency of the underlying memory banks.

\section dpram_4096_version_history Version history
| Version | Date       | Author   | Description                    |
|:-------:|:----------:|:---------|:-------------------------------|
| 1.0     | 02/05/2026 | Kawanami | Initial version of the module. |
********************************************************************************
*/

module dpram_4096 #(
    /// External data width in bits. Supported values are 32 and 64.
    parameter int unsigned DataWidth = 32,
    /// Total number of words. This wrapper only supports 4096.
    parameter int unsigned Depth     = 4096,
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
  // Local parameters
  // ---------------------------------------------------------------------------

  /// Number of words per internal bank.
  localparam int unsigned BANK_DEPTH = 2048;

  /// Address width of each internal 2048-word bank.
  localparam int unsigned BANK_ADDR_WIDTH = $clog2(BANK_DEPTH);

  /// Index of the bank-select bit in the external address.
  localparam int unsigned BANK_SELECT_BIT = AddrWidth - 1;

  // ---------------------------------------------------------------------------
  // Elaboration checks
  // ---------------------------------------------------------------------------

  // synthesis translate_off
  initial begin
    if (Depth != 4096) begin
      $fatal(1, "dpram_4096: Depth must be exactly 4096");
    end

    if (DataWidth != 32 && DataWidth != 64) begin
      $fatal(1, "dpram_4096: DataWidth must be either 32 or 64");
    end

    if (AddrWidth != 12) begin
      $fatal(1, "dpram_4096: AddrWidth must be 12 for Depth=4096");
    end
  end
  // synthesis translate_on

  // ---------------------------------------------------------------------------
  // Bank selection
  // ---------------------------------------------------------------------------

  /// Port A selected bank: 0 = lower bank, 1 = upper bank.
  logic a_bank_sel;

  /// Port B selected bank: 0 = lower bank, 1 = upper bank.
  logic b_bank_sel;

  /// Port A address inside the selected 2048-word bank.
  logic [BANK_ADDR_WIDTH-1:0] a_bank_addr;

  /// Port B address inside the selected 2048-word bank.
  logic [BANK_ADDR_WIDTH-1:0] b_bank_addr;

  /// Port A registered read bank selection.
  logic a_rbank_sel_q;

  /// Port B registered read bank selection.
  logic b_rbank_sel_q;

  /// Select the 2048-word bank for Port A.
  assign a_bank_sel = a_addr_i[BANK_SELECT_BIT];

  /// Select the 2048-word bank for Port B.
  assign b_bank_sel = b_addr_i[BANK_SELECT_BIT];

  /// Extract Port A local bank address.
  assign a_bank_addr = a_addr_i[BANK_ADDR_WIDTH-1:0];

  /// Extract Port B local bank address.
  assign b_bank_addr = b_addr_i[BANK_ADDR_WIDTH-1:0];

  /*!
   * \brief Register Port A read bank selection.
   *
   * The read data returns with the underlying memory latency. Therefore, the
   * read-data mux must use the bank selected at read-request time, not the
   * current address bank.
   */
  always_ff @(posedge a_clk_i) begin
    if (a_rden_i) begin
      a_rbank_sel_q <= a_bank_sel;
    end
  end

  /*!
   * \brief Register Port B read bank selection.
   */
  always_ff @(posedge b_clk_i) begin
    if (b_rden_i) begin
      b_rbank_sel_q <= b_bank_sel;
    end
  end

  // ---------------------------------------------------------------------------
  // Bank enables
  // ---------------------------------------------------------------------------

  /// Port A write enable for the lower bank.
  logic a_wren_lo;

  /// Port A write enable for the upper bank.
  logic a_wren_hi;

  /// Port A read enable for the lower bank.
  logic a_rden_lo;

  /// Port A read enable for the upper bank.
  logic a_rden_hi;

  /// Port B write enable for the lower bank.
  logic b_wren_lo;

  /// Port B write enable for the upper bank.
  logic b_wren_hi;

  /// Port B read enable for the lower bank.
  logic b_rden_lo;

  /// Port B read enable for the upper bank.
  logic b_rden_hi;

  /// Decode Port A lower-bank write access.
  assign a_wren_lo = a_wren_i && !a_bank_sel;

  /// Decode Port A upper-bank write access.
  assign a_wren_hi = a_wren_i && a_bank_sel;

  /// Decode Port A lower-bank read access.
  assign a_rden_lo = a_rden_i && !a_bank_sel;

  /// Decode Port A upper-bank read access.
  assign a_rden_hi = a_rden_i && a_bank_sel;

  /// Decode Port B lower-bank write access.
  assign b_wren_lo = b_wren_i && !b_bank_sel;

  /// Decode Port B upper-bank write access.
  assign b_wren_hi = b_wren_i && b_bank_sel;

  /// Decode Port B lower-bank read access.
  assign b_rden_lo = b_rden_i && !b_bank_sel;

  /// Decode Port B upper-bank read access.
  assign b_rden_hi = b_rden_i && b_bank_sel;

  // ---------------------------------------------------------------------------
  // Bank read data
  // ---------------------------------------------------------------------------

  /// Port A read data returned by the lower bank.
  logic [DataWidth-1:0] a_rdata_lo;

  /// Port A read data returned by the upper bank.
  logic [DataWidth-1:0] a_rdata_hi;

  /// Port B read data returned by the lower bank.
  logic [DataWidth-1:0] b_rdata_lo;

  /// Port B read data returned by the upper bank.
  logic [DataWidth-1:0] b_rdata_hi;

  /// Select Port A read data from the bank selected at read-request time.
  assign a_rdata_o = a_rbank_sel_q ? a_rdata_hi : a_rdata_lo;

  /// Select Port B read data from the bank selected at read-request time.
  assign b_rdata_o = b_rbank_sel_q ? b_rdata_hi : b_rdata_lo;

  // ---------------------------------------------------------------------------
  // 2048-word banks
  // ---------------------------------------------------------------------------

  /// Lower 2048-word bank.
  dpram_2048 #(
      .DataWidth(DataWidth),
      .Depth    (BANK_DEPTH),
      .AddrWidth(BANK_ADDR_WIDTH)
  ) ram_lo (
      .a_clk_i  (a_clk_i),
      .a_addr_i (a_bank_addr),
      .a_wdata_i(a_wdata_i),
      .a_be_i   (a_be_i),
      .a_wren_i (a_wren_lo),
      .a_rden_i (a_rden_lo),
      .a_rdata_o(a_rdata_lo),

      .b_clk_i  (b_clk_i),
      .b_addr_i (b_bank_addr),
      .b_wdata_i(b_wdata_i),
      .b_be_i   (b_be_i),
      .b_wren_i (b_wren_lo),
      .b_rden_i (b_rden_lo),
      .b_rdata_o(b_rdata_lo)
  );

  /// Upper 2048-word bank.
  dpram_2048 #(
      .DataWidth(DataWidth),
      .Depth    (BANK_DEPTH),
      .AddrWidth(BANK_ADDR_WIDTH)
  ) ram_hi (
      .a_clk_i  (a_clk_i),
      .a_addr_i (a_bank_addr),
      .a_wdata_i(a_wdata_i),
      .a_be_i   (a_be_i),
      .a_wren_i (a_wren_hi),
      .a_rden_i (a_rden_hi),
      .a_rdata_o(a_rdata_hi),

      .b_clk_i  (b_clk_i),
      .b_addr_i (b_bank_addr),
      .b_wdata_i(b_wdata_i),
      .b_be_i   (b_be_i),
      .b_wren_i (b_wren_hi),
      .b_rden_i (b_rden_hi),
      .b_rdata_o(b_rdata_hi)
  );

endmodule
