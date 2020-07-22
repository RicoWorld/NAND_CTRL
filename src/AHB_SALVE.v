`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 罗孟杰
// 
// Create Date: 2020/03/08 15:51:55
// Design Name: 
// Module Name: AHB_SALVE
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: AHB_SALVE
////////////////////////////////////////////////
// ------------------------------------------------------------------------------------------
// |主机寻址范围      |说明
// |0x0000——0x07FF    |BUFFER1 数据位宽32，总大小1024 byte
// |0x0800            |存储器时序参数寄存器，高16bit建立时间有关，低16bit保持时间
// |0x0804            |页内地址，colume address
// |0x0808            |块地址，row address
// |0x080C            |第0位表示ecc使能信号，1'b1:ON  ; 1’b0:off
//                    |第1位选择大小页模式， 1'b1:大页; 1'b0:小页    //大页：2byte Colume address ；小页：1byte colume address
//                    |第2位选择协议模式,    1'b1:ONFI; 1'b0:toggle
//                    |第3位选择ROW地址长度  1'b1:3byte 1'b0:2byte   //地址长度为Row地址总共需要的字节数
// |0x0810            |控制器命令寄存器
// |0x0814            |ID REGISTER 1
// |0x0818            |ID REGISTER 2
// |0x081C            |存储器状态寄存器，用于读取存储器状态
// |0x0820            |低16bit位主控逻辑状态寄存器，用于读取存储器状态，
//                    |第16位：ecc result :1'b1:ecc success 1'b0:ecc error

/////////////////////////////////////////////////////////////////////
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AHB_SALVE(
    input wire         ACLK,
	input wire         HCLK,
	//AHBLITE INTERFACE
		//Slave Select Signals
    input wire         HSEL,
		//Global Signal
    input wire         HRESETn,
		//Address, Control & Write Data
    input wire         HREADY,
	input wire         HWRITE,
    input wire  [31:0] HADDR,
    input wire  [ 1:0] HTRANS,
    input wire  [ 2:0] HSIZE,
    input wire  [31:0] HWDATA,
		// Transfer Response & Read Data

	output reg [31:0]  HRDATA,
    output wire        HREADYOUT,
	
	//
			
	//data from MFSM	
	
	input wire         bufwrite_i,
	input wire  [ 7:0] bufdata_i,
	input wire  [11:0] bufaddr_i,
	output wire [ 7:0] bufdata_o,
	output wire [15:0] command_o,
	
	input              flash_write_i,
    input              flash_read_i,
	input       [11:0] MFSM_state,
	input              done_i,
	input       [31:0] flash2ahb_i,
	
	input              decode_result_i,



	output      [7 :0] Block_addr1_o,
	output      [7 :0] Block_addr2_o,
	output      [7 :0] Block_addr3_o,
	output      [7 :0] Page_addr1_o,
	output      [7 :0] Page_addr2_o,

	output      [15:0] settime_o,
	output      [15:0] holdtime_o,
	output             ecc_en_o,
	output             page_width_o,
	output             interface_o,
	output             address_num_o,
	
	output             start,
		
	//data from fifo
	input              empty_i,
	input              full_i,
		
    output reg   [31:0]      APhase_HADDR,
	output reg               APhase_HWRITE

    
// AHB Lite Signal from slave to master
//    output reg         hready,
//    output reg  [ 1:0] hresp,
//    output reg  [31:0] hrdata
);
  reg APhase_HSEL;
//  reg APhase_HWRITE;
  reg [1:0] APhase_HTRANS;
//  reg [31:0] APhase_HADDR;
  reg [2:0] APhase_HSIZE;
  reg HREADYOUT_r;
  
  wire byte0,byte1,byte2,byte3;
  wire done_o;
  wire ahb_wait;
  wire [31:0] reg_data;
  
//  assign HWRITE_r = APhase_HWRITE;

  Register Config_Reg( 
          .hclk(HCLK),
		  .aclk(ACLK),
          .rstn(HRESETn),
		  .hsel(APhase_HSEL),
		  .htrans(APhase_HTRANS),
		  .hsize(APhase_HSIZE),
          .hwe(APhase_HWRITE),
          .hdata_i(HWDATA),
          .haddr(APhase_HADDR),  
          .hdata_o(reg_data),
		  .hready(HREADYOUT),
		  .start_o(start),
		  .start_ahb_o(ahb_wait),
		  .byte0_i(byte0),
		  .byte1_i(byte1),
		  .byte2_i(byte2),
		  .byte3_i(byte3),
       //MFSM data		  
		  .fwe(bufwrite_i),
		  .faddr(bufaddr_i),
		  .frd(),
		  .fdata_i(bufdata_i),
		  .fdata_o(bufdata_o),
		  .command_o(command_o),
		  .Block_addr1_o(Block_addr1_o),
		  .Block_addr2_o(Block_addr2_o),
		  .Block_addr3_o(Block_addr3_o),
		  .Page_addr1_o(Page_addr1_o),
		  .Page_addr2_o(Page_addr2_o),
		  .MFSM_state_i(MFSM_state),
		  .settime_o(settime_o),
		  .holdtime_o(holdtime_o),
		  .ecc_en_o(ecc_en_o),
		  .decode_result_i(decode_result_i),
		  .page_width_o(page_width_o),
		  .interface_o(interface_o),
		  .address_num_o(address_num_o),
		  .done_i(done_i),
		  .done_o(done_o)
  );    


   reg flash_read_r,flash_read_rr;
   reg flash_write_r,flash_write_rr;

   always @(posedge HCLK)
     begin
	   if(~HRESETn)
	     begin
	       flash_read_r  <= 1'b0;
		   flash_read_rr <= 1'b0;
		   flash_write_r <= 1'b0;
		   flash_write_rr <= 1'b0;
		 end
	   else
	     begin
		   flash_read_r   <= flash_read_i;
		   flash_read_rr  <= flash_read_r;
		   flash_write_r  <= flash_write_i;
		   flash_write_rr <= flash_write_r;
		 end
	 end


  always @(*)
    begin
      if(~flash_write_rr & flash_read_rr)
	    HRDATA <= flash2ahb_i;
      else
	    HRDATA <= reg_data;
	end
    

  always @(posedge HCLK)
    begin
	  if(~HRESETn)
	    HREADYOUT_r <= 1'b1;
	  else if((~flash_write_rr) & (~flash_read_rr) & ahb_wait)
	    HREADYOUT_r <= 1'b0;
	  else if((~flash_write_rr) & (~flash_read_rr) & done_o)
	    HREADYOUT_r <= 1'b1;
	  else if((~flash_write_rr) & (flash_read_rr) & ~empty_i) // read fifo
	    HREADYOUT_r <= 1'b1;
	  else if((~flash_write_rr) & (flash_read_rr) & empty_i)
	    HREADYOUT_r <= 1'b0;
	  else if((flash_write_rr) &  (~flash_read_rr) & (~full_i)) // write fifo
	    HREADYOUT_r <= 1'b1;
	  else if((flash_write_rr) &  (~flash_read_rr) & full_i )
	    HREADYOUT_r <= 1'b0;		
	end

 // assign HREADYOUT = HREADYOUT_r ;
  assign HREADYOUT = (flash_write_rr)?(HREADYOUT_r & (~full_i)):HREADYOUT_r; //consider fifo full


	
// Registers to store Adress Phase Signals

// Sample the Address Phase   
  always @(posedge HCLK or negedge HRESETn)
  begin
	 if(~HRESETn)
	 begin
		APhase_HSEL   <= 1'b0;
        APhase_HWRITE <= 1'b0;
        APhase_HTRANS <= 2'b00;
		APhase_HADDR  <= 32'h0;
		APhase_HSIZE  <= 3'b000;
	 end
    else if(HREADYOUT)
    begin
        APhase_HSEL   <= HSEL;
        APhase_HWRITE <= HWRITE;
        APhase_HTRANS <= HTRANS;
		APhase_HADDR  <= HADDR;
		APhase_HSIZE  <= HSIZE;
    end
  end


// Decode the bytes lanes depending on HSIZE & HADDR[1:0]

  wire tx_byte = ~APhase_HSIZE[1] & ~APhase_HSIZE[0];
  wire tx_half = ~APhase_HSIZE[1] &  APhase_HSIZE[0];
  wire tx_word =  APhase_HSIZE[1];
  
  wire byte_at_00 = tx_byte & ~APhase_HADDR[1] & ~APhase_HADDR[0];
  wire byte_at_01 = tx_byte & ~APhase_HADDR[1] &  APhase_HADDR[0];
  wire byte_at_10 = tx_byte &  APhase_HADDR[1] & ~APhase_HADDR[0];
  wire byte_at_11 = tx_byte &  APhase_HADDR[1] &  APhase_HADDR[0];
  
  wire half_at_00 = tx_half & ~APhase_HADDR[1];
  wire half_at_10 = tx_half &  APhase_HADDR[1];
  
  wire word_at_00 = tx_word;
  
  assign byte0 = word_at_00 | half_at_00 | byte_at_00;
  assign byte1 = word_at_00 | half_at_00 | byte_at_01;
  assign byte2 = word_at_00 | half_at_10 | byte_at_10;
  assign byte3 = word_at_00 | half_at_10 | byte_at_11;

// Writing to the memory



//  always @(posedge HCLK)
//  begin
//	 if(APhase_HSEL & APhase_HWRITE & APhase_HTRANS[1])
//	 begin
//		if(byte0)
//			memory[APhase_HADDR[11:2]][7:0] <= HWDATA[7:0];
//		if(byte1)
//			memory[APhase_HADDR[11:2]][15:8] <= HWDATA[15:8];
//		if(byte2)
//			memory[APhase_HADDR[11:2]][23:16] <= HWDATA[23:16];
//		if(byte3)               
//			memory[APhase_HADDR[11:2]][31:24] <= HWDATA[31:24];
//	  end
//  end

// Reading from memory 
//  assign HRDATA = memory[APhase_HADDR[11:2]];
 
endmodule
