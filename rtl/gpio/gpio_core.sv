module gpio_core #(
  parameter int WIDTH = 8
)(
  input logic clk,
  input logic rst_n,
  input logic [WIDTH-1:0] dir_reg,
  input logic [WIDTH-1:0] out_reg,
  output logic [WIDTH-1:0] in_reg,

  inout tri [WIDTH-1:0] gpio_pins
);

  genvar i;
  generate
    for (i = 0; i < WIDTH; i++) begin : gpio_loop
      assign gpio_pins[i] = dir_reg[i] ? out_reg[i] : 1'bz;
    end
  endgenerate

  logic [WIDTH-1:0] in_sync0_q;
  logic [WIDTH-1:0] in_sync1_q;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      in_sync0_q <= 0;
      in_sync1_q <= 0;
    end
    else begin
      in_sync0_q <= gpio_pins;
      in_sync1_q <= in_sync0_q;
    end
  end

  assign in_reg = in_sync1_q;


endmodule : gpio_core
