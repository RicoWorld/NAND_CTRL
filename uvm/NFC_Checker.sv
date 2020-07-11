//NAND Flash Controller Checker
//
//Project engineer: Xiaodong Liu
//Data: 15-Mar-2020
//
//Discription:
//
//-----------------------------------------------------------
`include "NFC_Monitor.sv"
class NFC_Checker;
    parameter row_addr = 32*4096;
    parameter col_addr = 512;	
    logic[31:0] memory[0:row_addr-1][0:col_addr-1];	
    int error_count;
    int data_count;
    mailbox #(mon_data) mon_mb;

    function new();
	  this.mon_mb = new();
      this.error_count = 0;
      this.data_count = 128;
    endfunction

    task run();
	  $display("CKR:running");
      this.do_compare();
    endtask
	
    task do_compare();
      mon_data cm;
      forever begin
        mon_mb.get(cm);
        case(cm.cmd)
          1'b0: begin
		          if(cm.data !== memory[cm.row_addr][cm.addr])
			        begin
				      this.error_count++;
				      $error("Compared failed!   data %h != %h.(Row:%h,Col:%h)",cm.data,memory[cm.row_addr][cm.addr],cm.row_addr,cm.addr);
				    end
			      else
			        begin
				      $display("Compared succeeded! data %h == %h.(Row:%h,Col:%h)",cm.data,memory[cm.row_addr][cm.addr],cm.row_addr,cm.addr);
				    end 
		        end
          1'b1: begin
		          memory[cm.row_addr][cm.addr] = cm.data;
		        end        
          default: ;
        endcase	
	    if(cm.cmp_end == 1)
		  $display("CKR: error count is %d ; all data count is %d",error_count,data_count);
      end		
    endtask
endclass:NFC_Checker