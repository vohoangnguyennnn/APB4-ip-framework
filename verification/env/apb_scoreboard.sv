class apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_scoreboard)

  uvm_analysis_imp #(apb_seq_item, apb_scoreboard) item_export;
  virtual apb_subsystem_if subsys_vif;

  function new(string name = "apb_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    item_export = new("item_export", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_subsystem_if)::get(this, "", "subsys_vif", subsys_vif)) begin
      `uvm_fatal("NOVIF", "virtual apb_subsystem_if must be set for apb_scoreboard")
    end
  endfunction

  function void write(apb_seq_item tr);
    `uvm_info("APB_SCB", tr.convert2string(), UVM_MEDIUM)
    `uvm_info("SUBSYS_SCB",
              $sformatf("gpio_pins=0x%0h timer_irq_o=0b%0b",
                        subsys_vif.gpio_pins, subsys_vif.timer_irq_o),
              UVM_MEDIUM)
  endfunction
  
endclass : apb_scoreboard
