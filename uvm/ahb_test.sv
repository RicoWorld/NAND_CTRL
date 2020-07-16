//NAND Flash Controller Root_Test
//
//Project engineer: Xiaodong Liu
//Data: 6-Apr-2020
//
//Discription:
//
//-----------------------------------------------------------

`include "NFC_RootTest.sv"

class ahb_test extends NFC_RootTest;
    virtual function void do_config();
		 assert(gen.randomize()with{nBurst==8;//nBurst是发送burst的数目
		                            size_test     ==`WORD;//size_test是发送的数据大小、步长。
									                 //WORD是32bit,HALFWORD是16bit，BYTE是8bit。
									ecc_enable    == 1'b1;//ecc使能信号     (1'b1:ON   ; 1’b0:off   )
									page_mode     == 1'b1;//大小页模式       (1'b1:大页 ; 1'b0:小页  )
									transfer_mode == 1'b1;//传输协议模式 (1'b1:ONFI ; 1'b0:toggle)
									row_length    == 1'b0;//row地址的长度(1'b1:3byte; 1'b0:2byte )
									cmd_list[0]==`READ_ID; //从以下操作中选择需要的操作，按执行顺序赋值
									cmd_list[1]==`PROGRAM_PAGE; // `READ_STATE
									cmd_list[2]==`PAGE_READ; // `PROGRAM_PAGE
									cmd_list[3]==`READ_STATE; // `READ_ID
									cmd_list[4]==`READ_ID; // `RESET
									cmd_list[5]==`IDLE; // `IDLE：读取主控逻辑的状态，用于闲时进行
									cmd_list[6]==`IDLE; // `PAGE_READ
									cmd_list[7]==`BLOCK_ERASE;
									})
		 
		 else $display("GEN randomization failure!");	 
	 endfunction
endclass
