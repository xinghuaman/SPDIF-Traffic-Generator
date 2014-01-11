///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////SPDIF GENERATOR BY zied.sassi@gmail.com /////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------
//
// CLASS: spdif_driver
//
//------------------------------------------------------------------------------
class spdif_driver extends uvm_driver #(spdif_transfer);

  bit parity;
  int j=0;
  rand int dirty_frame_stop_nb;
  rand int dirty_block_stop_nb;
  protected virtual spdif_if m_if;
   spdif_scoreboard scoreboard0;
  bit first_block=0;

  protected int master_id;
  // Provide implmentations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(spdif_driver)
  `uvm_field_int(master_id, UVM_ALL_ON)
  `uvm_component_utils_end
  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
   virtual function void build();
    super.build();
      scoreboard0 = spdif_scoreboard::type_id::create("scoreboard0", this);
  endfunction : build
  
  function void assign_vi (virtual interface spdif_if if_in);
    this.m_if = if_in;
  endfunction : assign_vi

  // run phase
  virtual task run();
    fork
      drive_signals();
    join
  endtask : run

  task no_traffic_task (spdif_transfer req);
    m_if.iSPDIFin = ~m_if.iSPDIFin;
    for(int i = 0; i < req.no_traffic_nb; i++) begin
      @(posedge m_if.CLK);
    end
  endtask : no_traffic_task

  task drive_signals ();
        forever begin 
      seq_item_port.get_next_item(req);
      if (req.no_traffic) begin
	no_traffic_task(req);
	seq_item_port.item_done();
      end else begin
	drive_transfer (req,j);
	if (first_block==1) begin
 	  scoreboard0.write_read({parity,req.cu,req.validity,req.data,req.aux},1);
	end
	first_block=1;
	seq_item_port.item_done();
	if (j!=191 & (j!=req.stop_frame_nb | ~req.in_block_stop) ) begin //193 * 2 - 1
	  j=j+1;
	end
	else begin
	  j=0;
	end		
      end				
    end
  endtask : drive_signals

  task drive_transfer (spdif_transfer req,int j);
    bit [31:0] frame_left;	
    bit [31:0] frame_right;
    bit [7:0] preambule;

    parity = ^{req.cu,req.validity,req.data,req.aux};
    frame_left ={parity,req.cu,req.validity,req.data,req.aux,4'b0};
    if (j==0) begin //channel B first left trame
      preambule=8'b00010111;
    end else if (j[0]==0) //channel M left trame
    begin
      preambule=8'b01000111;
    end else begin // channel W right trame
      preambule=8'b00100111;
    end
    if (m_if.iSPDIFin) begin
      preambule=~preambule;
    end
    for(int i = 0; i < 8; i++) begin
      m_if.iSPDIFin=preambule[i];
      @(posedge m_if.CLK);
    end 
    for(int i = 8; i < 64; i++) begin
      if (req.in_frame_stop) begin //Stop but in a clean way at the end of frame
      end else begin
      end
      if (i== req.stop_bit_nb -1 && req.in_frame_stop) begin //Stop but in a clean way at the end of frame
	i=64;
      end
      if (req.coding_type == 1) begin //manchester coding
	if (i[0]==0) begin
	  m_if.iSPDIFin = ~m_if.iSPDIFin;
	end 
	else begin
	  m_if.iSPDIFin = ~frame_left[(i-1)/2]& m_if.iSPDIFin | frame_left[(i-1)/2]& ~m_if.iSPDIFin;
	end
      end else begin //simple coding
	m_if.iSPDIFin = i[0];     
      end
      @(posedge m_if.CLK);
    end
  endtask : drive_transfer
endclass : spdif_driver
