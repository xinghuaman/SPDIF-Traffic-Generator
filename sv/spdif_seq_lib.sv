///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////SPDIF TRAFFIC GENERATOR BY zied.sassi@gmail.com /////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------
//
// CLASS: spdif_base_sequence
//
//------------------------------------------------------------------------------      
class spdif_base_sequence extends uvm_sequence #(spdif_transfer);

  function new(string name="spdif_base_sequencee");
    super.new(name);
  endfunction

  `uvm_sequence_utils(spdif_base_sequence, spdif_sequencer)
 
  // Raise in pre_body so the objection is only raised for root sequences.
  // There is no need to raise for sub-sequences since the root sequence
  // will encapsulate the sub-sequence. 
  virtual task pre_body();
    m_sequencer.uvm_report_info(get_type_name(),
      $psprintf("%s pre_body() raising an uvm_test_done objection", 
      get_sequence_path()), UVM_MEDIUM);
    uvm_test_done.raise_objection(this);
  endtask

  // Drop the objection in the post_body so the objection is removed when
  // the root sequence is complete. 
  virtual task post_body();
    m_sequencer.uvm_report_info(get_type_name(),
      $psprintf("%s post_body() dropping an uvm_test_done objection", 
      get_sequence_path()), UVM_MEDIUM);
    uvm_test_done.drop_objection(this);
  endtask
  
endclass : spdif_base_sequence
//------------------------------------------------------------------------------
//
// SEQUENCE: spdif_no_traffic_seq
//
//------------------------------------------------------------------------------
class spdif_no_traffic_seq extends spdif_base_sequence;

  function new(string name="spdif_no_traffic_seq");
    super.new(name);
  
  endfunction
   rand bit  no_traffic_nb;
   bit  no_traffic_nbb;
   `uvm_sequence_utils_begin(spdif_no_traffic_seq, spdif_sequencer)    
   `uvm_sequence_utils_end
    virtual task body();
	 no_traffic_nb=no_traffic_nbb;
     `uvm_do_with(req , { req.no_traffic == 1; req.no_traffic_nb == 20; })
    endtask
endclass : spdif_no_traffic_seq
//------------------------------------------------------------------------------
//
// SEQUENCE: read_byte
//
//------------------------------------------------------------------------------
class spdif_boundry_val_seq extends spdif_base_sequence;

  function new(string name="spdif_boundry_val_seq");
    super.new(name);
  endfunction
      rand bit  validity;
    rand bit [`DATA_SIZE-1:0] data;
    rand bit [3:0] aux;
    rand bit [1:0] cu;
    rand int unsigned block_nb;
    rand int unsigned block_delay;
	rand int stop_frame_nb;
	rand bit in_frame_stop;
	rand int in_block_stop=0;
	rand int clean_stop=0;
	rand int clean_stop_nb=0;
	rand int stop_bit_nb;
    int stop_bit_nbb;
    bit in_frame_stopp;
    bit coding_typee;
    rand bit no_traffic;
    bit no_trafficc;
    rand bit coding_type;
    bit in_block_stopp;
    int stop_frame_nbb;

   `uvm_sequence_utils_begin(spdif_boundry_val_seq, spdif_sequencer)    
    `uvm_field_int(block_nb, UVM_ALL_ON)
    `uvm_field_int(block_delay, UVM_ALL_ON)
    `uvm_sequence_utils_end
     constraint c_block_nb {block_nb < 10;block_nb >1;}
	 constraint c_in_block_stop {in_block_stop ==0;}
	 constraint c_stop_frame_nb {stop_frame_nb ==0;}
     constraint c_in_frame_stop {in_frame_stop ==0;}
	 constraint c_stop_bit_nb {stop_bit_nb ==64;}
     constraint c_coding_type {coding_type ==1;}

    virtual task body();

        uvm_report_info(get_type_name(),"STARTING spdif_boundry_val_seq : 3AMAR \n", UVM_LOW);
		for(int k = 0; k < block_nb ; k++) begin
          if (k==clean_stop_nb && clean_stop ==1)  begin
	     `uvm_do_with(req , { req.no_traffic == 1; req.no_traffic_nb == 20; })

		  end else begin	  
           randomize(stop_frame_nb);
           randomize(in_block_stop);
		   for(int j = 0; j < 384; j++) //192 * 2 - 1 
		    begin 
			    if(in_block_stop) begin
				 end
             if (j == 2* stop_frame_nb -2 && in_block_stop == 1)
              begin
			    j = 384;
              end			  
			            randomize(in_frame_stop);
			            randomize(stop_bit_nb);
			            randomize(coding_type);

			 stop_bit_nbb=stop_bit_nb;
			 in_frame_stopp=in_frame_stop;
			 coding_typee=coding_type;
			 stop_frame_nbb=stop_frame_nb;
			 in_block_stopp=in_block_stop;

			 `uvm_do_with(req , { req.coding_type == coding_typee; req.aux == 5; req.in_frame_stop == in_frame_stopp; 
			                      req.stop_bit_nb == stop_bit_nbb; req.no_traffic == 0;
								  req.in_block_stop == in_block_stopp; req.stop_frame_nb== stop_frame_nbb;})
            end
          end
         end
    endtask
  
endclass : spdif_boundry_val_seq
// spdif_boundry_val_seq Sub Sequence
//------------------------------------------------------------------------------
//
// SEQUENCE: spdif_clean_stop_seq
//
//------------------------------------------------------------------------------
class spdif_clean_stop_seq extends spdif_boundry_val_seq;
  function new(string name="spdif_clean_stop_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    uvm_test_done.raise_objection(this);
   
   endtask 
     constraint c_block_nb {block_nb < 6;block_nb >1;}
	 constraint c_clean_stop {clean_stop ==1;}
	 constraint c_clean_stop_nb {clean_stop_nb < block_nb;}
     `uvm_sequence_utils_begin(spdif_clean_stop_seq, spdif_sequencer)    
    `uvm_sequence_utils_end
endclass : spdif_clean_stop_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: spdif_in_frame_stop_seq
//
//------------------------------------------------------------------------------
class spdif_in_frame_stop_seq extends spdif_boundry_val_seq;
  function new(string name="spdif_in_frame_stop_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    // uvm_report_info(get_full_name(),"  \n \n pre_body() callback of spdif_in_block_stop_seqsssssssssssss1111111111  \n \n",UVM_LOW);
    uvm_test_done.raise_objection(this);
   
   endtask 
     constraint c_block_nb {block_nb < 3;block_nb >1;}
	 constraint c_in_frame_stop {in_frame_stop ==1 || in_frame_stop ==0;}
	 constraint c_stop_bit_nb {stop_bit_nb ==22 || stop_bit_nb ==33;}
	 constraint c_coding_type {coding_type ==1;}
     `uvm_sequence_utils_begin(spdif_in_frame_stop_seq, spdif_sequencer)    
    `uvm_sequence_utils_end
endclass : spdif_in_frame_stop_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: spdif_in_block_stop_seq
//
//------------------------------------------------------------------------------
class spdif_in_block_stop_seq extends spdif_boundry_val_seq;
  function new(string name="spdif_in_block_stop_seq");
    super.new(name);
  endfunction
   virtual task pre_body();
    uvm_test_done.raise_objection(this);
   endtask 
     constraint c_block_nb {block_nb < 5;block_nb >3;}
	 constraint c_in_block_stop {in_block_stop ==1;}
	 constraint c_stop_frame_nb {stop_frame_nb > 0;stop_frame_nb < 100;}
     `uvm_sequence_utils_begin(spdif_in_block_stop_seq, spdif_sequencer)    
    `uvm_sequence_utils_end
endclass : spdif_in_block_stop_seq
//------------------------------------------------------------------------------
//
// SEQUENCE: spdif_no_stop_seq
//
//------------------------------------------------------------------------------
class spdif_no_stop_seq extends spdif_boundry_val_seq;
  function new(string name="spdif_no_stop_seq");
    super.new(name);
  endfunction
   virtual task pre_body();
        uvm_test_done.raise_objection(this);
	endtask 
     constraint c_block_nb {block_nb < 6;block_nb >4;}
     constraint c_in_frame_stop {in_frame_stop ==0;}
     `uvm_sequence_utils_begin(spdif_no_stop_seq, spdif_sequencer)    
    `uvm_sequence_utils_end
endclass : spdif_no_stop_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: Manchester Coding
//
//------------------------------------------------------------------------------
class spdif_man_coding_seq extends spdif_boundry_val_seq;
  function new(string name="spdif_man_coding_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    uvm_test_done.raise_objection(this);
   
   endtask 
     constraint c_block_nb {block_nb < 3;block_nb >1;}
	 constraint c_coding_type {coding_type ==1 || coding_type ==0;}
     `uvm_sequence_utils_begin(spdif_man_coding_seq, spdif_sequencer)    
    `uvm_sequence_utils_end
endclass : spdif_man_coding_seq

