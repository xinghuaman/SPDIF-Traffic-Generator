///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////SPDIF GENERATOR BY zied.sassi@gmail.com /////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------
//
// CLASS: spdif_scoreboard
//
//------------------------------------------------------------------------------
class spdif_scoreboard extends uvm_scoreboard;
    protected bit disable_scoreboard = 0;
    logic [7:0] wr_cnt=0;
    logic [7:0] rd_cnt=0;
    logic [31:0] spdif_array [*];
    bit [31:0] temp1;
    static reg [31:0] temp2;
    byte trans_byte=0;

    `uvm_component_utils_begin(spdif_scoreboard)
        `uvm_field_int(disable_scoreboard, UVM_ALL_ON)
    `uvm_component_utils_end
    
    // new - constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    //build
    function void build();
        //item_collected_export = new("item_collected_export", this);
    endfunction
    // report
    virtual function void report();
        if(!disable_scoreboard) begin
            uvm_report_info(get_type_name(), $psprintf("Reporting scoreboard information...\n%s", this.sprint()), UVM_LOW);
        end
    endfunction : report
      // write
     function void write_read(logic [31:0] trans,logic write_nread);
        if(!disable_scoreboard) begin
		  if (write_nread) begin
			 temp2 = {trans,4'b0};
             uvm_report_info(get_type_name(), $psprintf("WRITE HERE : ...\n%s data= %x write = %d", this.sprint(),temp2,wr_cnt), UVM_LOW);
			 wr_cnt++;
           // compare (trans);
          end else begin
             if (temp2 [31:4] != (trans [31:4])) begin
                uvm_report_error (get_type_name(), $psprintf("HIT DATA MISMATCH @ Data = 0x%x  Expected = 0x%x\n", trans[31:4], temp2[31:4]));
             end else begin
               uvm_report_info(get_type_name(), $psprintf("PASS: HIT DATA MATCH Data = 0x%x == Expected Data = 0x%x read counter = %d", trans[31:4], temp2[31:4],rd_cnt), UVM_LOW);
             end
               rd_cnt++;  
		  end
        end
    endfunction : write_read

endclass : spdif_scoreboard

