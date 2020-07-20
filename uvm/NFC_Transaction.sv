//NAND Flash Controller Transaction
//
//Project engineer: Xiaodong Liu
//Data: 29-Feb-2020
//
//Discription:
//Transaction is data package sent to DUT.
//-----------------------------------------------------------
//HSIZE Define
`define BYTE     3'b000
`define HALFWORD 3'b001
`define WORD     3'b010
//HBURST Define
`define SINGLE 'b000 //Single burst
`define INCR   'b001 //Incrementing burst of undefined length
`define WRAP4  'b010 //4-bite wrapping burst
`define INCR4  'b011 //4-bite incrementing burst
`define WRAP8  'b100 //8-bite wrapping burst
`define INCR8  'b101 //8-bite incrementing burst
`define WRAP16 'b110 //16-bite wrapping burst
`define INCR16 'b111 //16-bite incrementing burst
//HTRANS Define
`define IDLE   'b00
`define BUSY   'b01
`define NONSEQ 'b10
`define SEQ    'b11
//COMMAND
`define PAGE_READ    32'h00000030
//`define ____       32'h000005E0
`define BLOCK_ERASE  32'h000060D0
`define READ_STATE   32'h00007000
`define PROGRAM_PAGE 32'h00008010
`define READ_ID      32'h00009000
`define RESET        32'h0000FF00
`define IDLE         32'h00000000

class NFC_Transaction;
	     logic       HSEL;
	     logic[31:0] HADDR;
	     logic       HWRITE;
	rand logic[2:0]  HSIZE;
	rand logic[2:0]  HBURST;
	     logic[1:0]  HTRANS;
         logic[31:0] HWDATA; 		  
		 logic       HREADY;
		 logic       HRESP;
		 logic[31:0] HRDATA;
		 int         rsp;
		 logic       fault_injection;
		  
	constraint c1{HSIZE inside {`BYTE,`HALFWORD,`WORD};
		          HBURST inside {`SINGLE,`INCR,`WRAP4,`INCR4,`WRAP8,`INCR8,`WRAP16,`INCR16};
	             };	 
		  
	function NFC_Transaction clone();
      NFC_Transaction c = new();
	  c.HSEL = this.HSEL;
      c.HADDR = this.HADDR;
	  c.HWRITE = this.HWRITE;
	  c.HSIZE = this.HSIZE;
	  c.HBURST = this.HBURST;
	  c.HTRANS = this.HTRANS;
	  c.HWDATA = this.HWDATA;
	  c.HREADY = this.HREADY;
	  c.HRESP = this.HRESP;
	  c.rsp = this.rsp;
	  c.fault_injection = this.fault_injection;
      return c;
    endfunction
	
endclass:NFC_Transaction