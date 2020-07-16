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
module ecc_code
	#(
	 parameter  N=9216,
	 parameter  K=8192,
	 parameter  M=1024
		)
	(
		input 						clk,
		input 						rst_n,
		input						ecc_code_sta,
		input		[8191:0]	    flash_data,
		input						code_output_over,
		output reg				    ecc_code_over,
		output reg [1023:0] 	    flash_code_data
	);
////////////decode state//////////
parameter IDLE			=		3'd0;
parameter CODE1		=		3'd1;
parameter CODE2		=		3'd2;
parameter CODE3		=		3'd3;
parameter CODE4		=		3'd4;
parameter CODE5		=		3'd5;
parameter CODE6		=		3'd6;
parameter OUT			=		3'd7;


reg[2:0] current_state;
reg[2:0] next_state;
//transform signal and condition
wire IDLE2CODE1;
wire CODE12CODE2;
wire CODE22CODE3;
wire CODE32CODE4;
wire CODE42CODE5;
wire CODE52CODE6;
wire CODE62OUT;
wire OUT2IDLE;

reg [511:0] c11_1;
reg [511:0] c21_1;
reg [511:0] c31_1;
reg [511:0] c41_1;
reg [511:0] c51_1;
reg [511:0] c61_1;
reg [511:0] c71_1;
reg [511:0] c81_1;
reg [511:0] c91_1;
reg [511:0] c101_1;
reg [511:0] c111_1;
reg [511:0] c121_1;
reg [511:0] c131_1;
reg [511:0] c141_1;
reg [511:0] c151_1;
reg [511:0] c161_1;


reg [511:0] c11_2;
reg [511:0] c21_2;
reg [511:0] c31_2;
reg [511:0] c41_2;
reg [511:0] c51_2;
reg [511:0] c61_2;
reg [511:0] c71_2;
reg [511:0] c81_2;
reg [511:0] c91_2;
reg [511:0] c101_2;
reg [511:0] c111_2;
reg [511:0] c121_2;
reg [511:0] c131_2;
reg [511:0] c141_2;
reg [511:0] c151_2;
reg [511:0] c161_2;



reg [511:0] c12;
reg [511:0] c22;
reg [511:0] c32;
reg [511:0] c42;
reg [511:0] c52;
reg [511:0] c62;
reg [511:0] c72;
reg [511:0] c82;
reg [511:0] c92;
reg [511:0] c102;
reg [511:0] c112;
reg [511:0] c122;
reg [511:0] c132;
reg [511:0] c142;
reg [511:0] c152;
reg [511:0] c162;

/////////////////// flash_data 分段
reg [511:0] flash_data1;
reg [511:0] flash_data2;
reg [511:0] flash_data3;
reg [511:0] flash_data4;
reg [511:0] flash_data5;
reg [511:0] flash_data6;
reg [511:0] flash_data7;
reg [511:0] flash_data8;
reg [511:0] flash_data9;
reg [511:0] flash_data10;
reg [511:0] flash_data11;
reg [511:0] flash_data12;
reg [511:0] flash_data13;
reg [511:0] flash_data14;
reg [511:0] flash_data15;
reg [511:0] flash_data16;
//flash_data={flash_data1,flash_data2.....,flash_data18}

////////H矩阵数据////////////
wire [8:0] G11_1;
wire [8:0] G11_2;
wire [8:0] G12;
wire [8:0] G21_1;
wire [8:0] G21_2;
wire [8:0] G22;
wire [8:0] G31_1;
wire [8:0] G31_2;
wire [8:0] G32;
wire [8:0] G41_1;
wire [8:0] G41_2;
wire [8:0] G42;
wire [8:0] G51_1;
wire [8:0] G51_2;
wire [8:0] G52;
wire [8:0] G61_1;
wire [8:0] G61_2;
wire [8:0] G62;
wire [8:0] G71_1;
wire [8:0] G71_2;
wire [8:0] G72;
wire [8:0] G81_1;
wire [8:0] G81_2;
wire [8:0] G82;
wire [8:0] G91_1;
wire [8:0] G91_2;
wire [8:0] G92;
wire [8:0] G101_1;
wire [8:0] G101_2;
wire [8:0] G102;
wire [8:0] G111_1;
wire [8:0] G111_2;
wire [8:0] G112;
wire [8:0] G121_1;
wire [8:0] G121_2;
wire [8:0] G122;
wire [8:0] G131_1;
wire [8:0] G131_2;
wire [8:0] G132;
wire [8:0] G141_1;
wire [8:0] G141_2;
wire [8:0] G142;
wire [8:0] G151_1;
wire [8:0] G151_2;
wire [8:0] G152;
wire [8:0] G161_1;
wire [8:0] G161_2;
wire [8:0] G162;


assign IDLE2CODE1 	=	current_state==IDLE&&ecc_code_sta;
assign CODE12CODE2		= 	current_state==CODE1&&ecc_code_sta;
assign CODE22CODE3		=	current_state==CODE2&&ecc_code_sta;
assign CODE32CODE4		=	current_state==CODE3&&ecc_code_sta;
assign CODE42CODE5		=	current_state==CODE4&&ecc_code_sta;
assign CODE52CODE6		=	current_state==CODE5&&ecc_code_sta;
assign CODE62OUT		=	current_state==CODE6&&ecc_code_sta;
assign OUT2IDLE	=	current_state==OUT&&(code_output_over||ecc_code_sta==0);



//////////////////////////s*g state machine///////////////

always@(posedge clk or negedge rst_n)begin//以验证
	if(!rst_n)
		current_state<=0;
	else 
		current_state<=next_state;
end


always@(*)begin//以验证
	case(current_state)
		IDLE:begin
				if(IDLE2CODE1)
					next_state=CODE1;
				else
					next_state=IDLE;
			end
	CODE1:begin
				if(CODE12CODE2)
					next_state=CODE2;
				else
					next_state=next_state;
			end
	CODE2:begin
				if(CODE22CODE3)
					next_state=CODE3;
				else
					next_state=next_state;
			end
	CODE3:begin
				if(CODE32CODE4)
					next_state=CODE4;
				else
					next_state=next_state;
			end
	CODE4:begin
				if(CODE42CODE5)
					next_state=CODE5;
				else
					next_state=next_state;
			end
	CODE5:begin
				if(CODE52CODE6)
					next_state=CODE6;
				else
					next_state=next_state;
			end
	CODE6:begin
				if(CODE62OUT)
					next_state=OUT;
				else
					next_state=next_state;
			end
		OUT:begin
				if(OUT2IDLE)
					next_state=IDLE;
				else
					next_state=next_state;
			end
	
	endcase
end
				

genvar i;//声明的此变量只用于生成块的循环计算，在电路里面并不存在
generate
   for(i=511;i>=0;i=i-1)
        begin:decode
				always@(posedge clk or negedge rst_n)begin//执行矩阵运算
					if(!rst_n)begin
						 c11_1[i]   <=0;
						 c21_1[i]   <=0;
						 c31_1[i]   <=0;
						 c41_1[i]   <=0;
						 c51_1[i]   <=0;
						 c61_1[i]   <=0;
						 c71_1[i]   <=0;
						 c81_1[i]   <=0;
						 c91_1[i]   <=0;
						 c101_1[i]  <=0;
						 c111_1[i]  <=0;
						 c121_1[i]  <=0;
						 c131_1[i]  <=0;
						 c141_1[i]  <=0;
						 c151_1[i]  <=0;
						 c161_1[i]  <=0;
						 c11_2[i]   <=0;
						 c21_2[i]   <=0;
						 c31_2[i]   <=0;
						 c41_2[i]   <=0;
						 c51_2[i]   <=0;
						 c61_2[i]   <=0;
						 c71_2[i]   <=0;
						 c81_2[i]   <=0;
						 c91_2[i]   <=0;
						 c101_2[i]  <=0;
						 c111_2[i]  <=0;
						 c121_2[i]  <=0;
						 c131_2[i]  <=0;
						 c141_2[i]  <=0;
						 c151_2[i]  <=0;
						 c161_2[i]  <=0;
						 c12[i]   <=0;
						 c22[i]   <=0;
						 c32[i]   <=0;
						 c42[i]   <=0;
						 c52[i]   <=0;
						 c62[i]   <=0;
						 c72[i]   <=0;
						 c82[i]   <=0;
						 c92[i]   <=0;
						 c102[i]  <=0;
						 c112[i]  <=0;
						 c122[i]  <=0;
						 c132[i]  <=0;
						 c142[i]  <=0;
						 c152[i]  <=0;
						 c162[i]  <=0;
						flash_data1[i]<=0;
						flash_data2[i]<=0;
						flash_data3[i]<=0;
						flash_data4[i]<=0;
						flash_data5[i]<=0;
						flash_data6[i]<=0;
						flash_data7[i]<=0;
						flash_data8[i]<=0;
						flash_data9[i]<=0;
						flash_data10[i]<=0;
						flash_data11[i]<=0;
						flash_data12[i]<=0;
						flash_data13[i]<=0;
						flash_data14[i]<=0;
						flash_data15[i]<=0;
						flash_data16[i]<=0;
			end
				else begin		
					case(current_state)
					IDLE:begin 
						c11_1[i]   <=0;
						 c21_1[i]   <=0;
						 c31_1[i]   <=0;
						 c41_1[i]   <=0;
						 c51_1[i]   <=0;
						 c61_1[i]   <=0;
						 c71_1[i]   <=0;
						 c81_1[i]   <=0;
						 c91_1[i]   <=0;
						 c101_1[i]  <=0;
						 c111_1[i]  <=0;
						 c121_1[i]  <=0;
						 c131_1[i]  <=0;
						 c141_1[i]  <=0;
						 c151_1[i]  <=0;
						 c161_1[i]  <=0;
						 c11_2[i]   <=0;
						 c21_2[i]   <=0;
						 c31_2[i]   <=0;
						 c41_2[i]   <=0;
						 c51_2[i]   <=0;
						 c61_2[i]   <=0;
						 c71_2[i]   <=0;
						 c81_2[i]   <=0;
						 c91_2[i]   <=0;
						 c101_2[i]  <=0;
						 c111_2[i]  <=0;
						 c121_2[i]  <=0;
						 c131_2[i]  <=0;
						 c141_2[i]  <=0;
						 c151_2[i]  <=0;
						 c161_2[i]  <=0;
						 c12[i]   <=0;
						 c22[i]   <=0;
						 c32[i]   <=0;
						 c42[i]   <=0;
						 c52[i]   <=0;
						 c62[i]   <=0;
						 c72[i]   <=0;
						 c82[i]   <=0;
						 c92[i]   <=0;
						 c102[i]  <=0;
						 c112[i]  <=0;
						 c122[i]  <=0;
						 c132[i]  <=0;
						 c142[i]  <=0;
						 c152[i]  <=0;
						 c162[i]  <=0;
						flash_data1[i]<=flash_data[7680+i];
						flash_data2[i]<=flash_data[7168+i];
						flash_data3[i]<=flash_data[6656+i];
						flash_data4[i]<=flash_data[6144+i];
						flash_data5[i]<=flash_data[5632+i];
						flash_data6[i]<=flash_data[5120+i];
						flash_data7[i]<=flash_data[4608+i];
						flash_data8[i]<=flash_data[4096+i];
						flash_data9[i]<=flash_data[3584+i];
						flash_data10[i]<=flash_data[3072+i];
						flash_data11[i]<=flash_data[2560+i];
						flash_data12[i]<=flash_data[2048+i];
						flash_data13[i]<=flash_data[1536+i];
						flash_data14[i]<=flash_data[1024+i];
						flash_data15[i]<=flash_data[512+i];
						flash_data16[i]<=flash_data[i];
						end
					CODE1:begin
								if(G11_1==0)//1
									c11_1[i]<=0;//
								else begin//

									if(G11_1+i>=511)//
										c11_1[i]<=flash_data1[G11_1+i-511];//
//有�
										  //c11[i]<=flash_data1[i];�//
									else//
										c11_1[i]<=flash_data1[G11_1+i+1];//
									       // c11[i]<=flash_data1[i];//

								end
								if(G11_2==0)//1
									c11_2[i]<=0;//
								else begin//

									if(G11_2+i>=511)//
										c11_2[i]<=flash_data1[G11_2+i-511];//
//有�
										  //c11[i]<=flash_data1[i];�//
									else//
										c11_2[i]<=flash_data1[G11_2+i+1];//
									       // c11[i]<=flash_data1[i];//

								end
								
								if(G21_1==0)//2
									c21_1[i]<=0;
								else begin
									if(G21_1+i>=511)
										c21_1[i]<=flash_data2[G21_1+i-511];
									else
										c21_1[i]<=flash_data2[G21_1+i+1];
								end
								if(G21_2==0)//2
									c21_2[i]<=0;
								else begin
									if(G21_2+i>=511)
										c21_2[i]<=flash_data2[G21_2+i-511];
									else
										c21_2[i]<=flash_data2[G21_2+i+1];
								end
								
								if(G31_1==0)//2
									c31_1[i]<=0;
								else begin
									if(G31_1+i>=511)
										c31_1[i]<=flash_data3[G31_1+i-511];
									else
										c31_1[i]<=flash_data3[G31_1+i+1];
								end
								if(G31_2==0)//2
									c31_2[i]<=0;
								else begin
									if(G31_2+i>=511)
										c31_2[i]<=flash_data3[G31_2+i-511];
									else
										c31_2[i]<=flash_data3[G31_2+i+1];
								end
								
								if(G41_1==0)//2
									c41_1[i]<=0;
								else begin
									if(G41_1+i>=511)
										c41_1[i]<=flash_data4[G41_1+i-511];
									else
										c41_1[i]<=flash_data4[G41_1+i+1];
								end
								if(G41_2==0)//2
									c41_2[i]<=0;
								else begin
									if(G41_2+i>=511)
										c41_2[i]<=flash_data4[G41_2+i-511];
									else
										c41_2[i]<=flash_data4[G41_2+i+1];
								end
								
								
								if(G51_1==0)//2
									c51_1[i]<=0;
								else begin
									if(G51_1+i>=511)
										c51_1[i]<=flash_data5[G51_1+i-511];
									else
										c51_1[i]<=flash_data5[G51_1+i+1];
								end
								if(G51_2==0)//2
									c51_2[i]<=0;
								else begin
									if(G51_2+i>=511)
										c51_2[i]<=flash_data5[G51_2+i-511];
									else
										c51_2[i]<=flash_data5[G51_2+i+1];
								end
								
								if(G61_1==0)//2
									c61_1[i]<=0;
								else begin
									if(G61_1+i>=511)
										c61_1[i]<=flash_data6[G61_1+i-511];
									else
										c61_1[i]<=flash_data6[G61_1+i+1];
								end
								if(G61_2==0)//2
									c61_2[i]<=0;
								else begin
									if(G61_2+i>=511)
										c61_2[i]<=flash_data6[G61_2+i-511];
									else
										c61_2[i]<=flash_data6[G61_2+i+1];
								end
								
								if(G71_1==0)//2
									c71_1[i]<=0;
								else begin
									if(G71_1+i>=511)
										c71_1[i]<=flash_data7[G71_1+i-511];
									else
										c71_1[i]<=flash_data7[G71_1+i+1];
								end
								if(G71_2==0)//2
									c71_2[i]<=0;
								else begin
									if(G71_2+i>=511)
										c71_2[i]<=flash_data7[G71_2+i-511];
									else
										c71_2[i]<=flash_data7[G71_2+i+1];
								end
								
								
								
								if(G81_1==0)//2
									c81_1[i]<=0;
								else begin
									if(G81_1+i>=511)
										c81_1[i]<=flash_data8[G81_1+i-511];
									else
										c81_1[i]<=flash_data8[G81_1+i+1];
								end
								if(G81_2==0)//2
									c81_2[i]<=0;
								else begin
									if(G81_2+i>=511)
										c81_2[i]<=flash_data8[G81_2+i-511];
									else
										c81_2[i]<=flash_data8[G81_2+i+1];
								end
								
								if(G91_1==0)//2
									c91_1[i]<=0;
								else begin
									if(G91_1+i>=511)
										c91_1[i]<=flash_data9[G91_1+i-511];
									else
										c91_1[i]<=flash_data9[G91_1+i+1];
								end
								if(G91_2==0)//2
									c91_2[i]<=0;
								else begin
									if(G91_2+i>=511)
										c91_2[i]<=flash_data9[G91_2+i-511];
									else
										c91_2[i]<=flash_data9[G91_2+i+1];
								end
								
								if(G101_1==0)//2
									c101_1[i]<=0;
								else begin
									if(G101_1+i>=511)
										c101_1[i]<=flash_data10[G101_1+i-511];
									else
										c101_1[i]<=flash_data10[G101_1+i+1];
								end
								if(G101_2==0)//2
									c101_2[i]<=0;
								else begin
									if(G101_2+i>=511)
										c101_2[i]<=flash_data10[G101_2+i-511];
									else
										c101_2[i]<=flash_data10[G101_2+i+1];
								end
								//
								
								if(G111_1==0)//1
									c111_1[i]<=0;//
								else begin//

									if(G111_1+i>=511)//
										c111_1[i]<=flash_data11[G111_1+i-511];//
//有�
										  //c111[i]<=flash_data1[i];�//
									else//
										c111_1[i]<=flash_data11[G111_1+i+1];//
									       // c111[i]<=flash_data1[i];//

								end
								if(G111_2==0)//1
									c111_2[i]<=0;//
								else begin//

									if(G111_2+i>=511)//
										c111_2[i]<=flash_data11[G111_2+i-511];//
//有�
										  //c111[i]<=flash_data1[i];�//
									else//
										c111_2[i]<=flash_data11[G111_2+i+1];//
									       // c111[i]<=flash_data1[i];//

								end
								
								if(G121_1==0)//2
									c121_1[i]<=0;
								else begin
									if(G121_1+i>=511)
										c121_1[i]<=flash_data12[G121_1+i-511];
									else
										c121_1[i]<=flash_data12[G121_1+i+1];
								end
								if(G121_2==0)//2
									c121_2[i]<=0;
								else begin
									if(G121_2+i>=511)
										c121_2[i]<=flash_data12[G121_2+i-511];
									else
										c121_2[i]<=flash_data12[G121_2+i+1];
								end
								
								if(G131_1==0)//2
									c131_1[i]<=0;
								else begin
									if(G131_1+i>=511)
										c131_1[i]<=flash_data13[G131_1+i-511];
									else
										c131_1[i]<=flash_data13[G131_1+i+1];
								end
								if(G131_2==0)//2
									c131_2[i]<=0;
								else begin
									if(G131_2+i>=511)
										c131_2[i]<=flash_data13[G131_2+i-511];
									else
										c131_2[i]<=flash_data13[G131_2+i+1];
								end
								
								if(G141_1==0)//2
									c141_1[i]<=0;
								else begin
									if(G141_1+i>=511)
										c141_1[i]<=flash_data14[G141_1+i-511];
									else
										c141_1[i]<=flash_data14[G141_1+i+1];
								end
								if(G141_2==0)//2
									c141_2[i]<=0;
								else begin
									if(G141_2+i>=511)
										c141_2[i]<=flash_data14[G141_2+i-511];
									else
										c141_2[i]<=flash_data14[G141_2+i+1];
								end
								
								
								if(G151_1==0)//2
									c151_1[i]<=0;
								else begin
									if(G151_1+i>=511)
										c151_1[i]<=flash_data15[G151_1+i-511];
									else
										c151_1[i]<=flash_data15[G151_1+i+1];
								end
								if(G151_2==0)//2
									c151_2[i]<=0;
								else begin
									if(G151_2+i>=511)
										c151_2[i]<=flash_data15[G151_2+i-511];
									else
										c151_2[i]<=flash_data15[G151_2+i+1];
								end
								
								if(G161_1==0)//2
									c161_1[i]<=0;
								else begin
									if(G161_1+i>=511)
										c161_1[i]<=flash_data16[G161_1+i-511];
									else
										c161_1[i]<=flash_data16[G161_1+i+1];
								end
								if(G161_2==0)//2
									c161_2[i]<=0;
								else begin
									if(G161_2+i>=511)
										c161_2[i]<=flash_data16[G161_2+i-511];
									else
										c161_2[i]<=flash_data16[G161_2+i+1];
								end
								
							//second_row
																if(G12 ==0)//1
									c12 [i]<=0;//
								else begin//
									if(G12 +i>=511)//
										c12 [i]<=flash_data1[G12 +i-511];//
									else//
										c12 [i]<=flash_data1[G12 +i+1];//
								end
							
								
								if(G22 ==0)//2
									c22 [i]<=0;
								else begin
									if(G22 +i>=511)
										c22 [i]<=flash_data2[G22 +i-511];
									else
										c22 [i]<=flash_data2[G22 +i+1];
								end
								
								
								if(G32 ==0)//2
									c32 [i]<=0;
								else begin
									if(G32 +i>=511)
										c32 [i]<=flash_data3[G32 +i-511];
									else
										c32 [i]<=flash_data3[G32 +i+1];
								end
								
								
								if(G42 ==0)//2
									c42 [i]<=0;
								else begin
									if(G42 +i>=511)
										c42 [i]<=flash_data4[G42 +i-511];
									else
										c42 [i]<=flash_data4[G42 +i+1];
								end
								
								
								if(G52 ==0)//2
									c52 [i]<=0;
								else begin
									if(G52 +i>=511)
										c52 [i]<=flash_data5[G52 +i-511];
									else
										c52 [i]<=flash_data5[G52 +i+1];
								end
								
								
								if(G62 ==0)//2
									c62 [i]<=0;
								else begin
									if(G62 +i>=511)
										c62 [i]<=flash_data6[G62 +i-511];
									else
										c62 [i]<=flash_data6[G62 +i+1];
								end
								
								
								if(G72 ==0)//2
									c72 [i]<=0;
								else begin
									if(G72 +i>=511)
										c72 [i]<=flash_data7[G72 +i-511];
									else
										c72 [i]<=flash_data7[G72 +i+1];
								end
								
								
								
								if(G82 ==0)//2
									c82 [i]<=0;
								else begin
									if(G82 +i>=511)
										c82 [i]<=flash_data8[G82 +i-511];
									else
										c82 [i]<=flash_data8[G82 +i+1];
								end
								
								
								if(G92 ==0)//2
									c92 [i]<=0;
								else begin
									if(G92 +i>=511)
										c92 [i]<=flash_data9[G92 +i-511];
									else
										c92 [i]<=flash_data9[G92 +i+1];
								end
								
								
								if(G102 ==0)//2
									c102 [i]<=0;
								else begin
									if(G102 +i>=511)
										c102 [i]<=flash_data10[G102 +i-511];
									else
										c102 [i]<=flash_data10[G102 +i+1];
								end
								
								//
								
								if(G112 ==0)//1
									c112 [i]<=0;//
								else begin//

									if(G112 +i>=511)//
										c112 [i]<=flash_data11[G112 +i-511];//
									else//
										c112 [i]<=flash_data11[G112 +i+1];//

								end
								
								
								if(G122 ==0)//2
									c122 [i]<=0;
								else begin
									if(G122 +i>=511)
										c122 [i]<=flash_data12[G122 +i-511];
									else
										c122 [i]<=flash_data12[G122 +i+1];
								end
								
								
								if(G132 ==0)//2
									c132 [i]<=0;
								else begin
									if(G132 +i>=511)
										c132 [i]<=flash_data13[G132 +i-511];
									else
										c132 [i]<=flash_data13[G132 +i+1];
								end
								
								if(G142 ==0)//2
									c142 [i]<=0;
								else begin
									if(G142 +i>=511)
										c142 [i]<=flash_data14[G142 +i-511];
									else
										c142 [i]<=flash_data14[G142 +i+1];
								end
								
								
								
								if(G152 ==0)//2
									c152 [i]<=0;
								else begin
									if(G152 +i>=511)
										c152 [i]<=flash_data15[G152 +i-511];
									else
										c152 [i]<=flash_data15[G152 +i+1];
								end
								
								
								if(G162 ==0)//2
									c162 [i]<=0;
								else begin
									if(G162 +i>=511)
										c162 [i]<=flash_data16[G162 +i-511];
									else
										c162 [i]<=flash_data16[G162 +i+1];
								end
							
								
							end
					CODE2:begin
					//first row nor
							c11_1[i]  <=c11_1[i]  +c11_2[i];
							c21_1[i]  <=c21_1[i]  +c21_2[i];
							c31_1[i]  <=c31_1[i]  +c31_2[i];
							c41_1[i]  <=c41_1[i]  +c41_2[i];
							c51_1[i]  <=c51_1[i]  +c51_2[i];
							c61_1[i]  <=c61_1[i]  +c61_2[i];
							c71_1[i]  <=c71_1[i]  +c71_2[i];
							c81_1[i]  <=c81_1[i]  +c81_2[i];
							c91_1[i]  <=c91_1[i]  +c91_2[i];
							c101_1[i] <=c101_1[i] +c101_2[i];
							c111_1[i] <=c111_1[i] +c111_2[i];
							c121_1[i] <=c121_1[i] +c121_2[i];
							c131_1[i] <=c131_1[i] +c131_2[i];
							c141_1[i] <=c141_1[i] +c141_2[i];
							c151_1[i] <=c151_1[i] +c151_2[i];
							c161_1[i] <=c161_1[i] +c161_2[i];
							
							
			
							c12[i] <=c12[i] +c22[i];
							c32[i] <=c32[i] +c42[i];
							c52[i] <=c52[i] +c62[i];
							c72[i] <=c72[i] +c82[i];
							c92[i] <=c92[i] +c102[i];
							c112[i]<=c112[i]+c122[i];
							c132[i]<=c132[i]+c142[i];
							c152[i]<=c152[i]+c162[i];
							end
					CODE3:begin
							c11_1[i]  <=	c11_1[i]	+	c21_1[i];
		
					        c31_1[i]  <=	c31_1[i]  	+	c41_1[i];
					        
					        c51_1[i]  <=	c51_1[i]	+	c61_1[i];

					        c71_1[i]  <=	c71_1[i]	+	c81_1[i];

					        c91_1[i]  <=	c91_1[i] 	+	c101_1[i];
				
					        c111_1[i] <=	c111_1[i]	+	c121_1[i];
					  
					        c131_1[i] <= 	c131_1[i]	+	c141_1[i];
					
					        c151_1[i] <=	c151_1[i]	+	c161_1[i];
							
							c12[i] <=	c12[i]	+	c32[i];
					
							c52[i] <=	c52[i]	+	c72[i];
						
							c92[i] <=	c92[i]	+	c112[i];
						
							c132[i]<=	c132[i]	+	c152[i];
					
							end
					CODE4:begin
							
							c11_1[i]  <=	c11_1[i]	+	 c31_1[i];
		
					      
					        
					        c51_1[i]  <=	c51_1[i]	+	c71_1[i];

					     

					        c91_1[i]  <=	c91_1[i] 	+	c111_1[i];
				
					        
					  
					        c131_1[i] <= 	c131_1[i]	+	c151_1[i];
					
					     
							
							c12[i] <=	c12[i]	+	c52[i];
					
							
						
							c92[i] <=	c92[i]	+	c132[i];
						

							
							end
					CODE5:begin
							c11_1[i]  <=	c11_1[i]	+	 c51_1[i];
		
					      
					        
					 

					     

					        c91_1[i]  <=	c91_1[i] 	+	c131_1[i];
				
					        
					  

					
					     
							
							c12[i] <=	c12[i]	+	c92[i];
					
							
						
						
							end
					CODE6:begin
							c11_1[i]  <=	c11_1[i]	+	 c91_1[i];
		
							
						
						
							end
					endcase
				end
			end
		end
endgenerate


always@(posedge clk or negedge rst_n)begin//判断译码是否完成
	if(!rst_n)begin
		ecc_code_over<=0;
		flash_code_data<=0;
	end
	else begin
		case(current_state)
		IDLE:begin
				ecc_code_over<=0;
				flash_code_data<=0;
		    end
	 CODE1:begin
		    end
     CODE2:begin
		    end
     CODE3:begin
		    end
     CODE4:begin
		    end
     CODE5:begin
		    end
	 CODE6:begin
		    end
		OUT:begin
					ecc_code_over<=1;
					flash_code_data<={c11_1,c12};
				end
		endcase
	end
end



G_matrix u_G_matrix(
.clk(clk),
.rst_n(rst_n),
.G1({G11_1,G11_2,G12}),
.G2({G21_1,G21_2,G22}),
.G3({G31_1,G31_2,G32}),
.G4({G41_1,G41_2,G42}),
.G5({G51_1,G51_2,G52}),
.G6({G61_1,G61_2,G62}),
.G7({G71_1,G71_2,G72}),
.G8({G81_1,G81_2,G82}),
.G9({G91_1,G91_2,G92}),
.G10({G101_1,G101_2,G102}),
.G11({G111_1,G111_2,G112}),
.G12({G121_1,G121_2,G122}),
.G13({G131_1,G131_2,G132}),
.G14({G141_1,G141_2,G142}),
.G15({G151_1,G151_2,G152}),
.G16({G161_1,G161_2,G162})
);

endmodule



	


	
