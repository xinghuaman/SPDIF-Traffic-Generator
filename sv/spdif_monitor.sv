///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////SPDIF GENERATOR TRAFFIC BY zied.sassi@gmail.com /////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
//
// CLASS: spdif_monitor
//
//------------------------------------------------------------------------------
class spdif_monitor extends uvm_monitor;
  // This property is the virtual interfaced needed for this component to drive
  // and view HDL signals. 
 // protected virtual xbus_if xmi;
  protected virtual interface spdif_if m_if;
  spdif_scoreboard scoreboard0;
  // Master Id
  protected int master_id;
  logic iSPDIFin_q=0;
  logic [63:0] collected_data;	
  logic [31:0] real_collected_data;	
  int cnt=0;	
  int frame_cnt=0;	
  event b_preambule_e;
  event m_preambule_e;
  event w_preambule_e;
  event data_transition_e;
  event end_of_block_e;
  event end_of_frame_e;
  event clean_stop_e;
  event in_block_stop_e;
  event in_frame_stop_e;
  event b_frame_missing_e;
  event frame_too_long_e;

  logic w_preambule;
  logic b_preambule;
  logic m_preambule;
  logic new_block_detected;
  logic end_of_block_detected;
  logic end_of_frame_detected;
  logic first_block=0;
  logic same_value=0;
  logic [6:0] max_val=0;
  logic [6:0] min_val=123;
  logic [6:0] freq_ratio=0;
  logic [6:0] freq_ratio_q=0;
  logic [2:0] first_seq_detect;
  logic [2:0] second_seq_detect;
  logic [2:0] third_seq_detect;
  logic [2:0] seq_detect;
  bit coverage_enable = 1;
  bit check_enable = 1;

  `uvm_component_utils_begin (spdif_monitor)
  `uvm_field_int (master_id, UVM_ALL_ON)
  `uvm_field_int(coverage_enable, UVM_DEFAULT)
  `uvm_component_utils_end

  uvm_analysis_port #(spdif_transfer) item_collected_port;
  
  protected spdif_transfer trans_collected;
  // new - constructor
  covergroup dut_spdif_cg @(clean_stop_e);
    clean_stp              : coverpoint new_block_detected {
      bins Detected = {1};
      bins Not_Detected = {1};
    }
  endgroup

  covergroup in_block_stp_cg @(in_block_stop_e);
    in_block_stp              : coverpoint end_of_block_detected {
      bins Detected = {1};
      bins Not_Detected = {1};
    }

    in_block_stp_nb            : coverpoint frame_cnt {
      bins first_frame = {1};
      bins last_frame = {192};
    }
  endgroup

  covergroup in_frame_stp_cg @(in_frame_stop_e);
    in_frame_stp              : coverpoint end_of_frame_detected {
      bins Detected = {1};
      bins Not_Detected = {1};
    }
    in_frame_stp_nb   : coverpoint cnt {
      bins first_data = {1};
      bins last_data = {62};

    }
  endgroup 

  function new  (string name = "spdif_monitor", uvm_component parent=null);
    super.new (name, parent);
    item_collected_port = new("item_collected_port", this);
    trans_collected = new ();
    dut_spdif_cg = new();
    dut_spdif_cg.set_inst_name ("dut_spdif_cg");
    in_block_stp_cg = new();
    in_block_stp_cg.set_inst_name ("in_block_stp_cg");
    in_frame_stp_cg = new();
    in_frame_stp_cg.set_inst_name ("in_frame_stp_cg");
  endfunction : new
 virtual function void build();
    super.build();
      scoreboard0 = spdif_scoreboard::type_id::create("scoreboard0", this);
  endfunction : build
  // assign_vi
  function void assign_vi(virtual interface spdif_if if_in);
    m_if = if_in;
  endfunction

  // run phase
  virtual task run();
    fork
      clock_detector ();
      block_start_detector ();
      if (coverage_enable)
      begin
	perform_transfer_coverage();
      end
        if (check_enable)
      begin
	  fork
	    perform_spdif_block_check();
	    perform_spdif_frame_check();
	    perform_spdif_b_frame_check();
	    perform_spdif_w_frame_check();
	    perform_spdif_m_frame_check();
		join
      end
      frame_cnt_task ();
    join
  endtask : run

  // collect_transactions
  virtual protected task clock_detector();
    forever 
    begin
      @( posedge m_if.iClk)
      if (iSPDIFin_q==m_if.iSPDIFin)
      begin 
	freq_ratio = freq_ratio + 1;
	seq_detect = 3;
      end
      else begin //if (iSPDIFin_q==m_if.iSPDIFin)
	if (freq_ratio > max_val && freq_ratio< (3* min_val+4))
	begin
	  max_val = freq_ratio;
	end
	if (freq_ratio < min_val & freq_ratio != 0)
	begin
	  min_val = freq_ratio;
	end
	if (freq_ratio < min_val + 2) 
	begin
	  seq_detect = 0;
	end
	else if (freq_ratio < max_val -4 ) 
	begin
	  seq_detect = 1;
	end
	else 
	begin
	  seq_detect = 2;
	end					 
	freq_ratio = 0;
	-> data_transition_e;
      end  //else of if (iSPDIFin_q==m_if.iSPDIFin)
      iSPDIFin_q =m_if.iSPDIFin;
    end 
  endtask : clock_detector
  virtual protected task block_start_detector();
    forever 
    begin
      @( negedge m_if.iClk)
      end_of_frame_detected=0;
      w_preambule=0;
      b_preambule=0;
      m_preambule=0;
      if (freq_ratio==0) 
      begin
	data_collector ();
		  //////////////////////////////////
		  //// first B seq detection ///////
		  //////////////////////////////////
	if (seq_detect==2 & first_seq_detect==0) begin
	  first_seq_detect=1;

	end else if (seq_detect==0 & first_seq_detect==1) begin
	  first_seq_detect=2;
	end else if (seq_detect==0 & first_seq_detect==2) begin
	  first_seq_detect=3;
	end else if (seq_detect==2 & first_seq_detect==3) begin
	  -> b_preambule_e;
	  b_preambule=1;
	  first_seq_detect=4;
	end else begin
	  first_seq_detect=0;
	end
		  //////////////////////////////////
		  //// second M seq detection ///////
		  //////////////////////////////////
	if (seq_detect==2 & second_seq_detect==0) begin
	  second_seq_detect=1;
	end else if (seq_detect==2 & second_seq_detect==1) begin
	  second_seq_detect=2;
	end else if (seq_detect==0 & second_seq_detect==2) begin
	  second_seq_detect=3;
	end else if (seq_detect==0 & second_seq_detect==3) begin
	  -> m_preambule_e;
	  m_preambule=1;
	  second_seq_detect=0;
	end else begin
	  second_seq_detect=0;
	end
		  //////////////////////////////////
		  //// third W seq detection ///////
		  //////////////////////////////////
	if (seq_detect==2 & third_seq_detect==0) begin
	  third_seq_detect=1;
	end else if (seq_detect==1 & third_seq_detect==1) begin
	  third_seq_detect=2;
	end else if (seq_detect==0 & third_seq_detect==2) begin
	  third_seq_detect=3;
	end else if (seq_detect==1 & third_seq_detect==3) begin
	  -> w_preambule_e;
	  w_preambule=1;
	  third_seq_detect=0;
	end else begin
	  third_seq_detect=0;
	end
      end
      freq_ratio_q=freq_ratio;
    end
  endtask : block_start_detector
  virtual protected task frame_cnt_task();
    fork
      forever
      begin
	@ ( m_preambule_e or w_preambule_e)
	if (frame_cnt == 191) begin
	  frame_cnt=#1 192;
	  ->end_of_block_e;
	  first_block=1;
	end else begin
	  frame_cnt= #1 frame_cnt+1;
	end	   
      end
      forever
      begin
	@b_preambule_e
	frame_cnt=1;
	if (frame_cnt != 191)
	begin
	end
      end	  
    join
  endtask : frame_cnt_task

  virtual protected task data_collector();
    if (first_seq_detect==4) //B first block left preambule
    begin 
      if (cnt<64) begin
	end_of_frame_detected=1;
      end
      cnt=8;
      if (m_if.iSPDIFin==0) 
      begin
	collected_data[63:57] ="00010111";
      end 
      else 
      begin
	collected_data[63:57] ="11101000";
      end	    
    end 
    else if (second_seq_detect==3) //M left preambule
    begin
      if (cnt<64) begin
	end_of_frame_detected=1;
      end
      cnt=8;
      if (m_if.iSPDIFin==0) 
      begin
	collected_data[63:57] ="00011101";
      end 
      else 
      begin
	collected_data[63:57] ="11100010";
      end
    end 
    else if (third_seq_detect==3) //W right preambule
    begin
      if (cnt<64) begin
	end_of_frame_detected=1;
      end
      cnt=8;
      if (m_if.iSPDIFin==0) 
      begin
	collected_data[63:57] ="00011011";
      end 
      else 
      begin
	collected_data[63:57] ="11100100";
      end
    end 
    else if (seq_detect==0) 
    begin
      collected_data ={"1",collected_data[63:1]};
      cnt++;
    end
    else if (seq_detect==1)
    begin
      collected_data ={"00",collected_data[63:2]};
      cnt++;
      cnt++;
    end	
    if (cnt==64)
    begin
      real_collected_data = { collected_data[62],collected_data[60],collected_data[58],collected_data[56]
	,collected_data[54],collected_data[52],collected_data[50],collected_data[48]
	,collected_data[46],collected_data[44],collected_data[42],collected_data[40]
	,collected_data[38],collected_data[36],collected_data[34],collected_data[32]
	,collected_data[30],collected_data[28],collected_data[26],collected_data[24]
	,collected_data[22],collected_data[20],collected_data[18],collected_data[16]
	,collected_data[14],collected_data[12],collected_data[10],collected_data[8]
	,collected_data[6],collected_data[4],collected_data[2],collected_data[0]
      };
      trans_collected.parity=real_collected_data[31];
      trans_collected.cu=real_collected_data[30:29];
      trans_collected.validity=real_collected_data[28];
      trans_collected.data=real_collected_data[27:8];
      trans_collected.aux=real_collected_data[7:4];
	  scoreboard0.write_read(real_collected_data[31:0],0);

      -> end_of_frame_e;
      cnt=65;
    end 
    if (cnt> 73) begin
	  -> frame_too_long_e;
    end
  endtask : data_collector

  virtual protected task perform_transfer_coverage();
    fork
      collect_clean_stop_cov();
      collect_in_block_stop_cov();
      collect_in_frame_stop_cov();
    join
  endtask : perform_transfer_coverage
  
  virtual protected task collect_in_frame_stop_cov();
    forever
    begin
      @(posedge m_if.iClk);
	  //first_block flag permit to skip the first block in which the spdif frequency is not yet determined
      if (end_of_frame_detected==1 & first_block==1) begin
	   -> in_frame_stop_e;
      end
    end
  @(negedge m_if.iClk);      
endtask : collect_in_frame_stop_cov

virtual protected task collect_in_block_stop_cov();
  forever
  begin
    @end_of_frame_e;
    if ( frame_cnt < 191) begin
      end_of_block_detected=1;
      for(int i = 0; i < min_val*9; i++) begin
	if (m_preambule) begin
	  end_of_block_detected=0;
	end
	if (w_preambule) begin
	  end_of_block_detected=0;
	end
	@(posedge m_if.iClk);   
      end
    end
    if (end_of_block_detected==1) begin
      -> in_block_stop_e;
    end
    @(negedge m_if.iClk);         
  end
endtask : collect_in_block_stop_cov

virtual protected task collect_clean_stop_cov();
  forever
  begin
    @end_of_block_e;
    @end_of_frame_e;
    new_block_detected=0;
    for(int i = 0; i < min_val*9; i++) begin
      @(negedge m_if.iClk);
      if (b_preambule_e.triggered) begin
	new_block_detected=1;
      end
    end
    if (new_block_detected==1) begin
      -> clean_stop_e;
    end else begin
      -> b_frame_missing_e;
    end
  end
endtask : collect_clean_stop_cov

 virtual protected task perform_spdif_block_check();  
forever
begin
      @(in_block_stop_e);
      uvm_report_error (get_type_name(), $psprintf(" Block shorter than expected \n"));    
end
endtask : perform_spdif_block_check 
virtual protected task perform_spdif_frame_check();  
forever
begin
      @(in_frame_stop_e);
      uvm_report_error (get_type_name(), $psprintf(" frame shorter than expected \n"));    
end
endtask : perform_spdif_frame_check
virtual protected task perform_spdif_b_frame_check();  
forever
begin
      @(b_frame_missing_e);
      uvm_report_error (get_type_name(), $psprintf(" B frame first one in block is missing \n"));    
end
endtask : perform_spdif_b_frame_check
virtual protected task perform_spdif_w_frame_check();  
forever
begin
      @(m_preambule_e);
	  if (frame_cnt[0]!=0 & first_block) begin
	    uvm_report_error (get_type_name(), $psprintf(" Waiting W frame but getting M frame \n"));    
      end
end
endtask : perform_spdif_w_frame_check

virtual protected task perform_spdif_frame_long_check();  
forever
begin
      @(frame_too_long_e);
	    uvm_report_error (get_type_name(), $psprintf(" Frame is longer than 32 bits \n"));    
end
endtask : perform_spdif_frame_long_check

virtual protected task perform_spdif_m_frame_check();  
forever
begin
      @(w_preambule_e);
	  if (frame_cnt[0]!=1 & first_block) begin
	    uvm_report_error (get_type_name(), $psprintf(" Waiting M frame but getting W frame \n"));    
      end
end
endtask : perform_spdif_m_frame_check
endclass : spdif_monitor

