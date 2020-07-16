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

module ecc_decode_control
	#(
	  parameter  loop=32,//迭代循环次数上限
	  parameter  N=9216,
	  parameter  K=8192,
	  parameter  M=1024)
	(
		input 					clk,
		input 					rst_n,
		input			[31:0]	data_in,//flash读出的data，前8192bit为数据位，后1024位为ecc校验位
		input						ecc_decode_req,//decode开始总信号，decode开始后始终拉高
		input						wr_en,//相对于ecc模块
		input						rd_en,
		input	 wire				ecc_decode_over,//ecc decode译码完成信号 从decode模块传出 准备开始数据传输
		input 		[8191:0]	flash_decode_data,
		output wire				ecc_decode_rdy,//ecc_decode ready信号
		output reg 	[9215:0] flash_data,
		output reg  [31:0] 	data_out,//falsh 译码后的数据
		output wire				ecc_decode_sta,//decode开始模块 decode模块工作状态下始终为1
		output reg				decode_output_over
	);
	
reg 				   ecc_decode_rdy_r;
reg					ecc_decode_sta_r;//传递给ecc译码模块 decode模块工作状态下始终为1
reg		[8:0]		counter;
//reg					decode_output_over;
wire					decode_wr_en;
wire					decode_rd_en;

assign 				decode_wr_en=	ecc_decode_req&&wr_en;
//assign				decode_rd_en=	ecc_decode_req&&rd_en;
assign				decode_rd_en=rd_en;

reg 	[8191:0]	flash_decode_data_r;

///////////////////数据读取模块，读取完成后产生译码开始信号ecc_decode_sta_r，同时拉低ecc_decode_rdy_r，模块不在空闲状态
always@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		flash_data<=9216'b0;
		ecc_decode_sta_r<=0;
		ecc_decode_rdy_r<=1;
		counter<=0;
	end
	else begin
		if(decode_wr_en==1&&ecc_decode_rdy_r==1&&decode_output_over==0)begin//请求译码信号拉高 同时decode模块ready信号拉高 开始译码 模块进入busy状态
			if(counter<256)begin
				ecc_decode_sta_r<=0;
				//flash_data<={data_in,flash_data[9215:1055],flash_data[1023:0]};//
				flash_data<={data_in,flash_data[9215:32]};
				ecc_decode_rdy_r<=1;
				counter<=counter+1;
			end
			else if(counter>=256&&counter<288)begin
				ecc_decode_sta_r<=0;
				flash_data<={flash_data[9215:1024],data_in,flash_data[1023:32]};//
				ecc_decode_rdy_r<=1;
				counter<=counter+1;
			end
		end
		else if(decode_output_over==1)begin//译码完成 模块进入 ready状态，可以重新接受req信号
			ecc_decode_sta_r<=0;
			flash_data<=0;
			ecc_decode_rdy_r<=1;
			counter<=0;
		end
		else if(counter==288)begin
			ecc_decode_sta_r<=1;
			flash_data<=flash_data;
			ecc_decode_rdy_r<=0;
			counter<=counter;
		end
		else begin//
			ecc_decode_sta_r<=ecc_decode_sta_r;
			flash_data<=flash_data;
			ecc_decode_rdy_r<=ecc_decode_rdy_r;
			counter<=counter;
		end
	end
end

///////////////////数据输出模块



reg [8:0] counter2;
always@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		decode_output_over<=0;
		data_out<=0;
		counter2<=0;
		flash_decode_data_r<=0;
	end
	else begin
		if(ecc_decode_over&&decode_rd_en)begin
			if(counter2<256)begin
				counter2<=counter2+1;
				decode_output_over<=0;
				if(counter2==0)begin
					data_out<=flash_decode_data[31:0];//
					flash_decode_data_r<=flash_decode_data>>32;
				end
				else begin
					data_out<=flash_decode_data_r[31:0];
					flash_decode_data_r<=flash_decode_data_r>>32;	
				end
				
				
			end
			else if(counter2==256) begin
				decode_output_over<=1;
				data_out<=data_out;
				counter2<=counter2;
			end
			/* else begin
				decode_output_over<=0;
				data_out<=0;
				counter2<=0;
			end */
		end
		else if(ecc_decode_over)begin
			decode_output_over<=0;
			data_out<=data_out;
			counter2<=counter2;
		end
		
		
		else begin
			decode_output_over<=0;
			data_out<=0;
			counter2<=0;
		end
	end
end










assign ecc_decode_sta		=	ecc_decode_sta_r;
assign ecc_decode_rdy		=	ecc_decode_rdy_r;

endmodule