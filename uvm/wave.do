onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group dut_top /tb/WE_n
add wave -noupdate -expand -group dut_top /tb/rstn
add wave -noupdate -expand -group dut_top /tb/RE_n
add wave -noupdate -expand -group dut_top /tb/R_nB
add wave -noupdate -expand -group dut_top /tb/dut_clk
add wave -noupdate -expand -group dut_top /tb/DIO
add wave -noupdate -expand -group dut_top /tb/clk
add wave -noupdate -expand -group dut_top /tb/CLE
add wave -noupdate -expand -group dut_top /tb/CE_n
add wave -noupdate -expand -group dut_top /tb/ALE
add wave -noupdate -expand -group dut_top /tb/dut/rstn_rr
add wave -noupdate -expand -group dut_top /tb/dut/rstn_r
add wave -noupdate -group AHB /tb/nfc_if/HWRITE
add wave -noupdate -group AHB /tb/nfc_if/HWDATA
add wave -noupdate -group AHB /tb/nfc_if/HADDR
add wave -noupdate -group AHB /tb/nfc_if/HTRANS
add wave -noupdate -group AHB /tb/nfc_if/HSIZE
add wave -noupdate -group AHB /tb/nfc_if/HSEL
add wave -noupdate -group AHB /tb/nfc_if/HRESP
add wave -noupdate -group AHB /tb/nfc_if/HRESET
add wave -noupdate -group AHB /tb/nfc_if/HREADY
add wave -noupdate -group AHB /tb/nfc_if/HRDATA
add wave -noupdate -group AHB /tb/nfc_if/HPROT
add wave -noupdate -group AHB /tb/nfc_if/HMASTLOCK
add wave -noupdate -group AHB /tb/nfc_if/HCLK
add wave -noupdate -group AHB /tb/nfc_if/HBURST
add wave -noupdate -expand -group main_ctrl /tb/dut/Main_FSM/fifo_rdata_cnt_i
add wave -noupdate -expand -group main_ctrl /tb/dut/Main_FSM/MFSM_start_i
add wave -noupdate -expand -group main_ctrl /tb/dut/Main_FSM/current_state
add wave -noupdate -expand -group main_ctrl /tb/dut/fifo_rdata_cnt
add wave -noupdate -expand -group main_ctrl /tb/dut/Main_FSM/next_state
add wave -noupdate -expand -group main_ctrl /tb/dut/Main_FSM/command_r
add wave -noupdate -expand -group main_ctrl /tb/dut/Main_FSM/command_i
add wave -noupdate -expand -group main_ctrl /tb/dut/Main_FSM/ecc_on_i
add wave -noupdate -expand -group main_ctrl /tb/dut/Main_FSM/cmd_code_o
add wave -noupdate -group Register /tb/dut/slave_ctrl/Config_Reg/memory
add wave -noupdate -group Register /tb/dut/slave_ctrl/Config_Reg/haddr_r
add wave -noupdate -group Register /tb/dut/slave_ctrl/flash_write_rr
add wave -noupdate -group Register /tb/dut/slave_ctrl/flash_read_rr
add wave -noupdate -group flash /tb/flash/Power_Up
add wave -noupdate -group fifo /tb/dut/AHB2FLASH_FIFO/wr_rst_busy
add wave -noupdate -group fifo /tb/dut/AHB2FLASH_FIFO/wr_en
add wave -noupdate -group fifo /tb/dut/AHB2FLASH_FIFO/wr_clk
add wave -noupdate -group fifo /tb/dut/AHB2FLASH_FIFO/rst
add wave -noupdate -group fifo /tb/dut/AHB2FLASH_FIFO/rd_rst_busy
add wave -noupdate -group fifo /tb/dut/AHB2FLASH_FIFO/rd_en
add wave -noupdate -group fifo /tb/dut/AHB2FLASH_FIFO/rd_clk
add wave -noupdate -group fifo /tb/dut/AHB2FLASH_FIFO/full
add wave -noupdate -group fifo /tb/dut/AHB2FLASH_FIFO/empty
add wave -noupdate -group fifo /tb/dut/AHB2FLASH_FIFO/dout
add wave -noupdate -group fifo /tb/dut/AHB2FLASH_FIFO/din
add wave -noupdate -group TFSM -radix decimal /tb/dut/TFSM/current_state
add wave -noupdate -group TFSM /tb/dut/TFSM/next_state
add wave -noupdate -group TFSM /tb/dut/TFSM/cmd_code_i
add wave -noupdate -group TFSM /tb/dut/TFSM/ecc_en_i
add wave -noupdate -group TFSM /tb/dut/TFSM/acnt_i
add wave -noupdate -group TOP /tb/dut/ahb2flash_r
add wave -noupdate -group TOP /tb/dut/ecc_on_w
add wave -noupdate -group TOP /tb/dut/ecc_rd_w
add wave -noupdate -group TOP /tb/dut/rd_en_w
add wave -noupdate -expand -group ECC_TOP /tb/dut/ecc_wr_w
add wave -noupdate -expand -group ECC_TOP /tb/dut/ecc_rd_w
add wave -noupdate -expand -group ECC_TOP /tb/dut/ecc_datain_w
add wave -noupdate -expand -group ECC_TOP /tb/dut/ecc_dataout_w
add wave -noupdate -expand -group ECC_TOP /tb/dut/ecc_ready_w
add wave -noupdate -expand -group ECC_TOP /tb/dut/ecc_done_w
add wave -noupdate -expand -group ECC_TOP /tb/dut/ecc_decode_en_w
add wave -noupdate -expand -group ECC_TOP /tb/dut/ecc_encode_en_w
add wave -noupdate -expand -group ECC_TOP /tb/dut/decode_result_w
add wave -noupdate -group {LDPC ECC} -expand -group code /tb/dut/LDPC_ECC_dut/u_ecc_decode_top/u_ecc_decode_control/flash_data
add wave -noupdate -group {LDPC ECC} -expand -group code /tb/dut/LDPC_ECC_dut/u_ecc_decode_top/u_ecc_decode_control/decode_wr_en
add wave -noupdate -group {LDPC ECC} -expand -group code /tb/dut/LDPC_ECC_dut/ecc_code_top/u_ecc_code_control/flash_data
add wave -noupdate -group {LDPC ECC} -expand -group code /tb/dut/LDPC_ECC_dut/ecc_code_top/u_ecc_code_control/ecc_code_rdy_r
add wave -noupdate -group {LDPC ECC} -expand -group code /tb/dut/LDPC_ECC_dut/ecc_code_top/u_ecc_code_control/data_in
add wave -noupdate -group {LDPC ECC} -expand -group code /tb/dut/LDPC_ECC_dut/ecc_code_top/u_ecc_code_control/flash_code_data
add wave -noupdate -group {LDPC ECC} -expand -group code /tb/dut/LDPC_ECC_dut/ecc_code_top/u_ecc_code_control/data_out
add wave -noupdate -group {LDPC ECC} -expand -group code -radix unsigned /tb/dut/LDPC_ECC_dut/ecc_code_top/u_ecc_code_control/counter2
add wave -noupdate -group {LDPC ECC} -expand -group code /tb/dut/LDPC_ECC_dut/ecc_code_top/u_ecc_code_control/code_rd_en
add wave -noupdate -group {LDPC ECC} -expand -group code /tb/dut/LDPC_ECC_dut/ecc_code_top/u_ecc_code_control/counter
add wave -noupdate -group {LDPC ECC} -expand -group code /tb/dut/LDPC_ECC_dut/ecc_code_top/u_ecc_code_control/code_output_over
add wave -noupdate -group {LDPC ECC} /tb/dut/LDPC_ECC_dut/u_ecc_decode_top/u_ecc_decode_control/flash_data
add wave -noupdate -group {LDPC ECC} /tb/dut/LDPC_ECC_dut/u_ecc_decode_top/flash_data
add wave -noupdate -group {LDPC ECC} /tb/dut/LDPC_ECC_dut/u_ecc_decode_top/u_ecc_decode_control/data_in
add wave -noupdate -group {LDPC ECC} -radix unsigned /tb/dut/LDPC_ECC_dut/u_ecc_decode_top/u_ecc_decode_control/counter
add wave -noupdate -group {LDPC ECC} /tb/dut/LDPC_ECC_dut/u_ecc_decode_top/rst_n
add wave -noupdate -group {LDPC ECC} /tb/dut/LDPC_ECC_dut/u_ecc_decode_top/rd_en
add wave -noupdate -group {LDPC ECC} /tb/dut/LDPC_ECC_dut/u_ecc_decode_top/data_in
add wave -noupdate -group {LDPC ECC} /tb/dut/LDPC_ECC_dut/u_ecc_decode_top/ecc_decode_rdy
add wave -noupdate -group {LDPC ECC} /tb/dut/LDPC_ECC_dut/u_ecc_decode_top/ecc_decode_req
add wave -noupdate -group {LDPC ECC} /tb/dut/LDPC_ECC_dut/u_ecc_decode_top/ecc_decode_sta
add wave -noupdate -radix unsigned /tb/dut/LDPC_ECC_dut/u_ecc_decode_top/u_ecc_decode/loop_counter
add wave -noupdate /tb/dut/LDPC_ECC_dut/u_ecc_decode_top/u_ecc_decode/decode_output_over
add wave -noupdate /tb/dut/LDPC_ECC_dut/u_ecc_decode_top/u_ecc_decode/decode_result
add wave -noupdate /tb/dut/LDPC_ECC_dut/u_ecc_decode_top/u_ecc_decode/current_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {876370000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 437
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {869200047 ps} {881980048 ps}
