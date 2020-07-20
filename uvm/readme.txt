This part is the verification envirment of our project.

The following is how to use it to verify.

The variables that can be modified are:
(1)ahb_test.sv
	 size_test：size_test是发送的数据大小、步长。 你可以选择以下数据大小：WORD是32bit,HALF WORD是16bit，BYTE是8bit。
	 ecc_enable：ecc使能信号        (1'b1:ON    ; 1’b0:off   )
	 page_mode：大小页模式         (1'b1:大页  ; 1'b0:小页    )
	 transfer_mode：传输协议模式  (1'b1:ONFI ; 1'b0:toggle)
	 row_length：row地址的长度    (1'b1:3byte ; 1'b0:2byte )
	 cmd_list[8]：从以下操作中选择需要的操作，按执行顺序赋值。`READ_STATE,   `PROGRAM_PAGE,  `READ_ID,   `RESET,   `IDLE,  `PAGE_READ
(2)tb.sv
	 fault_injectio()：控制错误的注入。它发生在读页操作之前。    									
                           repeat()里面的数字，代表了错误注入的个数。
                           fault_byte_addr：它代表了错误注入的地址（byte为单位），我将它分成打开ECC和关闭ECC两种情况。注意：这里的写页操作仅发生在flash模块的第4000页。
                                    如果打开ECC，错误注入的地址是16384896~16385919~16386047；//信息位+校验位
                                    如果关闭ECC，错误注入的地址是16385024~16386047。//仅信息位
                                    具体修改的格式如下：min+{$random}%(max-min+1) 代表从min到max的随机化数据。提交的代码中只取了信息位1024byte的前512byte进行错误注入，如需要对整体码字进行错误注入试验，可自行修改。

注意：(1)进行错误注入时，只能在ONFI模式下进行，因为只有ONFI模式对应的flash模型的页大小，可以支持题目要求的ECC位宽。
