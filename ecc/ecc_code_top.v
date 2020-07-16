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
module ecc_code_top(
input							clk,
input							rst_n,
input							ecc_code_req,
input							wr_en,
input							rd_en,
input		   [31:0]		data_in,
output wire					ecc_code_rdy,
output wire	[31:0]		data_out,
output wire					ecc_code_over,
output wire				code_output_over
    );

//intenal wire
wire [8191:0]	flash_data;
wire [1023:0]	flash_code_data;
wire				ecc_code_sta;
//wire				code_output_over;
ecc_code_control u_ecc_code_control (
    .clk(clk), 
    .rst_n(rst_n), 
    .data_in(data_in), //从flash中获得的32bit数据
    .ecc_code_req(ecc_code_req), //从外部获取的code开启请求
    .wr_en(wr_en), //外部wr enable
    .rd_en(rd_en), //外部rd enable
    .ecc_code_rdy(ecc_code_rdy), //ecc code模块ready信号
    .flash_data(flash_data), //控制模块准备给code模块的9216位待译码数据
    .data_out(data_out), //译码后输出的数据 每次32bit
    .ecc_code_over(ecc_code_over), //code 译码 完成信号 准备开始传输译码数据
    .flash_code_data(flash_code_data), //译码后的8192bit数据
    .ecc_code_sta(ecc_code_sta),//数据获取完成code开始工作
    .code_output_over(code_output_over)
    );
	 
ecc_code u_ecc_code (
    .clk(clk), 
    .rst_n(rst_n), 
    .ecc_code_sta(ecc_code_sta), 
    .flash_data(flash_data), 
    .ecc_code_over(ecc_code_over), 
    .flash_code_data(flash_code_data), 
   .code_output_over(code_output_over)
    );



endmodule
