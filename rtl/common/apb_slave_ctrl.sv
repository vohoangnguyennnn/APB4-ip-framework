module apb_slave_ctrl (
  apb_if.completer apb,

  input logic wait_req,
  input logic slverr_in,

  output logic setup_phase,
  output logic access_phase,
  output logic transfer_done,
  output logic read_access,
  output logic write_access,
  output logic read_pulse,
  output logic write_pulse
);

  assign setup_phase = apb.PSEL && !apb.PENABLE;
  assign access_phase = apb.PSEL &&  apb.PENABLE;

  assign apb.PREADY = access_phase ? !wait_req : 1'b1;
  assign transfer_done = access_phase && apb.PREADY;

  assign read_access = access_phase && !apb.PWRITE;
  assign write_access = access_phase &&  apb.PWRITE;

  assign read_pulse = transfer_done && !apb.PWRITE;
  assign write_pulse = transfer_done &&  apb.PWRITE;

  assign apb.PSLVERR = transfer_done ? slverr_in : 1'b0;

endmodule : apb_slave_ctrl
