//NAND Flash Controller Monitor
//
//Project engineer: Xiaodong Liu
//Data: 8-Mar-2020
//
//Discription:
//
//-----------------------------------------------------------
`define PAGE_READ    32'h00000030
`define PROGRAM_PAGE 32'h00008010
`define ini_mon intf//.Mon_ck 

  typedef struct packed {
    logic              cmd;//1:write  0:read
	logic[19:0]        row_addr;
	logic[11:0]        col_addr;	
	logic[31:0]        addr;
    logic[31:0]        data;
	logic              cmp_end;
  } mon_data;
 
class NFC_Monitor;
    local virtual NFC_Interface intf;
    mailbox #(mon_data) mon_mb;
    local int i = 0;
    local int k = 0;
	logic[31:0] addr1;

    function void set_interface(virtual NFC_Interface intf);
      if(intf == null)
        $error("Ini_Monitor's interface handle is NULL, please check if target interface has been intantiated");
      else
        this.intf = intf;
    endfunction	 
	 	 
    task run();
	  $display("MON:running");
      this.mon_trans();
    endtask

    task mon_trans();
      mon_data m;
	  fork
	    forever
	      begin		 
            @(posedge this.intf.HCLK);
			if(this.intf.HADDR == 32'h00000804)	 
			begin
              @(posedge this.intf.HCLK);
			  m.col_addr = this.intf.HWDATA;
              @(posedge this.intf.HCLK);
			  m.row_addr = this.intf.HWDATA;  
	          $display("MON:504 %h, 508 = %h",m.col_addr,m.row_addr);
			end
		  end
        forever 
	      begin
            @(posedge this.intf.HCLK );		  
		    if((addr1 == 32'h00000810)&&((this.intf.HWDATA == `PROGRAM_PAGE)||(this.intf.HWDATA == `PAGE_READ)))
		      begin	 
			    addr1 = this.intf.HADDR;
                if(this.intf.HWDATA == `PROGRAM_PAGE)m.cmd = 1'b1;
                else m.cmd = 1'b0; 		
                m.cmp_end = 1'b0;							
		        for(i=0;i<2;i++)  
		          begin
		            @(posedge this.intf.HCLK iff(this.intf.HREADY == 1'b1));
		            if(this.intf.HADDR == 32'h00000820)
					  begin
			            m.addr = addr1;
						if(m.cmd == 1'b1)
			  	          m.data = this.intf.HWDATA;
						else
			  	          m.data = this.intf.HRDATA;	
                        m.cmp_end = 1;						  
			            mon_mb.put(m);
			            i = 2;
					  end
			        else
			          begin
			            m.addr = addr1;
						if(m.cmd == 1'b1)
			  	          m.data = this.intf.HWDATA;
						else
			  	          m.data = this.intf.HRDATA;	
			            mon_mb.put(m);
				        i=i-1;
			          end 
			        addr1 = this.intf.HADDR;	
		          end
		      end
			else addr1 = this.intf.HADDR;
          end
      join
    endtask
endclass:NFC_Monitor
