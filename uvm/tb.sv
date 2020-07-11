//NAND Flash Controller Root_Test
//
//Project engineer: Xiaodong Liu
//Data: 6-Apr-2020
//
//Discription:
//Main test code.
//-----------------------------------------------------------
`include "ahb_test.sv"
`include "DUT.v"

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
 
 reg[1024*8-1:0] data_page;
 integer random_place;
 //integer num_fault;
 integer h,m;
 
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
  
k9s1208 flash(
    .IO7        (DIO[7]        )  
   ,.IO6        (DIO[6]        )   
   ,.IO5        (DIO[5]        )   
   ,.IO4        (DIO[4]        )   
   ,.IO3        (DIO[3]        )   
   ,.IO2        (DIO[2]        )   
   ,.IO1        (DIO[1]        )   
   ,.IO0        (DIO[0]        )   
   ,.CLE        (CLE           )  
   ,.ALE        (ALE           )   
   ,.CENeg      (CE_n          )   
   ,.RENeg      (RE_n          )   
   ,.WENeg      (WE_n          )   
   ,.WPNeg      (1'b1          )  
   ,.R          (R_nB          )
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
    ahb_te.run();
  end
  
  task fault_injection();
    h=0;
	m=0;
    foreach(tb.k9s1208_flash.Mem[i])
      begin 
	    data_page[m] = tb.k9s1208_flash.Mem[i];
		if(h<2111)
		  begin
		    data_page[m]<<8;
			h=h+1;
	      end
		else
		  begin
		    m=m+1;
		    h=0;
		  end		  
      end
	foreach(data_page[m])
	repeat(80)
	  begin 
	    random_c = {$random}%99;
		    if(random_c<80)
			  begin
			    data_f[j] = ~data_f[j];
			    num_fault = num_fault+1;
			  end
      end
  endtask 
  
endmodule