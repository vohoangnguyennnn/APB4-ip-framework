module apb_gpio #(
  parameter int ADDR_WIDTH = 12,
  parameter int DATA_WIDTH = 32,
  parameter int GPIO_WIDTH = 8,
  parameter int APB_WAIT_CYCLES = 0
)(
  input logic PCLK,
  input logic PRESETn,
  input logic [ADDR_WIDTH-1:0] PADDR,
  input logic [DATA_WIDTH-1:0] PWDATA,
  input logic PWRITE,
  input logic PENABLE,
  input logic [(DATA_WIDTH/8)-1:0] PSTRB,
  input logic PSEL,
  input logic [2:0] PPROT,
  output logic [DATA_WIDTH-1:0] PRDATA,
  output logic PREADY,
  output logic PSLVERR,
  inout tri [GPIO_WIDTH-1:0] gpio_pins
);

  localparam int NUM_REGS = 3;
  localparam int REG_ADDR_WIDTH = $clog2(NUM_REGS);

  localparam logic [REG_ADDR_WIDTH-1:0] REG_DIR = 'd0;
  localparam logic [REG_ADDR_WIDTH-1:0] REG_OUT = 'd1;
  localparam logic [REG_ADDR_WIDTH-1:0] REG_IN = 'd2;

  logic [DATA_WIDTH-1:0] reg_wdata;
  logic [DATA_WIDTH-1:0] reg_rdata;
  logic [REG_ADDR_WIDTH-1:0] reg_waddr;
  logic [REG_ADDR_WIDTH-1:0] reg_raddr;
  logic reg_wr_en;

  apb_if #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) apb (
    .PCLK(PCLK),
    .PRESETn(PRESETn)
  );

  assign apb.PADDR = PADDR;
  assign apb.PWDATA = PWDATA;
  assign apb.PWRITE = PWRITE;
  assign apb.PENABLE = PENABLE;
  assign apb.PSTRB = PSTRB;
  assign apb.PSEL = PSEL;
  assign apb.PPROT = PPROT;
  assign PRDATA = apb.PRDATA;
  assign PREADY = apb.PREADY;
  assign PSLVERR = apb.PSLVERR;

  generic_regs #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_REGS(NUM_REGS),
    .WAIT_CYCLES(APB_WAIT_CYCLES)
  ) u_regs (
    .apb(apb),
    .reg_wdata(reg_wdata),
    .reg_wstrb(),
    .reg_pprot(),
    .reg_waddr(reg_waddr),
    .reg_wr_en(reg_wr_en),
    .reg_raddr(reg_raddr),
    .reg_rdata(reg_rdata)
  );

  logic [GPIO_WIDTH-1:0] dir_q;
  logic [GPIO_WIDTH-1:0] out_q;
  logic [GPIO_WIDTH-1:0] in_w;

  initial begin
    if (GPIO_WIDTH > DATA_WIDTH) begin
      $error("GPIO_WIDTH must be less than or equal to DATA_WIDTH");
    end
  end

  always_ff @(posedge apb.PCLK or negedge apb.PRESETn) begin
    if (!apb.PRESETn) begin
      dir_q <= '0;
      out_q <= '0;
    end
    else if (reg_wr_en) begin
      unique case (reg_waddr)
        REG_DIR:  dir_q <= reg_wdata[GPIO_WIDTH-1:0];
        REG_OUT:  out_q <= reg_wdata[GPIO_WIDTH-1:0];
        default: ;
      endcase
    end
  end

  always_comb begin
    unique case (reg_raddr)
      REG_DIR: reg_rdata = {{(DATA_WIDTH-GPIO_WIDTH){1'b0}}, dir_q};
      REG_OUT: reg_rdata = {{(DATA_WIDTH-GPIO_WIDTH){1'b0}}, out_q};
      REG_IN: reg_rdata = {{(DATA_WIDTH-GPIO_WIDTH){1'b0}}, in_w};
      default: reg_rdata = '0;
    endcase
  end

  gpio_core #(
    .WIDTH (GPIO_WIDTH)
  ) u_core (
    .clk(apb.PCLK),
    .rst_n(apb.PRESETn),
    .dir_reg(dir_q),
    .out_reg(out_q),
    .in_reg(in_w),
    .gpio_pins(gpio_pins)
  );

endmodule : apb_gpio
