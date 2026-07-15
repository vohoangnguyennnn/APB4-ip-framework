interface apb_subsystem_if (
  input logic PCLK,
  input logic PRESETn
);
  tri   [7:0] gpio_pins;
  logic [1:0] timer_irq_o;
endinterface