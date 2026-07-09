module generic_regs #(
  parameter int ADDR_WIDTH = 12,
  parameter int DATA_WIDTH = 32,
  parameter int NUM_REGS = 4,
  parameter int WAIT_CYCLES = 0,
  parameter int REG_ADDR_WIDTH = (NUM_REGS <= 1) ? 1 : $clog2(NUM_REGS)
)(
  apb_if.completer apb,
  output logic [DATA_WIDTH-1:0] reg_wdata,
  output logic [(DATA_WIDTH/8)-1:0] reg_wstrb,
  output logic [2:0] reg_pprot,
  output logic [REG_ADDR_WIDTH-1:0] reg_waddr,
  output logic reg_wr_en,
  output logic [REG_ADDR_WIDTH-1:0] reg_raddr,
  input  logic [DATA_WIDTH-1:0] reg_rdata
);

  localparam int STRB_WIDTH = DATA_WIDTH / 8;
  localparam int ADDR_LSB   = (STRB_WIDTH <= 1) ? 0 : $clog2(STRB_WIDTH);
  localparam int WAIT_COUNT_WIDTH = (WAIT_CYCLES <= 1) ? 1 : $clog2(WAIT_CYCLES + 1);

  logic [ADDR_WIDTH-1:0]     word_addr;
  logic [REG_ADDR_WIDTH-1:0] reg_addr;
  logic [WAIT_COUNT_WIDTH-1:0] wait_count_q;
  logic aligned_addr;
  logic addr_in_range;
  logic setup_phase;
  logic access_phase;
  logic read_pulse;
  logic write_pulse;
  logic invalid_access;
  logic read_strobe_error;
  logic wait_req;
  logic [DATA_WIDTH-1:0] wstrb_mask;

  initial begin
    if (ADDR_WIDTH <= 0) begin
      $error("ADDR_WIDTH must be greater than zero");
    end

    if (ADDR_WIDTH > 32) begin
      $error("APB ADDR_WIDTH must be 32 bits or less");
    end

    if (!(DATA_WIDTH == 8 || DATA_WIDTH == 16 || DATA_WIDTH == 32)) begin
      $error("DATA_WIDTH must be 8, 16, or 32 bits");
    end

    if (NUM_REGS <= 0) begin
      $error("NUM_REGS must be greater than zero");
    end

    if (WAIT_CYCLES < 0) begin
      $error("WAIT_CYCLES must be greater than or equal to zero");
    end
  end

  assign word_addr = apb.PADDR >> ADDR_LSB;
  assign reg_addr = word_addr[REG_ADDR_WIDTH-1:0];
  assign addr_in_range = (word_addr < ADDR_WIDTH'(NUM_REGS));

  generate
    if (ADDR_LSB == 0) begin : g_no_byte_offset
      assign aligned_addr = 1'b1;
    end
    else begin : g_byte_offset
      assign aligned_addr = (apb.PADDR[ADDR_LSB-1:0] == '0);
    end
  endgenerate

  always_ff @(posedge apb.PCLK or negedge apb.PRESETn) begin
    if (!apb.PRESETn) begin
      wait_count_q <= '0;
    end
    else if (setup_phase) begin
      wait_count_q <= WAIT_COUNT_WIDTH'(WAIT_CYCLES);
    end
    else if (access_phase && wait_count_q != '0) begin
      wait_count_q <= wait_count_q - WAIT_COUNT_WIDTH'(1);
    end
  end

  assign wait_req = access_phase && (wait_count_q != '0);
  assign read_strobe_error = !apb.PWRITE && (apb.PSTRB != '0);
  assign invalid_access = !aligned_addr || !addr_in_range || read_strobe_error;

  apb_slave_ctrl u_ctrl (
    .apb(apb),
    .wait_req(wait_req),
    .slverr_in(invalid_access),
    .setup_phase(setup_phase),
    .access_phase(access_phase),
    .transfer_done(),
    .read_access(),
    .write_access(),
    .read_pulse(read_pulse),
    .write_pulse(write_pulse)
  );

  genvar byte_i;
  generate
    for (byte_i = 0; byte_i < STRB_WIDTH; byte_i++) begin : g_wstrb_mask
      assign wstrb_mask[(8*byte_i) +: 8] = {8{apb.PSTRB[byte_i]}};
    end
  endgenerate

  // reg_rdata must reflect the current selected register value for sparse writes.
  assign reg_wdata = (reg_rdata & ~wstrb_mask) | (apb.PWDATA & wstrb_mask);
  assign reg_wstrb = apb.PSTRB;
  assign reg_pprot = apb.PPROT;
  assign reg_waddr = reg_addr;
  assign reg_raddr = reg_addr;
  assign reg_wr_en = write_pulse && !invalid_access && (apb.PSTRB != '0);

  assign apb.PRDATA = (read_pulse && !invalid_access) ? reg_rdata : '0;

endmodule : generic_regs
