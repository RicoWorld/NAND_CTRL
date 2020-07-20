//NAND Flash Controller Root_Test
//
//Project engineer: Xiaodong Liu
//Data: 6-Apr-2020
//
//Discription:
//Main test code.
//-----------------------------------------------------------
`include "ahb_test.sv"

`timescale 1ns/1ps
module tb;
  logic         clk,dut_clk;
  logic         rstn;
  wire HREADY;
  wire HRESP;
  wire [7:0]DIO;
  wire WE_n;
  wire RE_n;
  wire CE_n;
  wire CLE;
  wire ALE;
  wire R_nB;
 
  parameter page = 4000;
  integer fault_byte_addr;
  integer fault_bite_addr;
  integer mem_addr;
  integer counter; 
  integer i;
  NFC_Interface nfc_if(.HCLK(clk),.HRESET(rstn));

  ahb_test ahb_te;
 
  Top dut(
     .HCLK      (clk           )
    ,.HRESETn   (rstn          )
	,.HSEL      (nfc_if.HSEL   )
    ,.HADDR     (nfc_if.HADDR  )
    ,.HWRITE    (nfc_if.HWRITE )
    ,.HSIZE     (nfc_if.HSIZE  )
    ,.HBURST    (nfc_if.HBURST )
    ,.HTRANS    (nfc_if.HTRANS )
    ,.HWDATA    (nfc_if.HWDATA )
    ,.HRDATA    (nfc_if.HRDATA )
    ,.HREADY    (1'b0          )
    ,.HRESP     (nfc_if.HRESP  )
	,.HREADYOUT (nfc_if.HREADY )
	,.ACLK      (dut_clk       )
	,.R_nB      (R_nB          )
	,.DIO       (DIO           )
	,.WE_n      (WE_n          )
	,.RE_n      (RE_n          )
	,.CE_n      (CE_n          )
	,.CLE       (CLE           )
	,.ALE       (ALE           )
  );
  
MX30LF1G08AA flash(
    .IO        (DIO           )  
   ,.CLE       (CLE           )  
   ,.ALE       (ALE           )   
   ,.CE_B      (CE_n          )   
   ,.RE_B      (RE_n          )   
   ,.WE_B      (WE_n          )   
   ,.WP_B      (1'b1          )  
   ,.RYBY_B    (R_nB          )
);

  // clock generation
  initial begin 
    clk <= 0;
    forever begin
      #10 clk <= !clk;
    end
  end
  initial begin 
    dut_clk <= 0;
    forever begin
      #5 dut_clk <= !dut_clk;
    end
  end
  
  
  // reset trigger
  initial begin 
        rstn <= 1'b1;
  #5    rstn <= 1'b0;
  #7000 rstn <= 1'b1;
  end

  initial begin 
    ahb_te = new();
    ahb_te.set_interface(nfc_if);    
    fork
	  ahb_te.run();
	  fault_injection();
    join
  end

  task fault_injection();
    forever 
	  begin
	    @(posedge clk);
	    if(nfc_if.fault_injection == 1)
	      begin//"以第4000页为例" byte 	
		    $display("%t >>> start to inject fault.",$time);
			/*//找到数据写入的具体位置
			counter = 0;
			for(i=0;i<32'h1100_0000;i++)
			begin					  
			  if(tb.flash.ARRAY[i]<8'hFF)
			      begin				   
				  $display("%d>>>i=%h data=%h",counter,i,tb.flash.ARRAY[i]);	
				  counter = counter + 1;			  
				  end
			end
			*/
			//随机产生80个地址，比如fault_byte_addr 896~2047;fault_bite_addr 0~7
	        repeat(5) //repeat()里面的数字代表了错误的注入个数
	          begin
			    if(ahb_te.gen.ecc_enable==1)//if ECC is open.
				  begin
				    fault_byte_addr = 16384896+{$random}%(16385919-512-16384896+1);//如果打开ECC，错误注入的地址是16384896~16385919~16386047
					fault_bite_addr = {$random}%(7+1);
					tb.flash.ARRAY[fault_byte_addr][fault_bite_addr] =~ tb.flash.ARRAY[fault_byte_addr][fault_bite_addr];
				  end
				else//if ECC is close.
				  begin
				    fault_byte_addr = 16385024+{$random}%(16386047-16385024+1);//如果关闭ECC，错误注入的地址是16385024~16386047//(max-min+1)
					fault_bite_addr = {$random}%(7+1);
					tb.flash.ARRAY[fault_byte_addr][fault_bite_addr] =~ tb.flash.ARRAY[fault_byte_addr][fault_bite_addr];
				  end  			     		   
	          end
			  
	        nfc_if.fault_injection = 0;
			$display("%t >>> finish injecting fault.",$time);			
	      end
	  end
  endtask 

endmodule