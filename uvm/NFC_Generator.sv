//NAND Flash Controller Generator
//
//Project engineer: Xiaodong Liu
//Data: 29-Feb-2020
//
//Discription:
//Generator is used to send transaction to NFC_Generator.
`include "NFC_Transaction.sv"

class NFC_Generator; 

	NFC_Transaction temp,req,rsp,sgn_req;
	mailbox #(NFC_Transaction) req_mb;
	mailbox #(NFC_Transaction) rsp_mb;
	mailbox #(NFC_Transaction) sgn_req_mb;
	mailbox #(NFC_Transaction) sgn_rsp_mb;
	
	rand int nBurst = 100;//burst的数量
	     int times  = 10; //一个read读times个data
	     int i = 0;       //计数
		 int h = 0;       //地址步长
		 int c = 0;       //cmd list的顺序
    rand logic[2:0]  size_test;
	rand logic       transfer_mode;
	rand logic       page_mode;
	rand logic       ecc_enable;
	rand logic[31:0] cmd_list[7:0];
	     logic[1:0]  status; // status={HRESP , HREADY}
	     logic[31:0] addr;   //address's parameter
		 logic[31:0] cmd;
	     event val,okay,free;
	function new();
	  this.req_mb = new();
      this.rsp_mb = new();
	  this.sgn_req_mb = new();
      this.sgn_rsp_mb = new();
	endfunction
	
	constraint c1{
	   nBurst < 10000;
	   nBurst > 0;
	}
	
	task run();	
		fork		  
		  begin
			do_config();
			repeat(nBurst)
			  begin
			    cmd = cmd_list[c];
			    send_trans();
				c=c+1;
			  end
			do_finish();
		  end
		  ready();
		join
	endtask
	
	task do_config();
        $display("GEN:  start to config NFC");		
		this.temp = new();
	    this.temp.HSEL   = 1'b1;
		this.temp.HWRITE = 1'b1;
		this.temp.HSIZE  = `WORD;
		this.temp.HBURST = `SINGLE;
		this.temp.HTRANS = `NONSEQ;
	    this.temp.HADDR  = 32'h00000510;
		this.temp.HWDATA = `RESET;
		JudgeAndDrive();		
	    this.temp.HSEL   = 1'b1;
		this.temp.HWRITE = 1'b1;
		this.temp.HSIZE  = `WORD;
		this.temp.HBURST = `SINGLE;
		this.temp.HTRANS = `NONSEQ;
	    this.temp.HADDR  = 32'h00000500;
		this.temp.HWDATA = 32'h000A000A;
		JudgeAndDrive();		
	    this.temp.HSEL   = 1'b1;
		this.temp.HWRITE = 1'b1;
		this.temp.HSIZE  = `WORD;
		this.temp.HBURST = `SINGLE;
		this.temp.HTRANS = `NONSEQ;
	    this.temp.HADDR  = 32'h0000050C;
		this.temp.HWDATA = {29'b0,transfer_mode,page_mode,ecc_enable};
		JudgeAndDrive();
	endtask
	
	task send_trans();		
		this.temp = new();
	    $display("GEN:  start a burst");
	/*	std::randomize(cmd)with{cmd inside {`PAGE_READ
	                                       ,`BLOCK_ERASE
				                           ,`READ_STATE
										   ,`PROGRAM_PAGE
										   ,`READ_ID
										   ,`RESET
										   ,`IDLE
										   };
						        };
	*/	case(cmd)
		  `PAGE_READ:this.page_read_t();
		  `BLOCK_ERASE:this.block_erase_t();
		  `READ_STATE:this.read_state_t();
		  `PROGRAM_PAGE:this.program_page_t();
		  `READ_ID:this.read_id_t();
		  `RESET:this.reset_t();
		  `IDLE:this.idle_t();
		  default:$error("GEN:  error cmd");
		endcase
	endtask	
	
	task page_read_t();
		idle_t();
	    $display("---------------------------------------------------------PAGE_READ");
	    //send “page read” cmd
	    this.temp.HSEL   = 1'b1;
		this.temp.HWRITE = 1'b1;
		//std::randomize(this.temp.HSIZE)with{this.temp.HSIZE inside {`BYTE,`HALFWORD,`WORD};};//方案1随机产生SIZE
		this.temp.HSIZE = size_test;//方案2 在test例化里面选定SIZE
		this.temp.HBURST = `SINGLE;
		this.temp.HTRANS = `NONSEQ;
		this.temp.HADDR  = 32'h00000504;//colume address
		case(this.temp.HSIZE)
		    `BYTE:     addr = {$random}%511;
			`HALFWORD: addr = 2*({$random}%255);
			`WORD:     addr = 4*({$random}%127);
			default:$display("GEN:  error temp.HSIZE");
		endcase
		addr = 32'h0000_03BF;//页内首地址固定（samsung：32'h0;micron:32'h0000_03BF=959）
		this.temp.HWDATA = addr;
		JudgeAndDrive();
		this.temp.HADDR  = 32'h00000508;//row address
		//this.temp.HWDATA = {$random}%(32*4096-1);//行地址随机（samsung：<32*4096-1;micron:<64,000）
		this.temp.HWDATA = 4000;//行地址固定4000
		JudgeAndDrive();
		this.temp.HADDR  = 32'h00000510;
		this.temp.HWDATA = `PAGE_READ;
		JudgeAndDrive();
		//config parameter
	    this.temp.HSEL   = 1'b1;
		this.temp.HWRITE = 1'b0;
		this.temp.HBURST = `INCR;
		this.temp.HWDATA = 32'h0;
		case(this.temp.HSIZE)
		    `BYTE:h=1;
			`HALFWORD:h=2;
			`WORD:h=4;
			default:$display("GEN:  error temp.HSIZE");
		endcase
		times=(512-addr)/h;//一个read读times个data（samsung：512;micron:1024）
		//start to read
		for(i=0;i<times;i++)begin
		    @(val);
			if(i==0)temp.HTRANS = `NONSEQ;
			else temp.HTRANS = `SEQ;
			case(this.status)
			2'b00:begin
			          @(okay);
				      temp.HADDR = addr;
					  drive();	
                      addr = addr + h;
				  end
			2'b01:begin
					  temp.HADDR = addr;
					  drive();	
                      addr = addr + h;
					end
			2'b10:begin
					  i = times;
					end
			2'b11:begin	       
			          temp.HTRANS = `IDLE;
					  i = i-1;
					  drive();					  
			      end
			default:begin
					@(okay);
                    i=i-1;					
					end
		    endcase
		end
	endtask
	
	task block_erase_t();
		idle_t();
	    $display("---------------------------------------------------------BLOCK_ERASE");
	    this.temp.HSEL=1'b1;
		this.temp.HWRITE = 1'b1;
		this.temp.HSIZE  = `WORD;
		this.temp.HBURST = `SINGLE;
		this.temp.HTRANS = `NONSEQ;
	    this.temp.HADDR  = 32'h00000508;
		this.temp.HWDATA = 4000;//固定快擦除的行地址
		JudgeAndDrive();
	    this.temp.HADDR  = 32'h00000510;
		this.temp.HWDATA = `BLOCK_ERASE;
		JudgeAndDrive();
	endtask
	
	task read_state_t();
		idle_t();
	    $display("---------------------------------------------------------READ_STATE");
	    this.temp.HSEL=1'b1;
		this.temp.HWRITE = 1'b1;
		this.temp.HSIZE  = `WORD;
		this.temp.HBURST = `SINGLE;
		this.temp.HTRANS = `NONSEQ;
	    this.temp.HADDR = 32'h00000510;
		this.temp.HWDATA=`READ_STATE;
		JudgeAndDrive();
	    this.temp.HADDR = 32'h0000051C;
		this.temp.HWDATA= 32'h00000000;
		JudgeAndDrive();
	endtask
	
	task program_page_t();
		idle_t();
	    $display("---------------------------------------------------------PROGRAM_PAGE");
	    //send “page read” cmd
	    this.temp.HSEL   = 1'b1;
		this.temp.HWRITE = 1'b1;
		//std::randomize(this.temp.HSIZE)with{this.temp.HSIZE inside {`BYTE,`HALFWORD,`WORD};};//方案1随机产生SIZE
		this.temp.HSIZE = size_test;//方案2 在test例化里面选定SIZE
		this.temp.HBURST = `SINGLE;
		this.temp.HTRANS = `NONSEQ;
		this.temp.HADDR  = 32'h00000504;//colume address
		case(this.temp.HSIZE)
		    `BYTE:     addr = {$random}%511;
			`HALFWORD: addr = 2*({$random}%255);
			`WORD:     addr = 4*({$random}%127);
			default:$display("GEN:  error temp.HSIZE");
		endcase
		addr = 32'h0000_03BF;//页内首地址固定
		this.temp.HWDATA = addr;
		JudgeAndDrive();
		this.temp.HADDR  = 32'h00000508;//row address
		//this.temp.HWDATA = {$random}%(32*4096-1);//行地址随机
		this.temp.HWDATA = 4000;//行地址固定
		JudgeAndDrive();
		this.temp.HADDR  = 32'h00000510;
		this.temp.HWDATA = `PROGRAM_PAGE;
		JudgeAndDrive();
		//config parameter
		this.temp.HSEL   = 1'b1;
		this.temp.HWRITE = 1'b1;
		this.temp.HBURST = `INCR;
		case(this.temp.HSIZE)
		    `BYTE:h=1;
			`HALFWORD:h=2;
			`WORD:h=4;
			default:$display("GEN:  error temp.HSIZE");
		endcase
		times=(1024-addr)/h;//一个write写times个data
		//start to read
		for(i=0;i<times;i++)begin
		    @(val);
			if(i==0)temp.HTRANS = `NONSEQ;
			else temp.HTRANS = `SEQ;
			case(this.status)
			2'b00:begin
			          @(okay);
				      temp.HADDR = addr;
					  case(this.temp.HSIZE)
		                `BYTE:temp.HWDATA = {$random}%255;
			            `HALFWORD:temp.HWDATA = {$random}%65535;
			            `WORD:temp.HWDATA = {$random}%4294967295;
			            default:$display("GEN:  error temp.HSIZE");
		              endcase					  
					  drive();	
                      addr = addr + h;
				  end
			2'b01:begin
					  temp.HADDR = addr;
					  case(this.temp.HSIZE)
		                `BYTE:temp.HWDATA = {$random}%255;
			            `HALFWORD:temp.HWDATA = {$random}%65535;
			            `WORD:temp.HWDATA = {$random}%4294967295;
			            default:$display("GEN:  error temp.HSIZE");
		              endcase
					  drive();	
                      addr = addr + h;
					end
			2'b10:begin
					  i = times;
					end
			2'b11:begin	       
			          temp.HTRANS = `IDLE;
					  i = i-1;
					  drive();				  
			      end
			default:begin
			        $display("GEN:  fail to judge last status");	
					@(okay);
					$display("GEN:  get okay");
                    i=i-1;					
					end
		    endcase
		end
	endtask
	
	task read_id_t();//从0514寄存器读ID
		idle_t();
	    $display("---------------------------------------------------------READ_ID");
	    this.temp.HSEL=1'b1;
		this.temp.HWRITE = 1'b1;
		this.temp.HSIZE  = `WORD;
		this.temp.HBURST = `SINGLE;
		this.temp.HTRANS = `NONSEQ;
	    this.temp.HADDR=32'h00000510;
		this.temp.HWDATA=`READ_ID;
		JudgeAndDrive();
	    this.temp.HADDR=32'h00000514;
		this.temp.HWDATA= 32'h00000000;
		JudgeAndDrive();
	endtask
	
	task reset_t();
		idle_t();
	    $display("---------------------------------------------------------RESET");
	    this.temp.HSEL=1'b1;
		this.temp.HWRITE = 1'b1;
		this.temp.HSIZE  = `WORD;
		this.temp.HBURST = `SINGLE;
		this.temp.HTRANS = `NONSEQ;
	    this.temp.HADDR=32'h00000510;
		this.temp.HWDATA=`RESET;
		JudgeAndDrive();
	endtask
	
	task idle_t();
	    $display("---------------------------------------------------------IDLE");
		this.temp.HSEL   = 1'b1;
		this.temp.HWRITE = 1'b0;
		this.temp.HSIZE  = `WORD;
		this.temp.HBURST = `SINGLE;
		this.temp.HTRANS = `NONSEQ;
	    this.temp.HADDR  = 32'h00000520;
		this.temp.HWDATA = 32'h00000000;
		JudgeAndDrive();
		@(free);
	endtask

	task drive();//generator将transaction发送给initiator
		this.req = new();
		this.req = temp.clone();
		this.req_mb.put(this.req);
        this.rsp_mb.get(this.rsp);
	endtask
	
	task ready();//这个任务是将sgn_req信号传给generator。sgn_req这个信号是用来告诉generator，此时的HREADY和HRESP是什么状态
	  forever begin
	    NFC_Transaction sgn_rsp = new();
		this.sgn_req_mb.get(this.sgn_req);
		sgn_rsp.rsp = 1;
		this.sgn_rsp_mb.put(sgn_rsp);
		this.status = {this.sgn_req.HRESP,this.sgn_req.HREADY};
		if(this.sgn_req.HRDATA==0)->free;
		#1;		
		->val;
		if(this.status==2'b01)->okay;
	  end 
	endtask
		
	task JudgeAndDrive();
	@(val);	
	case(this.status)
	2'b00:begin
			@(okay);
			drive();
		  end
    2'b01:begin
			drive();	
		  end
	2'b10:begin
			//$display("GEN:  status is error1");
			//$display("GEN:  finish error1");
		  end
	2'b11:begin		
            //$display("GEN:  status is error1");			
			//$display("GEN:  finish error1");		
		  end
    default:begin
			  @(okay);
			end
	endcase
	endtask
	
	task do_finish();	
	    this.temp.HSEL   = 1'b0;
		this.temp.HWRITE = 1'b0;
		this.temp.HSIZE  = 0;
		this.temp.HBURST = 0;
		this.temp.HTRANS = 0;
	    this.temp.HADDR  = 0;
		this.temp.HWDATA = 0;
		JudgeAndDrive();		
	endtask
	
endclass:NFC_Generator
	