module Timing_ctrl(
   CLE ,
   ALE ,
   WE_n,
   RE_n,
   CE_n,
//   R_nB,
   DOS ,
   DIS ,

   settime_i,
   holdtime_i,
   cnt_en_o,
   TC_i,

   empty_i,
   full_i,
   
   clk,
   rstn,
   start,
   cmd_code_i,
   ecc_ready_i,
   ecc_en_i,
   ecc_done_i,
   ecc_wr_o,
   ecc_rd_o,
   Done, 
   BF_o,

   acnt_i,
   rd_fifo_o,
   we_fifo_o
);//FLASH
  output reg CLE ; //-- CLE               
  output reg ALE ; //-- ALE               
  output reg WE_n; // -- ~WE              
  output reg RE_n; // -- ~RE              
  output reg CE_n; // -- ~CE              
  output reg DOS ; // -- data from Buffer to FLASH  
  output reg DIS ; //  -- data from FLASH to Buffer  
  output reg cnt_en_o; //-- byte counter enable   
  output reg BF_o  ; //-- Register write
  output reg Done;                  
//  input TC2048; 
                    
  input clk ;                        
  input rstn ;                        
  input start;   
//  input R_nB;
  input [2:0] cmd_code_i; //
  input [15:0] settime_i;
  input [15:0] holdtime_i;
  
  input empty_i;
  input full_i;
  input [11:0]acnt_i;
  input TC_i;

// for ecc
  input  ecc_ready_i;
  input  ecc_done_i;
  
  input   ecc_en_i;
  
  output reg ecc_rd_o;
  output reg ecc_wr_o;
  
//for fifo
  output reg rd_fifo_o;
  output reg we_fifo_o;
  
  


// Command codes:
// 000 -Cmd Latch
// 001 -Addr latch
// 010 -Data Read 1 (1 cycle as status)
// 100 -Data Read,Ecc Decode
// 101 -Data Read multiple (w TC2048)
// 110 -Data Write,Ecc Encode
// 111 -Data Write (w TC2048)
// others'll return to Init


  reg        rd_fifo_r;
  reg        we_fifo_r;
  
  
  reg [ 7:0] settime_r,holdtime_r;
  reg [ 7:0] settime_cnt_r; 
  reg        settime_done_r;
  reg [ 7:0] holdtime_cnt_r; 
  reg        holdtime_done_r;
  
  
  always @(posedge clk)
    begin
	  if(~rstn)
	    rd_fifo_r <= 1'b0;
	  else
	    rd_fifo_r <= rd_fifo_o;
	end
	
	
	
  always @(posedge clk)
    begin
	  if(~rstn)
	    we_fifo_r <= 1'b0;
	  else
	    we_fifo_r <= we_fifo_o;
    end
  
  

  //assign TC = cmd_code_int[0] ? TC2048:TC4;
  
  always @(posedge clk)
    begin
	  if(~rstn)
	    begin
		  settime_r <= 8'b0;
		  holdtime_r <= 8'b0;
		end
      else if (start)
        begin	  
	      settime_r <= settime_i;
	      holdtime_r <= holdtime_i;
	    end
	end


////state
  reg [7:0] current_state,next_state;
  parameter IDLE     = 8'b00000000;
  parameter START    = 8'b00000001;  //解析当前命令类型
//  parameter S_CLE    = 4'b00000010;  //Command start
  parameter CMD_SET  = 8'b00000011;  //Command set 
  parameter CMD_HOLD = 8'b00000100;  //Command hold
  parameter CMD_DONE = 8'b00000101;  //Command end
  
  parameter ALE_SET  = 8'b00001000;   //Address set
  parameter ALE_HOLD = 8'b00001001;   //Address hold
  parameter ALE_DONE = 8'b00001010;

  parameter READ_1CYC_SET = 8'd13;
  parameter READ_1CYC_HOLD = 8'd14;
  parameter READ_1CYC_DONE = 8'd15;
  parameter READ_1PAGE_START =8'd16;
  parameter READ_1PAGE_SET = 8'd17;
  parameter READ_1PAGE_HOLD= 8'd18;
  parameter READ_1PAGE_WAITL0=8'd19;
  parameter READ_1PAGE_WAITL1=8'd21;
  parameter READ_ECC_DECODE   = 8'd23;
  parameter READ_ECC_DECODE_START = 8'd31;
  parameter ECC_DECODE_END  = 8'd32;
  parameter ECC_DECODE_DONE    = 8'd22;
  parameter WRITE_1PAGE_START =8'd24;
  parameter WRITE_1PAGE_SET   = 8'd25;
  parameter WRITE_1PAGE_WAITL0 =8'd26;
  parameter WRITE_1PAGE_WAITL1=8'd27;
  parameter WRITE_1PAGE_HOLD = 8'd28;
  parameter WRITE_ECC_ENCODE = 8'd29;
  parameter ECC_ENCODE_DONE = 8'd30;
  
  parameter Finish    =8'b11110000;
  parameter FinishW   =8'b11000000;
  parameter FinishR   =8'b10000000;
  parameter FinishEcc =8'b11100000;
// settime?
  wire settime_en_w,holdtime_en_w;
  assign settime_en_w = (current_state == CMD_SET) |(current_state == ALE_SET)| (current_state == READ_1CYC_SET) | (current_state == WRITE_1PAGE_SET) | (current_state == READ_1PAGE_SET);
  
  always @(posedge clk)
    begin
	  if(~rstn)
	    settime_cnt_r <= 8'b0;
	  else if (settime_en_w)
	    settime_cnt_r <= settime_cnt_r + 1'b1;
	  else 
	    settime_cnt_r <= 8'b0;
	end
   
  always @(posedge clk)
    begin
	  if(~rstn)
	    settime_done_r <= 1'b0;
	  else if(settime_cnt_r == (settime_r - 1'b1))
	    settime_done_r <= 1'b1;
	  else
	    settime_done_r <= 1'b0;
	end
	
// holdtime

  assign holdtime_en_w = (current_state == CMD_HOLD) | (current_state == ALE_HOLD) | (current_state == READ_1CYC_HOLD) | (current_state == WRITE_1PAGE_HOLD) | (current_state == READ_1PAGE_HOLD);
  always @(posedge clk)
    begin
	  if(~rstn)
	    holdtime_cnt_r <= 8'b0;
	  else if (holdtime_en_w)
	    holdtime_cnt_r <= holdtime_cnt_r + 1'b1;
	  else 
	    holdtime_cnt_r <= 8'b0;
	end
   
  always @(posedge clk)
    begin
	  if(~rstn)
	    holdtime_done_r <= 1'b0;
	  else if(holdtime_cnt_r == (holdtime_r - 1'b1))
	    holdtime_done_r <= 1'b1;
	  else
	    holdtime_done_r <= 1'b0;
	end


  always @(posedge clk)
    begin
	  if(~rstn)
	    current_state <= IDLE;
	  else
	    current_state <= next_state;
    end
   
   always @(*)
     begin
	   Done      <= 1'b0;
//	   ecc_en_o <= 1'b0;  //ecc data address load
	   CLE       <= 1'b0;
	   ALE       <= 1'b0;
	   CE_n      <= 1'b1;
	   WE_n      <= 1'b1;
	   RE_n      <= 1'b1;
	   DOS       <= 8'b0;
	   DIS       <= 8'b0;
	   cnt_en_o  <= 1'b0;
	   rd_fifo_o <= 1'b0;
	   we_fifo_o <= 1'b0;
	   BF_o      <= 1'b0;
	   ecc_wr_o  <= 1'b0;
	   ecc_rd_o  <= 1'b0;
	   case(current_state)
	     IDLE:begin
		   Done   <= 1'b0;
//	       ecc_en_o   <= 1'b0;
	       CLE      <= 1'b0;
	       ALE      <= 1'b0;
	       CE_n     <= 1'b1;
	       WE_n     <= 1'b1;
	       RE_n     <= 1'b1;
	       DOS      <= 8'b0;
	       DIS      <= 8'b0;
	       if(start) 
		     next_state <= START;
		   else 
		     next_state <= IDLE;
	     end
		 
	     START:begin
		   CE_n <= 1'b0;
		   case(cmd_code_i)
		     3'b000:next_state <= CMD_SET;
			 3'b001:next_state <= ALE_SET;
			 3'b010:next_state <= READ_1CYC_SET;
			 3'b101:next_state <= READ_1PAGE_START;
			 3'b100:next_state <= READ_ECC_DECODE;
             3'b110:next_state <= WRITE_ECC_ENCODE;
			 3'b111:next_state <= WRITE_1PAGE_START;
			 default:next_state <=IDLE;
		   endcase
		  end
		   
         
         WRITE_ECC_ENCODE:begin
           if(~empty_i & ecc_ready_i)
	         begin
	           rd_fifo_o <= 1'b1;
		       ecc_wr_o  <= rd_fifo_r;
	         end
	       else
	         begin
	           rd_fifo_o <= 1'b0;
               ecc_wr_o  <= rd_fifo_r;
		     end 
	       if(ecc_done_i) next_state <= ECC_ENCODE_DONE;
	       else next_state  <= WRITE_ECC_ENCODE;
          end
		
		 ECC_ENCODE_DONE:begin
		   Done <= 1'b1;
		   next_state <=FinishEcc;
		 end
		

         READ_ECC_DECODE_START:begin
           if(~full_i) begin
		     ecc_rd_o   <=1'b1;
             next_state <= READ_ECC_DECODE;
		   end
		   else begin
		     ecc_rd_o   <= 1'b0;
             next_state <= READ_ECC_DECODE_START;
		   end
         end
		 
		 
		 READ_ECC_DECODE:begin
		   if(~full_i)
	         begin
	           we_fifo_o <= 1'b1;
		       ecc_rd_o  <= 1'b1;
	         end
	       else
	         begin
	           we_fifo_o <= 1'b0;
               ecc_rd_o  <= 1'b0;
		     end
	       if(ecc_done_i) next_state <= ECC_DECODE_END;
	       else next_state <= READ_ECC_DECODE;
		 end
		 
		 
		 ECC_DECODE_END:begin
		   if(~full_i) begin
		       we_fifo_o  <= 1'b1;
			   next_state <= ECC_DECODE_DONE;
		     end
		   else begin
		       we_fifo_o  <= 1'b0;
			   next_state <= ECC_DECODE_END;
		     end
		 end
		 
		 ECC_DECODE_DONE:begin
		   Done <= 1'b1;
		   next_state <=FinishEcc;
		 end
		 
		 
		 FinishEcc:begin
		   if(start) next_state    <= START;
		   else next_state         <= IDLE ;
		 end
	 
		 CMD_SET:begin
		   CE_n <= 1'b0;
           WE_n <= 1'b0;
		   CLE  <= 1'b1;
		   DOS  <= 1'b1;
		   if (settime_done_r)
		     next_state <= CMD_HOLD;
		   else
		     next_state <= CMD_SET;
		   end
		  
		 CMD_HOLD:begin
		   CE_n <= 1'b0;
		   WE_n <= 1'b1;
		   CLE  <= 1'b1;
		   DOS  <= 1'b1;
		   if (holdtime_done_r)
		     next_state <= CMD_DONE;
		   else
			 next_state <= CMD_HOLD;
		 end
		  
		 CMD_DONE:begin
		   Done   <= 1'b1;
		   CE_n   <= 1'b0;
		   WE_n   <= 1'b1;
		   CLE    <= 1'b0;
		   DOS    <= 1'b1;
		   next_state <= Finish;
		 end
		  

		  
		 ALE_SET:begin
		   CE_n <= 1'b0;
		   ALE  <= 1'b1;
		   WE_n <= 1'b0;
		   DOS  <= 1'b1;
		   if(settime_done_r)
		     next_state <= ALE_HOLD;
		   else
		     next_state <= ALE_SET ;
		 end
		 
		 ALE_HOLD:begin
		   CE_n <= 1'b0;
		   ALE  <= 1'b1;
		   WE_n <= 1'b1;
		   DOS  <= 1'b1;
		   if(holdtime_done_r)
		     next_state <= ALE_DONE;
		   else
		     next_state <= ALE_HOLD;
		 end
		 
		 ALE_DONE:begin
		   CE_n   <= 1'b0;
		   ALE    <= 1'b1;
		   WE_n   <= 1'b1;
		   DOS    <= 1'b1;
		   Done   <= 1'b1;
		   next_state <= Finish; 
		 end
		 
		 READ_1CYC_SET:begin
		   CE_n <= 1'b0;
		   RE_n <= 1'b0;
		   DIS  <= 1'b1;
		   if(settime_done_r)
		     begin
		       next_state  <= READ_1CYC_HOLD;
			   BF_o        <= 1'b1   ; // Register write
			 end
           else
		     next_state <= READ_1CYC_SET ;
		 end
		 
		 READ_1CYC_HOLD:begin
		   CE_n <= 1'b0;
		   RE_n <= 1'b1;
		   DIS  <= 1'b1;
		 if(holdtime_done_r)
		   next_state <= READ_1CYC_DONE;
		 else
		   next_state <= READ_1CYC_HOLD;
		 end
		 
		 READ_1CYC_DONE:begin
		   CE_n <= 1'b0;
		   RE_n <= 1'b1;
		   DIS  <= 1'b1;
		   Done <= 1'b1;
		   next_state <= Finish;
		 end
		 
		 WRITE_1PAGE_START:begin  //24
		   CE_n <= 1'b0;
		   CLE  <= 1'b0;
		   ALE  <= 1'b0;
		   WE_n <= 1'b1;
		   RE_n <= 1'b1;
		   DOS  <= 1'b0;
		   next_state <= WRITE_1PAGE_WAITL0;
		 end
		 
		 WRITE_1PAGE_WAITL0:begin //DATA prepare 26
		   CE_n <= 1'b0;
		   WE_n <= 1'b1;
		   DOS  <= 1'b1;
		   if(~ecc_en_i)begin
               if(acnt_i[1:0]==2'b00 & ~empty_i)
                 begin
		           rd_fifo_o <= 1'b1;
			       next_state <= WRITE_1PAGE_SET;
			     end
		       else if(acnt_i[1:0]==2'b00 & empty_i)
		         begin
		           rd_fifo_o <= 1'b0;
		           next_state <= WRITE_1PAGE_WAITL0;
		         end
		       else begin
		           rd_fifo_o <= 1'b0;
		           next_state <= WRITE_1PAGE_SET;
			     end
			end			
			else begin
			  if(acnt_i[1:0]==2'b00)
				begin
				    ecc_rd_o <= 1'b1;
				    next_state <= WRITE_1PAGE_SET;
				end
			  else
				begin
				    ecc_rd_o <= 1'b0;
				    next_state <= WRITE_1PAGE_SET;
				end
			end
		  end
		 
		 WRITE_1PAGE_SET:begin   //25
		   CE_n <= 1'b0;
		   WE_n <= 1'b0;
		   DOS  <= 1'b1;
		   if(settime_done_r )
		     next_state <= WRITE_1PAGE_HOLD;
		   else
		     next_state <= WRITE_1PAGE_SET;
		 end
		 
		 WRITE_1PAGE_HOLD:begin //28
		   CE_n <= 1'b0;
		   WE_n <= 1'b1;
		   DOS  <= 1'b1;
		   if(holdtime_done_r & (~TC_i))
		     next_state <= WRITE_1PAGE_WAITL1;
	       else if (holdtime_done_r & TC_i) //  flash write/read address counter finish
		     next_state <= FinishW;
		   else
		     next_state <= WRITE_1PAGE_HOLD;		     
		 end
		 
		 WRITE_1PAGE_WAITL1:begin //27
		   CE_n <= 1'b0;
		   WE_n <= 1'b1;
		   DOS  <= 1'b1;
		   cnt_en_o <= 1'b1;     //data address Counter enable
		   next_state <= WRITE_1PAGE_START;
		 end
		 
		 FinishW:begin
		   Done <=1'b1;
		   DOS  <=1'b1;
		   if(start)
		     next_state <= START;
		   else 
		     next_state <= IDLE;
		 end
	
	
		 READ_1PAGE_START:begin
		   CE_n <= 1'b0;
		   CLE  <= 1'b0;
		   ALE  <= 1'b0;
		   WE_n <= 1'b1;
		   RE_n <= 1'b1;
		   DOS  <= 1'b0;
		   next_state <= READ_1PAGE_SET;
		 end
		 	 
			 
		 READ_1PAGE_SET:begin   
		   CE_n <= 1'b0;
		   WE_n <= 1'b1;
		   RE_n <= 1'b0;
		   DOS  <= 1'b0;
		   if(settime_done_r )
		     next_state <= READ_1PAGE_HOLD;
		   else
		     next_state <= READ_1PAGE_SET;
		 end
		 
		 READ_1PAGE_HOLD:begin
		   CE_n <= 1'b0;
		   WE_n <= 1'b1;
		   RE_n <= 1'b1;
		   DOS  <= 1'b0;
		   if(holdtime_done_r )//& (~TC_i)) //  flash write/read address counter finish
		     next_state <= READ_1PAGE_WAITL0;
		   else
		     next_state <= READ_1PAGE_HOLD;
		 end
		 
		 
		 READ_1PAGE_WAITL0:begin //DATA prepare
		   CE_n <= 1'b0;
		   WE_n <= 1'b1;
		   DOS  <= 1'b0;
		   if(TC_i && ~full_i)
		     next_state <= FinishR;
		   else if (~TC_i & ~full_i)
		     next_state <= READ_1PAGE_WAITL1;
		   else
		     next_state <= READ_1PAGE_WAITL0;
		   if(~ecc_en_i) 
		     begin
		       if(acnt_i[1:0]==2'b11 & ~ full_i)
		         we_fifo_o <= 1'b1;
		       else
		         we_fifo_o <= 1'b0;
		     end
		   else
		     begin
			   if(acnt_i[1:0]==2'b11)
		         ecc_wr_o <= 1'b1;
		       else
			     ecc_wr_o <= 1'b0;
			 end
		 end
		 
		 READ_1PAGE_WAITL1:begin
		   CE_n     <= 1'b0;
		   WE_n     <= 1'b1;
		   RE_n     <= 1'b1;
		   DOS      <= 1'b0;
		   cnt_en_o <= 1'b1;
		   next_state <= READ_1PAGE_START;
		 end
		 
		 
		 FinishR:begin
		   DOS  <=1'b0;
		   Done <=1'b1;
		   next_state <= IDLE;
		 end
		
		
		
		
		
		
		
		
		 
		 
		 Finish:begin
		   CE_n <= 1'b0;
		   DOS  <= 1'b0; //  释放总线
//		   Done <= 1'b1;
           if (start)
             next_state <= START;
           else
             next_state <= IDLE;
		 end
		 
         default:begin
	       next_state <= IDLE;		 
		 end
	   endcase
	 end
  






endmodule