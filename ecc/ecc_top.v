`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:32:47 07/07/2020 
// Design Name: 
// Module Name:    ecc_code_top 
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
module ecc_top(
input							ecc_code_req,
//decode
input							ecc_decode_req,
output wire					decode_result,
//
input							clk,
input							rst_n,
input							wr_en,
input							rd_en,
output wire				    ecc_rdy,
input		[31:0]		    data_in,
output wire	[31:0]		            data_out,
output wire					ecc_over
    );



wire [31:0]data_out_code;
wire [31:0]data_out_decode;
wire		ecc_decode_over;
wire		ecc_code_over;
wire		ecc_decode_rdy;
wire		ecc_code_rdy;
wire		code_output_over;
wire		decode_output_over;
reg		ecc_code_over_r;
reg		ecc_decode_over_r;
reg		code_output_over_r;
reg		decode_output_over_r;

wire		ecc_code_over_flag;
wire		ecc_decode_over_flag;
wire		code_output_over_flag;
wire		decode_output_over_flag;
//assign data_out=ecc_code_req?data_out_code:data_out_decode;

assign data_out=ecc_code_over?data_out_code:data_out_decode;
assign ecc_rdy=ecc_code_req?ecc_code_rdy:ecc_decode_rdy;

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		ecc_code_over_r<=0;
		ecc_decode_over_r<=0;
		code_output_over_r<=0;
		decode_output_over_r<=0;
	end
	else begin
		ecc_code_over_r<=ecc_code_over;
		ecc_decode_over_r<=ecc_decode_over;
		code_output_over_r<=code_output_over;
		decode_output_over_r<=decode_output_over;
	end
end
	
assign 	ecc_code_over_flag= (~ecc_code_over_r)&&ecc_code_over;
assign 	ecc_decode_over_flag= (~ecc_decode_over_r)&&ecc_decode_over;
assign  code_output_over_flag=(~code_output_over_r)&&code_output_over;
assign  decode_output_over_flag=(~decode_output_over_r)&&decode_output_over;


assign ecc_over=ecc_code_over_flag||ecc_decode_over_flag||code_output_over_flag||decode_output_over_flag;
	
ecc_code_top ecc_code_top(
.clk(clk),
.rst_n(rst_n),
.ecc_code_req(ecc_code_req),
.wr_en(wr_en),
.rd_en(rd_en),
.data_in(data_in),
.data_out(data_out_code),
.ecc_code_rdy(ecc_code_rdy),
.ecc_code_over(ecc_code_over),
//.code_result(code_result),
.code_output_over(code_output_over)
);
 ecc_decode_top u_ecc_decode_top(
.clk(clk),
.rst_n(rst_n),
.ecc_decode_req(ecc_decode_req),
.wr_en(wr_en),
.rd_en(rd_en),
.data_in(data_in),
.ecc_decode_rdy(ecc_decode_rdy),
.data_out(data_out_decode),
.ecc_decode_over(ecc_decode_over),
.decode_result(decode_result),
.decode_output_over(decode_output_over)
    );


endmodule