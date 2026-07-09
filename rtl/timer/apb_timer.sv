module apb_timer #(
  parameter int ADDR_WIDTH      = 12,
  parameter int DATA_WIDTH      = 32,
  parameter int NUM_REGS        = 3,
  parameter int APB_WAIT_CYCLES = 0
)(
  input  logic PCLK,
  input  logic PRESETn,
  input  logic [ADDR_WIDTH-1:0]     PADDR,
  input  logic [DATA_WIDTH-1:0]     PWDATA,
  input  logic                      PWRITE,
  input  logic                      PENABLE,
  input  logic [(DATA_WIDTH/8)-1:0] PSTRB,
  input  logic                      PSEL,
  input  logic [2:0]                PPROT,
  output logic [DATA_WIDTH-1:0]     PRDATA,
  output logic                      PREADY,
  output logic                      PSLVERR,
  output logic [1:0]                irq_o
);

  logic [DATA_WIDTH-1:0]       reg_wdata;
  logic [$clog2(NUM_REGS)-1:0] reg_waddr;
  logic                        reg_wr_en;
  logic [$clog2(NUM_REGS)-1:0] reg_raddr;
  logic [DATA_WIDTH-1:0]       reg_rdata;

  apb_if #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) apb (
    .PCLK(PCLK),
    .PRESETn(PRESETn)
  );

  assign apb.PADDR   = PADDR;
  assign apb.PWDATA  = PWDATA;
  assign apb.PWRITE  = PWRITE;
  assign apb.PENABLE = PENABLE;
  assign apb.PSTRB   = PSTRB;
  assign apb.PSEL    = PSEL;
  assign apb.PPROT   = PPROT;
  assign PRDATA  = apb.PRDATA;
  assign PREADY  = apb.PREADY;
  assign PSLVERR = apb.PSLVERR;

  generic_regs #(
    .ADDR_WIDTH   (ADDR_WIDTH),
    .DATA_WIDTH   (DATA_WIDTH),
    .NUM_REGS     (NUM_REGS),
    .WAIT_CYCLES  (APB_WAIT_CYCLES)
  ) u_regs (
    .apb       (apb),
    .reg_wdata (reg_wdata),
    .reg_wstrb (),
    .reg_pprot (),
    .reg_waddr (reg_waddr),
    .reg_wr_en (reg_wr_en),
    .reg_raddr (reg_raddr),
    .reg_rdata (reg_rdata)
  );

  timer_core #(
    .DATA_WIDTH (DATA_WIDTH),
    .NUM_REGS (NUM_REGS)
  ) u_core (
    .clk         (apb.PCLK),
    .rst_n       (apb.PRESETn),
    .reg_wr_en   (reg_wr_en),
    .reg_waddr   (reg_waddr),
    .reg_wdata   (reg_wdata),
    .reg_raddr   (reg_raddr),
    .reg_rdata   (reg_rdata),
    .irq_overflow (irq_o[1]),
    .irq_compare  (irq_o[0])
  );

endmodule
