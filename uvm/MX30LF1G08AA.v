// *==============================================================================================
// *
// *   MX30LF1G08AA.v - 1G-BIT CMOS Flash Memory
// *
// *           COPYRIGHT 2014 Macronix International Co., Ltd.
// *----------------------------------------------------------------------------------------------
// * Environment  : Cadence NC-Verilog
// * Reference Doc: MX30LF1G08AA REV.1.4,FEB.27,2014
// * Creation Date: @(#)$Date: 2014/03/10 10:23:43 $
// * Version      : @(#)$Revision: 1.6 $
// * Description  : There is only one module in this file
// *                module MX30LF1G08AA -> behavior model for the 1G-Bit flash
// *----------------------------------------------------------------------------------------------
// * Note 1:model can load initial flash data from file when model define  parameter Init_File = "xxx"; 
// *        xxx: initial flash data file name;default value xxx = "none", initial flash data is "FF".
// * Note 2:power setup time is Tvcs = 1_000_000 ns, so after power up, chip can be enable.
// * Note 3:more than one values (min. typ. max. value) are defined for some AC parameters in the
// *        datasheet, but only one of them is selected in the behavior model, e.g. program and
// *        erase cycle time is typical value. For the detailed information of the parameters,
// *        please refer to datasheet and contact with Macronix.
// * Note 4:If you have any question and suggestion, please send your mail to follow email address :
// *                                    flash_model@mxic.com.tw
// *----------------------------------------------------------------------------------------------
// * History
// * Date  | Version   Description
// *==============================================================================================
// * $Log: MX30LF1G08AA.v,v $
// * Revision 1.6  2014/03/10 10:23:43  simmodel
// * *** empty log message ***
// *  
// *==============================================================================================
// * timescale define
// *==============================================================================================
`timescale 1ns / 1ns

`define MX30LF1G08AA

module MX30LF1G08AA  ( CE_B,  
                    IO,
                    RE_B,
                    WE_B,
                    CLE,
                    ALE,
                    WP_B,
                    RYBY_B);
                     
// *==============================================================================================
// * Declaration of ports (input, output, inout)
// *==============================================================================================
    parameter   Init_File   = "none";     // initial flash data file name
    parameter	A_MSB       = 27,         // Highest bit of address
         	CA_MSB      = 11,         // Highest bit of byte address
         	CA_SPA      = 5,          // Highest bit of byte address
         	MSB_PA_IN_BLOCK= 5,       // Highest page address within one block 
		IO_MSB      = 7;          // Highest data bit 
    input  CE_B;         // Chip enable, low active
    input  RE_B;         // Output enable, low active
    input  WE_B;         // Write enable, low active
    input  WP_B;         // Protect enable, low active
    input  CLE;          // Command latch enable, high active
    input  ALE;          // Address latch enable, high active
    inout  [IO_MSB:0] IO;// Bidirectional Data bus
    output RYBY_B;       // Ready/Busy Status, high for Ready, low for Busy 

// *==============================================================================================
// * Declaration of parameter 
// *==============================================================================================
    /*----------------------------------------------------------------------*/
    /* Density state parameter						    */
    /*----------------------------------------------------------------------*/
    parameter	Top_Add     = (1<<(A_MSB+1))-1;//chip size [0:Top_Add]x8bit
    parameter	Top_Byte    = (1<<CA_MSB) + (1<<CA_SPA+1)-1;  //7ff+3f,cache size [0:Top_Byte]x8bit
    parameter   Page_NUM    = 1<<(MSB_PA_IN_BLOCK+1);
    parameter   ALL_Page_NUM= 1<<(A_MSB-CA_MSB);
    parameter   NOP_MSB     = 1;
    parameter   NOP         = 4;

    /*----------------------------------------------------------------------*/
    /* Define ID Parameter                                                  */
    /*----------------------------------------------------------------------*/
    parameter   Maker_Code  = 8'hc2;
    parameter   Device_Code = 8'hf1;
    parameter   id2         = 8'h80;
    parameter   id3         = 8'h1d;

    /*----------------------------------------------------------------------*/
    /* AC Characters Parameter						    */
    /*----------------------------------------------------------------------*/
    parameter	
		Trea       = 20,	// REB access time
                Tcea       = 25,        // CEB access time
                Toh        = 10,        // Data-out hold time
                Trhz       = 50,        // REB high to output high impedance
                Tchz       = 50,        // CEB high to output high impedance
                Tr         = 25_000, 
                Twb        = 100,
                Trst_r     = 5_000,
                Trst_p     = 10_000,
                Trst_e     = 500_000;
    
    parameter	Tvcs       = 1000;  //edit by lmj for fast sim         //1_000_000;	// Vcc setup time
    parameter	Trcbsy     = 5_000;
 
    parameter	Tcbsy      = 4_000;
    parameter	Tprog      = 250_000;
    parameter	Terase     = 2_000_000;

    specify
        specparam
                Tcls       = 15,
                Tclh       = 5,
                Tcs        = 20,
                Tch        = 5,
                Twp        = 15,
                Tals       = 15,
                Talh       = 5,
                Tds        = 5,
                Tdh        = 5,
                Twc        = 30,
                Twh        = 10,
                Tadl       = 100,
                Tww        = 100,
                Trr        = 20,
                Trp        = 15,
                Trc        = 30,
                Treh       = 10, 
                Tir        = 0,
                Trhw       = 0,
                Twhr       = 60,
                Tclr       = 10,
                Tar        = 15;
    endspecify

    /*----------------------------------------------------------------------*/
    /* Internal State Machine State					    */
    /*----------------------------------------------------------------------*/
    parameter       INIT_STAT  = 6'h0,
                    READ_STAT1 = 6'h1,
                    RAND_STAT1 = 6'h2,
                    PGM_STAT1  = 6'h3,
                    CPPGM_STAT1= 6'h4,
                    ERS_STAT1  = 6'h5,
                    CARD_STAT1 = 6'h6,
                    READ_STAT2 = 6'h7;
		     
    /*----------------------------------------------------------------------*/
    /* Define Command Parameter						    */
    /*----------------------------------------------------------------------*/
    parameter       READ_CMD1  = 8'h00;
    parameter       READ_CMD2  = 8'h30;
    parameter       RAND_CMD1  = 8'h05;
    parameter       RAND_CMD2  = 8'he0;
    parameter       CARD_CMD2  = 8'h31;
    parameter       CARD_CMD3  = 8'h34;
    parameter       RDID_CMD   = 8'h90;
    parameter       RST_CMD    = 8'hff;
    parameter       STAT_CMD   = 8'h70;
    parameter       RANDIN_CMD1 = 8'h85;
    parameter       PGM_CMD1   = 8'h80;
    parameter       PGM_CMD2   = 8'h10;
    parameter       CAPGM_CMD2 = 8'h15;
    parameter       BKERS_CMD1 = 8'h60;
    parameter       BKERS_CMD2 = 8'hd0;

    /*----------------------------------------------------------------------*/
    /* Declaration of internal-register                                     */
    /*----------------------------------------------------------------------*/
    reg   RYBY_B_Reg;
    reg   [IO_MSB:0]    ARRAY[0:Top_Add];   // Flash Array
    reg   [IO_MSB:0]    Cache[0:Top_Byte];  // Cache Buffer
    reg   [IO_MSB:0]    PBuff[0:Top_Byte];  // Cache Buffer
    reg   [IO_MSB:0]    id[0:Top_Byte];     // id
    reg   [NOP_MSB+1:0] PGM_Count[0:ALL_Page_NUM-1];
    reg   [IO_MSB:0]	Q_Reg;		    // Register to drive Q port
    reg   [A_MSB:0]	Latch_A;	    // latched Address
    reg   [A_MSB:0]	Latch_A_4TMP;	    // latched Address
    reg   [IO_MSB:0]  	Latch_Q;	    // latched Data
    reg   [MSB_PA_IN_BLOCK:0] PA_IN_BLOCK;
    reg   [5:0]	        STATE;   	    // Internal Finite State Machine
    reg   OUT_EN;                	    // data ready to output
    reg   OUTZ_EN;                	    // data ready to output
    reg   Page_EN;                          // page internal read is finished
    reg   Power_Up;
    reg   sr7, sr6, sr5, sr4, sr3, sr2, sr1, sr0;
    reg   sr5_flag;
    reg   status_flag;
    reg   rdid_flag;
    reg   card_op;
    reg   capgm_op;
    reg   capgm_op_mode;
    reg   pgm_busy;
    reg   ers_busy;
    reg   wait_pgm;
    integer j; 
    integer ADR_CYC; 
    
    /*----------------------------------------------------------------------*/
    /* Power-on State in finite state machine                               */
    /*----------------------------------------------------------------------*/
    initial
    begin
        for ( j = 0;j < ALL_Page_NUM; j = j + 1 )
            PGM_Count[j] = 0;
        Power_Up       = 1'b0;
        #Tvcs Power_Up = 1'b1;
    end
  
    initial
    begin
        tk_reset;
    end
 
    /*----------------------------------------------------------------------*/
    /* preload memory                                                       */
    /*----------------------------------------------------------------------*/
    integer pa_count;
    initial
    begin:init_memory
        for ( j = 0;j <= Top_Add; j = j + 1 )
	    ARRAY[j] = 8'hff;
        if ( Init_File != "none" ) // user can load data from file
	    $readmemh( Init_File, ARRAY );
        id[0] = Maker_Code;
        id[1] = Device_Code;
        id[2] = id2;
        id[3] = id3;
    end

// *==============================================================================================
// * Input/Output bus operation 
// *==============================================================================================
    /*----------------------------------------------------------------------*/
    /* Specify the timing                                                   */
    /*----------------------------------------------------------------------*/
    wire RYBY_RE_W;
    assign RYBY_RE_W = !status_flag;

    specify
         $setuphold ( posedge WE_B, CLE, Tcls, Tclh );
         $setuphold ( posedge WE_B, ALE, Tals, Talh );
         $setuphold ( posedge WE_B, CE_B, Tcs, Tch );
         $width ( negedge WE_B, Twp );                    
         $setuphold ( posedge WE_B, IO, Tds, Tdh );
         $period( negedge WE_B, Twc ); 
         $width ( posedge WE_B, Twh );                    
         $setup ( WP_B, negedge WE_B, Tww );
         $setup ( posedge RYBY_B, negedge RE_B &&& RYBY_RE_W, Trr );
         $width ( negedge RE_B, Trp );                    
         $period( negedge RE_B, Trc ); 
         $width ( posedge RE_B, Treh );                    
         $setup ( IO, negedge RE_B, Tir );
         $setup ( posedge RE_B, negedge WE_B, Trhw );
         $setup ( posedge WE_B, negedge RE_B, Twhr );
         $setup ( negedge CLE, negedge RE_B, Tclr );
         $setup ( negedge ALE, negedge RE_B, Tar );
    endspecify

    reg Tadl_chk;
    integer Tadl_begin;
    integer Tadl_delta;
    initial
    begin
        Tadl_chk  = 1'b0;
        Tadl_begin= 0;
        Tadl_delta= 0;
    end

    always @ ( posedge WE_B ) begin
        if ( !ALE && !CLE ) begin
            Tadl_delta = $time - Tadl_begin;
            if (Tadl_delta < Tadl && $time > 0) begin
                $display($time," Warning:WE_B not meet spec Tadl=%dns, now it's %dns\n",Tadl,Tadl_delta);
            end
        end
        if ( ALE ) begin
            Tadl_chk  = 1'b1;
            Tadl_begin= $time;
        end
        else begin
            Tadl_chk  = 1'b0;
        end
    end

// *==============================================================================================
// * Declaration of read  
// *==============================================================================================
    event Read_Q;
    event OUT_Q;
    event load_pb2cache;
    
    always @ ( negedge RE_B ) begin
	if ( Power_Up && !CE_B) begin
	    ->Read_Q;
	end
    end
    
    always @ ( negedge CE_B ) begin
	if ( Power_Up && !RE_B && status_flag) begin
	    ->Read_Q;
	end
    end
    
    always @ ( Read_Q ) begin:read_mode
        disable Trhz_process;
        #Trea;
        ->OUT_Q;
    end

    always @ ( OUT_Q ) begin
	if ( Power_Up ) begin
            OUT_EN = 1;
	end
        Q_Reg = 8'hz;
	if ( status_flag ) begin
	    Q_Reg = {WP_B,sr6,sr5,3'b0,sr1,sr0};
	end
        else if ( rdid_flag ) begin
            Q_Reg = id[Latch_A[1:0]];
            Latch_A[1:0] = Latch_A[1:0] + 1;
        end
	else if ( Page_EN ) begin
            OUT_EN = 1;
            if ( Latch_A[CA_MSB:0] <= Top_Byte ) begin
	        Q_Reg = Cache[Latch_A[CA_MSB:0]];
                if ( Latch_A[CA_MSB:0] == Top_Byte ) begin
                    ->load_pb2cache;
                end
                Latch_A[CA_MSB:0] = Latch_A[CA_MSB:0] + 1;
            end
            else begin
            end
	end
    end

    always @ ( WP_B or sr6 or sr5 or sr1 or sr0 ) begin
        if ( status_flag ) begin
            Q_Reg = {WP_B,sr6,sr5,3'b0,sr1,sr0};
        end
    end

    /*----------------------------------------------------------------------*/
    /* Output (Read) Data if control signals do not disable                 */
    /*----------------------------------------------------------------------*/
    always @ ( posedge RE_B ) begin
        if ( Power_Up ) begin
            #Toh;
            OUT_EN = 0;
            OUTZ_EN = 1;
        end
    end

    always @ ( posedge RE_B ) begin:Trhz_process
        if ( Power_Up ) begin
            #Trhz OUTZ_EN = 0;
        end
    end

    wire CE_B_IN;
    wire CE_B_IN2;
    assign #Tcea CE_B_IN = CE_B;
    assign #Tchz CE_B_IN2= CE_B;
    assign #(0, 0) IO[IO_MSB:0]  = OUT_EN&&!CE_B_IN ? Q_Reg[IO_MSB:0] : OUTZ_EN&&!CE_B_IN2 ? 8'hx : 8'hz;
    assign #(0, 0) RYBY_B        = sr6 ? 1'b1 : 1'b0;//edit by lmj //sr6 ? 1'bz : 1'b0;
    
// *==============================================================================================
// * FSM state transition
// *==============================================================================================
    event internal_read;
    event page_pgm;
    event cache_pgm;
    event block_ers;
    event reset_event;
    event OUT_EN_event;
    event card_op_event;
    event capgm_op_event;
    always @ ( posedge WE_B or posedge CE_B ) begin
	if ( Power_Up ) begin
            if ( CE_B ) begin
                ->OUT_EN_event;
            end
            else if ( WE_B ) begin 
             if ( (STATE == PGM_STAT1) && !ALE && !CLE ) begin
                if ( Latch_A[CA_MSB:0] <= Top_Byte ) begin
                    Cache[Latch_A[CA_MSB:0]] = IO[IO_MSB:0];
                    Latch_A[CA_MSB:0] = Latch_A[CA_MSB:0] + 1;
                end
             end
             if ( ALE ) begin 
                if ( ADR_CYC == 0 ) begin
                    Latch_A[7:0] = IO[7:0];
                    ADR_CYC = 1;
                end
                else if ( ADR_CYC == 1 ) begin
                    Latch_A[CA_MSB:8] = IO[CA_MSB-8:0];
                    ADR_CYC = 2;
                end
                else if ( ADR_CYC == 2 ) begin
                    Latch_A[CA_MSB+8:CA_MSB+1] = IO[7:0];
                    ADR_CYC = 3;
                end
                else if ( ADR_CYC == 3 ) begin
                        Latch_A[A_MSB:CA_MSB+9] = IO[A_MSB-CA_MSB-9:0];
                        ADR_CYC = 0;
                end
             end
             if ( CLE ) begin
              Page_EN = 1'b0; 
              rdid_flag = 1'b0;
              ADR_CYC = 0;
              if (IO[7:0] == RST_CMD ) begin
                  ->reset_event;
              end
             case ( STATE )
                INIT_STAT,READ_STAT1,READ_STAT2: begin
                    if ( IO[7:0] == READ_CMD1 ) begin
                        status_flag = 1'b0;
                        if ( STATE == READ_STAT2 && sr6 ) begin
                               Page_EN = 1'b1; 
                        end
                        STATE = READ_STAT1;
                    end
                    else if ( IO[7:0] == RAND_CMD1 ) begin
                        status_flag = 1'b0;
                        STATE = RAND_STAT1;
                    end
                    else if ( IO[7:0] == STAT_CMD ) begin
                        status_flag = 1'b1;
                    end
                    else if ( IO[7:0] == RDID_CMD  && !card_op && sr6 ) begin
                        rdid_flag = 1'b1;
                        status_flag = 1'b0;
                    end
                    else if ( IO[7:0] == PGM_CMD1  && !card_op && sr6 && WP_B ) begin
                        for ( pa_count = 0; pa_count <= Top_Byte; pa_count = pa_count + 1) begin
                            Cache[pa_count] = 8'hff;
                        end
                        status_flag = 1'b0;
                        STATE = PGM_STAT1;
                    end
                    else if ( IO[7:0] == BKERS_CMD1  && !card_op && sr6 && WP_B ) begin
                        STATE = ERS_STAT1;
                        ADR_CYC = 2;
                        status_flag = 1'b0;
                    end
                    else if ( IO[7:0] == READ_CMD2  ) begin
                        STATE =  READ_STAT2; 
                        status_flag = 1'b0;
                        ->internal_read;
                    end
                    else if ( IO[7:0] == CARD_CMD2  ) begin
                        STATE =  CARD_STAT1; 
                        card_op = 1'b1;
                        status_flag = 1'b0;
                        ->internal_read;
                    end
                end
                CARD_STAT1: begin
                    if ( IO[7:0] == CARD_CMD3 ) begin
                                ->card_op_event;
                            status_flag = 1'b0;
                            STATE = INIT_STAT;
                    end
                    else if ( IO[7:0] == STAT_CMD ) begin
                            status_flag = 1'b1;
                    end
                    else if ( IO[7:0] == READ_CMD1 ) begin
                            status_flag = 1'b0;
                            if (sr6) begin
                                Page_EN = 1'b1;
                            end
                    end
                    else begin
                    end
                end
                RAND_STAT1: begin
                    if ( IO[7:0] == RAND_CMD2  ) begin
                            STATE =  READ_STAT2;
                            status_flag = 1'b0;
                            Page_EN = 1'b1;
                    end
                    else begin
                            STATE =  INIT_STAT;
                    end
                end
                PGM_STAT1: begin
                    if ( IO[7:0] == PGM_CMD2  ) begin
                        status_flag = 1'b0;
                        STATE =  INIT_STAT;
                        if(capgm_op) begin
                            ->cache_pgm;
                        end
                        else begin
                            ->page_pgm;
                        end
                        ->capgm_op_event;
                    end
                    else if ( IO[7:0] == CAPGM_CMD2  ) begin
                        status_flag = 1'b0;
                        STATE =  INIT_STAT;
                        if(!capgm_op) begin
                            capgm_op = 1;
                            ->page_pgm;
                        end
                        else begin
                            ->cache_pgm;
                        end
                    end
                    else if ( IO[7:0] == RANDIN_CMD1 ) begin
                        status_flag = 1'b0;
                    end
                    else begin
                        status_flag = 1'b0;
                        STATE = INIT_STAT;
                    end
                end
                ERS_STAT1: begin
                    if ( IO[7:0] == BKERS_CMD2  ) begin
                            status_flag = 1'b0;
                            STATE =  INIT_STAT;
                            ->block_ers;
                    end
                    else begin
                            status_flag = 1'b0;
                            STATE =  INIT_STAT;
                    end
                end
                default: begin
                    STATE =  INIT_STAT;
                    status_flag = 1'b0;
                end  
             endcase
             end 
            end
	end
    end

// *==============================================================================================
// * Module blocks Declaration
// *==============================================================================================
    /*----------------------------------------------------------------------*/
    /*  Read related blocks                                                 */
    /*----------------------------------------------------------------------*/
    event another_read;
    always @ ( internal_read ) begin: load_pagebuffer
        #Twb;
        sr5 = 1'b0;
        sr5_flag = 1'b0;
        sr6 = 1'b0;
        Page_EN = 1'b0;
        #(Tr-Twb);
        sr5 = 1'b1;
        sr5_flag = 1'b1;
        sr6 = 1'b1;
        if (!status_flag) begin
           Page_EN = 1'b1; 
        end
        Latch_A_4TMP[A_MSB:CA_MSB+1] = Latch_A[A_MSB:CA_MSB+1];
        Latch_A_4TMP[CA_MSB:0] = 0;
        for ( pa_count = 0; pa_count <= Top_Byte; pa_count = pa_count + 1) begin
            PBuff[pa_count] = ARRAY[Latch_A_4TMP[A_MSB:0] + pa_count];
            Cache[pa_count] = PBuff[pa_count];
        end
        if ( card_op ) begin
            Latch_A[CA_MSB:0] = 0;
            ->another_read;
        end
    end

    always @ ( another_read ) begin: load_pagebuffer2
        Latch_A[A_MSB:CA_MSB+1] = Latch_A[A_MSB:CA_MSB+1] + 1;
        Latch_A[CA_MSB:0] = 0;
        Latch_A_4TMP[A_MSB:CA_MSB+1] = Latch_A[A_MSB:CA_MSB+1];
        Latch_A_4TMP[CA_MSB:0] = 0;
        sr5 = 1'b0;
        sr5_flag = 1'b0;
        #Tr;
        sr5 = 1'b1;
        sr5_flag = 1'b1;
        for ( pa_count = 0; pa_count <= Top_Byte; pa_count = pa_count + 1) begin
            PBuff[pa_count] = ARRAY[Latch_A_4TMP[A_MSB:0] + pa_count];
        end
    end

    always @ ( load_pb2cache ) begin: load_cache
        for ( pa_count = 0; pa_count <= Top_Byte; pa_count = pa_count + 1) begin
            Cache[pa_count] = PBuff[pa_count];
        end
        if ( card_op ) begin
            ->another_read;
        end
    end

    /*----------------------------------------------------------------------*/
    /*  Program related blocks                                              */
    /*----------------------------------------------------------------------*/
    always @ ( page_pgm ) begin: page_pgm_p
        Latch_A_4TMP[A_MSB:CA_MSB+1] = Latch_A[A_MSB:CA_MSB+1];
        Latch_A_4TMP[CA_MSB:0] = 0;
        if ( PGM_Count[Latch_A_4TMP[A_MSB:CA_MSB+1]] == NOP ) begin
            $display($time,"The page in address PA[A_MSB:CA_MSB+1]=%h programmed times reachs NOP limit",Latch_A_4TMP[A_MSB:CA_MSB+1]);
        end
        else begin
            PGM_Count[Latch_A_4TMP[A_MSB:CA_MSB+1]] = PGM_Count[Latch_A_4TMP[A_MSB:CA_MSB+1]] + 1;
        end
        #Twb;
	capgm_op_mode = 1'b0;
        sr6 = 1'b0;
        sr5 = 1'b0;
        sr5_flag = 1'b0;
        pgm_busy = 1'b1;
        #(Tcbsy);
        for ( pa_count = 0; pa_count <= Top_Byte; pa_count = pa_count + 1) begin
            PBuff[pa_count] = Cache[pa_count];
        end
        if(capgm_op) begin
            sr6 = 1'b1;
        end
        #(Tprog-Tcbsy);
        pgm_busy = 1'b0;
        for ( pa_count = 0; pa_count <= Top_Byte; pa_count = pa_count + 1) begin
            //only can be programed from 1->0
            ARRAY[Latch_A_4TMP[A_MSB:0] + pa_count] = PBuff[pa_count]&ARRAY[Latch_A_4TMP[A_MSB:0] + pa_count];
        end
        if(!capgm_op) begin
            sr6 = 1'b1;
        end
        sr5 = 1'b1;
        sr5_flag = 1'b1;
	if (!capgm_op_mode) begin
            capgm_op = 0;
	end
    end

    always @ ( cache_pgm ) begin: cache_pgm_p
        sr6 <= #Twb 1'b0;
	capgm_op_mode = 1'b1;
        wait(sr5);
        sr5 = 1'b0;
        ->page_pgm;
    end

    /*----------------------------------------------------------------------*/
    /*  Erase related blocks                                                */
    /*----------------------------------------------------------------------*/
    integer block_count;
    always @ ( block_ers ) begin: block_ers_p
        #Twb;
        sr6 = 1'b0;
        sr5 = 1'b0;   
        sr5_flag = 1'b0;   
        ers_busy = 1'b1;
        for ( block_count = 0; block_count < Page_NUM; block_count = block_count + 1) begin
          Latch_A[CA_MSB+MSB_PA_IN_BLOCK+1:CA_MSB+1] = block_count;
          for ( pa_count = 0; pa_count <= Top_Byte; pa_count = pa_count + 1) begin
            Latch_A[CA_MSB:0] = pa_count;
            // set unknow first
            ARRAY[Latch_A[A_MSB:0]] = 8'hx;
          end
        end
        #(Terase); 
        ers_busy = 1'b0;
        for ( block_count = 0; block_count < Page_NUM; block_count = block_count + 1) begin
          Latch_A[CA_MSB+MSB_PA_IN_BLOCK+1:CA_MSB+1] = block_count;
          for ( pa_count = 0; pa_count <= Top_Byte; pa_count = pa_count + 1) begin
            Latch_A[CA_MSB:0] = pa_count;
            ARRAY[Latch_A[A_MSB:0]] = ~0;
            PGM_Count[Latch_A[A_MSB:CA_MSB+1]] = 0;
          end 
        end 
        sr5 = 1'b1;
        sr5_flag = 1'b1;
        sr6 = 1'b1;
    end

    /*----------------------------------------------------------------------*/
    /*  Reset related blocks                                                */
    /*----------------------------------------------------------------------*/
    always @ ( negedge WP_B ) begin
        if (ers_busy || pgm_busy)
                -> reset_event;
    end

    always @ ( reset_event ) begin
        #Twb;
        sr6 = 1'b0;
        Page_EN = 1'b0;
        if (ers_busy) fork:rst_ers
            begin
                wait (sr6);
                sr6 = 1'b0;
            end
            begin
                #Trst_e;
                disable rst_ers;
            end
        join
        else if (pgm_busy) fork:rst_pgm
            begin
                wait (sr6);
                sr6 = 1'b0;
            end
            begin
                #Trst_p;
                disable rst_pgm;
            end
        join
        else fork:rst_read
            begin
                wait (sr6);
                sr6 = 1'b0;
            end
            begin
                #Trst_r;
                disable rst_read;
            end
        join
        tk_reset;
    end

    task tk_reset;
    begin
        RYBY_B_Reg      = 1'b1;
        Q_Reg           = 0;
        Latch_A         = 0;
        Latch_A_4TMP    = 0;
        Latch_Q         = 0;
        PA_IN_BLOCK     = 0;
        STATE           = INIT_STAT;
        OUT_EN          = 1'b0;
        OUTZ_EN         = 1'b0;
        Page_EN         = 1'b0;
        sr6             = 1'b1;
        sr5             = 1'b1;
        sr4             = 1'b0;
        sr3             = 1'b0;
        sr2             = 1'b0;
        sr1             = 1'b0;
        sr0             = 1'b0;
        sr5_flag        = 1'b1;
        status_flag     = 1'b0;
        rdid_flag       = 1'b0;
        card_op         = 1'b0;
        capgm_op        = 1'b0;
        capgm_op_mode   = 1'b0;
        //clken           = 1'b0;
        pgm_busy        = 1'b0;
        ers_busy        = 1'b0;
        wait_pgm        = 1'b0;
        j               = 0;
        ADR_CYC         = 0;
        disable load_pagebuffer;
        disable load_pagebuffer2;
        disable load_cache;
        disable page_pgm_p;
        disable cache_pgm_p;
        disable block_ers_p;
    end
    endtask // tk_reset

    always @( OUT_EN_event ) begin
        #Toh OUT_EN = 0;
    end

    always @( card_op_event ) begin
        disable load_pagebuffer;
        disable load_pagebuffer2;
        disable load_cache;
        sr6 = 0;
        sr5 = 0;
        sr5_flag = 0;
        Page_EN = 1'b0;
        #Trcbsy; 
        card_op = 0;
        sr5 = 1;
        sr5_flag = 1;
        sr6 = 1;
    end

    always @( capgm_op_event ) begin
        wait (sr5_flag);
        capgm_op = 0;
    end

endmodule // MX30LF1G08AA
