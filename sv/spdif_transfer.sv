///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////SPDIF GENERATOR BY zied.sassi@gmail.com /////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------
//
// CLASS: spdif_transfer
//
//------------------------------------------------------------------------------

class spdif_block_transfer extends uvm_sequence_item;
    rand bit in_block_stop;
    rand int unsigned block_nb;
    rand int unsigned dirty_block_stop_nb;
	`uvm_object_utils_begin (spdif_block_transfer) 
    `uvm_field_int      (block_nb,           UVM_ALL_ON)
    `uvm_object_utils_end
    constraint c_block_nb {5<block_nb < 20;}
endclass : spdif_block_transfer
                                
class spdif_transfer extends uvm_sequence_item;                                  
    rand bit  parity;
    rand bit  validity;
    rand bit [19:0] data;
    rand bit [3:0] aux;
    rand bit [1:0] cu;
    rand bit coding_type;
    rand bit in_frame_stop;
    rand int stop_bit_nb;
    rand int no_traffic;
    rand int no_traffic_nb;
    rand int clean_stop_now;
    rand int stop_frame_nb;
    rand int in_block_stop;
    constraint c_validity {0<validity < 20;}
	
    `uvm_object_utils_begin (spdif_transfer) 
        `uvm_field_int      (cu,           UVM_ALL_ON)
        `uvm_field_int      (data,           UVM_ALL_ON)
        `uvm_field_int      (validity,           UVM_ALL_ON)
        `uvm_field_int      (parity,           UVM_ALL_ON)
        `uvm_field_int      (aux,           UVM_ALL_ON)
        `uvm_field_int      (coding_type,           UVM_ALL_ON)
        `uvm_field_int      (in_frame_stop,           UVM_ALL_ON)
        `uvm_field_int      (stop_bit_nb,           UVM_ALL_ON)
        `uvm_field_int      (no_traffic,           UVM_ALL_ON)
        `uvm_field_int      (no_traffic_nb,           UVM_ALL_ON)
        `uvm_field_int      (clean_stop_now,           UVM_ALL_ON)
        `uvm_field_int      (stop_frame_nb,           UVM_ALL_ON)
        `uvm_field_int      (in_block_stop,           UVM_ALL_ON)
    `uvm_object_utils_end
  // new - constructor
  function new (string name = "spdif_transfer_inst");
    super.new(name);
  endfunction : new
endclass : spdif_transfer

