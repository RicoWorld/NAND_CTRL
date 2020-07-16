`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/10 10:51:54
// Design Name: 
// Module Name: ecc_top
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

module ecc_code_control
	#(
	  parameter  loop=32,
	  parameter  N=9216,
	  parameter  K=8192,
	  parameter  M=1024)
	(
		input 					clk,
		input 					rst_n,
		input			[31:0]	data_in,//
		input						ecc_code_req,//cod
		input						wr_en,//
		input						rd_en,
		input		[1023:0]		flash_code_data,
		input  wire				ecc_code_over,//
		output wire				ecc_code_rdy,//
		output reg  [31:0] 	    data_out,//
		output wire				ecc_code_sta,//
		output reg				    code_output_over,
		output reg	 [8191:0]		flash_data//
	);
	
reg 				   ecc_code_rdy_r;
reg					ecc_code_sta_r;
reg		[8:0]		counter;
wire					code_wr_en;
wire					code_rd_en;

assign 				code_wr_en=	ecc_code_req&&wr_en;
//assign				code_rd_en=	ecc_code_req&&rd_en;
assign					code_rd_en=rd_en;

reg 	[9215:0]	flash_code_data_r;

//wire [9215:0] flash_and_ecc;
//assign flash_and_ecc = {flash_data,flash_code_data};

always@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		flash_data<=8191'b0;
		ecc_code_sta_r<=0;
		ecc_code_rdy_r<=1;
		counter<=0;
	end
	else begin
		if(code_wr_en==1&&ecc_code_rdy_r==1&&code_output_over==0)begin
			if(counter<256)begin
				ecc_code_sta_r<=0;
				flash_data<={data_in,flash_data[8191:32]};//low bit first in
				ecc_code_rdy_r<=1;
				counter<=counter+1;
			end
		end
		else if(code_output_over==1)begin
			ecc_code_sta_r<=0;
			flash_data<=0;
			ecc_code_rdy_r<=1;
			counter<=0;
		end
		else if(counter == 256)begin
			ecc_code_sta_r<=1;
			flash_data<=flash_data;
			ecc_code_rdy_r<=0;
			counter<=counter;
		end
		else begin//
			ecc_code_sta_r<=ecc_code_sta_r;
			flash_data<=flash_data;
			ecc_code_rdy_r<=ecc_code_rdy_r;
			counter<=counter;
		end
	end
end




reg [8:0] counter2;
always@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		code_output_over<=0;
		data_out<=0;
		counter2<=0;
		flash_code_data_r<=0;
	end
	else begin
		if(ecc_code_over&&code_rd_en)begin
			if(counter2<256)begin
				counter2<=counter2+1;
				code_output_over<=0;
				if(counter2==0)begin
					data_out<=flash_data[31:0];
					flash_code_data_r<=flash_data>>32;
				end
				else begin
					data_out<=flash_code_data_r[31:0];
					flash_code_data_r<=flash_code_data_r>>32;	
				end
				
			end
			
			if(counter2<288&&counter2>=256)begin
				counter2<=counter2+1;
				code_output_over<=0;
				if(counter2==256)begin
					data_out<=flash_code_data[31:0];
					flash_code_data_r<=flash_code_data>>32;
				end
				else begin
					data_out<=flash_code_data_r[31:0];
					flash_code_data_r<=flash_code_data_r>>32;	
				end
				 if(counter2==287) 
					code_output_over<=1;
				
			end
			
			
		end
		else if(ecc_code_over)begin
			code_output_over<=0;
			data_out<=data_out;
			counter2<=counter2;
		end
		
		
		else begin
			code_output_over<=0;
			data_out<=0;
			counter2<=0;
		end
	end
end



assign ecc_code_sta		=	ecc_code_sta_r;
assign ecc_code_rdy		=	ecc_code_rdy_r;

endmodule