`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:32:47 07/07/2020 
// Design Name: 
// Module Name:    ecc_decode_top 
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
module ecc_decode_top(
input							clk,
input							rst_n,
input							ecc_decode_req,
input							wr_en,
input							rd_en,
input		   [31:0]		data_in,
output wire					ecc_decode_rdy,
output wire	[31:0]		data_out,
output wire					ecc_decode_over,
output wire					decode_result,
output wire					decode_output_over
    );

//intenal wire
wire [9215:0]	flash_data;
wire [8191:0]	flash_decode_data;
wire				ecc_decode_sta;
//wire				decode_output_over;
ecc_decode_control u_ecc_decode_control (
    .clk(clk), 
    .rst_n(rst_n), 
    .data_in(data_in), //从flash中获得的32bit数据
    .ecc_decode_req(ecc_decode_req), //从外部获取的decode开启请求
    .wr_en(wr_en), //外部wr enable
    .rd_en(rd_en), //外部rd enable
    .ecc_decode_rdy(ecc_decode_rdy), //ecc decode模块ready信号
    .flash_data(flash_data), //控制模块准备给decode模块的9216位待译码数据
    .data_out(data_out), //译码后输出的数据 每次32bit
    .ecc_decode_over(ecc_decode_over), //decode 译码 完成信号 准备开始传输译码数据
    .flash_decode_data(flash_decode_data), //译码后的8192bit数据
    .ecc_decode_sta(ecc_decode_sta),//数据获取完成decode开始工作
	 .decode_output_over(decode_output_over)
    );
	 
ecc_decode u_ecc_decode (
    .clk(clk), 
    .rst_n(rst_n), 
    .ecc_decode_sta(ecc_decode_sta), 
    .flash_data(flash_data), 
    .ecc_decode_over(ecc_decode_over), 
    .flash_decode_data(flash_decode_data), 
    .decode_result(decode_result),
	 .decode_output_over(decode_output_over)
    );



endmodule
