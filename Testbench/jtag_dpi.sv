

module jtag_dpi
#(
  parameter TCP_PORT      = 4567,
  parameter TIMEOUT_COUNT = 6'h08 // 1/2 of a TCK clock will be this many clk_i ticks.  Must be less than 6 bits.
)
(
  input     clk_i,
  input     enable_i,

  output    tms_o,
  output    tck_o,
  output    trst_o,
  output    tdi_o,
  input     tdo_i
  );

  import "DPI-C"         function void jtag_init(input int port);
  import "DPI-C" context function int  jtag_recv(inout logic tck_o, inout logic trst_o, inout logic tdi_o, inout logic tms_o);
  import "DPI-C"         function void jtag_timeout();

  export "DPI-C" function rtl_get_tdo;


  logic [5:0] clk_count = TIMEOUT_COUNT + 1;

  logic tck;
  logic trstn;
  logic tdi;
  logic tms;




  function logic rtl_get_tdo();
    return tdo_i;
  endfunction

  // Handle commands from the upper level
  initial
  begin
    jtag_init(TCP_PORT);

    // wait for enable before doing anything
    @(posedge enable_i);

    while(1)
    begin
      @(posedge clk_i)
      if(jtag_recv(tck, trstn, tdi, tms))
      begin
        clk_count = 'h0;  // Reset the timeout clock in case jp wants to wait for a timeout / half TCK period
      end
    end
  end

  // Send timeouts / wait periods to the upper layer
  always @(posedge clk_i)
  begin
    if(clk_count < TIMEOUT_COUNT)
      clk_count = clk_count + 1;
    else if(clk_count == TIMEOUT_COUNT)
    begin
      jtag_timeout();
      clk_count = clk_count + 1;
    end
    // else it's already timed out, don't do anything
  end

  assign tck_o  = tck;
  assign trst_o = trstn;
  assign tdi_o  = tdi;
  assign tms_o  = tms;
endmodule
