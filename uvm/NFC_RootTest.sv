//NAND Flash Controller Root_Test
//
//Project engineer: Xiaodong Liu
//Data: 16-Mar-2020
//
//Discription:
//
//-----------------------------------------------------------

`include "NFC_Initiator.sv"
`include "NFC_Interface.sv"
`include "NFC_Checker.sv"

class NFC_RootTest;
	NFC_Generator gen;
	NFC_Initiator init;
	NFC_Monitor mon;
	NFC_Checker chker;
	protected string name;
	
	function new(string name = "NFC_Root_Test");
		this.name = name;
		this.gen = new();
		this.init = new();
		this.mon = new();	
		this.chker = new();	
		this.init.req_mb = this.gen.req_mb;
		this.init.rsp_mb = this.gen.rsp_mb;
		this.init.sgn_req_mb = this.gen.sgn_req_mb;
		this.init.sgn_rsp_mb = this.gen.sgn_rsp_mb;
		this.mon.mon_mb = this.chker.mon_mb;
   endfunction
	
	virtual task run();
		$display("**************%s started**************",this.name);
		this.do_config();
		fork
			gen.run();
			init.run();	
			mon.run();
			chker.run();
		join_none
	endtask
	
	virtual function void set_interface(virtual NFC_Interface vif);
		init.set_interface(vif);
		mon.set_interface(vif);
		$display("NRT:finish set interface");
	endfunction
	
	virtual function void do_config();
	endfunction
	
endclass:NFC_RootTest