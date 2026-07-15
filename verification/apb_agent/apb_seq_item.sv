class apb_seq_item extends uvm_sequence_item;
  `uvm_object_utils(apb_seq_item)

  rand bit [31:0] addr;
  rand bit [31:0] wdata;
  rand bit        write;
  rand bit [3:0]  strb;
  rand bit [2:0]  prot;

  bit [31:0] rdata;
  bit        slverr;

  constraint c_aligned_addr {
    addr[1:0] == 2'b00;
  }

  constraint c_default_read_strb {
    !write -> strb == 4'b0000;
  }

  function new(string name = "apb_seq_item");
    super.new(name);
  endfunction

endclass : apb_seq_item
