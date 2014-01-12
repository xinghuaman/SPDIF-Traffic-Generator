///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////SPDIF TRAFFIC GENERATOR BY zied.sassi@gmail.com /////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
`define HALF_PERIOD 52083
`define HALF_SMALL_PERIOD 2083

  `include "spdif_if.sv"

module spdif_tb_top;

  `include "spdif_def.svh"
  `include "spdif_test_lib.sv"

   spdif_if m_if ();
   logic rst_n;

 //   aes3rx aes3rx_inst (
 //        .clk(m_if.iClk),      
 //        .reset(~rst_n),           
 //        .sdata(),           
 //        .sclk(),           
 //        .bsync(),           
 //        .lrck(),           
 //        .aes3(m_if.iSPDIFin)
 //  );      
 
  initial begin
    run_test();
  end
    // generate clock 
  initial begin
      m_if.CLK = 1; 
              m_if.iClk = 1; 
      rst_n = 0; 
  end
  always
      #55 rst_n = 1;
  always 
      #`HALF_PERIOD m_if.CLK = ~m_if.CLK;
  always
      #`HALF_SMALL_PERIOD m_if.iClk = ~m_if.iClk;

  initial 
  begin
  end 

endmodule : spdif_tb_top
