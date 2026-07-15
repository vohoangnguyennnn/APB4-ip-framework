package apb_tb_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  localparam bit [31:0] GPIO_BASE  = 32'h0000_0000;
  localparam bit [31:0] TIMER_BASE = 32'h0000_1000;

  localparam bit [31:0] GPIO_DIR   = GPIO_BASE + 32'h0;
  localparam bit [31:0] GPIO_OUT   = GPIO_BASE + 32'h4;
  localparam bit [31:0] GPIO_IN    = GPIO_BASE + 32'h8;

  localparam bit [31:0] TIMER_VAL  = TIMER_BASE + 32'h0;
  localparam bit [31:0] TIMER_CTRL = TIMER_BASE + 32'h4;
  localparam bit [31:0] TIMER_CMP  = TIMER_BASE + 32'h8;

  `include "apb_seq_item.sv"
  `include "apb_sequencer.sv"
  `include "apb_driver.sv"
  `include "apb_monitor.sv"
  `include "apb_agent.sv"

  `include "apb_scoreboard.sv"
  `include "apb_env.sv"

  `include "apb_base_seq.sv"
  `include "apb_smoke_seq.sv"
  `include "gpio_seq.sv"
  `include "timer_seq.sv"
  `include "apb_error_seq.sv"
  `include "apb_random_seq.sv"

  `include "apb_base_test.sv"
  `include "gpio_test.sv"
  `include "timer_test.sv"
  `include "apb_subsystem_test.sv"
  
endpackage : apb_tb_pkg
