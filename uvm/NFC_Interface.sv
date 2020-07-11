//NAND Flash Controller NFC_Interface
//
//Project engineer: Xiaodong Liu
//Data: 4-Mar-2020
//
//Discription:
//
//-----------------------------------------------------------
`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//                                        NFC_Interface 
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
interface NFC_Interface(input HCLK,input HRESET);
	//Address and control
	logic       HSEL;
	logic[31:0] HADDR;
	logic       HWRITE;
	logic[2:0]  HSIZE;
	logic[2:0]  HBURST;
	logic[3:0]  HPROT;
	logic[1:0]  HTRANS;
	logic       HMASTLOCK;
	//Data
    logic[31:0] HWDATA; 
	logic[31:0] HRDATA;	
	//Respond
	logic HREADY;
	logic HRESP;
	
	/*
	clocking Dri_ck @(posedge HCLK);
		default input #1 output #1; 
		
		input HREADY;
		input HRESP;
		input HRDATA;
		
		output HSEL;
		output HADDR;
		output HWRITE;
		output HSIZE;
		output HBURST;
		output HPROT;
		output HTRANS;
		output HMASTLOCK;
		output HWDATA;
		output tran_valid;
		output mon_get;
		
	endclocking	
	
	clocking Mon_ck @(posedge HCLK);
		default input #1 output #1; 
		
		input HSEL;
		input HREADY;
		input HRESP;
		input HRDATA;
		input HADDR;
		input HWRITE;
		input HSIZE;
		input HBURST;
		input HPROT;
		input HTRANS;
		input HMASTLOCK;
		input HWDATA;
		input tran_valid;
		inout mon_get;
		
	endclocking	
	
	*/
endinterface:NFC_Interface
