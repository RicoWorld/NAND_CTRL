module Register(
   input                hclk,
   input                aclk,
   input                rstn,
   input                hsel,
   input        [ 1:0]  htrans,
   input        [ 2:0]  hsize,
   input                hwe,
   input                hready,
   input                byte0_i,
   input                byte1_i,
   input                byte2_i,
   input                byte3_i,
   input        [31:0]  hdata_i,
   input        [31:0]  haddr,
   output wire   [31:0]  hdata_o,
   output wire          start_o,
   output wire          start_ahb_o,

   
   input        [11:0]  MFSM_state_i,
   input                done_i,


   input                fwe,
   input        [11:0]  faddr,
   input                frd,
   input        [ 7:0]  fdata_i,
   output       [ 7:0]  fdata_o,


   
   output       [15:0]  command_o,
   output wire  [ 7:0]  Block_addr1_o,
   output wire  [ 7:0]  Block_addr2_o,
   output wire  [ 7:0]  Block_addr3_o,
   output wire  [ 7:0]  Page_addr1_o,
   output wire  [ 7:0]  Page_addr2_o,
   
   output wire  [15:0]  settime_o,
   output wire  [15:0]  holdtime_o,

   output wire  [15:0]  ecc_en_o,
   output wire          page_width_o,
   output wire          interface_o,
   
   output wire          done_o
);


// REGISTER
// Address                |Description

//
//0 |0x0500               |存储器时序参数寄存器，高16bit建立时间有关，低16bit保持时间
//1 |0x0504               |colume address
//2 |0x0508               |row address
//3 |0x050C               |0 bit:ecc_en
//4 |0x0510               |控制器命令寄存器

//5,6 |0x514,0x0518             |ID REGISTER
//7 |0x051C               |存储器状态寄存器，用于读取存储器状濿
//8 |0x0520               |MFSM STATE




//for host
//R-Register
  reg [ 7:0]  ID_r[0:5]           ;
  reg [31:0]  FLASH_state_r  ;



///////////////////// 
///write R-Register
///////////////////// 

  //ID 
  always @(posedge aclk)
    begin
      if(~rstn)
	    ID_r[0] <= 8'h00;
	  else if(fwe && faddr == 12'h500) 
	    ID_r[0] <= fdata_i;
	end
	
  always @(posedge aclk)
    begin
      if(~rstn)
	    ID_r[1] <= 8'h00;
	  else if(fwe && faddr == 12'h501) 
	    ID_r[1] <= fdata_i;
	end
	
  always @(posedge aclk)
    begin
      if(~rstn)
	    ID_r[2] <= 8'h00;
	  else if(fwe && faddr == 12'h502) 
	    ID_r[2] <= fdata_i;
	end
	
  always @(posedge aclk)
    begin
      if(~rstn)
	    ID_r[3] <= 8'h00;
	  else if(fwe && faddr == 12'h503) 
	    ID_r[3] <= fdata_i;
	end
	
  always @(posedge aclk)
    begin
      if(~rstn)
	    ID_r[4] <= 8'h00;
	  else if(fwe && faddr == 12'h504) 
	    ID_r[4] <= fdata_i;
	end
	
  always @(posedge aclk)
    begin
      if(~rstn)
	    ID_r[5] <= 8'h00;
	  else if(fwe && faddr == 12'h505) 
	    ID_r[5] <= fdata_i;
	end
	
//FLASH STATE
  always @(posedge aclk)
    begin
	  if(~rstn)
	    FLASH_state_r <= 8'h00;
	  else if(fwe && faddr == 12'h506)
	    FLASH_state_r <= fdata_i;
	end
	
	

///////////////////       	 
//address decode 
////////////////// 
  reg [31:0] memory[0:8];
  reg [ 3:0] haddr_r;
  reg        wen_r  ;
  always @(*)
    begin
	  case(haddr)
	  12'h500:begin
          haddr_r <= 4'd0;
	      wen_r   <= 1'b1;
	    end
	  12'h504:begin
	      haddr_r <= 4'd1;
	      wen_r   <= 1'b1;
	    end
	  12'h508:begin
	      haddr_r <= 4'd2;
	      wen_r   <= 1'b1;
	    end
	  12'h50C:begin
	      haddr_r <= 4'd3;
	      wen_r   <= 1'b1;
	    end    
	  12'h510:begin
	      haddr_r <= 4'd4;
	      wen_r   <= 1'b1;
	    end
      12'h514:begin
	      haddr_r <= 4'd5;
	      wen_r   <= 1'b0;
	    end
	  12'h518:begin
	      haddr_r <= 4'd6;
	      wen_r   <= 1'b0;
	    end
	  12'h51C:begin
	      haddr_r <= 4'd7;
	      wen_r   <= 1'b0;
	    end
	  12'h520:begin
	      haddr_r <= 4'd8;
	      wen_r   <= 1'b0;
	    end
	  default:begin
	      haddr_r <= 4'd8;
          wen_r   <= 1'b0;		  
	  end
	  endcase
    end
  
  always @(posedge hclk)
    begin
	  if(~rstn)
	    begin
		  memory[0] <= 32'b0;
		  memory[1] <= 32'b0;
		  memory[2] <= 32'b0;
		  memory[3] <= 32'b0;
		  memory[4] <= 32'b0;
		  memory[5] <= 32'b0;
		  memory[6] <= 32'b0;
		  memory[7] <= 32'b0;
		  memory[8] <= 32'b0;
		end
	  else
	    begin
	      memory[5]<={ID_r[3],ID_r[2],ID_r[1],ID_r[0]};
	      memory[6]<={16'b0,ID_r[5],ID_r[4]};
	      memory[7]<={24'b0,FLASH_state_r};
	      memory[8]<={20'b0,MFSM_state_i};
	    if(hsel & hwe & htrans[1] & hready & wen_r)
	      begin
		    if(byte0_i)
		  	  memory[haddr_r][7:0] <= hdata_i[7:0];
		    if(byte1_i)
		      memory[haddr_r][15:8] <= hdata_i[15:8];
		    if(byte2_i)
		      memory[haddr_r][23:16] <= hdata_i[23:16];
		    if(byte3_i)               
			  memory[haddr_r][31:24] <= hdata_i[31:24];
	      end
	    end
     end
 

  reg [31:0]command_r;
 
  always @(posedge hclk)
    begin
	  if(~rstn)
	    command_r <= 32'b0;
	  else
	    command_r <= memory[4];
	end
//  always @(posedge hclk)
//    begin
//	  if(~rstn)
//	    start <= 1'b0;
//	  else if(memory[7] != command_r)
//	    start <= 1'b1;
//	  else
//	    start <= 1'b0;
//	end

//sample start	

  wire start;
  reg d1,d2,d3;
//  assign start=(memory[4] != command_r)?1'b1:1'b0; // two hclk
  assign start=(haddr_r == 4)?1'b1:1'b0; // two hclk
  
  always @(posedge aclk) 
    begin
	  if(~rstn)
	    begin
	      d1 <= 1'b0;
		  d2 <= 1'b0;
//		  d3 <= 1'b0;
		end
	  else
	    begin
	      d1 <= start;
		  d2 <= d1;
//		  d3 <= d2   ;
		end
    end	
	
//  assign start_o = d2 & ~d3; // rising edge
  assign start_o = d2 ; //to mfsm
  assign start_ahb_o = start ;//to ahb host
  
//sample done signal

  wire done_rst;
  
  assign done_rst = ~done_i && done_o;
  reg q1, q2, q3;


  always @(negedge rstn or posedge done_i or posedge done_rst) begin
    if (done_rst | ~rstn)
      begin
        q1 <= 1'b0;
      end
    else 
	  begin
        q1 <= 1'b1;
      end
end

  always @(posedge hclk ) begin
    if (~rstn) 
	  begin
        q2 <= 1'b0;
        q3 <= 1'b0;
      end
    else 
	  begin
        q2 <= q1;
        q3 <= q2;
      end
  end

assign done_o = q3;

assign hdata_o = memory[haddr_r];

 
/////////////////////////////////////////////////
//地址说明
////////////////////////////////////////////////// 
/////
//Page_addr_r [ 7: 0] CA7-CA0 ;         ca1
//            [15: 8] {4{0},CA11-CA8}   ca2
//
//Block_addr_r[ 7: 0] RA19-RA12    ra1
//            [15: 8] RA27-RA20    ra2
//            [23:16] {7{0},RA28}  ra3


 assign Block_addr1_o = memory[2][7:0];
 assign Block_addr2_o = memory[2][15:8];
 assign Block_addr3_o = memory[2][23:16];
 assign Page_addr1_o  = memory[1][7:0];
 assign Page_addr2_o  = memory[1][15:8];
 assign command_o     = memory[4][15:0];
 
 assign settime_o     = memory[0][31:16];
 assign holdtime_o    = memory[0][15 :0];
 assign ecc_en_o      = memory[3][0];
 assign page_width_o  = memory[3][1];
 assign interface_o   = memory[3][2];
	
endmodule