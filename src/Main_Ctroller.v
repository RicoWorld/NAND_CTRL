module MFSM(
  input clk,
  input rstn,
  input R_nB,
  input MFSM_start_i,
//  input WE_n,
//  input RE_n,
 
  input [15:0] command_i,  //read id addres 00 or 90
  input        ecc_on_i,
  input        interface_i,
  input        address_num_i,
  input        page_width_i,
  
  input [31:0] fifo_rdata_cnt_i,
  input [11:0] data_field_i,

  output [11:0] MFSM_state_o,
  //TIMING_Ctroller
  
  input              toggle_done_i,
  output reg         toggle_en_o,  //Toggle enable
  input              tCLR_i,
  input              tWB_i ,

  output reg         acnt_rst_o,

  output reg  [2:0]  cmd_code_o,   //Toggle command code
  output reg  [7:0]  cmd_o,        //flash command 
  output reg         cmd_en_o,     //flash command latch 
  
  output reg         radr_en_o,    //row address latch
  output reg         cadr_en_o,    //colume address lathch
  output reg         CE_n,

//for ecc
  output reg         ecc_en_o ,
  output reg         ecc_decode_en_o,
  output reg         ecc_encode_en_o,
  input              ecc_done_i     ,

  //Flash
  output reg  [11:0] bf_reg_addr_o, // register address
  output reg  [ 1:0] CAD_sel_o ,  //Command /Address /Data
  output reg  [ 2:0] AMUX_sel_o,
  output reg         wCnt_rst_o,
  output reg         wCnt_en_o,
  output reg         OP_done_o,
  output reg         flash_read_o,
  output reg         flash_write_o
  
);





 


// -----------------------------------------------------------
//| COMMAND
//|0x0030              PAGE_READ
//|0x05E0              
//|0x60D0              BLOCK ERASE
//|0x7000              READ STATE
//|0x8010              PROGRAM PAGE
//|0x9000/20           READ ID
//|0xFF00              Reset
 

///////////////////////////////////
////////////////MFSM///////////////
///////////////////////////////////

 

  
  parameter IDLE = 12'h000;
   
  parameter CMD_DECODE        = 12'h001; 
  parameter READ_ID_CMDL0     = 12'h002; 
  parameter READ_ID_CMDL1     = 12'h003; 
  parameter READ_ID_ADDRL0    = 12'h004;
  
  parameter READ_ID_ADDRL1    = 12'h005;
  parameter READ_ID_WAIT      = 12'h006;
  parameter READ_ID_DR1       = 12'h007;
  parameter READ_ID_DR2       = 12'h008;
  parameter READ_ID_DR3       = 12'h009;
  parameter READ_ID_DR4       = 12'h00a;
  parameter READ_ID_DR5       = 12'h00b;
  parameter READ_ID_DR6       = 12'h00c;
  parameter READ_ID_DONE      = 12'h00d;
  
 
  parameter RESET_CMDL0       = 12'h010;
  parameter RESET_CMDL1       = 12'h011;
  parameter RESET_WAIT        = 12'h012;
  parameter RESET_DONE        = 12'h113;
  
  parameter READ_STATE_CMDL0  = 12'h013;
  parameter READ_STATE_CMDL1  = 12'h014;
  parameter READ_STATE_ADDRL0 = 12'h080;
  parameter READ_STATE_ADDRL1 = 12'h081;
  parameter READ_STATE_WAITL0 = 12'h016;
  parameter READ_STATE_WAITL1 = 12'h017;
  parameter READ_STATE_DR1    = 12'h018;
  parameter READ_STATE_DONE   = 12'h019;
  
  
  parameter BLOCK_ERASE_CMDL0 = 12'h020;
  parameter BLOCK_ERASE_CMDL1 = 12'h021;
  parameter BLOCK_ERASE_CMDL2 = 12'h022;
  parameter BLOCK_ERASE_CMDL3 = 12'h023;  
  parameter BLOCK_ERASE_ADDRL0 = 12'h024;
  parameter BLOCK_ERASE_ADDRL1 = 12'h025;
  parameter BLOCK_ERASE_ADDRL2 = 12'h026;
  parameter BLOCK_ERASE_WAITL0 = 12'h027;
  parameter BLOCK_ERASE_WAITL1 = 12'h028;
  parameter BLOCK_ERASE_WAITL2 = 12'h029;
  
  
  parameter PAGE_PROGRAM_CMDL0  = 12'h040;
  parameter PAGE_PROGRAM_CMDL1  = 12'h041;
  parameter PAGE_PROGRAM_CMDL2  = 12'h042;
  parameter PAGE_PROGRAM_CMDL3  = 12'h043;
  parameter PAGE_PROGRAM_CMDL4  = 12'h044;
  parameter PAGE_PROGRAM_CMDL5  = 12'h045;
  parameter PAGE_PROGRAM_CMDL6  = 12'h046;
  parameter PAGE_PROGRAM_ADDRL0 = 12'h047;
  parameter PAGE_PROGRAM_ADDRL1 = 12'h048;
  parameter PAGE_PROGRAM_ADDRL2 = 12'h049;
  parameter PAGE_PROGRAM_ADDRL3 = 12'h04a;
  parameter PAGE_PROGRAM_ADDRL4 = 12'h04b;
  parameter PAGE_PROGRAM_ADDRL5 = 12'h04c;
  parameter PAGE_PROGRAM_ADDRL6 = 12'h04d;
  parameter PAGE_PROGRAM_WAITL0 = 12'h04e;
  parameter PAGE_PROGRAM_WAITL1 = 12'h04f;  
  parameter PAGE_PROGRAM_WAITL2 = 12'h050;
  parameter PAGE_PROGRAM_WAITL3 = 12'h051;
  parameter PAGE_PROGRAM_WAITL4 = 12'h052;
  parameter PAGE_PROGRAM_WAITL5 = 12'h053;
  parameter PAGE_PROGRAM_WPAL0  = 12'h054;
  parameter PAGE_PROGRAM_WPAL1  = 12'h055;
  
  
  parameter PAGE_READ_CMDL0     = 12'h060;  
  parameter PAGE_READ_CMDL1     = 12'h061;
  parameter PAGE_READ_CMDL2     = 12'h062;
  parameter PAGE_READ_CMDL3     = 12'h063;
  parameter PAGE_READ_CMDL4     = 12'h064;
  parameter PAGE_READ_CMDL5     = 12'h065;
  parameter PAGE_READ_CMDL6     = 12'h066;
  parameter PAGE_READ_CMDL7     = 12'h067;
  parameter PAGE_READ_ADDRL0    = 12'h068;
  parameter PAGE_READ_ADDRL1    = 12'h069;
  parameter PAGE_READ_ADDRL2    = 12'h06a;
  parameter PAGE_READ_ADDRL3    = 12'h06b;
  parameter PAGE_READ_ADDRL4    = 12'h06c;
  parameter PAGE_READ_ADDRL5    = 12'h06d;
  parameter PAGE_READ_ADDRL6    = 12'h06e;
  parameter PAGE_READ_WAITL0    = 12'h06f;
  parameter PAGE_READ_WAITL1    = 12'h070;
  parameter PAGE_READ_WAITL2    = 12'h071;
  parameter PAGE_READ_WAITL3    = 12'h072;
  parameter PAGE_READ_WAITL4    = 12'h073;
  parameter PAGE_READ_WAITL5    = 12'h074;
  parameter PAGE_READ_DONE      = 12'h075;
  parameter PAGE_READ_RPAL0     = 12'h076;
  parameter PAGE_READ_RPAL1     = 12'h077;
  parameter PAGE_READ_WAITL6    = 12'h078;
  
  
  parameter PAGE_ECC_ENCODE_WRITE = 12'h100;
  parameter PAGE_ECC_ENCODE_WAIT1 = 12'h101;
  
  parameter PAGE_ECC_DECODE_READ  = 12'h110;
  parameter PAGE_ECC_DECODE_WAIT1 = 12'h111;
  
  

  
  
   reg [11:0] current_state,next_state;
   reg [15:0] command_r;
  
  //output 
  assign MFSM_state_o = current_state;  
  
  
  always @(posedge clk)
  begin
    if(~rstn)
	  command_r <= 16'b0;
	else if (MFSM_start_i)
	  command_r <= command_i;
	else 
	  command_r <= 16'b0;
  end
  ///////////////////////////
  always @(posedge clk)
    begin
      if (~rstn)
  	    current_state <= IDLE;
  	  else
  	    current_state <= next_state;
    end
  	    
  
  
  
  always @(*)
    begin
      toggle_en_o     <= 1'b0   ;
  	  CAD_sel_o       <= 2'b11  ; //default is command
  	  AMUX_sel_o      <= 3'b000 ; //default is cad1
      cmd_o           <= 8'h00  ;
      cmd_en_o        <= 1'b0 	 ;
	  OP_done_o       <= 1'b0   ;
	  wCnt_en_o       <= 1'b0   ;
	  wCnt_rst_o      <= 1'b0   ;
	  cmd_code_o      <= 3'b000 ;
	  acnt_rst_o      <= 1'b0   ;
	  cadr_en_o       <= 1'b0   ;
	  radr_en_o       <= 1'b0   ;
	  CE_n            <= 1'b1   ;
//	  ecc_we_o        <= 1'b0   ;
//	  ecc_re_o        <= 1'b0   ;
	  ecc_en_o        <= 1'b0   ;
	  flash_write_o   <= 1'b0   ;
	  flash_read_o    <= 1'b0   ;
	  ecc_decode_en_o <= 1'b0   ;
	  ecc_encode_en_o <= 1'b0   ;
      case(current_state)
  	  IDLE:begin
  	    if(MFSM_start_i)
  		  next_state <= CMD_DECODE;
  		else
  		  next_state <= IDLE;
  	  end
	  
  	  CMD_DECODE:begin
	    acnt_rst_o <= 1'b1;//reset data address count
  	    casex(command_r)
		16'h8010:begin
		  if (ecc_on_i) next_state <= PAGE_ECC_ENCODE_WRITE;
		  else next_state <= PAGE_PROGRAM_CMDL0 ;
		end
  		16'h7000:next_state <= READ_STATE_CMDL0  ; 
  		16'h90xx:next_state <= READ_ID_CMDL0     ;
		16'h60D0:next_state <= BLOCK_ERASE_CMDL0 ;
		16'h0030:next_state <= PAGE_READ_CMDL0   ;
  		16'hFF00:next_state <= RESET_CMDL0       ;
		default :next_state <= IDLE              ;
  		endcase
  	  end
  	  
	  
	  PAGE_ECC_ENCODE_WRITE:begin
	  	cmd_code_o      <= 3'b110;
	    ecc_en_o        <= 1'b1;
		ecc_encode_en_o <= 1'b1;
		flash_read_o    <= 1'b0;
		flash_write_o   <= 1'b1;
		toggle_en_o     <= 1'b1;
	    if(toggle_done_i)
		  next_state <= PAGE_PROGRAM_CMDL0;
		else
		  next_state <= PAGE_ECC_ENCODE_WRITE;
	  end
	  
//	  PAGE_ECC_ENCODE_WAIT1:begin
//	    if(ecc_done_i) next_state <= PAGE_PROGRAM_CMDL0;
//		else next_state <= PAGE_ECC_ENCODE_WAIT1;
//	  end
	  
	  
	  PAGE_PROGRAM_CMDL0:begin
	    cmd_o      <= 8'h80;
		radr_en_o  <= 1'b1 ;
		cadr_en_o  <= 1'b1 ;
		cmd_en_o   <= 1'b1 ;
		next_state <= PAGE_PROGRAM_CMDL1;
	  end
	  
	  
	  PAGE_PROGRAM_CMDL1:begin
	    toggle_en_o <= 1'b1  ;
		cmd_code_o  <= 3'b000;
		CAD_sel_o   <= 2'b11 ;
		if(toggle_done_i)
		  next_state <= PAGE_PROGRAM_ADDRL0;
		else
		  next_state <= PAGE_PROGRAM_CMDL1 ;
	  end
	  
	  PAGE_PROGRAM_ADDRL0:begin
	    toggle_en_o <= 1'b1  ;
		cmd_code_o  <= 3'b001;
		CAD_sel_o   <= 2'b10 ;
		AMUX_sel_o  <= 3'b000; //-- colume address 1
		if(toggle_done_i)
		  begin
		    if(page_width_i)
		      next_state <= PAGE_PROGRAM_ADDRL1;
		    else
		      next_state <= PAGE_PROGRAM_ADDRL2;
		  end
	    else next_state <=PAGE_PROGRAM_ADDRL0;
	  end
	  
	  PAGE_PROGRAM_ADDRL1:begin
	    toggle_en_o <= 1'b1  ;
		cmd_code_o  <= 3'b001;
		CAD_sel_o   <= 2'b10 ;
		AMUX_sel_o  <= 3'b001; //-- colume address 2
		if(toggle_done_i)
		  next_state <= PAGE_PROGRAM_ADDRL2;
		else
		  next_state <= PAGE_PROGRAM_ADDRL1;
	  end
	  
	  PAGE_PROGRAM_ADDRL2:begin
	  	toggle_en_o <= 1'b1  ;
		cmd_code_o  <= 3'b001;
		CAD_sel_o   <= 2'b10 ;
		AMUX_sel_o  <= 3'b010; //-- row address 1
        if(toggle_done_i)
		  next_state <= PAGE_PROGRAM_ADDRL3;
		else
		  next_state <= PAGE_PROGRAM_ADDRL2;
	  end
	  
	  PAGE_PROGRAM_ADDRL3:begin
	    toggle_en_o <= 1'b1  ;
		cmd_code_o  <= 3'b001;
		CAD_sel_o   <= 2'b10 ;
		AMUX_sel_o  <= 3'b011; //-- row address 2
        if(toggle_done_i & address_num_i)
		  next_state <= PAGE_PROGRAM_ADDRL4;
		else if(toggle_done_i & ~address_num_i)
		  next_state <= PAGE_PROGRAM_WAITL0;
		else
		  next_state <= PAGE_PROGRAM_ADDRL3;
	  end
	  
	  PAGE_PROGRAM_ADDRL4:begin
	  	toggle_en_o <= 1'b1  ;
		cmd_code_o  <= 3'b001;
		CAD_sel_o   <= 2'b10 ;
		AMUX_sel_o  <= 3'b100; //-- row address 3
		if(toggle_done_i)
		  next_state <= PAGE_PROGRAM_WAITL0;
		else
		  next_state <= PAGE_PROGRAM_ADDRL4;
	  end
	  
	  PAGE_PROGRAM_WAITL0:begin
	    acnt_rst_o <= 1'b1;
		wCnt_rst_o <= 1'b1;
		next_state <= PAGE_PROGRAM_WAITL1;
	  end
	  
	  PAGE_PROGRAM_WAITL1:begin
	    wCnt_en_o  <= 1'b1;
		if(tCLR_i) begin
			cadr_en_o  <= 1'b1;
		    next_state <= PAGE_PROGRAM_WAITL2;
		  end
		else
		  next_state <= PAGE_PROGRAM_WAITL1;
	  end
	  
	  PAGE_PROGRAM_WAITL2:begin
	    if(R_nB)
		  next_state <= PAGE_PROGRAM_WPAL0;
		else
		  next_state <= PAGE_PROGRAM_WAITL2;
	  end	  
	  
	  PAGE_PROGRAM_WPAL0:begin
	     toggle_en_o    <= 1'b1;
		 cmd_code_o     <= 3'b111 ;  //--data write one page , colume start address ---- address[2047]
		 if(ecc_on_i)begin
		   //CAD_sel_o      <= 2'b01  ;  // ECC data to flash
		   CAD_sel_o      <= 2'b00  ;  // ECC data to flash
		   flash_read_o   <= 1'b0   ; 
           flash_write_o  <= 1'b0   ;
           ecc_en_o		  <= 1'b1   ;
		 end
		 else begin
		   CAD_sel_o      <= 2'b00  ;  // AHB data to flash
		   flash_read_o   <= 1'b0   ; 
           flash_write_o  <= 1'b1   ;
           ecc_en_o		  <= 1'b0   ;
		 end
		 if(toggle_done_i)
		   next_state <= PAGE_PROGRAM_CMDL5;
		 else
		   next_state <= PAGE_PROGRAM_WPAL0;
	  end
	  
	  
	  PAGE_PROGRAM_CMDL5:begin
	    cmd_o    <= 8'h10;
		cmd_en_o <= 1'b1;
		next_state <= PAGE_PROGRAM_CMDL6;
	  end
	  
	  PAGE_PROGRAM_CMDL6:begin
	    toggle_en_o <= 1'b1;
		cmd_code_o  <= 3'b000;
		if(toggle_done_i)
		  next_state <= PAGE_PROGRAM_WAITL3;
		else
		  next_state <= PAGE_PROGRAM_CMDL6;
	  end
	   
	  PAGE_PROGRAM_WAITL3:begin
//	    acnt_rst_o <= 1'b1;
		wCnt_rst_o <= 1'b1;
		next_state <= PAGE_PROGRAM_WAITL4;
	  end
	  
	  PAGE_PROGRAM_WAITL4:begin
	    wCnt_en_o  <= 1'b1;
		if(tCLR_i)
		  next_state <= PAGE_PROGRAM_WAITL5;
		else
		  next_state <= PAGE_PROGRAM_WAITL4;
	  end
	  
	  PAGE_PROGRAM_WAITL5:begin
	    if(R_nB)
		  next_state <= READ_STATE_CMDL0;
		else
		  next_state <= PAGE_PROGRAM_WAITL5;
	  end
	  
 
	  PAGE_READ_CMDL0:begin  //
	    cmd_o      <= 8'h00 ;
		cmd_en_o   <= 1'b1  ;
		radr_en_o  <= 1'b1  ;
		cadr_en_o  <= 1'b1  ;
		next_state <= PAGE_READ_CMDL1;
	  end	  
	  	  
      PAGE_READ_CMDL1:begin	  
	    toggle_en_o <= 1'b1   ;  
		cmd_code_o  <= 3'b000 ;  
		CAD_sel_o   <= 2'b11  ;  
		if(toggle_done_i)
		  next_state <= PAGE_READ_ADDRL0; //DATA filed address
		else
		  next_state <= PAGE_READ_CMDL1;
	  end  
 	  
	  
	  PAGE_READ_ADDRL0:begin
	    toggle_en_o <= 1'b1   ;
	    cmd_code_o  <= 3'b001 ;
	    CAD_sel_o   <= 2'b10  ;
	    AMUX_sel_o  <= 3'b000 ;
	    ecc_en_o    <= 1'b0   ;
	    if(toggle_done_i & page_width_i)
	      next_state <= PAGE_READ_ADDRL1;
	    else if (toggle_done_i & (~page_width_i))
	      next_state <= PAGE_READ_ADDRL2;
	    else
	      next_state <= PAGE_READ_ADDRL0;
	  end
	  
	  PAGE_READ_ADDRL1:begin
	    toggle_en_o <= 1'b1   ;
	    cmd_code_o  <= 3'b001 ;
	    CAD_sel_o   <= 2'b10  ;
	    AMUX_sel_o  <= 3'b001 ;
	    ecc_en_o    <= 1'b0   ;
	    if(toggle_done_i)
	      next_state <= PAGE_READ_ADDRL2;
	    else
	      next_state <= PAGE_READ_ADDRL1;
	  end
	  	  
	  PAGE_READ_ADDRL2:begin
	    toggle_en_o <= 1'b1;
		cmd_code_o  <= 3'b001;
		CAD_sel_o   <= 2'b10;
		AMUX_sel_o  <= 3'b010;
		if(toggle_done_i)
		  next_state <= PAGE_READ_ADDRL3;
		else
		  next_state <= PAGE_READ_ADDRL2;
	  end
	  
	  PAGE_READ_ADDRL3:begin
	    toggle_en_o <= 1'b1;
		cmd_code_o  <= 3'b001;
		CAD_sel_o   <= 2'b10;
		AMUX_sel_o  <= 3'b011;
		if(toggle_done_i & address_num_i)
		  next_state <= PAGE_READ_ADDRL4;
		else if (toggle_done_i & ~address_num_i & interface_i)
		  next_state <= PAGE_READ_CMDL2;
		else if (toggle_done_i & ~address_num_i & ~interface_i)
		  next_state <= PAGE_READ_WAITL0;
		else 
		  next_state <= PAGE_READ_ADDRL3;
	  end
	  
	  PAGE_READ_ADDRL4:begin
	    toggle_en_o <= 1'b1;
		cmd_code_o  <= 3'b001;
		CAD_sel_o   <= 2'b10;
		AMUX_sel_o  <= 3'b100;
		if(toggle_done_i & interface_i)
		  next_state <= PAGE_READ_CMDL2 ;
		else if(toggle_done_i & ~interface_i)
		  next_state <= PAGE_READ_WAITL0 ;
		else
		  next_state <= PAGE_READ_ADDRL4;	  
	  end
	  
	  PAGE_READ_CMDL2:begin
		cmd_o      <= 8'h30;
		cmd_en_o   <= 1'b1;
		next_state <= PAGE_READ_CMDL3;
	  end
	  
	  PAGE_READ_CMDL3:begin
	    toggle_en_o <= 1'b1;
	    cmd_code_o  <= 3'b000;
		CAD_sel_o   <= 2'b11;
		if(toggle_done_i)
		  next_state <= PAGE_READ_WAITL0;
	  end
	  
	  PAGE_READ_WAITL0:begin
//	    acnt_rst_o <= 1'b1;
        CE_n       <= 1'b0;    
		wCnt_rst_o <= 1'b1;
		next_state <= PAGE_READ_WAITL1;
	  end
	  
	  PAGE_READ_WAITL1:begin
	    wCnt_en_o  <= 1'b1;
		CE_n       <= 1'b0;
		if(tCLR_i)
		  next_state <= PAGE_READ_WAITL2;
		else
		  next_state <= PAGE_READ_WAITL1;
	  end
	  
	  PAGE_READ_WAITL2:begin
	    CE_n       <= 1'b0;
	    if(R_nB)
		  next_state <= PAGE_READ_RPAL0;  
		else
		  next_state <= PAGE_READ_WAITL2;
	  end	

      PAGE_READ_RPAL0:begin //read data in fifo module
	     CE_n       <= 1'b0;
	     toggle_en_o <= 1'b1;
		 cmd_code_o  <= 3'b101 ;  //--data read one page , colume start address ---- address[2047]/[512]		 
		 if(ecc_on_i)
		   begin
		     flash_read_o    <= 1'b0   ;
		     flash_write_o   <= 1'b0   ;
			 ecc_decode_en_o <= 1'b1   ;
			 ecc_en_o        <= 1'b1   ;
		   end
		 else
		   begin
		     flash_read_o    <= 1'b1   ;
		     flash_write_o   <= 1'b0   ;
			 ecc_decode_en_o <= 1'b0   ;
			 ecc_en_o        <= 1'b0   ;
		   end		 		 
		 if(toggle_done_i && ~ecc_on_i)
		   next_state <= PAGE_READ_WAITL6; 
		 else if(toggle_done_i && ecc_on_i)
		   next_state <= PAGE_ECC_DECODE_WAIT1; 
		 else
		   next_state <= PAGE_READ_RPAL0;
	  end 
	  
	  
	  PAGE_ECC_DECODE_WAIT1:begin
	    ecc_decode_en_o <= 1'b1;
	    if(ecc_done_i) next_state <= PAGE_ECC_DECODE_READ;
		else next_state <= PAGE_ECC_DECODE_WAIT1;
	  end
	  
	  
	  PAGE_ECC_DECODE_READ:begin
        cmd_code_o      <= 3'b100;
		flash_read_o    <= 1'b1;
		flash_write_o   <= 1'b0;
		toggle_en_o     <= 1'b1;
	    if(toggle_done_i)
		  next_state <= PAGE_READ_WAITL6;
		else
		  next_state <= PAGE_ECC_DECODE_READ;
	  end
	  
	  
	  PAGE_READ_WAITL6:begin
	    flash_read_o <= 1'b1      ;
		flash_write_o <=1'b0      ;
		if(~ecc_on_i) begin
		  if(fifo_rdata_cnt_i == (data_field_i+1))
		    next_state <=PAGE_READ_DONE;
		  else
		    next_state <=PAGE_READ_WAITL6;
		end
		else if(ecc_on_i)begin
		  if(fifo_rdata_cnt_i == (12'h784))
		    next_state <=PAGE_READ_DONE;
		  else
		    next_state <=PAGE_READ_WAITL6;
		end
		else  next_state <=PAGE_READ_WAITL6;
	  end
	  
	  PAGE_READ_DONE:begin
	    OP_done_o <= 1'b1;
		next_state <= IDLE;
	  end
	  
	  
//	  PAGE_READ_RPAL1:begin
//	    toggle_en_o <= 1'b1;
//	    cmd_code_o  <= 3'b101 ;  //--data read one page , colume start address ---- address[2047]
//	// CAD_sel_o   <= 2'b00  ;  // AHB fifo data to flash
//        ecc_we_o    <= 1'b1   ;  // flash to  ecc
//	    ecc_re_o    <= 1'b1   ;
//	    flash_read_o <= 1'b1   ;  //FALSH DATA TO ECC
//		flash_write_o <= 1'b0 ;
//	    fifo_delay_o   <= 1'b1    ;  //delay 3 cyce for 12 byte data
//		if(toggle_done_i)
//		  next_state <= PAGE_READ_DONE;
//		else
//		  next_state <= PAGE_READ_RPAL1;
//	  end
//	  
//	  PAGE_READ_DONE:begin
//	    OP_done_o <= 1'b1;
//		next_state <= IDLE;
//	  end
	  
  	  READ_ID_CMDL0:begin
  		cmd_o      <= 8'h90  ;//--h90 to flash data out
  		cmd_en_o   <= 1'b1   ;
        next_state <= READ_ID_CMDL1;
  	  end
  	  
  	  READ_ID_CMDL1:begin
  	    toggle_en_o <= 1'b1   ; //timing ctroller enbale
  		cmd_code_o  <= 3'b000 ;   
		CAD_sel_o   <= 2'b11  ;
  	    if(toggle_done_i)
  	      next_state <= READ_ID_ADDRL0;
  	    else
  		  next_state <= READ_ID_CMDL1;
      end
	  
  	  READ_ID_ADDRL0:begin
  	    cmd_en_o     <= 1'b1    ;  //enbale 8'h00 to flash
		cmd_o        <= 8'h00; 
        next_state   <= READ_ID_ADDRL1;	
      end

  	  
      READ_ID_ADDRL1:begin
	    toggle_en_o  <= 1'b1    ;
		cmd_code_o   <= 3'b001  ;  // 
//		AMUX_sel_o   <= 3'b010  ;  // rad_1	 
		CAD_sel_o    <= 2'b11   ;  // address out
		if (toggle_done_i)
  		  next_state <= READ_ID_WAIT;
  		else 
		  next_state <= READ_ID_ADDRL1;
	  end      
	  
  	  READ_ID_WAIT:begin  //tAR time min:10ns
	    toggle_en_o <= 1'b1;
  	    wCnt_rst_o  <= 1'b1;
		next_state  <= READ_ID_DR1; 
  	  end
	   
//	  READ_ID_DSR1:begin
//	    toggle_en_o <= 1'b1   ;
//   	    cmd_code_o  <= 1'b100 ; // 4 byte
//		if(toggle_done_i)
//		  next_state <= READ_ID_DONE;
//		else
//		  next_state <= READ_ID_DSR1;
//	  end
	  
	  READ_ID_DR1:begin
	    toggle_en_o   <= 1'b1   ;
		cmd_code_o    <= 3'b010 ;  
		bf_reg_addr_o <= 12'h800; // ID reg address
		if(toggle_done_i)
		  next_state <= READ_ID_DR2;
		else
		  next_state <= READ_ID_DR1;
	  end
	  
	  READ_ID_DR2:begin
	    toggle_en_o   <= 1'b1   ;
		cmd_code_o    <= 3'b010 ;  
		bf_reg_addr_o <= 12'h801; // ID reg address
		if(toggle_done_i)
		  next_state <= READ_ID_DR3;
		else
		  next_state <= READ_ID_DR2;
	  end
	  
	  READ_ID_DR3:begin
	    toggle_en_o   <= 1'b1   ;
		cmd_code_o    <= 3'b010 ; 
	    bf_reg_addr_o <= 12'h802; // ID reg address		
		if(toggle_done_i)
		  next_state <= READ_ID_DR4;
		else
		  next_state <= READ_ID_DR3;
	  end
	  
	  READ_ID_DR4:begin
	    toggle_en_o    <= 1'b1   ; 
		cmd_code_o     <= 3'b010 ;  
		bf_reg_addr_o  <= 12'h803; // ID reg address
		if(toggle_done_i && command_r[5])
		  next_state <= READ_ID_DR5;  //6byte
		else if(toggle_done_i && (~command_r[5]))
		  next_state <= READ_ID_DONE; //4byte
		else
		  next_state <= READ_ID_DR4;
	  end
	  
	  READ_ID_DR5:begin
	    toggle_en_o   <= 1'b1;
		cmd_code_o    <= 3'b010;  
		bf_reg_addr_o <= 12'h804; // ID reg address
		if(toggle_done_i)
		  next_state <= READ_ID_DR6;
		else
		  next_state <= READ_ID_DR5;
	  end
	  
	  READ_ID_DR6:begin
	    toggle_en_o   <= 1'b1;
		cmd_code_o    <= 3'b010;
	    bf_reg_addr_o <= 12'h805; // ID reg address		
		if(toggle_done_i)
		  next_state <= READ_ID_DONE;
		else
		  next_state <= READ_ID_DR6;
	  end
	  
	  READ_ID_DONE:begin
	    OP_done_o  <= 1'b1;
		next_state <= IDLE;
	  end
  	   
	  RESET_CMDL0:begin
	    cmd_o    <= 8'hff;
		cmd_en_o <= 1'b1;
	    next_state <= RESET_CMDL1;
	  end
	  
	  RESET_CMDL1:begin
	    cmd_code_o  <= 3'b000;
		toggle_en_o <= 1'b1;
		if(toggle_done_i)
		  next_state <= RESET_WAIT;
		else
		  next_state <= RESET_CMDL1;
	  end
	  
	  RESET_WAIT:begin  //请立即下拉R_Bn
	    if(R_nB)
		  next_state <= RESET_DONE;
		else
		  next_state  <= RESET_WAIT;
      end
	  
	  RESET_DONE:begin
	    OP_done_o <= 1'b1;
		next_state <= IDLE;
	  end
    
	  READ_STATE_CMDL0:begin
	    cmd_o      <= 8'h70;
		cmd_en_o   <= 1'b1;
	    next_state <= READ_STATE_CMDL1;
	  end
	  
	  READ_STATE_CMDL1:begin
	    cmd_code_o  <= 3'b000;
		toggle_en_o <= 1'b1;
		if (toggle_done_i)
		  next_state <= READ_STATE_WAITL0;
	    else
		  next_state <= READ_STATE_CMDL1;
	  end
	  
//  	  READ_STATE_ADDRL0:begin
//  	    cmd_en_o     <= 1'b1    ;  //enbale 8'h00 to flash
//		cmd_o        <= 8'h00; 
//        next_state   <= READ_STATE_ADDRL1;	
//      end
//	
//	  
//	  READ_STATE_ADDRL1:begin
//	   	toggle_en_o  <= 1'b1    ;
//		cmd_code_o   <= 3'b001  ;  // 
////		AMUX_sel_o   <= 3'b010  ;  // rad_1	 
//		CAD_sel_o    <= 2'b11   ;  // address out
//		if (toggle_done_i)
//  		  next_state <= READ_STATE_WAITL0;
//  		else 
//		  next_state <= READ_STATE_ADDRL1; 
//	  end
	  READ_STATE_WAITL0:begin  
  	    wCnt_rst_o  <= 1'b1;
		next_state  <= READ_STATE_WAITL1; 
	  end
	  
	  READ_STATE_WAITL1:begin //tCLR
	    wCnt_en_o   <= 1'b1;
		if(tCLR_i)
		  next_state  <= READ_STATE_DR1;
		else
		  next_state  <= READ_STATE_WAITL1;
	  end
	  
	  READ_STATE_DR1:begin
	    toggle_en_o <= 1'b1;
		cmd_code_o  <= 3'b010;
		bf_reg_addr_o <= 12'h806; //state reg
		if (toggle_done_i)
		  next_state <= READ_STATE_DONE;
		else
		  next_state <= READ_STATE_DR1;
	  end
	  
	  READ_STATE_DONE:begin
	    OP_done_o  <= 1'b1;
		next_state <= IDLE;
	  end
	  
	  BLOCK_ERASE_CMDL0:begin
	    radr_en_o  <= 1'b1  ;
	    cmd_o    <= 8'h60 ;
		cmd_en_o   <= 1'b1  ;
		next_state <= BLOCK_ERASE_CMDL1;
	  end
	  
	  BLOCK_ERASE_CMDL1:begin
	    toggle_en_o <= 1'b1;
		cmd_code_o  <= 3'b000;
		if(toggle_done_i)
		  next_state <= BLOCK_ERASE_ADDRL0;
		else
		  next_state <= BLOCK_ERASE_CMDL1;
	  end
	  
	  BLOCK_ERASE_ADDRL0:begin
	    CAD_sel_o   <= 2'b10;
		AMUX_sel_o  <= 3'b010;
		cmd_code_o  <= 3'b001;
		toggle_en_o <= 1'b1;
		if(toggle_done_i)
		  next_state <= BLOCK_ERASE_ADDRL1;
		else
		  next_state <= BLOCK_ERASE_ADDRL0;
	  end
	  
	  BLOCK_ERASE_ADDRL1:begin
	    CAD_sel_o   <= 2'b10;
		AMUX_sel_o  <= 3'b011;
		cmd_code_o  <= 3'b001;
		toggle_en_o <= 1'b1;
		if(toggle_done_i && address_num_i)
		  next_state <= BLOCK_ERASE_ADDRL2;
		else if(toggle_done_i && ~address_num_i)
		  next_state <= BLOCK_ERASE_CMDL2;
		else
		  next_state <= BLOCK_ERASE_ADDRL1;
	  end
	  
	  BLOCK_ERASE_ADDRL2:begin
	    CAD_sel_o   <= 2'b10 ;
		AMUX_sel_o  <= 3'b100;
		cmd_code_o  <= 3'b001;
		toggle_en_o <= 1'b1   ;
		if(toggle_done_i)
		  next_state <= BLOCK_ERASE_CMDL2;
		else
		  next_state <= BLOCK_ERASE_ADDRL2;
	  end
	  
	  BLOCK_ERASE_CMDL2:begin
	    cmd_o    <= 8'hd0;
		cmd_en_o <= 1'b1;
		next_state <= BLOCK_ERASE_CMDL3;
	  end
	  
	  BLOCK_ERASE_CMDL3:begin
	    toggle_en_o <= 1'b1;
		cmd_code_o  <= 3'b000;
		if(toggle_done_i)
		  next_state <= BLOCK_ERASE_WAITL0;
		else next_state <= BLOCK_ERASE_CMDL3;
	  end
	  
	  BLOCK_ERASE_WAITL0:begin 
	    wCnt_rst_o <= 1'b1 ;
		next_state <= BLOCK_ERASE_WAITL1;
	  end
	  
	  BLOCK_ERASE_WAITL1:begin //tWB 100~200ns
	    wCnt_en_o  <=1'b1;
		if(tWB_i)
		  next_state <= BLOCK_ERASE_WAITL2;
		else
		  next_state <= BLOCK_ERASE_WAITL1;
	  end
	  
	  BLOCK_ERASE_WAITL2:begin //wait R_Bn
	    if(R_nB)
		  next_state <= READ_STATE_CMDL0;//BLOCK_ERASE_CMDL5
		else
		  next_state <= BLOCK_ERASE_WAITL2;
	  end
	  default:next_state <= IDLE;
	  endcase
  end
//	  BLOCK_ERASE_CMDL5:begin
//	    cmd_o    <= 8'h70;
//		cmd_en_o <= 1'b1;
//		next_state <= BLOCK_ERASE_CMDL6;
//	  end
//	  
//	  BLOCK_ERASE_CMDL7:begin
//	    cmd_code_o <= 3'b000;
//		toggle_en_o <= 1'b1;
//	    if(toggle_done_i)
//		  next_state <= BLOCK_ERASE_WAITL3;
//		else
//		  next_state <= BLOCK_ERASE_CMDL7;
//	  end
//	  
//	  BLOCK_ERASE_WAITL3:begin 
//	    wCnt_rst_o <= 1'b1;
//		next_state <= BLOCK_ERASE_WAITL4;
//	  end
//	  
//	  BLOCK_ERASE_WAITL4:begin //tWHR  80-120ns
//	    wCnt_en_o  <= 1'b1;
//		if(tWHR_i)
//		  next_state <= 
//	  end
	  
	  
	  
	  
    
   
  /////output data

endmodule