///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////SPDIF TRAFFIC GENERATOR BY zied.sassi@gmail.com /////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
//
// CLASS: spdif_env
//
//------------------------------------------------------------------------------

class spdif_env extends uvm_env;

  // Virtual Interface variable
	protected virtual interface spdif_if m_if ;
  // Components of the environment
	spdif_monitor m_monitor;
	spdif_sequencer m_sequencer;
	spdif_driver m_driver;
  // Provide implementations of virtual methods such as get_type_name and create
	`uvm_component_utils_begin(spdif_env)
	`uvm_component_utils_end

  // new - constructor
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

  // build
	function void build();
		string inst_name;
		super.build();
		m_monitor = spdif_monitor::type_id::create("m_monitor", this);
		m_driver = spdif_driver::type_id::create("m_driver", this);
		m_sequencer = spdif_sequencer::type_id::create("m_sequencer", this);
		$display ("INSIDE ASSIGN BUI:D 2 \n");
	endfunction : build
  // set_slave_address_map
  // Function to assign the virtual intf for all components in this env
	function void assign_vi(virtual interface spdif_if mif);
		m_if = mif ;
		m_monitor.assign_vi(mif);
		m_sequencer.assign_vi(mif);
		m_driver.assign_vi(mif);
	endfunction : assign_vi

	function void connect();
		m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
	endfunction : connect

endclass : spdif_env

