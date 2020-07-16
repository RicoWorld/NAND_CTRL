`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// EnHineer: 
// 
// Create Date:    16:57:01 06/10/2020 
// DesiHn Name: 
// Module Name:    H_matrix 
// Project Name: 
// TarHet Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////


module H_matrix(  
		input 				clk,
		input				 rst_n,
		output wire [161:0] H1,//H 第一行，第8913列 H全0
		output wire [161:0] H2
/* 		output wire [17:0] H3,
		output wire [17:0] H4,
		output wire [17:0] H5,
		output wire [17:0] H6,
		output wire [17:0] H7,
		output wire [17:0] H8,
		output wire [17:0] H9,
		output wire [17:0] H10,
		output wire [17:0] H11,
		output wire [26:0] H12,
		output wire [17:0] H13,
		output wire [17:0] H14,
		output wire [17:0] H15,
		output wire [17:0] H16 */
	);
	
reg [161:0] H1_r;
reg [161:0] H2_r;
/* reg [17:0] H3_r;
reg [17:0] H4_r;	
reg [17:0] H5_r;
reg [17:0] H6_r;
reg [17:0] H7_r;
reg [17:0] H8_r;	
reg [17:0] H9_r;
reg [17:0] H10_r;
reg [17:0] H11_r;
reg [26:0] H12_r;	
reg [17:0] H13_r;
reg [17:0] H14_r;
reg [17:0] H15_r;
reg [17:0] H16_r;	 */	

assign H1=H1_r;
assign H2=H2_r;
/* assign H3=H3_r;
assign H4=H4_r;
assign H5=H5_r;
assign H6=H6_r;
assign H7=H7_r;
assign H8=H8_r;
assign H9=H9_r;
assign H10=H10_r;
assign H11=H11_r;
assign H12=H12_r;
assign H13=H13_r;
assign H14=H14_r;
assign H15=H15_r;
assign H16=H16_r; */

//assign  H1_r={8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0};
//assign  H2_r={8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0};
//assign  H3_r={8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0};
//assign  H4_r={8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0};

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		H1_r<=0;
		H2_r<=0;
/* 		H3_r<=0;
		H4_r<=0;
		H5_r<=0;
		H6_r<=0;
		H7_r<=0;
		H8_r<=0;
		H9_r<=0;
		H10_r<=0;
		H11_r<=0;
		H12_r<=0;
		H13_r<=0;
		H14_r<=0;
		H15_r<=0;
		H16_r<=0; */
		
	end
	else begin																	
            H1_r<={9'd110,9'd167,9'd128,9'd332,9'd90,9'd487,9'd218,9'd69,9'd52,9'd21,9'd474,9'd465,9'd310,9'd501,9'd151,9'd10,9'd0,9'd122};
            H2_r<={9'd32,9'd134,9'd219,9'd394,9'd91,9'd463,9'd179,9'd213,9'd329,9'd447,9'd175,9'd511,9'd16,9'd54,9'd143,9'd370,9'd367,9'd381};
																					
 /*            H3_r<={9'd0,9'd0};
            H4_r<={9'd485,9'd85};
			H5_r<={9'd277,9'd389};
            H6_r<={9'd416,9'd16};
            H7_r<={9'd0,9'd416};
            H8_r<={9'd0,9'd53};
			H9_r<={9'd0,9'd0};
            H10_r<={9'd432,9'd32};
            H11_r<={9'd0,9'd160};
            H12_r<={9'd368,9'd123,9'd480};//123+480
			H13_r<={9'd368,9'd480};
            H14_r<={9'd0,9'd0};
            H15_r<={9'd0,9'd0};
            H16_r<={9'd0,9'd0}; */
        end
end
endmodule

