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
module ecc_decode
	#(
	 parameter  N=9216,
	 parameter  K=8192,
	 parameter  M=1024,
	 parameter  loop=32)
	(
		input 						clk,
		input 						rst_n,
		input						ecc_decode_sta,
		input			[9215:0]	flash_data,
		input						decode_output_over,
		output reg				ecc_decode_over,
		output reg [8191:0] 	    flash_decode_data,
		output reg						decode_result
	);
////////////decode state//////////
parameter IDLE			=		4'd0;
parameter DECODE1		=		4'd1;
parameter DECODE2		=		4'd2;
parameter DECODE3		=		4'd3;
parameter DECODE4		=		4'd4;
parameter DECODE5		=		4'd5;
parameter DECODE6		=		4'd6;
parameter JUDGEMENT	=		4'd7;
parameter FIX1			=		4'd8;
parameter FIX2			=		4'd9;
parameter FIX3			=		4'd10;

reg[3:0] current_state;
reg[3:0] next_state;
//transform signal and condition
wire IDLE2DE1;
wire DE12DE2;
wire DE22DE3;
wire DE32DE4;
wire DE42DE5;
wire DE52DE6;
wire DE62JUD;
wire JUD2FIX1;
wire FIX12FIX2;
wire FIX22FIX3;
wire FIX22DE1;
wire FIX32DE1;
wire JUD2IDLE;

reg [511:0] c11;
reg [511:0] c12;
reg [511:0] c13;
reg [511:0] c14;
reg [511:0] c15;
reg [511:0] c16;
reg [511:0] c17;
reg [511:0] c18;
reg [511:0] c19;
reg [511:0] c110;
reg [511:0] c111;
reg [511:0] c112;
reg [511:0] c113;
reg [511:0] c114;
reg [511:0] c115;
reg [511:0] c116;
reg [511:0] c117;
reg [511:0] c118;

reg [511:0] c21;
reg [511:0] c22;
reg [511:0] c23;
reg [511:0] c24;
reg [511:0] c25;
reg [511:0] c26;
reg [511:0] c27;
reg [511:0] c28;
reg [511:0] c29;
reg [511:0] c210;
reg [511:0] c211;
reg [511:0] c212;
reg [511:0] c213;
reg [511:0] c214;
reg [511:0] c215;
reg [511:0] c216;
reg [511:0] c217;
reg [511:0] c218;
reg	 [4:0] loop_counter;
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
reg [511:0] flash_data17;
reg [511:0] flash_data18;
//flash_data={flash_data1,flash_data2.....,flash_data18}

////////H矩阵数据////////////
wire [8:0] H11;
wire [8:0] H12;
wire [8:0] H13;
wire [8:0] H14;
wire [8:0] H15;
wire [8:0] H16;
wire [8:0] H17;
wire [8:0] H18;
wire [8:0] H19;
wire [8:0] H110;
wire [8:0] H111;
wire [8:0] H112;
wire [8:0] H113;
wire [8:0] H114;
wire [8:0] H115;
wire [8:0] H116;
wire [8:0] H117;
wire [8:0] H118;
wire [8:0] H21;
wire [8:0] H22;
wire [8:0] H23;
wire [8:0] H24;
wire [8:0] H25;
wire [8:0] H26;
wire [8:0] H27;
wire [8:0] H28;
wire [8:0] H29;
wire [8:0] H210;
wire [8:0] H211;
wire [8:0] H212;
wire [8:0] H213;
wire [8:0] H214;
wire [8:0] H215;
wire [8:0] H216;
wire [8:0] H217;
wire [8:0] H218;
wire [511:0]temp1;//temp是译码后得到的方程组
wire [511:0]temp2;//temp是译码后得到的方程组

//reg fix_en;
wire fix_en;
reg[511:0] error_count11;//纠错计数器
reg[511:0] error_count12;
reg[511:0] error_count13;
reg[511:0] error_count14;
reg[511:0] error_count15;
reg[511:0] error_count16;
reg[511:0] error_count17;
reg[511:0] error_count18;
reg[511:0] error_count19;
reg[511:0] error_count110;
reg[511:0] error_count111;
reg[511:0] error_count112;
reg[511:0] error_count113;
reg[511:0] error_count114;
reg[511:0] error_count115;
reg[511:0] error_count116;
reg[511:0] error_count117;
reg[511:0] error_count118;

reg[511:0] error_count21;
reg[511:0] error_count22;
reg[511:0] error_count23;
reg[511:0] error_count24;
reg[511:0] error_count25;
reg[511:0] error_count26;
reg[511:0] error_count27;
reg[511:0] error_count28;
reg[511:0] error_count29;
reg[511:0] error_count210;
reg[511:0] error_count211;
reg[511:0] error_count212;
reg[511:0] error_count213;
reg[511:0] error_count214;
reg[511:0] error_count215;
reg[511:0] error_count216;
reg[511:0] error_count217;
reg[511:0] error_count218; 

reg [511:0]one_loop_over1;
reg [511:0]one_loop_over2;
reg [511:0]one_loop_over3;
reg [511:0]one_loop_over4;
reg [511:0]one_loop_over5;
reg [511:0]one_loop_over6;
reg [511:0]one_loop_over7;
reg [511:0]one_loop_over8;
reg [511:0]one_loop_over9;
reg [511:0]one_loop_over10;
reg [511:0]one_loop_over11;
reg [511:0]one_loop_over12;
reg [511:0]one_loop_over13;
reg [511:0]one_loop_over14;
reg [511:0]one_loop_over15;
reg [511:0]one_loop_over16;
reg [511:0]one_loop_over17;
reg [511:0]one_loop_over18;

wire[9215:0]one_loop_over;
assign one_loop_over={one_loop_over18,one_loop_over17,one_loop_over16,one_loop_over15,one_loop_over14,one_loop_over13,one_loop_over12,one_loop_over11,one_loop_over10,one_loop_over9,one_loop_over8,one_loop_over7,one_loop_over6,one_loop_over5,one_loop_over4,one_loop_over3,one_loop_over2,one_loop_over1};
assign fix_en		=(current_state==JUDGEMENT&&(temp1!=0||temp2!=0)&&(loop_counter<loop-1))?1:0;

assign IDLE2DE1 	=	current_state==IDLE&&ecc_decode_sta;
assign DE12DE2		= 	current_state==DECODE1&&ecc_decode_sta;
assign DE22DE3		=	current_state==DECODE2&&ecc_decode_sta;
assign DE32DE4		=	current_state==DECODE3&&ecc_decode_sta;
assign DE42DE5		=	current_state==DECODE4&&ecc_decode_sta;
assign DE52DE6		=	current_state==DECODE5&&ecc_decode_sta;
assign DE62JUD		=	current_state==DECODE6&&ecc_decode_sta;
assign JUD2FIX1	= 	current_state==JUDGEMENT&&ecc_decode_sta&&fix_en;
assign FIX12FIX2	=	current_state==FIX1&&ecc_decode_sta;
//&&fix_en;
assign FIX22FIX3	=	current_state==FIX3&&ecc_decode_sta&&one_loop_over==0;
assign FIX22DE1	=	current_state==FIX2&&ecc_decode_sta;
//&&one_loop_over!=0;
assign FIX32DE1	=	current_state==FIX3&&ecc_decode_sta;
assign JUD2IDLE	=	current_state==JUDGEMENT&&(decode_output_over||ecc_decode_sta==0)&&fix_en==0;
//assign flash_decode_data={c11,c12,c13,c14,c15,c16,c17,c18,c19,c110,c111,c112,c113,c114,c115,c116,c117,c118};

assign temp1=c11;//c11的第0位实际上是校验方程的第一个
assign temp2=c21;//c12的第0位实际上是校验方程的第512个
//reg [9215:0] flash_data_r;


//////////////////////////H*CT state machine///////////////

always@(posedge clk or negedge rst_n)begin//以验证
	if(!rst_n)
		current_state<=0;
	else 
		current_state<=next_state;
end


always@(*)begin//以验证
	case(current_state)
		IDLE:begin
				if(IDLE2DE1)
					next_state=DECODE1;
				else
					next_state=IDLE;
			end
	DECODE1:begin
				if(DE12DE2)
					next_state=DECODE2;
				else
					next_state=next_state;
			end
	DECODE2:begin
				if(DE22DE3)
					next_state=DECODE3;
				else
					next_state=next_state;
			end
	DECODE3:begin
				if(DE32DE4)
					next_state=DECODE4;
				else
					next_state=next_state;
			end
	DECODE4:begin
				if(DE42DE5)
					next_state=DECODE5;
				else
					next_state=next_state;
			end
	DECODE5:begin
				if(DE52DE6)
					next_state=DECODE6;
				else
					next_state=next_state;
			end
	DECODE6:begin
				if(DE62JUD)
					next_state=JUDGEMENT;
				else
					next_state=next_state;
			end
   JUDGEMENT:begin
				if(JUD2FIX1)
					next_state=FIX1;
				else if(JUD2IDLE)
					next_state=IDLE;
				else
					next_state=next_state;
			end
	    FIX1:begin
				if(FIX12FIX2)
					next_state=FIX2;
				else
					next_state=next_state;
			end
		FIX2:begin
				if(FIX22FIX3)
					next_state=FIX3;
				else if(FIX22DE1)
					next_state=DECODE1;	
				else
					next_state=next_state;
			end
		FIX3:begin
				if(FIX32DE1)
					next_state=DECODE1;
				else
					next_state=next_state;
			end	
	endcase
end
				




genvar i;//声明的此变量只用于生成块的循环计算，在电路里面并不存在
generate
   for(i=0;i<512;i=i+1)
        begin:decode
				always@(posedge clk or negedge rst_n)begin//执行矩阵运算
					if(!rst_n)begin
						 c11[i]   <=0;
						 c12[i]   <=0;
						 c13[i]   <=0;
						 c14[i]   <=0;
						 c15[i]   <=0;
						 c16[i]   <=0;
						 c17[i]   <=0;
						 c18[i]   <=0;
						 c19[i]   <=0;
						 c110[i]  <=0;
						 c111[i]  <=0;
						 c112[i]  <=0;
						 c113[i]  <=0;
						 c114[i]  <=0;
						 c115[i]  <=0;
						 c116[i]  <=0;
						 c117[i]  <=0;
						 c118[i]  <=0;
						 c21[i]   <=0;
						 c22[i]   <=0;
						 c23[i]   <=0;
						 c24[i]   <=0;
						 c25[i]   <=0;
						 c26[i]   <=0;
						 c27[i]   <=0;
						 c28[i]   <=0;
						 c29[i]   <=0;
						 c210[i]  <=0;
						 c211[i]  <=0;
						 c212[i]  <=0;
						 c213[i]  <=0;
						 c214[i]  <=0;
						 c215[i]  <=0;
						 c216[i]  <=0;
						 c217[i]  <=0;
						 c218[i]  <=0;
					end
				else begin		
					case(current_state)
					IDLE:begin 
						c11[i] 	 <=0;
				        c12[i] 	 <=0;
				        c13[i] 	 <=0;
				        c14[i] 	 <=0;
				        c15[i] 	 <=0;
				        c16[i] 	 <=0;
				        c17[i] 	 <=0;
				        c18[i] 	 <=0;
				        c19[i] 	 <=0;
				        c110[i]  <=0;
				        c111[i]  <=0;
				        c112[i]  <=0;
				        c113[i]  <=0;
				        c114[i]  <=0;
						c115[i]  <=0;
						c116[i]  <=0;
						c117[i]  <=0;
						c118[i]  <=0;
						c21[i] 	 <=0;
				        c22[i] 	 <=0;
				        c23[i] 	 <=0;
				        c24[i] 	 <=0;
				        c25[i] 	 <=0;
				        c26[i] 	 <=0;
				        c27[i] 	 <=0;
				        c28[i] 	 <=0;
				        c29[i] 	 <=0;
				        c210[i]  <=0;
				        c211[i]  <=0;
				        c212[i]  <=0;
				        c213[i]  <=0;
				        c214[i]  <=0;
					    c215[i]  <=0;
						c216[i]  <=0;
                        c217[i]  <=0;
                        c218[i]  <=0;
						end
					DECODE1:begin
								if(H11==0)//1
									c11[i]<=0;//
								else begin//

									if(H11<i)//
										c11[i]<=flash_data1[512+H11-i];//
//有�
										  //c11[i]<=flash_data1[i];�//
									else//
										c11[i]<=flash_data1[H11-i];//
									       // c11[i]<=flash_data1[i];//

								end
								
								if(H12==0)//2
									c12[i]<=0;
								else begin
									if(H12<i)
										c12[i]<=flash_data2[H12-i+512];
									else
										c12[i]<=flash_data2[H12-i];
								end
								
								if(H13==0)//3
									c13[i]<=0;
								else begin
									if(H13<i)
										c13[i]<=flash_data3[H13-i+512];
									else
										c13[i]<=flash_data3[H13-i];
								end
								
								if(H14==0)//4
									c14[i]<=0;
								else begin
									if(H14<i)
										c14[i]<=flash_data4[H14-i+512];
									else
										c14[i]<=flash_data4[H14-i];
								end
								
								if(H15==0)
									c15[i]<=0;
								else begin
									if(H15<i)
										c15[i]<=flash_data5[H15-i+512];
									else
										c15[i]<=flash_data5[H15-i];
								end
								
								if(H16==0)
									c16[i]<=0;
								else begin
									if(H16<i)
										c16[i]<=flash_data6[H16-i+512];
									else
										c16[i]<=flash_data6[H16-i];
								end
								
								if(H17==0)
									c17[i]<=0;
								else begin
									if(H17<i)
										c17[i]<=flash_data7[H17-i+512];
									else
										c17[i]<=flash_data7[H17-i];
								end
								
								if(H18==0)
									c18[i]<=0;
								else begin
									if(H18<i)
										c18[i]<=flash_data8[H18-i+512];
									else
										c18[i]<=flash_data8[H18-i];
								end
								
								if(H19==0)
									c19[i]<=0;
								else begin
									if(H19<i)
										c19[i]<=flash_data9[H19-i+512];
									else
										c19[i]<=flash_data9[H19-i];
								end
								
								if(H110==0)
									c110[i]<=0;
								else begin
									if(H110<i)
										c110[i]<=flash_data10[H110-i+512];
									else
										c110[i]<=flash_data10[H110-i];
								end
								
								if(H111==0)
									c111[i]<=0;
								else begin
									if(H111<i)
										c111[i]<=flash_data11[H111-i+512];
									else
										c111[i]<=flash_data11[H111-i];
								end
								
								if(H112==0)
									c112[i]<=0;
								else begin
									if(H112<i)
										c112[i]<=flash_data12[H112-i+512];
									else
										c112[i]<=flash_data12[H112-i];
								end
								
								if(H113==0)
									c113[i]<=0;
								else begin
									if(H113<i)
										c113[i]<=flash_data13[H113-i+512];
									else
										c113[i]<=flash_data13[H113-i];
								end
								
								if(H114==0)
									c114[i]<=0;
								else begin
									if(H114<i)
										c114[i]<=flash_data14[H114-i+512];
									else
										c114[i]<=flash_data14[H114-i];
								end
								
								if(H115==0)
									c115[i]<=0;
								else begin
									if(H115<i)
										c115[i]<=flash_data15[H115-i+512];
									else
										c115[i]<=flash_data15[H115-i];
								end
								
								if(H116==0)
									c116[i]<=0;
								else begin
									if(H116<i)
										c116[i]<=flash_data16[H116-i+512];
									else
										c116[i]<=flash_data16[H116-i];
								end
								
								if(H117==0)
									c117[i]<=0;
								else begin
									if(H117<i)
										c117[i]<=flash_data17[H117-i+512];
									else
										c117[i]<=flash_data17[H117-i];
								end
								
								if(H118==0)
									c118[i]<=0;
								else begin
									if(H118<i)
										c118[i]<=flash_data18[H118-i+512];
									else
										c118[i]<=flash_data18[H118-i];
								end
								
							//second_row
								if(H21==0)//1
									c21[i]<=0;
								else begin
									if(H21<i)
										c21[i]<=flash_data1[H21-i+512];
									else
										c21[i]<=flash_data1[H21-i];
								end
								
								if(H22==0)//2
									c22[i]<=0;
								else begin
									if(H22<i)
										c22[i]<=flash_data2[H22-i+512];
									else
										c22[i]<=flash_data2[H22-i];
								end
								
								if(H23==0)//3
									c23[i]<=0;
								else begin
									if(H23<i)
										c23[i]<=flash_data3[H23-i+512];
									else
										c23[i]<=flash_data3[H23-i];
								end
								
								if(H24==0)//4
									c24[i]<=0;
								else begin
									if(H24<i)
										c24[i]<=flash_data4[H24-i+512];
									else
										c24[i]<=flash_data4[H24-i];
								end
								
								if(H25==0)
									c25[i]<=0;
								else begin
									if(H25<i)
										c25[i]<=flash_data5[H25-i+512];
									else
										c25[i]<=flash_data5[H25-i];
								end
								
								if(H26==0)
									c26[i]<=0;
								else begin
									if(H26<i)
										c26[i]<=flash_data6[H26-i+512];
									else
										c26[i]<=flash_data6[H26-i];
								end
								
								if(H27==0)
									c27[i]<=0;
								else begin
									if(H27<i)
										c27[i]<=flash_data7[H27-i+512];
									else
										c27[i]<=flash_data7[H27-i];
								end
								
								if(H28==0)
									c28[i]<=0;
								else begin
									if(H28<i)
										c28[i]<=flash_data8[H28-i+512];
									else
										c28[i]<=flash_data8[H28-i];
								end
								
								if(H29==0)
									c29[i]<=0;
								else begin
									if(H29<i)
										c29[i]<=flash_data9[H29-i+512];
									else
										c29[i]<=flash_data9[H29-i];
								end
								
								if(H210==0)
									c210[i]<=0;
								else begin
									if(H210<i)
										c210[i]<=flash_data10[H210-i+512];
									else
										c210[i]<=flash_data10[H210-i];
								end
								
								if(H211==0)
									c211[i]<=0;
								else begin
									if(H211<i)
										c211[i]<=flash_data11[H211-i+512];
									else
										c211[i]<=flash_data11[H211-i];
								end
								
								if(H212==0)
									c212[i]<=0;
								else begin
									if(H212<i)
										c212[i]<=flash_data12[H212-i+512];
									else
										c212[i]<=flash_data12[H212-i];
								end
								
								if(H213==0)
									c213[i]<=0;
								else begin
									if(H213<i)
										c213[i]<=flash_data13[H213-i+512];
									else
										c213[i]<=flash_data13[H213-i];
								end
								
								if(H214==0)
									c214[i]<=0;
								else begin
									if(H214<i)
										c214[i]<=flash_data14[H214-i+512];
									else
										c214[i]<=flash_data14[H214-i];
								end
								
								if(H215==0)
									c215[i]<=0;
								else begin
									if(H215<i)
										c215[i]<=flash_data15[H215-i+512];
									else
										c215[i]<=flash_data15[H215-i];
								end
								
								if(H216==0)
									c216[i]<=0;
								else begin
									if(H216<i)
										c216[i]<=flash_data16[H216-i+512];
									else
										c216[i]<=flash_data16[H216-i];
								end
								
								if(H217==0)
									c217[i]<=0;
								else begin
									if(H217<i)
										c217[i]<=flash_data17[H217-i+512];
									else
										c217[i]<=flash_data17[H217-i];
								end
								
								if(H218==0)
									c218[i]<=0;
								else begin
									if(H218<i)
										c218[i]<=flash_data18[H218-i+512];
									else
										c218[i]<=flash_data18[H218-i];
								end
							end
					DECODE2:begin
					//first row nor
							c11[i] <=c11[i]+c12[i];
							c13[i] <=c13[i]+c14[i];
							c15[i] <=c15[i]+c16[i];
							c17[i] <=c17[i]+c18[i];
							c19[i] <=c19[i]+c110[i];
							c111[i]<=c111[i]+c112[i];
							c113[i] <=c113[i]+c114[i];
							c115[i] <=c115[i]+c116[i];
							c117[i] <=c117[i]+c118[i];
							c21[i]<=c21[i]+c22[i];
							c23[i]<=c23[i]+c24[i];
							c25[i]<=c25[i]+c26[i];
							c27[i]<=c27[i]+c28[i];
							c29[i]<=c29[i]+c210[i];
							c211[i]<=c211[i]+c212[i];
							c213[i]<=c213[i]+c214[i];
							c215[i]<=c215[i]+c216[i];
							c217[i]<=c217[i]+c218[i];
							end
					DECODE3:begin
							c11[i]<=c11[i]+c13[i];
							c15[i]<=c15[i]+c17[i];
							c19[i]<=c19[i]+c111[i];
							c113[i]<=c113[i]+c115[i];
							c21[i]<=c21[i]+c23[i];
							c25[i]<=c25[i]+c27[i];
							c29[i]<=c29[i]+c211[i];
							c213[i]<=c213[i]+c215[i];
							end
					DECODE4:begin
							c11[i]<=c11[i]+c15[i];
							c19[i]<=c19[i]+c113[i];
							c21[i]<=c21[i]+c25[i];
							c29[i]<=c29[i]+c213[i];
							end
					DECODE5:begin
							c11[i]<=c11[i]+c19[i];
							c21[i]<=c21[i]+c29[i];
							end
					DECODE6:begin
							c11[i]<=c11[i]+c117[i];
							c21[i]<=c21[i]+c217[i];
					
							end
					endcase
				end
			end
		end
endgenerate



always@(posedge clk or negedge rst_n)begin//判断译码是否完成
	if(!rst_n)begin
		loop_counter<=0;
		decode_result<=0;
		ecc_decode_over<=0;
		//fix_en<=0;
		flash_decode_data<=0;
	end
	else begin
		case(current_state)
		IDLE:begin
				loop_counter<=0;
				decode_result<=0;
				ecc_decode_over<=0;
				flash_decode_data<=0;
				//fix_en<=0;
		    end
	 DECODE1:begin
		    end
     DECODE2:begin
		    end
     DECODE3:begin
		    end
     DECODE4:begin
		    end
     DECODE5:begin
		    end
     DECODE6:begin
		    end
   JUDGEMENT:begin
				if(temp1==0&&temp2==0)begin//为0译码成功，译码迭代次数置为0，译码结果为1，进入fix状态置为0，输出译码后的数据
					loop_counter<=0;
					decode_result<=1;
					ecc_decode_over<=1;
					//fix_en<=0;
					flash_decode_data<={flash_data1,flash_data2,flash_data3,flash_data4,flash_data5,flash_data6,flash_data7,flash_data8,flash_data9,flash_data10,flash_data11,flash_data12,flash_data13,flash_data14,flash_data15,flash_data16};
				end
				else if(loop_counter==loop-1)begin//达到循环次数上限，译码失败
					loop_counter<=loop_counter;
					decode_result<=0;
					ecc_decode_over<=1;
					//fix_en<=0;
					flash_decode_data<={flash_data1,flash_data2,flash_data3,flash_data4,flash_data5,flash_data6,flash_data7,flash_data8,flash_data9,flash_data10,flash_data11,flash_data12,flash_data13,flash_data14,flash_data15,flash_data16};
				end
				else begin//进入纠错阶段
					loop_counter<=loop_counter+1;
					ecc_decode_over<=0;
					decode_result<=0;
					//fix_en<=1;
					flash_decode_data<=flash_decode_data;
				end
			end
		FIX1:begin
		    end
		FIX2:begin
		    end
		FIX3:begin
		    end
		endcase
	end
end


genvar k;//声明的此变量只用于生成块的循环计算，在电路里面并不存在
generate
   for(k=0;k<512;k=k+1)
        begin:fixx
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		error_count11[k]<=0;
		error_count12[k]<=0;
		error_count13[k]<=0;
		error_count14[k]<=0;
		error_count15[k]<=0;
		error_count16[k]<=0;
		error_count17[k]<=0;
		error_count18[k]<=0;
		error_count19[k]<=0;
		error_count110[k]<=0;
		error_count111[k]<=0;
		error_count112[k]<=0;
		error_count113[k]<=0;
		error_count114[k]<=0;
		error_count115[k]<=0;
		error_count116[k]<=0;
		error_count117[k]<=0;
		error_count118[k]<=0;
		error_count21[k]<=0;
		error_count22[k]<=0;
		error_count23[k]<=0;
		error_count24[k]<=0;
		error_count25[k]<=0;
		error_count26[k]<=0;
		error_count27[k]<=0;
		error_count28[k]<=0;
		error_count29[k]<=0;
		error_count210[k]<=0;
		error_count211[k]<=0;
		error_count212[k]<=0;
		error_count213[k]<=0;
		error_count214[k]<=0;
		error_count215[k]<=0;
		error_count216[k]<=0;
		error_count217[k]<=0;
		error_count218[k]<=0;
		one_loop_over1[k]<=0;
		one_loop_over2[k]<=0;
		one_loop_over3[k]<=0;
		one_loop_over4[k]<=0;
		one_loop_over5[k]<=0;
		one_loop_over6[k]<=0;
		one_loop_over7[k]<=0;
		one_loop_over8[k]<=0;
		one_loop_over9[k]<=0;
		one_loop_over10[k]<=0;
		one_loop_over11[k]<=0;
		one_loop_over12[k]<=0;
		one_loop_over13[k]<=0;
		one_loop_over14[k]<=0;
		one_loop_over15[k]<=0;
		one_loop_over16[k]<=0;
		one_loop_over17[k]<=0;
		one_loop_over18[k]<=0;
		flash_data1[k]<=0;
		flash_data2[k]<=0;
		flash_data3[k]<=0;
		flash_data4[k]<=0;
		flash_data5[k]<=0;
		flash_data6[k]<=0;
		flash_data7[k]<=0;
		flash_data8[k]<=0;
		flash_data9[k]<=0;
		flash_data10[k]<=0;
		flash_data11[k]<=0;
		flash_data12[k]<=0;
		flash_data13[k]<=0;
		flash_data14[k]<=0;
		flash_data15[k]<=0;
		flash_data16[k]<=0;
		flash_data17[k]<=0;
		flash_data18[k]<=0;
	end
	else begin
		case(current_state)
		IDLE:begin
			error_count11[k]<=0;
			error_count12[k]<=0;
			error_count13[k]<=0;
			error_count14[k]<=0;
			error_count15[k]<=0;
			error_count16[k]<=0;
			error_count17[k]<=0;
			error_count18[k]<=0;
			error_count19[k]<=0;
			error_count110[k]<=0;
			error_count111[k]<=0;
			error_count112[k]<=0;
			error_count113[k]<=0;
			error_count114[k]<=0;
			error_count115[k]<=0;
			error_count116[k]<=0;
			error_count117[k]<=0;
			error_count118[k]<=0;
			error_count21[k]<=0;
			error_count22[k]<=0;
			error_count23[k]<=0;
			error_count24[k]<=0;
			error_count25[k]<=0;
			error_count26[k]<=0;
			error_count27[k]<=0;
			error_count28[k]<=0;
			error_count29[k]<=0;
			error_count210[k]<=0;
			error_count211[k]<=0;
			error_count212[k]<=0;
			error_count213[k]<=0;
			error_count214[k]<=0;
			error_count215[k]<=0;
			error_count216[k]<=0;
			error_count217[k]<=0;
			error_count218[k]<=0;
			one_loop_over1[k]<=0;
			one_loop_over2[k]<=0;
			one_loop_over3[k]<=0;
			one_loop_over4[k]<=0;
			one_loop_over5[k]<=0;
			one_loop_over6[k]<=0;
			one_loop_over7[k]<=0;
			one_loop_over8[k]<=0;
			one_loop_over9[k]<=0;
			one_loop_over10[k]<=0;
			one_loop_over11[k]<=0;
			one_loop_over12[k]<=0;
			one_loop_over13[k]<=0;
			one_loop_over14[k]<=0;
			one_loop_over15[k]<=0;
			one_loop_over16[k]<=0;
			one_loop_over17[k]<=0;
			one_loop_over18[k]<=0;
			flash_data1[k]<=flash_data[8704+k];
			flash_data2[k]<=flash_data[8192+k];
			flash_data3[k]<=flash_data[7680+k];
			flash_data4[k]<=flash_data[7168+k];
			flash_data5[k]<=flash_data[6656+k];
			flash_data6[k]<=flash_data[6144+k];
			flash_data7[k]<=flash_data[5632+k];
			flash_data8[k]<=flash_data[5120+k];
			flash_data9[k]<=flash_data[4608+k];
			flash_data10[k]<=flash_data[4096+k];
			flash_data11[k]<=flash_data[3584+k];
			flash_data12[k]<=flash_data[3072+k];
			flash_data13[k]<=flash_data[2560+k];
			flash_data14[k]<=flash_data[2048+k];
			flash_data15[k]<=flash_data[1536+k];
			flash_data16[k]<=flash_data[1024+k];
			flash_data17[k]<=flash_data[512+k];
			flash_data18[k]<=flash_data[k];		
		 end
     DECODE1:begin
		     end
     DECODE2:begin
		     end
     DECODE3:begin
		     end
     DECODE4:begin
		     end
     DECODE5:begin
		     end
     DECODE6:begin
		     end
   JUDGEMENT:begin
		     end
          FIX1:begin//实现计算每个元素错误的次数
				if(temp1[k]!=0)begin
					if(H11<k)//前512*512 
						error_count11[512+H11-k]<=1;
					else
						error_count11[H11-k]<=1;	
							
					if(H12<k)//第二个512*512 
						error_count12[512+H12-k]<=1;
					else
						error_count12[H12-k]<=1;
					
					if(H13<k)//第3个512*512 
						error_count13[512+H13-k]<=1;
					else
						error_count13[H13-k]<=1;
					
					if(H14<k)//第4个512*512 
						error_count14[512+H14-k]<=1;
					else
						error_count14[H14-k]<=1;
						
					if(H15<k)//第5个512*512 
						error_count15[512+H15-k]<=1;
					else
						error_count15[H15-k]<=1;
					
					if(H16<k)//第6个512*512 
						error_count16[512+H16-k]<=1;
					else
						error_count16[H16-k]<=1;
						
					if(H17<k)//第7个512*512 
						error_count17[512+H17-k]<=1;
					else
						error_count17[H17-k]<=1;
						
					if(H18<k)//第8个512*512 
						error_count18[512+H18-k]<=1;
					else
						error_count18[H18-k]<=1;
						
					if(H19<k)//第9个512*512  
						error_count19[512+H19-k]<=1;
					else
						error_count19[H19-k]<=1;
						
					if(H110<k)//第10个512*512  
						error_count110[512+H110-k]<=1;
					else
						error_count110[H110-k]<=1;
						
					if(H111<k)//第11个512*512 
						error_count111[512+H111-k]<=1;
					else
						error_count111[H111-k]<=1;
		
					if(H112<k)//第12个512*512 
						error_count112[512+H112-k]<=1;
					else
						error_count112[H112-k]<=1;	
					
					if(H113<k)//第13个512*512  
						error_count113[512+H113-k]<=1;
					else
						error_count113[H113-k]<=1;
					
					if(H114<k)//第14个512*512 
						error_count114[512+H114-k]<=1;
					else
						error_count114[H114-k]<=1;
						
					if(H115<k)//第15个512*512 
						error_count115[512+H115-k]<=1;
					else
						error_count115[H115-k]<=1;
						
					if(H116<k)//第16个512*512 
						error_count116[512+H116-k]<=1;
					else
						error_count116[H116-k]<=1;
						
					error_count117[k]<=0;
					//第17全0 无
					if(H118<k)//第18个512*512 
						error_count118[512+H118-k]<=1;
					else
						error_count118[H118-k]<=1;		
				end
				else begin
					if(H11<k)//前512*512 
						error_count11[512+H11-k]<=0;
					else
						error_count11[H11-k]<=0;	
							
					if(H12<k)//第二个512*512 
						error_count12[512+H12-k]<=0;
					else
						error_count12[H12-k]<=0;
					
					if(H13<k)//第3个512*512 
						error_count13[512+H13-k]<=0;
					else
						error_count13[H13-k]<=0;
					
					if(H14<k)//第4个512*512 
						error_count14[512+H14-k]<=0;
					else
						error_count14[H14-k]<=0;
						
					if(H15<k)//第5个512*512 
						error_count15[512+H15-k]<=0;
					else
						error_count15[H15-k]<=0;
					
					if(H16<k)//第6个512*512 
						error_count16[512+H16-k]<=0;
					else
						error_count16[H16-k]<=0;
						
					if(H17<k)//第7个512*512 
						error_count17[512+H17-k]<=0;
					else
						error_count17[H17-k]<=0;
						
					if(H18<k)//第8个512*512 
						error_count18[512+H18-k]<=0;
					else
						error_count18[H18-k]<=0;
						
					if(H19<k)//第9个512*512  
						error_count19[512+H19-k]<=0;
					else
						error_count19[H19-k]<=0;
						
					if(H110<k)//第10个512*512  
						error_count110[512+H110-k]<=0;
					else
						error_count110[H110-k]<=0;
						
					if(H111<k)//第11个512*512 
						error_count111[512+H111-k]<=0;
					else
						error_count111[H111-k]<=0;
		
					if(H112<k)//第12个512*512 
						error_count112[512+H112-k]<=0;
					else
						error_count112[H112-k]<=0;	
					
					if(H113<k)//第13个512*512  
						error_count113[512+H113-k]<=0;
					else
						error_count113[H113-k]<=0;
					
					if(H114<k)//第14个512*512 
						error_count114[512+H114-k]<=0;
					else
						error_count114[H114-k]<=0;
						
					if(H115<k)//第15个512*512 
						error_count115[512+H115-k]<=0;
					else
						error_count115[H115-k]<=0;
						
					if(H116<k)//第16个512*512 
						error_count116[512+H116-k]<=0;
					else
						error_count116[H116-k]<=0;
						
					error_count117[k]<=0;
					//第17全0 无
					if(H118<k)//第18个512*512 
						error_count118[512+H118-k]<=0;
					else
						error_count118[H118-k]<=0;	
				end

	///第二行
				if(temp2[k]!=0)begin
					if(H21<k)//前512*512 
						error_count21[512+H21-k]<=1;
					else
						error_count21[H21-k]<=1;	
							
					if(H22<k)//第二个512*512 
						error_count22[512+H22-k]<=1;
					else
						error_count22[H22-k]<=1;
					
					if(H23<k)//第3个512*512 
						error_count23[512+H23-k]<=1;
					else
						error_count23[H23-k]<=1;
					
					if(H24<k)//第4个512*512 
						error_count24[512+H24-k]<=1;
					else
						error_count24[H24-k]<=1;
						
					if(H25<k)//第5个512*512 
						error_count25[512+H25-k]<=1;
					else
						error_count25[H25-k]<=1;
					
					if(H26<k)//第6个512*512 
						error_count26[512+H26-k]<=1;
					else
						error_count26[H26-k]<=1;
						
					if(H27<k)//第7个512*512 
						error_count27[512+H27-k]<=1;
					else
						error_count27[H27-k]<=1;
						
					if(H28<k)//第8个512*512 
						error_count28[512+H28-k]<=1;
					else
						error_count28[H28-k]<=1;
						
					if(H29<k)//第9个512*512  
						error_count29[512+H29-k]<=1;
					else
						error_count29[H29-k]<=1;
						
					if(H210<k)//第10个512*512  
						error_count210[512+H210-k]<=1;
					else
						error_count210[H210-k]<=1;
						
					if(H211<k)//第11个512*512 
						error_count211[512+H211-k]<=1;
					else
						error_count211[H211-k]<=1;
		
					if(H212<k)//第12个512*512 
						error_count212[512+H212-k]<=1;
					else
						error_count212[H212-k]<=1;	
					
					if(H213<k)//第13个512*512  
						error_count213[512+H213-k]<=1;
					else
						error_count213[H213-k]<=1;
					
					if(H214<k)//第14个512*512 
						error_count214[512+H214-k]<=1;
					else
						error_count214[H214-k]<=1;
						
					if(H215<k)//第15个512*512 
						error_count215[512+H215-k]<=1;
					else
						error_count215[H215-k]<=1;
						
					if(H216<k)//第16个512*512 
						error_count216[512+H216-k]<=1;
					else
						error_count216[H216-k]<=1;
						
					if(H217>k)//第17个512*512 第145个元素 
						error_count216[512+H217-k]<=1;
					else
						error_count216[H217-k]<=1;
						
					if(H218<k)//第18个512*512 
						error_count218[512+H218-k]<=1;
					else
						error_count218[H218-k]<=1;		
				end
				else begin
					if(H21<k)//前512*512 
						error_count21[512+H21-k]<=0;
					else
						error_count21[H21-k]<=0;	
							
					if(H22<k)//第二个512*512 
						error_count22[512+H22-k]<=0;
					else
						error_count22[H22-k]<=0;
					
					if(H23<k)//第3个512*512 
						error_count23[512+H23-k]<=0;
					else
						error_count23[H23-k]<=0;
					
					if(H24<k)//第4个512*512 
						error_count24[512+H24-k]<=0;
					else
						error_count24[H24-k]<=0;
						
					if(H25<k)//第5个512*512 
						error_count25[512+H25-k]<=0;
					else
						error_count25[H25-k]<=0;
					
					if(H26<k)//第6个512*512 
						error_count26[512+H26-k]<=0;
					else
						error_count26[H26-k]<=0;
						
					if(H27<k)//第7个512*512 
						error_count27[512+H27-k]<=0;
					else
						error_count27[H27-k]<=0;
						
					if(H28<k)//第8个512*512 
						error_count28[512+H28-k]<=0;
					else
						error_count28[H28-k]<=0;
						
					if(H29<k)//第9个512*512  
						error_count29[512+H29-k]<=0;
					else
						error_count29[H29-k]<=0;
						
					if(H210<k)//第10个512*512  
						error_count210[512+H210-k]<=0;
					else
						error_count210[H210-k]<=0;
						
					if(H211<k)//第11个512*512 
						error_count211[512+H211-k]<=0;
					else
						error_count211[H211-k]<=0;
		
					if(H212<k)//第12个512*512 
						error_count212[512+H212-k]<=0;
					else
						error_count212[H212-k]<=0;	
					
					if(H213<k)//第13个512*512  
						error_count213[512+H213-k]<=0;
					else
						error_count213[H213-k]<=0;
					
					if(H214<k)//第14个512*512 
						error_count214[512+H214-k]<=0;
					else
						error_count214[H214-k]<=0;
						
					if(H215<k)//第15个512*512 
						error_count215[512+H215-k]<=0;
					else
						error_count215[H215-k]<=0;
						
					if(H216<k)//第16个512*512 
						error_count216[512+H216-k]<=0;
					else
						error_count216[H216-k]<=0;
						
					if(H217>k)//第17个512*512 第145个元素 
						error_count216[512+H217-k]<=0;
					else
						error_count216[H217-k]<=0;
						
					if(H218<k)//第18个512*512 
						error_count218[512+H218-k]<=0;
					else
						error_count218[H218-k]<=0;	
				end
	        end
       FIX2:begin//若有错误次数2次，先反转
				if(error_count11[k]&&error_count21[k])begin
					flash_data1[k]<=~flash_data1[k];
					one_loop_over1[k]<=1;
				end
				else begin
					flash_data1[k]<=flash_data1[k];
					one_loop_over1[k]<=0;
				end
				
				if(error_count12[k]&&error_count22[k])begin
					flash_data2[k]<=~flash_data2[k];
					one_loop_over2[k]<=1;
				end
				else begin
					flash_data2[k]<=flash_data2[k];
					one_loop_over2[k]<=0;
				end
				
				if(error_count13[k]&&error_count23[k])begin
					flash_data3[k]<=~flash_data3[k];
					one_loop_over3[k]<=1;
				end
				else begin
					flash_data3[k]<=flash_data3[k];
					one_loop_over3[k]<=0;
				end
				
				if(error_count14[k]&&error_count24[k])begin
					flash_data4[k]<=~flash_data4[k];
					one_loop_over4[k]<=1;
				end
				else begin
					flash_data4[k]<=flash_data4[k];
					one_loop_over4[k]<=0;
				end
				
				if(error_count15[k]&&error_count25[k])begin
					flash_data5[k]<=~flash_data5[k];
					one_loop_over5[k]<=1;
				end
				else begin
					flash_data5[k]<=flash_data5[k];
					one_loop_over5[k]<=0;
				end
				
				if(error_count16[k]&&error_count26[k])begin
					flash_data6[k]<=~flash_data6[k];
					one_loop_over6[k]<=1;
				end
				else begin
					flash_data6[k]<=flash_data6[k];
					one_loop_over6[k]<=0;
				end
				
				if(error_count17[k]&&error_count27[k])begin
					flash_data7[k]<=~flash_data7[k];
					one_loop_over7[k]<=1;
				end
				else begin
					flash_data7[k]<=flash_data7[k];
					one_loop_over7[k]<=0;
				end
				
				if(error_count18[k]&&error_count28[k])begin
					flash_data8[k]<=~flash_data8[k];
					one_loop_over8[k]<=1;
				end
				else begin
					flash_data8[k]<=flash_data8[k];
					one_loop_over8[k]<=0;
				end
				
				if(error_count19[k]&&error_count29[k])begin
					flash_data9[k]<=~flash_data9[k];
					one_loop_over9[k]<=1;
				end
				else begin
					flash_data9[k]<=flash_data9[k];
					one_loop_over9[k]<=0;
				end
				
				if(error_count110[k]&&error_count210[k])begin
					flash_data10[k]<=~flash_data10[k];
					one_loop_over10[k]<=1;
				end
				else begin
					flash_data10[k]<=flash_data10[k];
					one_loop_over10[k]<=0;
				end
				
				if(error_count111[k]&&error_count211[k])begin
					flash_data11[k]<=~flash_data11[k];
					one_loop_over11[k]<=1;
				end
				else begin
					flash_data11[k]<=flash_data11[k];
					one_loop_over11[k]<=0;
				end
				
				if(error_count112[k]&&error_count212[k])begin
					flash_data12[k]<=~flash_data12[k];
					one_loop_over12[k]<=1;
				end
				else begin
					flash_data12[k]<=flash_data12[k];
					one_loop_over12[k]<=0;
				end
		
				if(error_count113[k]&&error_count213[k])begin
					flash_data13[k]<=~flash_data13[k];
					one_loop_over13[k]<=1;
				end
				else begin
					flash_data13[k]<=flash_data13[k];
					one_loop_over13[k]<=0;
				end
				
				if(error_count114[k]&&error_count214[k])begin
					flash_data14[k]<=~flash_data14[k];
					one_loop_over14[k]<=1;
				end
				else begin
					flash_data14[k]<=flash_data14[k];
					one_loop_over14[k]<=0;
				end
				
				if(error_count115[k]&&error_count215[k])begin
					flash_data15[k]<=~flash_data15[k];
					one_loop_over15[k]<=1;
				end
				else begin
					flash_data15[k]<=flash_data15[k];
					one_loop_over15[k]<=0;
				end
				
				if(error_count116[k]&&error_count216[k])begin
					flash_data16[k]<=~flash_data16[k];
					one_loop_over16[k]<=1;
				end
				else begin
					flash_data16[k]<=flash_data16[k];
					one_loop_over16[k]<=0;
				end
				
				if(error_count117[k]&&error_count217[k])begin
					flash_data17[k]<=~flash_data17[k];
					one_loop_over17[k]<=1;
				end
				else begin
					flash_data17[k]<=flash_data17[k];
					one_loop_over17[k]<=0;
				end
				
				if(error_count118[k]&&error_count218[k])begin
					flash_data18[k]<=~flash_data18[k];
					one_loop_over18[k]<=1;
				end
				else begin
					flash_data18[k]<=flash_data18[k];
					one_loop_over18[k]<=0;
				end
	        end
//	   FIX3:begin//只有1次的
//				if(error_count11[k]||error_count21[k])
//					flash_data1[k]<=~flash_data1[k];
//				else 
//					flash_data1[k]<=flash_data1[k];
//				
//				if(error_count12[k]||error_count22[k])
//					flash_data2[k]<=~flash_data2[k];
//				
//				else 
//					flash_data2[k]<=flash_data2[k];
//					
//				
//				if(error_count13[k]||error_count23[k])
//					flash_data3[k]<=~flash_data3[k];
//				
//				else 
//					flash_data3[k]<=flash_data3[k];
//					
//				
//				if(error_count14[k]||error_count24[k])
//					flash_data4[k]<=~flash_data4[k];
//					
//				else 
//					flash_data4[k]<=flash_data4[k];
//				
//				
//				if(error_count15[k]||error_count25[k])
//					flash_data5[k]<=~flash_data5[k];
//					
//				else 
//					flash_data5[k]<=flash_data5[k];
//					
//				
//				if(error_count16[k]||error_count26[k])
//					flash_data6[k]<=~flash_data6[k];
//					
//				else 
//					flash_data6[k]<=flash_data6[k];
//					
//				
//				if(error_count17[k]||error_count27[k])
//					flash_data7[k]<=~flash_data7[k];
//					
//				else 
//					flash_data7[k]<=flash_data7[k];
//					
//				
//				if(error_count18[k]||error_count28[k])
//					flash_data8[k]<=~flash_data8[k];
//					
//				else 
//					flash_data8[k]<=flash_data8[k];
//					
//				
//				if(error_count19[k]||error_count29[k])
//					flash_data9[k]<=~flash_data9[k];
//				
//				else 
//					flash_data9[k]<=flash_data9[k];
//					
//				
//				if(error_count110[k]||error_count210[k])
//					flash_data10[k]<=~flash_data10[k];
//					
//				else 
//					flash_data10[k]<=flash_data10[k];
//					
//				
//				if(error_count111[k]||error_count211[k])
//					flash_data11[k]<=~flash_data11[k];
//				
//				else 
//					flash_data11[k]<=flash_data11[k];
//				
//				
//				if(error_count112[k]||error_count212[k])
//					flash_data12[k]<=~flash_data12[k];
//					
//				else 
//					flash_data12[k]<=flash_data12[k];
//				
//	
//				if(error_count113[k]||error_count213[k])
//					flash_data13[k]<=~flash_data13[k];
//					
//				else
//					flash_data13[k]<=flash_data13[k];
//					
//				
//				if(error_count114[k]||error_count214[k])
//					flash_data14[k]<=~flash_data14[k];
//					
//				else 
//					flash_data14[k]<=flash_data14[k];
//				
//				
//				if(error_count115[k]||error_count215[k])
//					flash_data15[k]<=~flash_data15[k];
//					
//				else 
//					flash_data15[k]<=flash_data15[k];
//				
//				
//				if(error_count116[k]||error_count216[k])
//					flash_data16[k]<=~flash_data16[k];
//					
//				else 
//					flash_data16[k]<=flash_data16[k];
//					
//				
//				if(error_count117[k]||error_count217[k])
//					flash_data17[k]<=~flash_data17[k];
//				
//				else 
//					flash_data17[k]<=flash_data17[k];
//				
//				
//				if(error_count118[k]||error_count218[k])
//					flash_data18[k]<=~flash_data18[k];
//					
//				else
//					flash_data18[k]<=flash_data18[k];
//		    end	
	    endcase
    end
end
end
endgenerate


H_matrix u_H_matrix(
.clk(clk),
.rst_n(rst_n),
.H1({H11,H12,H13,H14,H15,H16,H17,H18,H19,H110,H111,H112,H113,H114,H115,H116,H117,H118}),
.H2({H21,H22,H23,H24,H25,H26,H27,H28,H29,H210,H211,H212,H213,H214,H215,H216,H217,H218})
);

endmodule



	


	
