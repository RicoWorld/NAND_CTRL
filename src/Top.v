`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/12 17:10:02
// Design Name: 
// Module Name: Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//
module Top(
   //FLASH Interface
   input           ACLK     ,  // dut clock
   input           HCLK     ,  // ahb clock
   input           R_nB     ,
   inout  [7 :0]   DIO      ,
   output          WE_n     ,
   output          RE_n     ,
   output          CE_n     ,
   output          CLE      ,
   output          ALE      ,
   
   //AHB Interface
   input           HWRITE   ,
   input           HSEL     ,
   input           HRESETn  ,
   input           HREADY   ,
   input  [1 :0]   HTRANS   ,
   input  [2 :0]   HSIZE    , 
   input  [31:0]   HWDATA   ,
   input  [31:0]   HADDR    ,
   input  [2 :0]   HBURST   ,
   output [31:0]   HRDATA   ,
   output          HRESP    ,
   output          HREADYOUT
   
    );


  reg   [ 7:0] FlashCmd_r    ; //flash command 
  reg   [ 7:0] cadr1_r       ; //flash colume address 1 LSB
  reg   [ 7:0] cadr2_r       ; //flash colume address 2 MSB
  reg   [ 7:0] radr1_r       ; //flash row address 1 LSB
  reg   [ 7:0] radr2_r       ; //flash row address 2
  reg   [ 7:0] radr3_r       ; //flash row address 3 MSB
  reg   [ 7:0] addr_data_r   ; //flash address
  reg   [ 7:0] ECC_data_r    ;
  reg   [ 7:0] FlashDataOu_r ; //falsh output data
  wire  [ 1:0] CAD_sel_w     ; //flash data type select
  wire  [ 2:0] AMUX_sel_w    ; //flash address select
  wire         DOS           ; //output to flash enable
  wire         DIS           ;
 
  reg   [11:0] acnt_r        ; //flash write/read address counter 
  wire         acnt_rst_w    ; //flash write/read address counter
  wire         acnt_en_w     ; //flash write/read address counter enable 
  wire         TC_w          ; //finish flag
  wire         TC_data_w     ; //data finish flag    
  wire         TC_ecc_w      ; //ecc data finish flag
  wire         arst_w        ; //address counter reset
  
  
  //AHB slave
  reg  [31:0]  ahb2flash_r       ; //AHB to flash data(write flash command)

  wire [15:0]  command_w         ; 
  wire [ 7:0]  Block_addr_w[0:2] ;
  wire [ 7:0]  Page_addr_w [0:1] ;
  wire [11:0]  MFSM_state_w      ; 
  wire         bf_we_w           ; //register write enable
  wire [ 7:0]  bf_data_w         ; //register data 
  wire [11:0]  bf_addr_w         ; //register address
  wire [11:0]  bf_reg_addr_w     ;
 
 
  //MFSM
  wire         toggle_done_w     ; //TFSM done
  wire         toggle_en_w       ; //TFSM enable
  wire         cmd_en_w          ; //TFSM command enable
  wire [ 2:0]  cmd_code_w        ; //TFSM command
  wire [ 7:0]  cmd_reg_w         ; //TFSM command register
  
  wire         ecc_rd_w          ; //ecc read enable
  reg          ecc_rd_r          ; //ecc read enable
  wire         ecc_wr_w          ; //ecc write enbale
  wire         ecc_en_w          ; //ecc enable
  wire         radr_en_w         ; //row address enable
  wire         cadr_en_w         ; //colume address enable
  wire         wCnt_rst_w        ; //wait time counter reset
  wire         wCnt_en_w         ; //wait time counter enable
  reg  [ 4:0]  wCnt_r            ; //MFSM wait counter
  wire         tWB_w             ; //tWB
  wire         tWHB_w            ; //tWHB
//  wire         fifo_delay_w      ;
//flash write or read flag for fifo ctrl
  wire         flash_read_w      ; 
  wire         flash_write_w     ;
  wire         flash_write_rr    ;
  wire         flash_read_rr     ;
  

  
 
 
 //tfsm

  wire         ecc_busy_w        ;
  wire         fifo_en_w         ;
  wire         BF_w              ;//register  enable
  wire         Flash_BF_we       ;//register  enable
  wire         fwr_en_w          ;//register write enable
  wire         frd_en_w          ;//register read enable
  
  
  
 //fifo
  wire         empty_w           ;
  wire         full_w            ;
  reg          wr_clk            ;
  reg          rd_clk            ;

  reg          wr_en_w           ;
  reg          rd_en_w           ;
  reg  [31:0]  din_w             ;
  wire [31:0]  dout_w            ;
  
  wire         wr_rst_busy_w     ;
  wire         rd_rst_busy_w     ;
  wire [31:0]  APhase_HADDR      ;
  wire         srst              ; // soft reset fifo after program or read page
  
//ecc

  wire [31:0]  ecc_dataout_w;
  reg  [31:0]  ecc_datain_w;
  wire         ecc_on_w;

//top

  reg          rstn_r,rstn_rr;
  reg  [31:0]  FlashDataIn_r;
  wire [ 7:0]  FlashDataIn;
               
  wire [15:0]  colume_addr_w;
//  wire [15:0]  ecc_addr_w;
               
  wire [15:0]  settime_w;
  wire [15:0]  holdtime_w;
               
               
  wire [31:0]  fifo2ahb_w;
  wire [31:0]  flash2ahb_w;
  wire         done_w;
  wire         page_width_w;
  wire         interface_w;
  wire         address_num_w;
  wire         start;

  wire         CE_n_M,CE_n_T;
  
  reg  [11:0]  data_field_r;
  reg  [11:0]  spare_field_r;
  wire [11:0]  data_field_w;

  reg  [31:0]  fifo_rdata_cnt;
  
  assign CE_n = CE_n_M & CE_n_T ;
	
///////////////////////////////////////////////
/////////////////RESET MODULE//////////////////
///////////////////////////////////////////////
//Asynchronous reset and synchronous release///

  always @(posedge ACLK or negedge HRESETn)
    begin
	  if(~HRESETn)
	    rstn_r <= 1'b0;
	  else 
	    rstn_r <= 1'b1;
	end
	
  always @(posedge ACLK or negedge HRESETn)
    begin
	  if(~HRESETn)
	    rstn_rr <= 1'b0;
	  else 
	    rstn_rr <= rstn_r;
	end
	
  assign rstn = rstn_rr; //	
	
	
  assign srst = ( MFSM_state_w == 12'h075 || MFSM_state_w == 12'h051 ) ? 1'b1:1'b0;
	
  AHB_SALVE slave_ctrl(
    .ACLK              (ACLK           ),
    .HCLK              (HCLK           ),
    .HSEL              (HSEL           ),
    .HRESETn           (HRESETn        ),
    .HREADY            (HREADY         ),
    .HWRITE            (HWRITE         ),
    .HADDR             (HADDR          ),
    .HTRANS            (HTRANS         ),
    .HSIZE             (HSIZE          ),
    .HWDATA            (HWDATA         ),
    .HRDATA            (HRDATA         ),
    .HREADYOUT         (HREADYOUT      ),
    .bufwrite_i        (bf_we_w        ),
    .bufdata_i         (bf_data_w      ),
    .bufaddr_i         (bf_addr_w      ),  
    .bufdata_o         (               ),
    .command_o         (command_w      ),
    .flash_write_i     (flash_write_w  ),
    .flash_read_i      (flash_read_w   ),
    .Block_addr1_o     (Block_addr_w[0]),
    .Block_addr2_o     (Block_addr_w[1]),
    .Block_addr3_o     (Block_addr_w[2]),
    .Page_addr1_o      (Page_addr_w[0] ),
    .Page_addr2_o      (Page_addr_w[1] ),
    .MFSM_state        (MFSM_state_w   ),
    .settime_o         (settime_w      ),
    .holdtime_o        (holdtime_w     ),
    .done_i            (done_w         ),
    .ecc_en_o          (ecc_on_w       ),
	.decode_result_i   (decode_result_w),
    .page_width_o      (page_width_w   ),
    .interface_o       (interface_w    ),
	.address_num_o     (address_num_w  ),
    .empty_i           (empty_w        ),
    .full_i            (full_w         ),
    .start             (start          ),
    .flash2ahb_i       (fifo2ahb_w     ),
    .APhase_HADDR      (APhase_HADDR   ),
    .APhase_HWRITE     (APhase_HWRITE  )
  );

  MFSM Main_FSM(
    .clk               (ACLK           ),
    .rstn              (rstn           ),
    .R_nB              (R_nB           ),
    .CE_n              (CE_n_M         ),
    .MFSM_start_i      (start          ),
    .command_i         (command_w      ),
    .MFSM_state_o      (MFSM_state_w   ),
    .toggle_done_i     (toggle_done_w  ),
    .toggle_en_o       (toggle_en_w    ),
    .tWB_i             (tWB_w          ),
    .tCLR_i            (tWHB_w         ),
    .acnt_rst_o        (acnt_rst_w     ),
    .cmd_code_o        (cmd_code_w     ), // to timing ctroller
    .cmd_o             (cmd_reg_w      ), // to flash
    .cmd_en_o          (cmd_en_w       ),
    .radr_en_o         (radr_en_w      ),
    .cadr_en_o         (cadr_en_w      ),
    .ecc_on_i          (ecc_on_w       ),
    .interface_i       (interface_w    ),
    .page_width_i      (page_width_w   ),
	.address_num_i     (address_num_w  ),
    .ecc_en_o          (ecc_en_w       ),
	.ecc_decode_en_o   (ecc_decode_en_w),
	.ecc_encode_en_o   (ecc_encode_en_w),
    .ecc_done_i        (ecc_done_w     ),
    .bf_reg_addr_o     (bf_reg_addr_w  ),    
    .AMUX_sel_o        (AMUX_sel_w     ),
    .CAD_sel_o         (CAD_sel_w      ),
    .wCnt_rst_o        (wCnt_rst_w     ),
    .wCnt_en_o         (wCnt_en_w      ),
    .OP_done_o         (done_w         ),
    .flash_read_o      (flash_read_w   ),
    .flash_write_o     (flash_write_w  ),
    .fifo_rdata_cnt_i  (fifo_rdata_cnt ),
    .data_field_i      (data_field_w   )
  );


  Timing_ctrl TFSM(
    .CLE               (CLE            ),
    .ALE               (ALE            ),
    .WE_n              (WE_n           ),
    .RE_n              (RE_n           ),
    .CE_n              (CE_n_T         ),
    .DOS               (DOS            ),
    .DIS               (DIS            ),
    .settime_i         (settime_w      ),
    .holdtime_i        (holdtime_w     ), 
    .cnt_en_o          (acnt_en_w      ),
    .TC_i              (TC_w           ),
    .empty_i           (empty_w        ),
    .full_i            (full_w         ),
    .clk               (ACLK           ),
    .rstn              (rstn           ),
    .start             (toggle_en_w    ),
    .cmd_code_i        (cmd_code_w     ),
    .acnt_i            (acnt_r         ),
    .we_fifo_o         (fwr_en_w       ),
    .rd_fifo_o         (frd_en_w       ),
	.ecc_ready_i       (ecc_ready_w    ),
	.ecc_done_i        (ecc_done_w     ),
    .ecc_wr_o          (ecc_wr_w       ),
    .ecc_rd_o	       (ecc_rd_w       ),
	.ecc_en_i          (ecc_en_w       ),
    .Done              (toggle_done_w  ),
    .BF_o              (BF_w           )
  );



//assign bf_data_w  = flash_read_w ? FlashDataIn   : ahb_data_w;
//assign bf_addr_w  = flash_read_w ? bf_reg_addr_w : ahb_addr_w;
//assign bf_we_w    = flash_read_w ? Flash_BF_we : ahb_we_w;
assign bf_data_w   = FlashDataIn  ;
assign bf_addr_w   = bf_reg_addr_w ;
assign bf_we_w     = Flash_BF_we ;

assign Flash_BF_we = DIS & BF_w;


  ecc_top LDPC_ECC_dut(
    .clk               (ACLK           ),
	.rst_n             (rstn           ),
    .wr_en             (ecc_wr_w       ),
    .rd_en             (ecc_rd_w       ),
    .data_in           (ecc_datain_w   ),      
    .data_out          (ecc_dataout_w  ),       
    .ecc_rdy           (ecc_ready_w    ),        //ECC to AHB
    .ecc_over          (ecc_done_w     ),
    .ecc_decode_req    (ecc_decode_en_w),
	.ecc_code_req      (ecc_encode_en_w),
	.decode_result     (decode_result_w)
  );

always@(*)
  begin
    if(ecc_encode_en_w)  ecc_datain_w <= dout_w;
    else if (ecc_decode_en_w) ecc_datain_w <= FlashDataIn_r;
	else ecc_datain_w <=32'b0;
  end
  


fifo_generator_0 AHB2FLASH_FIFO (
  .rst                  (~rstn | srst  ),     //done_w     // input wire rst
  .wr_clk               (wr_clk        ),            // input wire wr_clk
  .rd_clk               (rd_clk        ),            // input wire rd_clk
  .din                  (din_w         ),                  // input wire [31 : 0] din
  .wr_en                (wr_en_w       ),              // input wire wr_en
  .rd_en                (rd_en_w       ),              // input wire rd_en
  .dout                 (dout_w        ),                // output wire [31 : 0] dout
  .full                 (full_w        ),                // output wire full
  .empty                (empty_w       ),              // output wire empty
  .wr_rst_busy          (wr_rst_busy_w ),  // output wire wr_rst_busy
  .rd_rst_busy          (rd_rst_busy_w )   // output wire rd_rst_busy
);



  always@(*) 
    begin
	  if(~flash_write_w & ~flash_read_w)
	    wr_en_w <= 1'b0;
	  else if(flash_write_w & ~flash_read_w & ~full_w & (APhase_HADDR <=data_field_r) & HREADYOUT)
	    wr_en_w <= APhase_HWRITE;
	  else if(~flash_write_w & flash_read_w )
	    wr_en_w <= fwr_en_w;
	  else
	    wr_en_w <= 1'b0;
    end  
	
  always@(*)
    begin
	 if((~flash_write_w) & ~flash_read_w)
	   rd_en_w <= 1'b0;
	 else if(~flash_write_w & flash_read_w & ~empty_w & (APhase_HADDR <=data_field_r) )
	   rd_en_w <= ~APhase_HWRITE;
	 else if(flash_write_w & ~flash_read_w )
	   rd_en_w <= frd_en_w;
	 else
	   rd_en_w <= 1'b0;
	end

  always@(*)
    begin
	  if(flash_write_w & ~flash_read_w)
	    din_w <= HWDATA;
	  else if(~flash_write_w & flash_read_w & ~ecc_on_w)
	    din_w <= flash2ahb_w;
	  else if(~flash_write_w & flash_read_w & ecc_on_w)
	    din_w <= ecc_dataout_w;
	  else
	    din_w <= 0;	  
	end
	
  always@(*)  //clk gate
    begin
      if(flash_write_w & ~flash_read_w)
	    begin
		  wr_clk <= HCLK;
		  rd_clk <= ACLK ;
		end
	  else if(~flash_write_w & flash_read_w)
	    begin
		  wr_clk <= ACLK;
		  rd_clk <= HCLK;
		end
	  else
	    begin
		  wr_clk <= HCLK;
		  rd_clk <= HCLK;
		end
	end
	
	
	

//  assign din_w   = flash_write_w   ? HWDATA : (ecc_on_w) ? (ecc2ahb_w):(flash2ahb_w);
//  assign wr_clk  = flash_write_w   ? (HCLK)    : (ACLK);
//  assign rd_clk  = flash_write_w   ? (ACLK)    : (HCLK);
//  assign wr_en_w = (flash_write_w & (HADDR <= 12'h3ff))  ? (HWRITE)  : (fwr_en_w);
//  assign rd_en_w = (flash_write_w & (HADDR <= 12'h3ff))  ? (frd_en_w): (~HWRITE);


  always @(posedge HCLK) //fifo rdata counter;
    begin
	  if(~rstn)
	    fifo_rdata_cnt <= 0;
	  else if (start)
	    begin
		  if(page_width_w) fifo_rdata_cnt <= {Page_addr_w[1],Page_addr_w[0]};
		  else fifo_rdata_cnt <= Page_addr_w[0];
		end
      else if(~flash_write_w & flash_read_w & rd_en_w)
	    fifo_rdata_cnt <= fifo_rdata_cnt + 4;	    
    end
	

//
// fifo data for write flash 
//

  always @(posedge ACLK)
    begin
	  if(~rstn)
	    ecc_rd_r <= 1'b0;
	  else
	    ecc_rd_r <= ecc_rd_w;
	end
	
  always @(posedge ACLK)  
    begin
	  if(~rstn)
	    ahb2flash_r <=0;
	  else if(rd_en_w && ~ecc_on_w)
	    ahb2flash_r <= dout_w ;
	  else if(ecc_rd_r && ecc_on_w)
	    ahb2flash_r <= ecc_dataout_w;
	end

//
// fifo data for read flash	
//
  assign fifo2ahb_w   = dout_w; //read flash

  assign arst_w =( (~rstn) | acnt_rst_w); 
  assign colume_addr_w={Page_addr_w[1],Page_addr_w[0]};
  
  always @(*)
    begin
	  if(page_width_w == 1'b0)
	    begin
	      data_field_r  <= 12'h1ff; 
		  spare_field_r <= 12'h20f;
		end
	  else 
        begin
		  data_field_r  <= 12'h7ff; 
		  spare_field_r <= 12'h7ff; // no use spare filed
		end
	end

  assign data_field_w = ecc_on_w ? spare_field_r:data_field_r;
  assign TC_data_w = (acnt_r == data_field_r)?1'b1:1'b0; //2048/512 byte data 
  assign TC_ecc_w  = (acnt_r == spare_field_r)?1'b1:1'b0; //add 64/16   byte ecc
  assign TC_w      = (ecc_en_w)?(TC_ecc_w):(TC_data_w);
//  assign fifo_en_w = (fifo_delay_w &(acnt_r > 12'h007)) ?1'b1:1'b0; //wait 6 byte data ,ecc data ready
  always @(posedge ACLK)
    begin
	  if(arst_w)
	    acnt_r <= 0;
	  else if(cadr_en_w)
	    acnt_r <= {Page_addr_w[1],Page_addr_w[0]};
	  else if(acnt_en_w)
	    acnt_r <= acnt_r + 1'b1;
	end
	
  
  always @(posedge ACLK)
    begin
	  if(~rstn | wCnt_rst_w)
	    wCnt_r <= 5'b00000;
      else if (wCnt_en_w)
	    wCnt_r <= wCnt_r + 1'b1;  //wait cnt
	end

  assign tWB_w = (wCnt_r == (5'b1010-1'b1))?1'b1:1'b0;
  assign tWHB_w = (wCnt_r == (5'b1100-1'b1))?1'b1:1'b0;



  always @(posedge ACLK)
    begin
	  if(~rstn)
	    begin
		  radr1_r <= 8'b00000000;
		  radr2_r <= 8'b00000000;
		  radr3_r <= 8'b00000000;
		end
	  else if(radr_en_w)
	    begin
		  radr1_r <= Block_addr_w[0];
		  radr2_r <= Block_addr_w[1];
		  radr3_r <= Block_addr_w[2];
	    end
	end
	
  always @(posedge ACLK)
    begin
	  if(~rstn)
	    begin
          cadr1_r <= 8'b00000000;
	      cadr2_r <= 8'b00000000;
		end
	  else if(cadr_en_w)  
	    begin
		  cadr1_r <= Page_addr_w[0];
		  cadr2_r <= Page_addr_w[1];
		end
    end



//FLASH cmd
  always@(posedge ACLK)
    begin
      if (~rstn)
        FlashCmd_r <= 8'b00000000;
      else if (cmd_en_w)
        FlashCmd_r <= cmd_reg_w;
    end




//rad //row  address
//cad //Colume address
//FLASH??
  always@(*)
   begin
    case (AMUX_sel_w)
//	   3'b110 : addr_data_r <= ecc_addr_w[15:0];
//	   3'b101 : addr_data_r <= ecc_addr_w[ 7:0];
	   3'b100 : addr_data_r <= radr3_r;
       3'b011 : addr_data_r <= radr2_r;
       3'b010 : addr_data_r <= radr1_r;
       3'b001 : addr_data_r <= cadr2_r;
	   3'b000 : addr_data_r <= cadr1_r;
       default: addr_data_r <= cadr1_r;
    endcase
   end



//

  always@(*)
    begin
      case (CAD_sel_w)
         2'b11 : FlashDataOu_r <= FlashCmd_r;
         2'b10 : FlashDataOu_r <= addr_data_r;
         2'b01 : begin
		   case(acnt_r[1:0])
		     2'b00:FlashDataOu_r <= ecc_dataout_w[ 7: 0];
			 2'b01:FlashDataOu_r <= ecc_dataout_w[15: 8];
			 2'b10:FlashDataOu_r <= ecc_dataout_w[23:16];
			 2'b11:FlashDataOu_r <= ecc_dataout_w[31:24];
			 default:FlashDataOu_r <= ecc_dataout_w[ 7: 0];
		   endcase
		 end
		 2'b00 : begin
		   case(acnt_r[1:0])
		     2'b00:FlashDataOu_r <= ahb2flash_r[ 7: 0];
			 2'b01:FlashDataOu_r <= ahb2flash_r[15: 8];
			 2'b10:FlashDataOu_r <= ahb2flash_r[23:16];
			 2'b11:FlashDataOu_r <= ahb2flash_r[31:24];
			 default:FlashDataOu_r <= ahb2flash_r[ 7: 0];
		   endcase
		 end
         default: FlashDataOu_r <= FlashCmd_r;
      endcase
    end
	

  always@ (posedge RE_n )
    begin
      if(~rstn)
	    FlashDataIn_r <= 32'h00000000;
      else begin
	    FlashDataIn_r <= (FlashDataIn_r>>8);
		FlashDataIn_r[31:24] <= FlashDataIn;
      end
    end

  assign flash2ahb_w =FlashDataIn_r;

  assign FlashDataIn = DIO;


  assign DIO =(DOS == 1'b1) ? FlashDataOu_r : 8'hzz;
	
  endmodule
