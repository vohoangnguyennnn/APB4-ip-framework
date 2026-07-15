module apb_tb_top;
  import uvm_pkg::*;
  import apb_tb_pkg::*;

  logic PCLK;
  logic PRESETn;

  apb_if #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32)
  ) apb_vif (
    .PCLK(PCLK),
    .PRESETn(PRESETn)
  );

  apb_subsystem_if subsys_vif (
    .PCLK(PCLK),
    .PRESETn(PRESETn)
  );

  initial begin
    PCLK = 1'b0;
    forever #5 PCLK = ~PCLK;
  end

  initial begin
    PRESETn = 1'b0;
    repeat (5) @(posedge PCLK);
    PRESETn = 1'b1;
  end

  initial begin
    uvm_config_db#(virtual apb_if.requester)::set(null, "uvm_test_top.env.agent.driver", "vif", apb_vif);
    uvm_config_db#(virtual apb_if.monitor)::set(null, "uvm_test_top.env.agent.monitor", "vif", apb_vif);
    uvm_config_db#(virtual apb_subsystem_if)::set(null, "uvm_test_top.env.scoreboard", "subsys_vif", subsys_vif);
    run_test();
  end

  apb_subsystem #(
    .ADDR_WIDTH       (32),
    .DATA_WIDTH       (32),
    .GPIO_WIDTH       (8),
    .SLAVE_ADDR_WIDTH (12),
    .GPIO_BASE_ADDR   (GPIO_BASE),
    .TIMER_BASE_ADDR  (TIMER_BASE)
  ) u_dut (
    .PCLK        (PCLK),
    .PRESETn     (PRESETn),
    .PADDR       (apb_vif.PADDR),
    .PWDATA      (apb_vif.PWDATA),
    .PWRITE      (apb_vif.PWRITE),
    .PENABLE     (apb_vif.PENABLE),
    .PSTRB       (apb_vif.PSTRB),
    .PSEL        (apb_vif.PSEL),
    .PPROT       (apb_vif.PPROT),
    .PRDATA      (apb_vif.PRDATA),
    .PREADY      (apb_vif.PREADY),
    .PSLVERR     (apb_vif.PSLVERR),
    .gpio_pins   (subsys_vif.gpio_pins),
    .timer_irq_o (subsys_vif.timer_irq_o)
  );
  
endmodule : apb_tb_top
