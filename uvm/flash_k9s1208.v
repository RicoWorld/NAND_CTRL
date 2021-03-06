
//////////////////////////////////////////////////////////////////////////////
//  File name : k9s1208.v
//////////////////////////////////////////////////////////////////////////////
//  Copyright (C) 2004 Free Model Foundry; http://www.FreeModelFoundry.com
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation.
//
//  MODIFICATION HISTORY:
//
//  version: | author:    | mod date: | changes made:
//  V1.0      T.Popovic     04 Sep 29   Initial Release
//////////////////////////////////////////////////////////////////////////////
//  PART DESCRIPTION:
//
//  Library:     FLASH
//  Technology:  FLASH MEMORY
//  Part:        K9S1208
//
//  Description: 64 MB SmartMedia Card
//
//////////////////////////////////////////////////////////////////////////////
//  Known Bugs:
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// MODULE DECLARATION                                                       //
//////////////////////////////////////////////////////////////////////////////
`timescale 1 ns/1 ns

module k9s1208
 (
    IO7     ,
    IO6     ,
    IO5     ,
    IO4     ,
    IO3     ,
    IO2     ,
    IO1     ,
    IO0     ,

    CLE     ,
    ALE     ,
    CENeg   ,
    RENeg   ,
    WENeg   ,
    WPNeg   ,
    R
 );

////////////////////////////////////////////////////////////////////////
// Port / Part Pin Declarations
////////////////////////////////////////////////////////////////////////

    inout  IO7  ;
    inout  IO6  ;
    inout  IO5  ;
    inout  IO4  ;
    inout  IO3  ;
    inout  IO2  ;
    inout  IO1  ;
    inout  IO0  ;

    input  CLE     ;
    input  ALE     ;
    input  CENeg   ;
    input  RENeg   ;
    input  WENeg   ;
    input  WPNeg   ;
    output R       ;

// interconnect path delay signals

    wire  IO7_ipd  ;
    wire  IO6_ipd  ;
    wire  IO5_ipd  ;
    wire  IO4_ipd  ;
    wire  IO3_ipd  ;
    wire  IO2_ipd  ;
    wire  IO1_ipd  ;
    wire  IO0_ipd  ;

    wire [7 : 0] A;
    assign A = {IO7_ipd,
                IO6_ipd,
                IO5_ipd,
                IO4_ipd,
                IO3_ipd,
                IO2_ipd,
                IO1_ipd,
                IO0_ipd };

    wire [7 : 0 ] DIn;
    assign DIn = {IO7_ipd,
                  IO6_ipd,
                  IO5_ipd,
                  IO4_ipd,
                  IO3_ipd,
                  IO2_ipd,
                  IO1_ipd,
                  IO0_ipd };

    wire [7 : 0 ] DOut;
    assign DOut = {IO7,
                   IO6,
                   IO5,
                   IO4,
                   IO3,
                   IO2,
                   IO1,
                   IO0 };

    wire  CLE_ipd     ;
    wire  ALE_ipd     ;
    wire  CENeg_ipd   ;
    wire  RENeg_ipd   ;
    wire  WENeg_ipd   ;
    wire  WPNeg_ipd   ;

//  internal delays

    reg PROG_in         ;
    reg PROG_out        ;
    reg BERS_in         ;
    reg BERS_out        ;
    reg DBSY_in         ;
    reg DBSY_out        ;
    reg TR_in           ;
    reg TR_out          ;

    reg [7 : 0] DOut_zd;

    wire  IO7_Pass   ;
    wire  IO6_Pass   ;
    wire  IO5_Pass   ;
    wire  IO4_Pass   ;
    wire  IO3_Pass   ;
    wire  IO2_Pass   ;
    wire  IO1_Pass   ;
    wire  IO0_Pass   ;

    reg [7 : 0] DOut_Pass;
    assign {IO7_Pass,
            IO6_Pass,
            IO5_Pass,
            IO4_Pass,
            IO3_Pass,
            IO2_Pass,
            IO1_Pass,
            IO0_Pass  } = DOut_Pass;

    reg R_zd = 1'b0;

    parameter mem_file_name   = "none";
    parameter spare_file_name = "none";
    parameter UserPreload     = 1'b0;
    parameter TimingModel     = "DefaultTimingModel";

    parameter PartID         = "k9s1208";
    parameter MaxData        = 8'hFF;
    parameter BlockNum       = 4095;
    parameter BlockSize      = 31;
    parameter PageNum        = 20'h1FFFF;
    parameter PlaneNum       = 3;
    parameter SpareSize      = 15;
    parameter PageSize       = 527;
    parameter HiAddrBit      = 26;

     // powerup
    reg PoweredUp       =1'b0;
    reg reseted         =1'b0;

    // control signals
    reg TRANSFER        =1'b0;//transfer to read buffer active
    reg INTCE           =1'b0;
    reg ERS_ACT         =1'b0;
    reg PRG_ACT         =1'b0;
    reg RSTSTART        =1'b0;
    reg RSTDONE         =1'b0;
    reg NEXT_PAGE       =1'b0;
    reg LAST_PAGE       =1'b0;

    reg write           =1'b0;
    reg read            =1'b0;

     // 8 bit Address
    integer AddrCom          ;
     // Address within page
    integer Address          ;      // 0 - Pagesize
     // Page Number
    integer PageAddr         = -1;  //-1 - PageNum
     // Block Number
    integer BlockAddr        = -1;  //-1 - BlockNum
     // Plane Number
    integer PlaneAddr        ;      //-1 - PlaneNum

     //Data
    integer Data             ;      //-1 - MaxData

    //ID control signals
    integer IDAddr           ;      // 0 - 4

         // program control signals
    integer WrBuffData[0:(PageSize+1)*3+PageSize];
    integer WrBuffStartAddr[0:3];
    integer WrBuffEndAddr[0:3];
    integer WrBuffBlock[0:3];
    integer WrBuffPage[0:3];
    reg [PlaneNum:0]  WrPlane = 0 ;
    integer WrAddr          ;     // -1  - Pagesize +1
    integer WrPage          ;     //  0  - PageNum
    integer WrCnt           =-1;  // -1  - 3

        //erase control signals
    integer ErsQueue[0:3]   ;
    reg [PlaneNum:0]  ErsPlane = 0 ;
    integer ErsCnt          = -1;//-1 - 3

        //Program count variables
    integer ProgCntMain[0:PageNum] ;
    integer ProgCntSpare[0:PageNum];

     // Mem(Page)(Address)
    integer Mem[0:(PageSize+1)*PageNum + PageSize];

    // ID Array
    integer IDArray[0:3];

    // timing check violation
    reg Viol    = 1'b0;

    // initial
    integer i,j;

    //Bus Cycle Decode
    reg[7:0] A_tmp          ;
    reg[7:0] D_tmp          ;

     //RstTime
    time duration;

    //Functional
    reg[7:0] Status         = 8'hC0;
    reg[7:0] Old_status     = 8'b0;
    reg[7:0] temp           ;
    reg oe = 1'b0;
    reg[7:0] old_bit ;
    reg[7:0] new_bit ;
    integer old_int ;
    integer new_int ;
    integer Page     ; // 0 - PageNum
    integer Blck     ; // 0 - BlockNum
    integer Plane    ; // 0 - PlaneNum

    //TPD_DATA
    time REDQ_t;
    time CEDQ_t;
    time RENeg_event;
    time CENeg_event;
    reg FROMRE;
    reg FROMCE;
    integer   REDQ_01;
    integer   CEDQ_01;
    integer   REDQz_01;
    integer   CEDQz_01;
    integer   WER_01;

    reg[7:0] TempData;

    event oe_event;

    // states
    reg [4:0] current_state;
    reg [4:0] next_state;

    reg [1:0] RD_MODE;
    reg [1:0] STATUS_MODE;

    // FSM states
    parameter IDLE          =8'h00;
    parameter RESET         =8'h01;
    parameter A0_RD         =8'h02;
    parameter A1_RD         =8'h03;
    parameter A2_RD         =8'h04;
    parameter BUFF_TR       =8'h05;
    parameter RD            =8'h06;
    parameter ID_PREL       =8'h07;
    parameter ID            =8'h08;
    parameter PREL_PRG      =8'h09;
    parameter A0_PRG        =8'h0A;
    parameter A1_PRG        =8'h0B;
    parameter A2_PRG        =8'h0C;
    parameter DATA_PRG      =8'h0D;
    parameter PGMS          =8'h0E;
    parameter DBSY          =8'h0F;
    parameter RDY_PRG       =8'h10;
    parameter PREL_ERS      =8'h11;
    parameter A1_ERS        =8'h12;
    parameter A2_ERS        =8'h13;
    parameter A3_ERS        =8'h14;
    parameter BERS_EXEC     =8'h15;

    //read mode
    parameter READ_A        =4'd0;
    parameter READ_B        =4'd1;
    parameter READ_C        =4'd2;

    //status mode
    parameter NONE          =4'd0;
    parameter STAT          =4'd1;
    parameter MULTI_PLANE   =4'd2;

///////////////////////////////////////////////////////////////////////////////
//Interconnect Path Delay Section
///////////////////////////////////////////////////////////////////////////////

    buf   (IO7_ipd , IO7 );
    buf   (IO6_ipd , IO6 );
    buf   (IO5_ipd , IO5 );
    buf   (IO4_ipd , IO4 );
    buf   (IO3_ipd , IO3 );
    buf   (IO2_ipd , IO2 );
    buf   (IO1_ipd , IO1 );
    buf   (IO0_ipd , IO0 );

    buf   (CLE_ipd      , CLE      );
    buf   (ALE_ipd      , ALE      );
    buf   (CENeg_ipd    , CENeg    );
    buf   (RENeg_ipd    , RENeg    );
    buf   (WENeg_ipd    , WENeg    );
    buf   (WPNeg_ipd    , WPNeg    );

///////////////////////////////////////////////////////////////////////////////
// Propagation  delay Section
///////////////////////////////////////////////////////////////////////////////

    nmos   (IO7  ,   IO7_Pass  , 1);
    nmos   (IO6  ,   IO6_Pass  , 1);
    nmos   (IO5  ,   IO5_Pass  , 1);
    nmos   (IO4  ,   IO4_Pass  , 1);
    nmos   (IO3  ,   IO3_Pass  , 1);
    nmos   (IO2  ,   IO2_Pass  , 1);
    nmos   (IO1  ,   IO1_Pass  , 1);
    nmos   (IO0  ,   IO0_Pass  , 1);

    nmos   (R    ,   R_zd      , 1);

    wire deg;

 // Needed for TimingChecks
 // VHDL CheckEnable Equivalent

    wire Check_IO0_WENeg;
    assign Check_IO0_WENeg    =  ~CENeg;

    wire Check_CENeg_posedge;
    assign Check_CENeg_posedge = TRANSFER;

specify

    // tipd delays: interconnect path delays , mapped to input port delays.
    // In Verilog is not necessary to declare any tipd_ delay variables,
    // they can be taken from SDF file
    // With all the other delays real delays would be taken from SDF file

    specparam       tpd_CENeg_IO0           =   1;//tcea, tchz
    specparam       tpd_RENeg_IO0           =   1;//trea, trhZ
    specparam       tpd_WENeg_R             =   1;//twb
    specparam       tpd_RENeg_R             =   1;//trb
    specparam       tpd_CENeg_R             =   1;//tcry

    //tsetup values
    specparam       tsetup_CLE_WENeg        =   1;//tcls edge \
    specparam       tsetup_CENeg_WENeg      =   1;//tcs edge \
    specparam       tsetup_ALE_WENeg        =   1;//tals edge \
    specparam       tsetup_IO0_WENeg        =   1;//tds edge /
    specparam       tsetup_ALE_RENeg        =   1;//tclr edge \
    specparam       tsetup_CLE_RENeg        =   1;//tar edge \
    specparam       tsetup_WENeg_RENeg      =   1;//twhr edge \

    //thold values
    specparam       thold_CLE_WENeg         =   1;//tclh edge /
    specparam       thold_CENeg_WENeg       =   1;//tch edge /
    specparam       thold_ALE_WENeg         =   1;//talh edge /
    specparam       thold_IO0_WENeg         =   1;//tdh edge /

    //tpw values
    specparam       tpw_WENeg_negedge       =   1;//twp
    specparam       tpw_WENeg_posedge       =   1;//twh
    specparam       tpw_RENeg_negedge       =   1;//trp
    specparam       tpw_RENeg_posedge       =   1;//treh
    specparam       tpw_CENeg_posedge       =   1;//tceh
    specparam       tperiod_WENeg           =   1;//twc
    specparam       tperiod_RENeg           =   1;//trc

    //tdevice values: values for internal delays
    // Program Operation
    specparam       tdevice_PROG            =   200000;
    //Block Erase Operation
    specparam       tdevice_BERS            =   2000000;
    //Dummy busy time
    specparam       tdevice_DBSY            =   1000;
    //Data transfer time
    specparam       tdevice_TR              =   10000;

///////////////////////////////////////////////////////////////////////////////
// Input Port  Delays  don't require Verilog description
///////////////////////////////////////////////////////////////////////////////
// Path delays                                                               //
///////////////////////////////////////////////////////////////////////////////

// specify transport delay for Data output paths
    specparam       PATHPULSE$CENeg$IO0     =   (0);
    specparam       PATHPULSE$CENeg$IO1     =   (0);
    specparam       PATHPULSE$CENeg$IO2     =   (0);
    specparam       PATHPULSE$CENeg$IO3     =   (0);
    specparam       PATHPULSE$CENeg$IO4     =   (0);
    specparam       PATHPULSE$CENeg$IO5     =   (0);
    specparam       PATHPULSE$CENeg$IO6     =   (0);
    specparam       PATHPULSE$CENeg$IO7     =   (0);

    specparam       PATHPULSE$RENeg$IO0     =   (0);
    specparam       PATHPULSE$RENeg$IO1     =   (0);
    specparam       PATHPULSE$RENeg$IO2     =   (0);
    specparam       PATHPULSE$RENeg$IO3     =   (0);
    specparam       PATHPULSE$RENeg$IO4     =   (0);
    specparam       PATHPULSE$RENeg$IO5     =   (0);
    specparam       PATHPULSE$RENeg$IO6     =   (0);
    specparam       PATHPULSE$RENeg$IO7     =   (0);

// Data ouptut paths
    if (FROMCE)
            ( CENeg => IO0 ) = tpd_CENeg_IO0;
    if (FROMCE)
            ( CENeg => IO1 ) = tpd_CENeg_IO0;
    if (FROMCE)
            ( CENeg => IO2 ) = tpd_CENeg_IO0;
    if (FROMCE)
            ( CENeg => IO3 ) = tpd_CENeg_IO0;
    if (FROMCE)
            ( CENeg => IO4 ) = tpd_CENeg_IO0;
    if (FROMCE)
            ( CENeg => IO5 ) = tpd_CENeg_IO0;
    if (FROMCE)
            ( CENeg => IO6 ) = tpd_CENeg_IO0;
    if (FROMCE)
            ( CENeg => IO7 ) = tpd_CENeg_IO0;

    if (FROMRE)
            ( RENeg => IO0 ) = tpd_RENeg_IO0;
    if (FROMRE)
            ( RENeg => IO1 ) = tpd_RENeg_IO0;
    if (FROMRE)
            ( RENeg => IO2 ) = tpd_RENeg_IO0;
    if (FROMRE)
            ( RENeg => IO3 ) = tpd_RENeg_IO0;
    if (FROMRE)
            ( RENeg => IO4 ) = tpd_RENeg_IO0;
    if (FROMRE)
            ( RENeg => IO5 ) = tpd_RENeg_IO0;
    if (FROMRE)
            ( RENeg => IO6 ) = tpd_RENeg_IO0;
    if (FROMRE)
            ( RENeg => IO7 ) = tpd_RENeg_IO0;

// R output paths
    (CENeg => R) = tpd_CENeg_R;

    if ( ~CENeg )
        ( WENeg =>  R ) = tpd_WENeg_R;

    if ( ~CENeg )
        ( RENeg =>  R ) = tpd_RENeg_R;

////////////////////////////////////////////////////////////////////////////////
// Timing Violation                                                           //
////////////////////////////////////////////////////////////////////////////////

        $setup ( IO0 ,posedge WENeg &&& Check_IO0_WENeg ,tsetup_IO0_WENeg,Viol);
        $setup ( IO1 ,posedge WENeg &&& Check_IO0_WENeg ,tsetup_IO0_WENeg,Viol);
        $setup ( IO2 ,posedge WENeg &&& Check_IO0_WENeg ,tsetup_IO0_WENeg,Viol);
        $setup ( IO3 ,posedge WENeg &&& Check_IO0_WENeg ,tsetup_IO0_WENeg,Viol);
        $setup ( IO4 ,posedge WENeg &&& Check_IO0_WENeg ,tsetup_IO0_WENeg,Viol);
        $setup ( IO5 ,posedge WENeg &&& Check_IO0_WENeg ,tsetup_IO0_WENeg,Viol);
        $setup ( IO6 ,posedge WENeg &&& Check_IO0_WENeg ,tsetup_IO0_WENeg,Viol);
        $setup ( IO7 ,posedge WENeg &&& Check_IO0_WENeg ,tsetup_IO0_WENeg,Viol);

        $hold ( posedge WENeg &&& Check_IO0_WENeg , IO0 ,thold_IO0_WENeg, Viol);
        $hold ( posedge WENeg &&& Check_IO0_WENeg , IO1 ,thold_IO0_WENeg, Viol);
        $hold ( posedge WENeg &&& Check_IO0_WENeg , IO2 ,thold_IO0_WENeg, Viol);
        $hold ( posedge WENeg &&& Check_IO0_WENeg , IO3 ,thold_IO0_WENeg, Viol);
        $hold ( posedge WENeg &&& Check_IO0_WENeg , IO4 ,thold_IO0_WENeg, Viol);
        $hold ( posedge WENeg &&& Check_IO0_WENeg , IO5 ,thold_IO0_WENeg, Viol);
        $hold ( posedge WENeg &&& Check_IO0_WENeg , IO6 ,thold_IO0_WENeg, Viol);
        $hold ( posedge WENeg &&& Check_IO0_WENeg , IO7 ,thold_IO0_WENeg, Viol);

        $setup ( CLE    ,negedge WENeg  ,tsetup_CLE_WENeg   , Viol);

        $setup ( ALE    ,negedge WENeg  ,tsetup_ALE_WENeg   , Viol);

        $setup ( CENeg  ,negedge WENeg  ,tsetup_CENeg_WENeg , Viol);

        $setup ( CLE    ,negedge RENeg  ,tsetup_CLE_RENeg   , Viol);

        $setup ( ALE    ,negedge RENeg  ,tsetup_ALE_RENeg   , Viol);

        $setup ( WENeg  ,negedge RENeg  ,tsetup_WENeg_RENeg , Viol);

        $hold  ( posedge WENeg  ,CLE    ,thold_CLE_WENeg    , Viol);

        $hold  ( posedge WENeg  ,ALE    ,thold_ALE_WENeg    , Viol);

        $hold  ( posedge WENeg  ,CENeg  ,thold_CENeg_WENeg  , Viol);

        $width (posedge CENeg &&& Check_CENeg_posedge , tpw_CENeg_posedge);
        $width (posedge WENeg                         , tpw_WENeg_posedge);
        $width (negedge WENeg                         , tpw_WENeg_negedge);
        $width (posedge RENeg                         , tpw_RENeg_posedge);
        $width (negedge RENeg                         , tpw_RENeg_negedge);
        $period(negedge WENeg                         , tperiod_WENeg);
        $period(posedge WENeg                         , tperiod_WENeg);
        $period(negedge RENeg                         , tperiod_RENeg);
        $period(posedge RENeg                         , tperiod_RENeg);

    endspecify

     //Used as wait periods
    time       poweredupT      = 1000;  // 1 us
    time       INTCET          = 100;   // 100 ns
    time       RstErsT         = 500000;// 500 us
    time       RstProgT        = 10000; // 10 us
    time       RstReadT        = 5000;  // 5 us

////////////////////////////////////////////////////////////////////////////////
// Main Behavior Block                                                        //
////////////////////////////////////////////////////////////////////////////////

 reg deq;
    //////////////////////////////////////////////////////////
    //          Output Data Gen
    //////////////////////////////////////////////////////////

   always @(DOut_zd)
   begin : OutputZGen1
        if (DOut_zd[0] === 1'bz)
        begin
            CEDQ_t = CENeg_event  + CEDQz_01;
            REDQ_t = RENeg_event  + REDQz_01;
            FROMRE = 1'b1;
            FROMCE = ((CEDQ_t < REDQ_t) && (CEDQ_t > $time)) ||(REDQ_t < $time);
            if ( ~ FROMCE)
            begin
                TempData   = DOut_zd;
                #( REDQz_01 - CEDQz_01 ) DOut_Pass  =  TempData;
            end
            else
                DOut_Pass = DOut_zd;
        end
    end

    always @(DOut_zd)
    begin : OutputGen
        if (DOut_zd[0] !== 1'bz)
        begin
            disable OutputZGen1;
            CEDQ_t = CENeg_event  + CEDQ_01;
            REDQ_t = RENeg_event  + REDQ_01;
            FROMCE = 1'b1;
            FROMRE = ((REDQ_t >= CEDQ_t) && ( REDQ_t >= $time));
            DOut_Pass = DOut_zd;
        end
    end

   always @(posedge CENeg)
   begin : OutputZGen2
        CENeg_event = $time;
        CEDQ_t = CENeg_event  + CEDQz_01;
        REDQ_t = RENeg_event  + REDQz_01;
        FROMCE = ((CEDQ_t < REDQ_t) && (CEDQ_t > $time));
        FROMRE = ~FROMCE;
        if (FROMCE)
        begin
            disable OutputZGen1;
            DOut_Pass <= 8'bz;
        end
        else
            DOut_Pass = 8'bz;
    end

    always @(DIn, DOut)
    begin
        if (DIn==DOut)
            deq=1'b1;
        else
            deq=1'b0;
    end
    // check when data is generated from model to avoid setuphold check in
    // those occasion
    assign deg=deq;

    initial
    begin
        //////////////////////////////////////////////////////////////////-
        //ID array data / K9S1208 DEVICE SPECIFIC
        //////////////////////////////////////////////////////////////////-
        IDArray[4'd0] = 8'hEC;
        IDArray[4'd1] = 8'h76;
        IDArray[4'd2] = 8'hA5;
        IDArray[4'd3] = 8'hC0;
    end

    // initialize memory and load preoload files if any
    initial
    begin: InitMemory
    integer i,j;
    integer m_mem[0:(PageSize-SpareSize)*PageNum+PageSize-SpareSize-1];

        for (i=0;i<= PageNum;i=i+1)
        begin
            for (j=0;j<= PageSize-SpareSize-1;j=j+1)
            begin
                m_mem[i*(PageSize-SpareSize)+j]=MaxData;
            end
        end

        if (UserPreload && !(mem_file_name == "none"))
        begin
            ////////////////////////////////////////////////////////////////////
            /////   k9s1208 memory preload file format /////////////////////////
            ////////////////////////////////////////////////////////////////////
            //   /       - comment
            //   @aaaaaaa   - <aaaaaaa> stands for page address and address
            //               within first 512 bytes of a page
            //   dd        - <dd> is Byte to be written at Mem(page)(offset++)
            //               page is <aaaaaaa> div 512
            //               offset is <aaaaaaa> mod 512
            //               offset is incremented on every write
            ///////////////////////////////////////////////////////////////////
           $readmemh(mem_file_name,m_mem);
        end
        for (i=0;i<= PageNum;i=i+1)
        begin
            for (j=0;j<= PageSize-SpareSize-1;j=j+1)
            begin
                Mem[i*(PageSize+1)+j] =m_mem[i*(PageSize-SpareSize)+j];
            end
        end

        for (i=0;i<= PageNum;i=i+1)
        begin
            for (j=0;j<= PageSize-SpareSize-1;j=j+1)
            begin
                m_mem[i*(PageSize-SpareSize)+j]=MaxData;
            end
        end

        if (UserPreload && !(spare_file_name == "none"))
        begin
            //////////////////////////////////////////////////////////////////
            ////-k9s1208 spare memory preload file format /////////////////
            //////////////////////////////////////////////////////////////////
            //   /       - comment
            //   @aaaaaaa   - <aaaaaaa> stands for page address and address
            //                within spare area of a page
            //   dd        - <dd> is Byte to be written at
            //               Mem(page)(512+(offset++))
            //               page is <aaaaaaa> div 512
            //               offset is <aaaaaaa> mod 512 and should be < 16
            //               offset is incremented on every write
            //////////////////////////////////////////////////////////////////
            $readmemh(spare_file_name,m_mem);
        end

        for (i=0;i<= PageNum;i=i+1)
        begin
            for (j=0;j<= SpareSize;j=j+1)
            begin
                Mem[i*(PageSize+1)+j+PageSize-SpareSize]
                                          =m_mem[i*(PageSize-SpareSize)+j];
            end
        end
    end

    initial
    begin
        TRANSFER        =1'b0;
        INTCE           =1'b0;
        ERS_ACT         =1'b0;
        PRG_ACT         =1'b0;
        RSTSTART        =1'b0;
        RSTDONE         =1'b0;
        NEXT_PAGE       =1'b0;
        LAST_PAGE       =1'b0;
        write           =1'b0;
        read            =1'b0;

        for(i=0;i<=3;i=i+1)
        begin
            for(j=0;j<=PageSize;j=j+1)
                WrBuffData[i*(PageSize+1)+j] = -1;
            WrBuffStartAddr[i] = -1;
            WrBuffEndAddr[i]   = -1;
            WrBuffBlock[i]     = -1;
            WrBuffPage[i]      = -1;
            ErsQueue[i]        = -1;
        end

        for(i=0;i<=PlaneNum;i=i+1)
        begin
            ErsPlane[i]= 1'b0;
            WrPlane[i] = 1'b0;
        end

        for(i=0;i<=PageNum;i=i+1)
        begin
            ProgCntMain[i] = 0;
            ProgCntSpare[i]= 0;
        end

        current_state  = IDLE;
        next_state     = IDLE;
        RD_MODE        = READ_A;
        STATUS_MODE    = NONE;
        Status         = 8'hC0;
        Old_status     = 8'b0;
    end

     //Power Up time 1 us;
    initial
    begin
        PoweredUp = 1'b0;
        #poweredupT  PoweredUp = 1'b1;
    end

    //Program Operation
    always @(posedge PROG_in)
    begin:ProgTime
        #(tdevice_PROG+WER_01) PROG_out = 1'b1;
    end
    always @(negedge PROG_in)
    begin
        disable ProgTime;
        PROG_out = 1'b0;
    end
    //Block Erase Operation
    always @(posedge BERS_in)
    begin : ErsTime
        #(tdevice_BERS+WER_01) BERS_out = 1'b1;
    end
    always @(negedge BERS_in)
    begin
        disable ErsTime;
        BERS_out = 1'b0;
    end
    // Dummy busy time
    always @(posedge DBSY_in)
    begin : DummyBusyTime
        #(tdevice_DBSY+WER_01) DBSY_out = 1'b1;
    end
    always @(negedge DBSY_in)
    begin
        disable DummyBusyTime;
        DBSY_out = 1'b0;
    end
    //Data transfer time
    always @(posedge TR_in)
    begin : DataTransferTime
        #(tdevice_TR) TR_out = 1'b1;
    end
    always @(negedge TR_in)
    begin
        disable DataTransferTime;
        TR_out = 1'b0;
    end

    ////////////////////////////////////////////////////////////////////////////
    ////     obtain 'LAST_EVENT information
    ////////////////////////////////////////////////////////////////////////////
    always @(RENeg)
    begin
        RENeg_event = $time;
    end
    always @(CENeg)
    begin
        CENeg_event = $time;
    end

    ////////////////////////////////////////////////////////////////////////////
    // process for reset control and FSM state transition
    ////////////////////////////////////////////////////////////////////////////
    always @(next_state, PoweredUp)
    begin
        if (PoweredUp)
        begin
            current_state = next_state;
            reseted       = 1'b1;
        end
        else
        begin
            current_state = IDLE;
            RD_MODE       = READ_A;
            STATUS_MODE   = NONE;
            reseted       = 1'b0;
        end
    end

    //////////////////////////////////////////////////////////////////////////
    //process for generating the write and read signals
    //////////////////////////////////////////////////////////////////////////
    always @ (WENeg, CENeg, RENeg)
    begin
        if (~WENeg && ~CENeg && RENeg)
            write  =  1'b1;
        else if (WENeg &&  ~CENeg && RENeg)
            write  =  1'b0;
        else
            write = 1'b0;
        if (WENeg &&  ~CENeg && ~RENeg && ~ALE && ~CLE )
            read = 1'b1;
        else if (WENeg &&  ~CENeg && RENeg && ~ALE && ~CLE )
            read = 1'b0;
        else
            read = 1'b0;
    end

    //////////////////////////////////////////////////////////////////////////
    //Latches 8 bit address on rising edge of RE#
    //Latches data on rising edge of WE#
    //////////////////////////////////////////////////////////////////////////
    always @(A)
    begin
        // sample new address or data
        if ( ~WENeg && ~CENeg )
            A_tmp    = A[7:0];
            D_tmp    = DIn[7:0];
        end

    always @( negedge WENeg)
    begin
        // sample new address or data
        if (~CENeg)
        begin
            A_tmp    = A[7:0];
            D_tmp    = DIn[7:0];
        end
    end

    always @ (posedge WENeg)
    begin
        // latch 8 bit read address
        if (ALE && ~CENeg && WENeg)
            AddrCom = A_tmp[7:0];
        // latch data
        if (~ALE && ~CENeg && RENeg)
            Data   =  D_tmp[7:0];
    end

    //////////////////////////////////////////////////////////////////////////
    // Process that controls CE interception of read operations
    //////////////////////////////////////////////////////////////////////////
    always @(posedge TRANSFER)
    begin : CEInt0
        if (CENeg)
            #INTCET INTCE = 1'b1;

    end

    always @(posedge CENeg)
    begin : CEInt1
        if (TRANSFER)
            #INTCET INTCE = 1'b1;
    end

    always @(negedge CENeg)
    begin
        disable CEInt0;
        disable CEInt1;
        INTCE = 1'b0;
    end

    ////////////////////////////////////////////////////////////////////////////
    // Timing control for the Reset Operation
    ////////////////////////////////////////////////////////////////////////////

    event rstdone_event;
    always @ (posedge reseted)
    begin
        disable rstdone_process;
        RSTDONE = 1'b1;  // reset done
    end

    always @ (posedge RSTSTART)
    begin
        if (reseted &&  RSTDONE)
        begin
            if (ERS_ACT)
                duration = RstErsT + WER_01;
            else if (PRG_ACT)
                duration = RstProgT+ WER_01;
            else
                duration = RstReadT+ WER_01;
            RSTDONE   = 1'b0;
            ->rstdone_event;
        end
    end

    always @(rstdone_event)
    begin:rstdone_process
        #duration RSTDONE = 1'b1;
    end

    ////////////////////////////////////////////////////////////////////////////
    // Main Behavior Process
    // combinational process for next state generation
    ////////////////////////////////////////////////////////////////////////////

    //WRITE CYCLE TRANSITIONS
    always @(negedge write or negedge reseted)
    begin
        if (reseted != 1'b1 )
            next_state = current_state;
        else
            case (current_state)
            IDLE :
            begin
                if (CLE  && Data==8'h00  )
                    next_state = IDLE; // READ AREA A
                else if ( CLE  && Data==8'h01  )
                    next_state = IDLE; // READ AREA B
                else if ( CLE  && Data==8'h50  )
                    next_state = IDLE; // READ AREA C
                else if ( CLE  && Data==8'h70  )
                    next_state = IDLE; // read status
                else if ( CLE  && Data==8'h71  )
                    next_state = IDLE; // read multi-plane status
                else if ( CLE  && Data==8'h90  )
                    next_state = ID_PREL;
                else if ( CLE  && Data==8'h80  )
                    next_state = PREL_PRG;
                else if ( CLE  && Data==8'h60  )
                    next_state = PREL_ERS;
                else if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
                else if ( ALE  && STATUS_MODE == NONE)
                    next_state = A0_RD;
            end

            A0_RD :
            begin
                if ( ALE )
                    next_state = A1_RD;
                else if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
            end

            A1_RD :
            begin
                if ( ALE )
                    next_state = A2_RD;
                else if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
            end

            A2_RD :
            begin
                if ( ALE )
                    next_state = BUFF_TR;
                else if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
            end

            BUFF_TR :
            begin
                if ( CLE  && Data==8'hFF )
                    next_state = RESET; // reset
            end

            RD :
            begin
                if ( CLE  && Data==8'h00  )
                    next_state = IDLE; // READ AREA A
                else if ( CLE  && Data==8'h01  )
                    next_state = IDLE; // READ AREA B
                else if ( CLE  && Data==8'h50  )
                    next_state = IDLE; // READ AREA C
                else if ( CLE  && Data==8'h70  )
                    next_state = IDLE; // read status
                else if ( CLE  && Data==8'h71  )
                    next_state = IDLE; // read multi-plane status
                else if ( CLE  && Data==8'h90  )
                    next_state = ID_PREL;
                else if ( CLE  && Data==8'h80  )
                    next_state = PREL_PRG;
                else if ( CLE  && Data==8'h60  )
                    next_state = PREL_ERS;
                else if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
                else if ( ALE  )
                    next_state = A0_RD;
            end

            ID_PREL :
            begin
                if ( ALE  && AddrCom==8'h00  )
                    next_state = ID;
                else if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
            end

            ID :
            begin
                if ( CLE  && Data==8'h00  )
                    next_state = IDLE; // READ AREA A
                else if ( CLE  && Data==8'h01  )
                    next_state = IDLE; // READ AREA B
                else if ( CLE  && Data==8'h50  )
                    next_state = IDLE; // READ AREA C
                else if ( CLE  && Data==8'h70  )
                    next_state = IDLE; // read status
                else if ( CLE  && Data==8'h71  )
                    next_state = IDLE; // read multi-plane status
                else if ( CLE  && Data==8'h90  )
                    next_state = ID_PREL;
                else if ( CLE  && Data==8'h80  )
                    next_state = PREL_PRG;
                else if ( CLE  && Data==8'h60  )
                    next_state = PREL_ERS;
                else if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
            end

            PREL_PRG :
            begin
                if ( ALE  )
                    next_state = A0_PRG;
                else if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
            end

            A0_PRG :
            begin
                if ( ALE  )
                    next_state = A1_PRG;
                else if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
            end

            A1_PRG :
            begin
                if ( ALE  )
                    next_state = A2_PRG;
                else if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
            end

            A2_PRG :
            begin
                if ( ALE  )
                    next_state = DATA_PRG;
                else if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
            end

            DATA_PRG :
            begin
                if (CLE &&(Data==8'h10 || Data==8'h15 )
                        && WrAddr==WrBuffStartAddr[WrCnt])
                    next_state = IDLE;
                else if ( CLE  && Data==8'h10  )
                    next_state = PGMS;
                else if ( CLE  && Data==8'h15  )
                    next_state = PGMS; // accumulate status
                else if ( CLE  && Data==8'h11
                     && (WrCnt == 3 || WrAddr==WrBuffStartAddr[WrCnt]))
                    next_state = IDLE;
                else if ( CLE  && Data==8'h11  && WrCnt < 3 )
                    next_state = DBSY;
                else if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
                else if ( ~ALE && ~CLE && WrAddr < PageSize+1 )
                    next_state = DATA_PRG; // write next word to buffer
            end

            PGMS :
            begin
                if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
                else if ( CLE  && Data==8'h70  )
                    next_state = PGMS; // read status
                else if ( CLE  && Data==8'h71  )
                    next_state = PGMS; // read multi-plane status
            end

            DBSY :
            begin
                if ( CLE  && Data==8'h70  )
                    next_state = DBSY; // read status
                else if ( CLE  && Data==8'h71  )
                    next_state = DBSY; // read multi-plane status
                else if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
            end

            RDY_PRG :
            begin
                if ( CLE  && Data==8'h80  )
                    next_state = PREL_PRG;
                else if ( CLE  && Data==8'h70  )
                    next_state = RDY_PRG; // read status
                else if ( CLE  && Data==8'h71  )
                    next_state = RDY_PRG; // read multi-plane status
                else if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
            end

            PREL_ERS :
            begin
                if ( ALE  )
                    next_state = A1_ERS;
                else if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
            end

            A1_ERS :
            begin
                if ( ALE  )
                    next_state = A2_ERS;
                else if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
            end

            A2_ERS :
            begin
                if ( ALE  )
                    next_state = A3_ERS;
                else if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
            end

            A3_ERS :
            begin
                if ( CLE  && Data==8'h60  && ErsCnt < 3 )
                    next_state = PREL_ERS;
                else if ( CLE  && Data==8'hD0  )
                    next_state = BERS_EXEC;
                else if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
            end

            BERS_EXEC :
            begin
                if ( CLE  && Data==8'hFF  )
                    next_state = RESET; // reset
                else if ( CLE  && Data==8'h70  )
                    next_state = BERS_EXEC; // read status
                else if ( CLE  && Data==8'h71  )
                    next_state = BERS_EXEC; // read multi-plane status
            end

            endcase
    end

    // RESET state, RSTDONE
    always @(posedge RSTDONE)
    begin: StateGen1
        if (current_state == RESET)
            next_state = IDLE;
    end

    // BUFF_TR, TR_out
    always @(posedge TR_out)
    begin: StateGen2
        if (current_state == BUFF_TR)
            next_state = RD; // buffer transfered
    end

    // BUFF_TR, INTCE
    always @(posedge INTCE)
    begin: StateGen3
        if (current_state == BUFF_TR && CENeg)
            next_state = IDLE; // read intercepted
    end

    // RD, read negedge
    always @(negedge read)
    begin: StateGen4
        if (reseted!=1'b1)
            next_state = current_state;
        else
        begin
            if (current_state == RD && NEXT_PAGE)
                next_state = BUFF_TR;
        end
    end

    // PGMS, PROG_out
    always @(posedge PROG_out)
    begin: StateGen5
        if (current_state == PGMS )
            next_state = IDLE; // programming done
    end

    // DBSY, DBSY_out
    always @(posedge DBSY_out)
    begin: StateGen6
        if (current_state == DBSY )
            next_state = RDY_PRG;
    end

    // BERS_EXEC, BERS_out
    always @(posedge BERS_out)
    begin: StateGen7
        if (current_state == BERS_EXEC )
            next_state = IDLE;
    end

    ///////////////////////////////////////////////////////////////////////////
    //FSM Output generation and general funcionality
    ///////////////////////////////////////////////////////////////////////////

    always @(posedge read)
    begin
          ->oe_event;
    end

    always @(oe_event)
    begin
        oe = 1'b1;
        #1 oe = 1'b0;
    end

    always @( posedge oe)
    begin: Output
        case (current_state)
            IDLE :
            begin
                if ( STATUS_MODE !== NONE )
                    READ_STATUS(STATUS_MODE);
            end

            RD :
            begin
                READ_DATA(Address,PageAddr);
            end

            ID :
            begin
                if ( IDAddr < 4 )
                begin
                    DOut_zd = IDArray[IDAddr];
                    IDAddr  = IDAddr+1;
                end
                else
                    DOut_zd = 8'bz;
            end

            PGMS :
            begin
                if ( STATUS_MODE !== NONE )
                    READ_STATUS(STATUS_MODE);
            end

            DBSY :
            begin
                if ( STATUS_MODE !== NONE )
                    READ_STATUS(STATUS_MODE);
            end

            RDY_PRG :
            begin
                if ( STATUS_MODE !== NONE )
                    READ_STATUS(STATUS_MODE);
            end

            BERS_EXEC :
            begin
                if ( STATUS_MODE !== NONE )
                    READ_STATUS(STATUS_MODE);
            end
        endcase
    end

    always @(negedge write)
    begin: Func0
        if ( reseted === 1'b1 )
        case (current_state)
        IDLE :
        begin
            if ( CLE && Data==8'h00 )
            begin
                RD_MODE = READ_A; // READ AREA A
                STATUS_MODE = NONE;
            end
            else if ( CLE && Data==8'h01 )
            begin
                RD_MODE = READ_B; // READ AREA B
                STATUS_MODE = NONE;
            end
            else if ( CLE && Data==8'h50 )
            begin
                RD_MODE = READ_C; // READ AREA C
                STATUS_MODE = NONE;
            end
            else if ( CLE && Data==8'h70 )
                STATUS_MODE = STAT; // read status
            else if ( CLE && Data==8'h71 )
                STATUS_MODE = MULTI_PLANE; // read multi-plane status
            else if ( CLE && Data==8'h90 )
                STATUS_MODE = NONE;
            else if ( CLE && Data==8'h80 )
            begin
                STATUS_MODE = NONE;
                WrCnt   = 0;
                WrPlane = 0;
                Status  = 8'b11000000;
            end
            else if ( CLE && Data==8'h60 )
            begin
                STATUS_MODE = NONE;
                ErsCnt= 0;
                ErsPlane= 0;
                for(i=0;i<=3;i=i+1)
                    ErsQueue[i]= -1;
                Status  = 8'b11000000;
            end
            else if ( CLE && Data==8'hFF )
            begin
                STATUS_MODE = NONE;
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
            else if ( ALE && STATUS_MODE == NONE )
            begin
                if ( RD_MODE== READ_C )
                    Address = (AddrCom % 16);
                else
                    Address = AddrCom;
            end
        end

        A0_RD :
        begin
            if ( ALE )
                Page = AddrCom;
            else if ( CLE && Data==8'hFF )
            begin
                STATUS_MODE = NONE;
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
        end

        A1_RD :
        begin
            if ( ALE )
                Page = Page + ( AddrCom*12'h100);
            else if ( CLE && Data==8'hFF )
            begin
                STATUS_MODE = NONE;
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
        end

        A2_RD :
        begin
            if ( ALE )
            begin
                Page = Page + (AddrCom*20'h10000);
                PageAddr  = Page;
                BlockAddr = Page / (BlockSize + 1);
                TRANSFER  = 1'b1;
                TR_in     = 1'b1;
                R_zd      = 1'b0;
                Status[6] = 1'b0;
            end
            else if ( CLE && Data==8'hFF )
            begin
                STATUS_MODE = NONE;
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
        end

        BUFF_TR :
        begin
            if ( CLE && Data==8'hFF )
            begin
                TR_in = 1'b0;
                TRANSFER    = 1'b0;
                STATUS_MODE = NONE;
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
        end

        RD :
        begin
            if ( CLE && Data==8'h00 )
            begin
                RD_MODE = READ_A; // READ AREA A
                STATUS_MODE = NONE;
            end
            else if ( CLE && Data==8'h01 )
            begin
                RD_MODE = READ_B; // READ AREA B
                STATUS_MODE = NONE;
            end
            else if ( CLE && Data==8'h50 )
            begin
                RD_MODE = READ_C; // READ AREA C
                STATUS_MODE = NONE;
            end
            else if ( CLE && Data==8'h70 )
            begin
                STATUS_MODE = STAT; // read status
                if ( RD_MODE == READ_B )
                    RD_MODE = READ_A;
            end
            else if ( CLE && Data==8'h71 )
            begin
                STATUS_MODE = MULTI_PLANE; // read multi-plane status
                if ( RD_MODE == READ_B )
                    RD_MODE = READ_A;
            end
            else if ( CLE && Data==8'h90 )
            begin
                STATUS_MODE = NONE;
                if ( RD_MODE == READ_B )
                    RD_MODE = READ_A;
            end
            else if ( CLE && Data==8'h80 )
            begin
                STATUS_MODE = NONE;
                WrCnt   = 0;
                WrPlane = 0;
                Status  = 8'b11000000;
            end
            else if ( CLE && Data==8'h60 )
            begin
                STATUS_MODE = NONE;
                ErsCnt= 0;
                ErsPlane= 0;
                for(i=0;i<=3;i=i+1)
                    ErsQueue[i]= -1;
                Status  = 8'b11000000;
            end
            else if ( CLE && Data==8'hFF )
            begin
                STATUS_MODE = NONE;
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
            else if ( ALE )
            begin
                STATUS_MODE = NONE;
                if ( RD_MODE == READ_C )
                    Address = (AddrCom % 16);
                else
                    Address = AddrCom;
                if ( RD_MODE == READ_B )
                    RD_MODE = READ_A;
            end
        end

        ID_PREL :
        begin
            if ( ALE && AddrCom==8'h00 )
                IDAddr = 0;
            else if ( CLE && Data==8'hFF )
            begin
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
        end

        ID :
        begin
            if ( CLE && Data==8'h00 )
                RD_MODE = READ_A; // READ AREA A
            else if ( CLE && Data==8'h01 )
                RD_MODE = READ_B; // READ AREA B
            else if ( CLE && Data==8'h50 )
                RD_MODE = READ_C; // READ AREA C
            else if ( CLE && Data==8'h70 )
                STATUS_MODE = STAT; // read status
            else if ( CLE && Data==8'h71 )
                STATUS_MODE = MULTI_PLANE; // read multi-plane status
            else if ( CLE && Data==8'h80 )
            begin
                WrCnt   = 0;
                WrPlane = 0;
                Status  = 8'b11000000;
            end
            else if ( CLE && Data==8'h60 )
            begin
                ErsCnt  = 0;
                ErsPlane= 0;
                for(i=0;i<=3;i=i+1)
                    ErsQueue[i]= -1;
                Status  = 8'b11000000;
            end
            else if ( CLE && Data==8'hFF )
            begin
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
        end

        PREL_PRG :
        begin
            if ( ALE )
            begin
                if ( RD_MODE == READ_A )
                begin
                    WrAddr                 = AddrCom;
                    WrBuffStartAddr[WrCnt] = AddrCom;
                end
                else if ( RD_MODE == READ_B )
                begin
                    WrAddr                 = AddrCom + 12'h100;
                    WrBuffStartAddr[WrCnt] = AddrCom + 12'h100;
                end
                else // RD_MODE == READ_C
                begin
                    WrAddr                = (AddrCom % 16) + 12'h200;
                    WrBuffStartAddr[WrCnt]= (AddrCom % 16) + 12'h200;
                end
            end
            else if ( CLE && Data==8'hFF )
            begin
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
        end

        A0_PRG :
        begin
            if ( ALE )
                Page = AddrCom;
            else if ( CLE && Data==8'hFF )
            begin
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
        end

        A1_PRG :
        begin
            if ( ALE )
                Page = Page + ( AddrCom*12'h100);
            else if ( CLE && Data==8'hFF )
            begin
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
        end

        A2_PRG :
        begin
            if ( ALE )
                Page = Page + ( AddrCom*20'h10000);
            else if ( CLE && Data==8'hFF )
            begin
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
        end

        DATA_PRG :
        begin
            if ( CLE && Data==8'h10
                            && WrAddr==WrBuffStartAddr[WrCnt] )
            begin
                //do nothing
            end
            else if ( CLE && (Data==8'h10 || Data==8'h15) )
            begin
                Blck = Page / (BlockSize + 1);
                Plane= Blck % 4;
                if ( WrCnt==0 )
                begin
                    WrPage = Page % (BlockSize+1);
                end
                WrBuffEndAddr[WrCnt]   = WrAddr-1;
                if ( RD_MODE == READ_B && WrCnt > 0 )
                begin
                    Status[(Plane % 4) +1]   = 1'b1;
                    WrBuffBlock[WrCnt] = -1;
                    WrBuffPage[WrCnt]  = -1;
                end
                else if ( WrCnt>0 && (Page % (BlockSize+1))!==WrPage )
                begin
                    Status[(Plane % 4) +1]   = 1'b1;
                    WrBuffBlock[WrCnt] = -1;
                    WrBuffPage[WrCnt]  = -1;
                end
                else if ( WrPlane[Plane] !== 1'b0 )
                begin
                    Status[4:0] = ~(0);
                    WrPlane     = ~(0);
                    for(i=0;i<=3;i=i+1)
                    begin
                        WrBuffBlock[i]= -1;
                        WrBuffPage[i] = -1;
                    end
                end
                else if ( ProgCntMain[Page] > 0
                                && WrBuffStartAddr[WrCnt] < 512 )
                begin
                    Status[(Plane % 4) +1]   = 1'b1;
                    WrBuffBlock[WrCnt] = -1;
                    WrBuffPage[WrCnt]  = -1;
                end
                else if ( ProgCntSpare[Page] > 1
                                && (WrAddr-1) >= 512 )
                                //WrBuffEndAddr(WrCnt)>=512
                begin
                    Status[(Plane % 4) +1]   = 1'b1;
                    WrBuffBlock[WrCnt] = -1;
                    WrBuffPage[WrCnt]  = -1;
                end
                else
                begin
                    Status[(Plane % 4) +1]   = 1'b0;
                    WrBuffBlock[WrCnt] = Blck;
                    WrBuffPage[WrCnt]  = Page;
                    WrPlane[Plane] = 1'b1;
                end
                PROG_in  = 1'b1;
                PRG_ACT  = 1'b0;
                PRG_ACT  <= #1 1'b1;
                R_zd     = 1'b0;
                Status[7]= 1'b1;
                Status[6]= 1'b0;
                if ( Status[4:1] == 4'b0000 )
                    Status[0] = 1'b0;
                else
                    Status[0] = 1'b1;
                Status[4:0]=(Old_status[4:0] | Status[4:0]);
                if ( Data == 8'h15 )
                    //accumulate status
                    Old_status = Status;
                else
                    Old_status = 8'b0;
            end
            else if ( CLE && Data==8'h11
                    && (WrCnt == 3 || WrAddr==WrBuffStartAddr[WrCnt]) )
            begin
                // do nothing
            end
            else if ( CLE && Data==8'h11 && WrCnt < 3 )
            begin
                Blck = Page / (BlockSize + 1);
                Plane= (Blck % 4);
                if ( WrCnt==0 )
                begin
                    WrPage       = Page % (BlockSize+1);
                end
                WrBuffEndAddr[WrCnt]   = WrAddr-1;
                if ( RD_MODE == READ_B )
                begin
                    Status[(Plane % 4)+1]    = 1'b1;
                    WrBuffBlock[WrCnt] = -1;
                    WrBuffPage[WrCnt]  = -1;
                end
                else if ( WrCnt>0 && (Page % (BlockSize+1))!==WrPage )
                begin
                    Status[(Plane % 4)+1]    = 1'b1;
                    WrBuffBlock[WrCnt] = -1;
                    WrBuffPage[WrCnt]  = -1;
                end
                else if ( WrPlane[Plane] !== 1'b0 )
                begin
                    Status[4:0] = ~(0);
                    WrPlane     = ~(0);
                    for(i=0;i<=3;i=i+1)
                    begin
                        WrBuffBlock[i]= -1;
                        WrBuffPage[i] = -1;
                    end
                end
                else if ( ProgCntMain[Page] > 0
                                && WrBuffStartAddr[WrCnt] < 512 )
                begin
                    Status[(Plane % 4)+1]    = 1'b1;
                    WrBuffBlock[WrCnt] = -1;
                    WrBuffPage[WrCnt]  = -1;
                end
                else if ( ProgCntSpare[Page] > 1
                                && (WrAddr-1) >= 512 )
                                // WrBuffEndAddr(WrCnt) >= 512
                begin
                    Status[(Plane % 4)+1]    = 1'b1;
                    WrBuffBlock[WrCnt] = -1;
                    WrBuffPage[WrCnt]  = -1;
                end
                else
                begin
                    Status[(Plane % 4)+1]    = 1'b0;
                    WrBuffBlock[WrCnt] = Blck;
                    WrBuffPage[WrCnt]  = Page;
                    WrPlane[Plane] = 1'b1;
                end
                DBSY_in   = 1'b1;
                R_zd      = 1'b0;
                Status[6] = 1'b0;
            end
            else if ( CLE && Data==8'hFF )
            begin
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
            else if ( ~ALE && ~CLE && WrAddr < PageSize+1 )
            begin
                WrBuffData[WrCnt*(PageSize+1)+WrAddr] = Data;
                WrAddr = WrAddr + 1;
            end
        end

        PGMS :
        begin
            if ( CLE && Data==8'hFF )
            begin
                WrCnt   = -1;
                PROG_in = 1'b0;
                STATUS_MODE = NONE;
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
            else if ( CLE && Data==8'h70 )
                STATUS_MODE = STAT; // read status
            else if ( CLE && Data==8'h71 )
                STATUS_MODE = MULTI_PLANE; // read multi-plane status
        end

        DBSY :
        begin
            if ( CLE && Data==8'h70 )
                STATUS_MODE = STAT; // read status
            else if ( CLE && Data==8'h71 )
                STATUS_MODE = MULTI_PLANE; // read multi-plane status
            else if ( CLE && Data==8'hFF )
            begin
                WrCnt     = -1;
                DBSY_in   = 1'b0;
                STATUS_MODE = NONE;
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
        end

        RDY_PRG :
        begin
            if ( CLE && Data==8'h80 )
            begin
                STATUS_MODE = NONE;
                WrCnt = WrCnt + 1;
            end
            else if ( CLE && Data==8'h70 )
                STATUS_MODE = STAT; // read status
            else if ( CLE && Data==8'h71 )
                STATUS_MODE = MULTI_PLANE; // read multi-plane status
            else if ( CLE && Data==8'hFF )
            begin
                STATUS_MODE = NONE;
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
        end

        PREL_ERS :
        begin
            if ( ALE )
                Page = AddrCom;
            else if ( CLE && Data==8'hFF )
            begin
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
        end

        A1_ERS :
        begin
            if ( ALE )
                Page = Page + ( AddrCom*12'h100);
            else if ( CLE && Data==8'hFF )
            begin
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
        end

        A2_ERS :
        begin
            if ( ALE )
                Page = Page + ( AddrCom*20'h10000);
            else if ( CLE && Data==8'hFF )
            begin
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
        end

        A3_ERS :
        begin
            if ( CLE && Data==8'h60 && ErsCnt < 3 )
            begin
                Blck = Page / (BlockSize + 1);
                Plane= (Blck % 4);
                if ( ErsPlane[Plane] !== 1'b0 )
                begin
                    Status[4:0] = ~(0);
                    ErsPlane    = ~(0);
                    for(i=0;i<=3;i=i+1)
                        ErsQueue[i]= -1;
                end
                else
                begin
                    Status[(Plane % 4)+1]  = 1'b0;
                    ErsQueue[ErsCnt] = Blck;
                    ErsPlane[Plane]  = 1'b1;
                end
                ErsCnt <= #1(ErsCnt + 1);
            end
            else if ( CLE && Data==8'hD0 )
            begin
                Blck = Page / (BlockSize + 1);
                Plane= (Blck % 4);
                if ( ErsPlane[Plane] !== 1'b0 )
                begin
                    Status[4:0] = ~(0);
                    ErsPlane    = ~(0);
                    for(i=0;i<=3;i=i+1)
                        ErsQueue[i]= -1;
                end
                else
                begin
                    Status[(Plane % 4)+1]  = 1'b0;
                    ErsQueue[ErsCnt] = Blck;
                    ErsPlane[Plane]  = 1'b1;
                end
                BERS_in = 1'b1;
                ERS_ACT = 1'b0;
                ERS_ACT <= #1 1'b1;
                R_zd    = 1'b0;
                Status[7] = 1'b1;
                Status[6] = 1'b0;
                if ( Status [4:1] == 4'b0000 )
                    Status[0] = 1'b0;
                else
                    Status[0] = 1'b1;
                Old_status = 8'b0;
            end
            else if ( CLE && Data==8'hFF )
            begin
                ErsCnt    = -1;
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
        end

        BERS_EXEC :
        begin
            if ( CLE && Data==8'hFF )
            begin
                ErsCnt  = -1;
                BERS_in = 1'b0;
                STATUS_MODE = NONE;
                RSTSTART  = 1'b1;
                RSTSTART  <= #1 1'b0;
                R_zd      = 1'b0;
            end
            else if ( CLE && Data==8'h70 )
                STATUS_MODE = STAT; // read status
            else if ( CLE && Data==8'h71 )
                STATUS_MODE = MULTI_PLANE; // read multi-plane status
        end
        endcase
    end

    //RESET state, RSTDONE
    always @(posedge RSTDONE)
    begin: Func1
        if (current_state == RESET )
        begin
            if ( RD_MODE == READ_B )
                RD_MODE = READ_A;
            PRG_ACT = 1'b0;
            ERS_ACT = 1'b0;
            R_zd    = 1'b1;
            Status      = 8'b11000000;
            Old_status  = 8'b0;
        end
    end

    //BUFF_TR state, TR_out
    always @(posedge TR_out)
    begin: Func2
        if (current_state == BUFF_TR )
        begin
            // transfer buffer
            if ( RD_MODE == READ_B )
                Address = Address + 12'h100;
            else if ( RD_MODE == READ_C )
                Address = Address + 12'h200;
            TRANSFER = 1'b0;
            R_zd     = 1'b1;
            Status[6]= 1'b1;
            TR_in    = 1'b0;
        end
    end

    //BUFF_TR state, INTCE
    always @(posedge INTCE)
    begin: Func3
        if (current_state == BUFF_TR && CENeg)
        begin
            //read intercepted
            if ( RD_MODE == READ_B )
                RD_MODE = READ_A;
            TRANSFER = 1'b0;
            R_zd     = 1'b1;
            Status[6]= 1'b1;
            TR_in    = 1'b0;
        end
    end

    //RD state, read
    always @(negedge read)
    begin: Func4
        if (current_state == RD)
            if ( NEXT_PAGE )
            begin
                if ( ~LAST_PAGE )
                begin
                    TRANSFER  = 1'b1;
                    TR_in     = 1'b1;
                end
                else
                begin
                    TRANSFER  = 1'b1;
                    TR_in     = 1'b0;
                end
                R_zd      = 1'b0;
                Status[6] = 1'b0;
            end
    end

    //DBSY state, DBSY_out
    always @(posedge DBSY_out)
    begin: Func6
        if (current_state == DBSY)
        begin
            DBSY_in = 1'b0;
            R_zd    = 1'b1;
            Status[6] = 1'b1;
            if ( read && STATUS_MODE!== NONE )
                READ_STATUS(STATUS_MODE);
        end
    end

    //PGMS state,PRG_ACT
    always @(posedge PRG_ACT)
    begin: Func5a
    integer i,j,k;
        if (current_state==PGMS)
        begin
            if ( WPNeg !== 1'b0 )
            begin
                for(i=0;i<=WrCnt;i=i+1)
                begin
                    if ( WrBuffBlock[i] !== -1 )
                    begin
                        for(j=WrBuffStartAddr[i];j<=WrBuffEndAddr[i];j=j+1)
                        begin
                            new_int= WrBuffData[i*(PageSize+1)+j];
                            old_int= Mem[WrBuffPage[i]*(PageSize+1)+j];
                            new_bit= new_int;
                            if ( old_int>-1 )
                            begin
                                old_bit=old_int;
                                for(k=0;k<=7;k=k+1)
                                    if ( ~old_bit[k])
                                        new_bit[k]=1'b0;
                                new_int=new_bit;
                            end
                            WrBuffData[i*(PageSize+1)+j]= new_int;
                        end
                        for(j=WrBuffStartAddr[i];j<=WrBuffEndAddr[i];j=j+1)
                            Mem[WrBuffPage[i]*(PageSize+1)+j]= -1;
                    end
                end
                Status[7] = 1'b1;
            end
            else
                Status[7] = 1'b0;
        end
    end

    //PGMS state,PROG_out
    always @(posedge PROG_out)
    begin: Func5b
    integer i,j,k;
        if (current_state==PGMS)
        begin
            PROG_in   = 1'b0;
            PRG_ACT   = 1'b0;
            R_zd      = 1'b1;
            Status[6] = 1'b1;
            if ( read && STATUS_MODE!==NONE )
                READ_STATUS(STATUS_MODE);
            if ( RD_MODE == READ_B )
                RD_MODE = READ_A;
            if ( WPNeg !== 1'b0 )
            begin
                for(i=0;i<=WrCnt;i=i+1)
                begin
                    if ( WrBuffBlock[i] !== -1 )
                    begin
                        for(j=WrBuffStartAddr[i];j<=WrBuffEndAddr[i];j=j+1)
                        begin
                            Mem[WrBuffPage[i]*(PageSize+1)+j]
                                            = WrBuffData[i*(PageSize+1)+j];
                            WrBuffData[i*(PageSize+1)+j]= -1;
                        end
                        if ( WrBuffStartAddr[i] < 512 )
                            ProgCntMain[(WrBuffPage[i])]
                                    = ProgCntMain[(WrBuffPage[i])] +1;
                        if ( WrBuffEndAddr[i] >= 512 )
                            ProgCntSpare[(WrBuffPage[i])]
                                    = ProgCntSpare[(WrBuffPage[i])] +1;
                    end
                end
            end
        end
    end

    //BERS_EXEC state,ERS_ACT
    always @(posedge ERS_ACT)
    begin: Func7a
    integer i,j,k;
        if (current_state==BERS_EXEC)
        begin
            if ( WPNeg!== 1'b0 )
            begin
                for(i=0;i<=ErsCnt;i=i+1)
                begin
                    if ( ErsQueue[i] !== -1 )
                        for(j= (ErsQueue[i])*(BlockSize+1);
                             j<=(ErsQueue[i])*(BlockSize+1) + BlockSize;j=j+1)
                        begin
                            for(k=0;k<=PageSize;k=k+1)
                                Mem[j*(PageSize+1)+k] = -1;
                        end
                end
                Status[7] = 1'b1;
            end
            else
                Status[7] = 1'b0;
        end
    end

    //BERS_EXEC state,BERS_out
    always @(posedge BERS_out)
    begin: Func7b
    integer i,j,k;
        if (current_state==BERS_EXEC)
        begin
            BERS_in   = 1'b0;
            ERS_ACT   = 1'b0;
            R_zd      = 1'b1;
            Status[6] = 1'b1;
            if ( read && STATUS_MODE!==NONE )
                READ_STATUS(STATUS_MODE);
            if ( RD_MODE == READ_B )
                RD_MODE = READ_A;
            if ( WPNeg!== 1'b0 )
            begin
                for(i=0;i<=ErsCnt;i=i+1)
                begin
                    if ( ErsQueue[i] !== -1 )
                        for(j= (ErsQueue[i])*(BlockSize+1);
                             j<=(ErsQueue[i])*(BlockSize+1) + BlockSize;j=j+1)
                        begin
                            for(k=0;k<=PageSize;k=k+1)
                                Mem[j*(PageSize+1)+k] = MaxData;
                            ProgCntMain[j]  = 0;
                            ProgCntSpare[j] = 0;
                        end
                end
            end
        end
    end

    //Output Disable Control
    always @(posedge RENeg )
    begin
        DOut_zd    = 8'bZ;
    end

    //Output Disable Control
    always @(posedge CENeg)
    begin
        DOut_zd    = 8'bZ;
    end

    task READ_STATUS;
    input reg[1:0] mode;
    begin
        if (mode == MULTI_PLANE)
            DOut_zd = Status;
        else // mode == STATUS
        begin
            DOut_zd = Status;
            DOut_zd[4:1] = 4'b0;
        end
   end
   endtask

   task READ_DATA;
   inout integer Addr;
   inout integer Page;
   begin
        if (Mem[Page*(PageSize+1)+Addr] !== -1)
            DOut_zd  = Mem[Page*(PageSize+1)+Addr];
        else
            DOut_zd  = 8'bx;
        if (Addr == PageSize)
        begin
            Addr  = 0;
            if (RD_MODE == READ_B)
                RD_MODE = READ_A;
            NEXT_PAGE  = 1'b1;
            if ((Page % (BlockSize+1)) == BlockSize)
                LAST_PAGE  = 1'b1;
            else
            begin
                LAST_PAGE  = 1'b0;
                Page       = Page + 1;
            end
        end
        else
        begin
            Addr       = Addr+1;
            NEXT_PAGE  = 1'b0;
        end
   end
   endtask

   reg  BuffInRE,  BuffInCE,  BuffInzRE,  BuffInzCE ,BuffInR;
   wire BuffOutRE, BuffOutCE, BuffOutzRE, BuffOutzCE,BuffOutR;

    BUFFER    BUFRE          (BuffOutRE  , BuffInRE);
    BUFFER    BUFCE          (BuffOutCE  , BuffInCE);
    BUFFER    BUFZRE         (BuffOutzRE , BuffInzRE);
    BUFFER    BUFZCE         (BuffOutzCE , BuffInzCE);
    BUFFER    BUFR           (BuffOutR   , BuffInR);

    initial
    begin
        BuffInRE    = 1'b1;
        BuffInCE    = 1'b1;
        BuffInzRE   = 1'b1;
        BuffInzCE   = 1'b1;
        BuffInR     = 1'b1;
    end

    always @(posedge BuffOutRE)
    begin
        REDQ_01 = $time;
    end
    always @(posedge BuffOutCE)
    begin
        CEDQ_01 = $time;
    end
    always @(posedge BuffOutzRE)
    begin
        REDQz_01 = $time;
    end
    always @(posedge BuffOutzCE)
    begin
        CEDQz_01 = $time;
    end
    always @(posedge BuffOutR)
    begin
        WER_01   = $time;
    end

endmodule

module BUFFER (OUT,IN);
    input IN;
    output OUT;
    buf   ( OUT, IN);
endmodule