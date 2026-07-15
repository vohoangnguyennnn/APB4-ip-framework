class apb_driver extends uvm_driver #(apb_seq_item);
  `uvm_component_utils(apb_driver)

  virtual apb_if.requester vif;

  function new(string name = "apb_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if.requester)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "virtual apb_if must be set for apb_driver")
    end
  endfunction

  task run_phase(uvm_phase phase);
    apb_seq_item req;

    drive_idle();
    wait (vif.PRESETn === 1'b1);

    forever begin
      seq_item_port.get_next_item(req);
      drive_transfer(req);
      seq_item_port.item_done();
    end
  endtask

  task drive_idle();
    vif.PSEL    <= 1'b0;
    vif.PENABLE <= 1'b0;
    vif.PWRITE  <= 1'b0;
    vif.PADDR   <= '0;
    vif.PWDATA  <= '0;
    vif.PSTRB   <= '0;
    vif.PPROT   <= '0;
  endtask

  task drive_transfer(apb_seq_item tr);
    @(posedge vif.PCLK);
    vif.PSEL    <= 1'b1;
    vif.PENABLE <= 1'b0;
    vif.PWRITE  <= tr.write;
    vif.PADDR   <= tr.addr;
    vif.PWDATA  <= tr.wdata;
    vif.PSTRB   <= tr.strb;
    vif.PPROT   <= tr.prot;

    @(posedge vif.PCLK);
    vif.PENABLE <= 1'b1;

    do begin
      @(posedge vif.PCLK);
    end while (vif.PREADY !== 1'b1);

    vif.PSEL    <= 1'b0;
    vif.PENABLE <= 1'b0;
  endtask
  
endclass : apb_driver
