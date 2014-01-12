`ifndef __MEM_TEST_LIB
`define __MEM_TEST_LIB

spdif_block_transfer spdif_block_transfer_inst = new(); 
// Base Test
class spdif_base_test extends uvm_test;

    `uvm_component_utils(spdif_base_test)
    spdif_tb spdif_tb_inst0;
    uvm_table_printer printer;

    function new (string name="spdif_base_test", 
        uvm_component parent=null);
        super.new (name, parent);
    endfunction : new 

  virtual function void build();
    super.build();
    // Enable transaction recording for everything
    set_config_int("*", "recording_detail", UVM_FULL);
    // Create the tb
    spdif_tb_inst0 = spdif_tb::type_id::create("spdif_tb_inst0", this);
    // Create a specific depth printer for printing the created topology
    printer = new();
    printer.knobs.depth = 3;
  endfunction : build

  function void end_of_elaboration();
    spdif_tb_inst0.m_env0.m_monitor.set_report_verbosity_level(UVM_FULL);
   `uvm_info(get_type_name(),
      $psprintf("Printing the test topology_test :\n%s", this.sprint(printer)), UVM_LOW)
  endfunction : end_of_elaboration
  task run();
   uvm_test_done.set_drain_time(this, 2);
  endtask : run
  
endclass : spdif_base_test

//------------------------------------------------------------------------------
//
// VIRTUAL SEQUENCE: spdif_virt_sequence
//
//------------------------------------------------------------------------------
class spdif_virt_sequence extends uvm_sequence #(spdif_transfer);
  spdif_in_block_stop_seq in_block_stop_seq;
  spdif_no_stop_seq no_stop_seq;
  spdif_clean_stop_seq  clean_stop_seq;
  spdif_in_frame_stop_seq in_frame_stop_seq;
  spdif_man_coding_seq man_coding_seq;
  spdif_no_traffic_seq no_traffic_seq;
  function new(string name="spdif_virt_sequence");
    super.new(name);
  endfunction
  `uvm_sequence_utils(spdif_virt_sequence, spdif_sequencer)
  virtual task pre_body();
    m_sequencer.uvm_report_info(get_type_name(),
      $psprintf("%s pre_body() raising an uvm_test_done objection", 
      get_sequence_path()), UVM_MEDIUM);
    uvm_test_done.raise_objection(this);
  endtask
  virtual task post_body();
    m_sequencer.uvm_report_info(get_type_name(),
      $psprintf("%s post_body() dropping an uvm_test_done objection", 
      get_sequence_path()), UVM_MEDIUM);
    uvm_test_done.drop_objection(this);
  endtask
  virtual task body();
  // `uvm_do(no_traffic_seq);
     `uvm_do(no_stop_seq);
     // `uvm_do(in_block_stop_seq);
    // `uvm_do(no_traffic_seq);
      // `uvm_do(in_frame_stop_seq);
    // `uvm_do(no_traffic_seq);
    // `uvm_do(man_coding_seq);
     `uvm_do(no_stop_seq);
     `uvm_do(clean_stop_seq);
endtask : body
endclass : spdif_virt_sequence

class spdif2_virt_sequence extends uvm_sequence #(spdif_transfer);
  spdif_in_block_stop_seq in_block_stop_seq;
  spdif_no_stop_seq no_stop_seq;
  spdif_clean_stop_seq  clean_stop_seq;
  spdif_in_frame_stop_seq in_frame_stop_seq;
  spdif_man_coding_seq man_coding_seq;
  spdif_no_traffic_seq no_traffic_seq;
  function new(string name="spdif2_virt_sequence");
    super.new(name);
  endfunction
  `uvm_sequence_utils(spdif2_virt_sequence, spdif_sequencer)

  virtual task pre_body();
    m_sequencer.uvm_report_info(get_type_name(),
      $psprintf("%s pre_body() raising an uvm_test_done objection", 
      get_sequence_path()), UVM_MEDIUM);
    uvm_test_done.raise_objection(this);
  endtask

  virtual task post_body();
    m_sequencer.uvm_report_info(get_type_name(),
      $psprintf("%s post_body() dropping an uvm_test_done objection", 
      get_sequence_path()), UVM_MEDIUM);
    uvm_test_done.drop_objection(this);
  endtask
  virtual task body();

   //`uvm_do(no_traffic_seq);
    // `uvm_do(no_stop_seq);
     //`uvm_do(in_block_stop_seq);
   // `uvm_do(clean_stop_seq);
    // `uvm_do(no_traffic_seq);
    `uvm_do(in_frame_stop_seq);
    //`uvm_do(man_coding_seq);

endtask : body
endclass : spdif2_virt_sequence

class spdif_test_clean_traffic extends spdif_base_test;
  `uvm_component_utils(spdif_test_clean_traffic)
  function new(string name = "spdif_test_clean_traffic", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new
  virtual function void build();
    set_config_string("spdif_tb_inst0.m_env0.m_sequencer",
    "default_sequence", "spdif_virt_sequence");
    super.build();
  endfunction : build

endclass : spdif_test_clean_traffic

class spdif_test_stops extends spdif_base_test;
  `uvm_component_utils(spdif_test_stops)
  function new(string name = "spdif_test_stops", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new
  virtual function void build();
    set_config_string("spdif_tb_inst0.m_env0.m_sequencer",
    "default_sequence", "spdif2_virt_sequence");
    super.build();
  endfunction : build

endclass : spdif_test_stops

`endif //__MEM_TEST_LIB

