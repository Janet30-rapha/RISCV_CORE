

`ifndef DEBUG_BUS_SV
`define DEBUG_BUS_SV

`include "config.sv"

interface DEBUG_BUS
#(
    parameter ADDR_WIDTH = 15
);

  logic                  req;
  logic                  gnt;
  logic                  rvalid;
  logic [ADDR_WIDTH-1:0] addr;
  logic                  we;
  logic [31: 0]          wdata;
  logic [31: 0]          rdata;


  // Master Side
  //***************************************
  modport Master
  (
    output      req,  addr,   we, wdata,
    input       gnt,  rvalid,     rdata
  );

  // Slave Side
  //***************************************
  modport Slave
  (
    input       req,  addr,   we, wdata,
    output      gnt,  rvalid,     rdata
  );

endinterface

`endif
