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
    parameter col_addr = 2000;	
    logic[31:0] memory[0:row_addr-1][0:col_addr-1];	
	logic[31:0] fault_bite;
    int error_count;
    int data_count;
	int fault_num;
    mailbox #(mon_data) mon_mb;

    function new();
	  this.mon_mb = new();
      this.error_count = 0;
      this.data_count = 0;
    endfunction

    task run();
	  $display("CKR:running");
      this.do_compare();
    endtask
	
    task do_compare();
      mon_data cm;
	  fault_num = 0;
      forever begin
        mon_mb.get(cm);
        case(cm.cmd)
          1'b0: begin
		          if(cm.data !== memory[cm.row_addr][cm.addr])//if READ data is fault.
			        begin
				      error_count = error_count + 1;
					  fault_bite = cm.data^memory[cm.row_addr][cm.addr];					  
					  foreach(fault_bite[i])
					    fault_num = fault_num + fault_bite[i];
				      $error("Compared failed!   data %h != %h.(Row:%h,Col:%h)  fault_num=%d",cm.data,memory[cm.row_addr][cm.addr],cm.row_addr,cm.addr,fault_num);
				    end
			      else//if READ data is right.
			        begin
					  data_count = data_count + 1;
				      $display("Compared succeeded! data %h == %h.(Row:%h,Col:%h)",cm.data,memory[cm.row_addr][cm.addr],cm.row_addr,cm.addr);
				    end 
		        end
          1'b1: begin//save WRITE data.
		          memory[cm.row_addr][cm.addr] = cm.data;
		        end        
          default: ;
        endcase	
	    if(cm.cmp_end == 1)
		  begin
		    $display("CKR: error count is %d ; all data count is %d",error_count,data_count);
			data_count = 0;
			error_count = 0;
		  end
      end		
    endtask
endclass:NFC_Checker