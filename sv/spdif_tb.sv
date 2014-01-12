///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////SPDIF TRAFFIC GENERATOR BY zied.sassi@gmail.com /////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
//
// CLASS: spdif_tb
//
//------------------------------------------------------------------------------
`include "spdif_seq_lib.sv"
class spdif_tb extends uvm_env;

  `uvm_component_utils(spdif_tb)
  spdif_env m_env0;
  // new
  function new (string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  // build
  virtual function void build();
    super.build();
    m_env0 = spdif_env::type_id::create("m_env0", this);
  endfunction : build

  function void connect();
    m_env0.assign_vi(spdif_tb_top.m_if);
  endfunction : connect
  
  function void end_of_elaboration();
  endfunction : end_of_elaboration

endclass : spdif_tb

`endif // SPDIF_TB_SV

