module timer_core #(
  parameter int DATA_WIDTH = 32,
  parameter int NUM_REGS = 3
)(
  input  logic                        clk,
  input  logic                        rst_n,

  input  logic                        reg_wr_en,
  input  logic [$clog2(NUM_REGS)-1:0] reg_waddr,
  input  logic [DATA_WIDTH-1:0]       reg_wdata,

  input  logic [$clog2(NUM_REGS)-1:0] reg_raddr,
  output logic [DATA_WIDTH-1:0]       reg_rdata,

  output logic                        irq_overflow,
  output logic                        irq_compare
);

  localparam int ADDR_TIMER = 0;
  localparam int ADDR_CTRL  = 1;
  localparam int ADDR_CMP   = 2;

  localparam logic [$clog2(NUM_REGS)-1:0] ADDR_TIMER_L = ADDR_TIMER[$clog2(NUM_REGS)-1:0];
  localparam logic [$clog2(NUM_REGS)-1:0] ADDR_CTRL_L  = ADDR_CTRL [$clog2(NUM_REGS)-1:0];
  localparam logic [$clog2(NUM_REGS)-1:0] ADDR_CMP_L   = ADDR_CMP  [$clog2(NUM_REGS)-1:0];

  localparam int CTRL_ENABLE_BIT    = 0;
  localparam int CTRL_PRESCALER_LSB = 1;
  localparam int CTRL_PRESCALER_MSB = 3;

  logic [DATA_WIDTH-1:0] timer_q;
  logic [3:0] ctrl_q;
  logic [DATA_WIDTH-1:0] cmp_q;

  logic [DATA_WIDTH-1:0] timer_d;
  logic [3:0]            ctrl_d;

  logic       prescaler_en;
  logic [2:0] prescaler_val;
  logic [2:0] prescaler_cnt_q;
  logic [2:0] prescaler_cnt_d;
  logic       timer_tick;

  initial begin
    if (!(DATA_WIDTH == 8 || DATA_WIDTH == 16 || DATA_WIDTH == 32)) begin
      $fatal(1, "DATA_WIDTH must be 8, 16, or 32 bits");
    end

    if (NUM_REGS != 3) begin
      $fatal(1, "timer_core expects exactly 3 registers");
    end
  end

  assign prescaler_en  = ctrl_q[CTRL_ENABLE_BIT];
  assign prescaler_val = ctrl_q[CTRL_PRESCALER_MSB : CTRL_PRESCALER_LSB];
  assign timer_tick = prescaler_en & ((prescaler_val == 3'b0) | (prescaler_cnt_q >= prescaler_val));

  // Next-state logic
  always_comb begin
    timer_d         = timer_q;
    ctrl_d          = ctrl_q;
    prescaler_cnt_d = prescaler_cnt_q;

    // APB write CTRL
    if (reg_wr_en && reg_waddr == ADDR_CTRL_L) begin
      ctrl_d = reg_wdata[3:0];
    end

    // TIMER update logic
    if (reg_wr_en && reg_waddr == ADDR_TIMER_L) begin
      timer_d = reg_wdata;
    end
    // Deliberate side effect: writing the CMP register also resets the
    // running timer count to 0. This is internal peripheral behavior
    // (outside APB protocol scope) and must be documented for software
    // drivers, since it is not implied by the register name alone.
    else if ((reg_wr_en && reg_waddr == ADDR_CMP_L) || irq_overflow || irq_compare) begin
      timer_d = '0;
    end
    else if (timer_tick) begin
      timer_d = timer_q + 1'b1;
    end

    // Prescaler counter logic
    if (!prescaler_en || prescaler_val == 3'b0 || prescaler_cnt_q >= prescaler_val) begin
      prescaler_cnt_d = 3'b0;
    end else begin
      prescaler_cnt_d = prescaler_cnt_q + 1'b1;
    end
  end

  // Sequential state
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      timer_q         <= '0;
      ctrl_q          <= 4'b0;
      cmp_q           <= '0;
      prescaler_cnt_q <= 3'b0;
    end else begin
      timer_q         <= timer_d;
      ctrl_q          <= ctrl_d;
      cmp_q           <= (reg_wr_en && reg_waddr == ADDR_CMP_L) ? reg_wdata : cmp_q;
      prescaler_cnt_q <= prescaler_cnt_d;
    end
  end

  assign irq_overflow = (timer_q == {DATA_WIDTH{1'b1}});
  assign irq_compare  = (timer_q == cmp_q) && (cmp_q != '0);

  // Register read
  always_comb begin
    case (reg_raddr)
      ADDR_TIMER_L: reg_rdata = timer_q;
      ADDR_CTRL_L : reg_rdata = {{(DATA_WIDTH-4){1'b0}}, ctrl_q};
      ADDR_CMP_L  : reg_rdata = cmp_q;
      default     : reg_rdata = '0;
    endcase
  end

endmodule
