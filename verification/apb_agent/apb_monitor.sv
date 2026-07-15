class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)

  virtual apb_if.monitor vif;
  uvm_analysis_port #(apb_seq_item) item_ap;

  function new(string name = "apb_monitor", uvm_component parent = null);
    super.new(name, parent);
    item_ap = new("item_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if.monitor)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "virtual apb_if must be set for apb_monitor")
    end
  endfunction

  task run_phase(uvm_phase phase);
    apb_seq_item tr;

    forever begin
      @(posedge vif.PCLK);
      if (vif.PSEL && vif.PENABLE && vif.PREADY) begin
        tr = apb_seq_item::type_id::create("tr", this);
        tr.addr   = vif.PADDR;
        tr.wdata  = vif.PWDATA;
        tr.write  = vif.PWRITE;
        tr.strb   = vif.PSTRB;
        tr.prot   = vif.PPROT;
        tr.rdata  = vif.PRDATA;
        tr.slverr = vif.PSLVERR;
        item_ap.write(tr);
      end
    end
  endtask
  
endclass : apb_monitor
