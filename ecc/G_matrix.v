`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:57:01 06/10/2020 
// Design Name: 
// Module Name:    G_matrix 
// Project Name: 
// Target Devices: 
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


module G_matrix(  
		input 				clk,
		input				 rst_n,
		output wire [26:0] G1,//G 第一行，第8913列 G全0
		output wire [26:0] G2,
		output wire [26:0] G3,
		output wire [26:0] G4,
		output wire [26:0] G5,
		output wire [26:0] G6,
		output wire [26:0] G7,
		output wire [26:0] G8,
		output wire [26:0] G9,
		output wire [26:0] G10,
		output wire [26:0] G11,
		output wire [26:0] G12,
		output wire [26:0] G13,
		output wire [26:0] G14,
		output wire [26:0] G15,
		output wire [26:0] G16
	);
	
reg [26:0] G1_r;
reg [26:0] G2_r;
reg [26:0] G3_r;
reg [26:0] G4_r;	
reg [26:0] G5_r;
reg [26:0] G6_r;
reg [26:0] G7_r;
reg [26:0] G8_r;	
reg [26:0] G9_r;
reg [26:0] G10_r;
reg [26:0] G11_r;
reg [26:0] G12_r;	
reg [26:0] G13_r;
reg [26:0] G14_r;
reg [26:0] G15_r;
reg [26:0] G16_r;		

assign G1=G1_r;
assign G2=G2_r;
assign G3=G3_r;
assign G4=G4_r;
assign G5=G5_r;
assign G6=G6_r;
assign G7=G7_r;
assign G8=G8_r;
assign G9=G9_r;
assign G10=G10_r;
assign G11=G11_r;
assign G12=G12_r;
assign G13=G13_r;
assign G14=G14_r;
assign G15=G15_r;
assign G16=G16_r;

//assign  G1_r={8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0};
//assign  G2_r={8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0};
//assign  G3_r={8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0};
//assign  G4_r={8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0};

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		G1_r<=0;
		G2_r<=0;
		G3_r<=0;
		G4_r<=0;
		G5_r<=0;
		G6_r<=0;
		G7_r<=0;
		G8_r<=0;
		G9_r<=0;
		G10_r<=0;
		G11_r<=0;
		G12_r<=0;
		G13_r<=0;
		G14_r<=0;
		G15_r<=0;
		G16_r<=0;
		
	end
	else begin
        /*    G1_r<={9'd334,9'd509,9'd11};
            G2_r<={9'd232,9'd452,9'd466};
            G3_r<={9'd147,9'd491,9'd505};
            G4_r<={9'd287,9'd484,9'd301};
	    G5_r<={9'd17,9'd275,9'd31};
            G6_r<={9'd132,9'd415,9'd146};
            G7_r<={9'd187,9'd401,9'd415};
            G8_r<={9'd38,9'd153,9'd52};
	    G9_r<={9'd37,9'd55,9'd69};
            G10_r<={9'd86,9'd431,9'd100};
            G11_r<={9'd145,9'd191,9'd159};
            G12_r<={9'd154,9'd367,9'd168};//123+480
	    G13_r<={9'd309,9'd350,9'd323};
            G14_r<={9'd118,9'd312,9'd132};
            G15_r<={9'd223,9'd468,9'd482};
            G16_r<={9'd97,9'd508,9'd111};*/

	    G1_r<={9'd176,9'd1,9'd499};
            G2_r<={9'd278,9'd58,9'd44};

            G3_r<={9'd363,9'd19,9'd5};

            G4_r<={9'd223,9'd26,9'd209};

	    G5_r<={9'd493,9'd235,9'd479};

            G6_r<={9'd378,9'd95,9'd364};

            G7_r<={9'd323,9'd109,9'd95};

            G8_r<={9'd472,9'd357,9'd458};

	    G9_r<={9'd473,9'd455,9'd441};

            G10_r<={9'd424,9'd79,9'd410};

            G11_r<={9'd365,9'd319,9'd351};

            G12_r<={9'd356,9'd143,9'd342};//342

	    G13_r<={9'd201,9'd160,9'd187};

            G14_r<={9'd392,9'd198,9'd378};

            G15_r<={9'd287,9'd42,9'd28};

            G16_r<={9'd413,9'd2,9'd399};

        end
end
endmodule

