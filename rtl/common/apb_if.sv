interface apb_if #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
)(
  input logic PCLK,
  input logic PRESETn
);

  localparam int STRB_WIDTH = DATA_WIDTH/8;

// signal REQUESTER to COMPLETER

  logic [ADDR_WIDTH-1:0] PADDR;
  logic [DATA_WIDTH-1:0] PWDATA;
  logic PWRITE;
  logic PENABLE;
  logic [STRB_WIDTH-1:0] PSTRB;
  logic PSEL;
  logic [2:0] PPROT;

// signal COMPLETER to REQUESTER

  logic [DATA_WIDTH-1:0] PRDATA;
  logic PREADY;
  logic PSLVERR;

  initial begin
    if (DATA_WIDTH % 8 != 0 || DATA_WIDTH <= 0) begin
      $error("APB ADDR_WIDTH error");
      end

    if (ADDR_WIDTH <= 0) begin
      $error("APB DATA_WIDTH error");
      end
  end

  function automatic logic setup_phase();
    return (PSEL && !PENABLE);
  endfunction

  function automatic logic access_phase();
    return (PSEL && PENABLE);
  endfunction

  function automatic logic transfer_done();
    return (PSEL && PENABLE && PREADY);
  endfunction

  function automatic logic transfer_error();
    return (PSEL && PENABLE && PSLVERR);
  endfunction

  function automatic logic read_done();
    return (PSEL && PENABLE && PREADY && !PWRITE);
  endfunction

  modport requester (
    input PCLK,
    input PRESETn,
    output PADDR,
    output PWDATA,
    output PPROT,
    output PWRITE,
    output PENABLE,
    output PSTRB,
    output PSEL,
    input PREADY,
    input PSLVERR,
    input PRDATA
  );

  modport completer (
    input PCLK,
    input PRESETn,
    input PADDR,
    input PWDATA,
    input PPROT,
    input PWRITE,
    input PENABLE,
    input PSTRB,
    input PSEL,
    output PREADY,
    output PSLVERR,
    output PRDATA
  );

  modport monitor (
    input PCLK,
    input PRESETn,
    input PADDR,
    input PWDATA,
    input PPROT,
    input PWRITE,
    input PENABLE,
    input PSTRB,
    input PSEL,
    input PREADY,
    input PSLVERR,
    input PRDATA
  );

endinterface : apb_if