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
 
 reg[(2048+64)*8-1:0] data_page[0:64000-1];
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
  #1200 rstn <= 1'b1;
  end

  initial begin 
    ahb_te = new();
    ahb_te.set_interface(nfc_if);    
    ahb_te.run();
  end
 /* 
  task fault_injection();
    h=0;
	m=0;
    foreach(tb.MX30LF1G08AA_flash.Mem[i])
      begin 
	    if(h>=960)
	      data_page[m] = tb.MX30LF1G08AA_flash.Mem[i];
		if(h<1983)
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
	foreach(data_page[j])
	  repeat(80)
	    begin 
	      random_place = {$random}%4095;		    
		  data_page[random_place] = ~data_page[random_place];			  
        end
  endtask 
 */ 
endmodule