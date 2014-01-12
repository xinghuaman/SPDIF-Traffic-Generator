///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////SPDIF GENERATOR TRAFFIC BY zied.sassi@gmail.com /////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
//
// CLASS: spdif_sequencer
//
//------------------------------------------------------------------------------

class spdif_sequencer extends uvm_sequencer #(spdif_transfer);

  // The virtual interface used to drive and view HDL signals.
    protected virtual spdif_if m_if;
  // Master Id
  protected int master_id;
  `uvm_sequencer_utils_begin(spdif_sequencer)
    `uvm_field_int(master_id, UVM_ALL_ON)
  `uvm_sequencer_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
    `uvm_update_sequence_lib_and_item(spdif_transfer)
  endfunction : new

  // assign_vi
    function void assign_vi (virtual interface spdif_if m_if);
        this.m_if = m_if;
    endfunction : assign_vi

endclass : spdif_sequencer

