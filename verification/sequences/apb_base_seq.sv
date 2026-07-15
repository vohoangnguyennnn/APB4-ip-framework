class apb_base_seq extends uvm_sequence #(apb_seq_item);
  `uvm_object_utils(apb_base_seq)

  function new(string name = "apb_base_seq");
    super.new(name);
  endfunction

  task apb_write(bit [31:0] addr, bit [31:0] data,
                 bit [3:0] strb = 4'hF, bit [2:0] prot = 3'b000);
    apb_seq_item tr;

    tr = apb_seq_item::type_id::create("tr");
    start_item(tr);
    tr.addr  = addr;
    tr.wdata = data;
    tr.write = 1'b1;
    tr.strb  = strb;
    tr.prot  = prot;
    finish_item(tr);
  endtask

  task apb_read(bit [31:0] addr, bit [2:0] prot = 3'b000);
    apb_seq_item tr;

    tr = apb_seq_item::type_id::create("tr");
    start_item(tr);
    tr.addr  = addr;
    tr.wdata = '0;
    tr.write = 1'b0;
    tr.strb  = 4'h0;
    tr.prot  = prot;
    finish_item(tr);
  endtask

  task apb_random_write(bit [31:0] min_addr, bit [31:0] max_addr);
    apb_seq_item tr;

    tr = apb_seq_item::type_id::create("tr");
    start_item(tr);
    if (!tr.randomize() with {
      write == 1'b1;
      addr >= min_addr;
      addr <= max_addr;
      strb inside {[4'h1:4'hF]};
      prot == 3'b000;
    }) begin
      `uvm_error("RAND", "apb_random_write randomize failed")
    end
    finish_item(tr);
  endtask

  task apb_random_read(bit [31:0] min_addr, bit [31:0] max_addr);
    apb_seq_item tr;

    tr = apb_seq_item::type_id::create("tr");
    start_item(tr);
    if (!tr.randomize() with {
      write == 1'b0;
      addr >= min_addr;
      addr <= max_addr;
      strb == 4'h0;
      prot == 3'b000;
    }) begin
      `uvm_error("RAND", "apb_random_read randomize failed")
    end
    finish_item(tr);
  endtask

endclass : apb_base_seq
