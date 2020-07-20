//NAND Flash Controller Initiator
//
//Project engineer: Xiaodong Liu
//Data: 3-Mar-2020
//
//Discription:
//Drive transaction to DUT.
//-----------------------------------------------------------
`include "NFC_Generator.sv"

`define driver intf 
semaphore input_flag = new();

class NFC_Initiator;
    local virtual NFC_Interface intf;
    mailbox #(NFC_Transaction) req_mb;
    mailbox #(NFC_Transaction) rsp_mb;
	mailbox #(NFC_Transaction) sgn_req_mb;
	mailbox #(NFC_Transaction) sgn_rsp_mb;
	int nready;
	logic HREADY = 'b1;	
	logic HRESP = 'b0;
	logic newburst = 0;
    logic[1:0] status;//depend on HRESP and HREADY
	
		
    function new();	   
    endfunction
  
    function void set_interface(virtual NFC_Interface intf);
      if(intf == null)
        $error("INI:  interface handle is NULL, please check if target interface has been intantiated");
      else begin
        this.intf = intf;
	  end
    endfunction

    task run();
      this.drive();
    endtask

    task drive();
		NFC_Transaction req, rsp, sgn_req, sgn_rsp, data1, data2;
		data1=new();
		data2=new();		
      @(negedge intf.HRESET);
	   $display("INI:  start initiator");
		 fork 
		 forever begin
		   @(posedge intf.HCLK);
		   if(intf.HRESET==1)begin
		   sgn_req = new();
		   sgn_req.HRESP = 0;//this.intf.HRESP;
		   sgn_req.HREADY = this.intf.HREADY;
		   sgn_req.HRDATA = this.intf.HRDATA;
		   sgn_req.fault_injection = this.intf.fault_injection;
		   sgn_req_mb.put(sgn_req);
		   sgn_rsp_mb.get(sgn_rsp);
		   assert(sgn_rsp.rsp)
		 	 else $error("[RSPERR] %0t sgn_rsp error response received!", $time);
		   end
		 end
		 forever begin
		   @(this.req_mb.num());
		   begin
			  this.req_mb.get(req);
			  rsp = req.clone();
              data1.HWDATA = req.HWDATA;
              req.HWDATA = data2.HWDATA;			  
			  this.send(req);
			  data2.HWDATA = data1.HWDATA;
			  rsp.rsp = 1;
			  this.rsp_mb.put(rsp);	
		   end
		 end
         join		  
     
    endtask
  
    task send(input NFC_Transaction t);
	    `driver.HSEL <= t.HSEL;
		`driver.HADDR <= t.HADDR;
		`driver.HWRITE <= t.HWRITE;
		`driver.HSIZE <= t.HSIZE;
		`driver.HBURST <= t.HBURST;
		`driver.HTRANS <= t.HTRANS;
		`driver.HWDATA <= t.HWDATA; 
		`driver.fault_injection <= t.fault_injection; 
	endtask	
	
	
endclass:NFC_Initiator