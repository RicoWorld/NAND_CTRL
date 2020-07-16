# This is NAND FLASH verilog source(option ecc)

######################################
## fifo_generator_0.v / DATA_Buffer.v
######################################
# This Module is implemented as asynchronous fifo which facilitates storing 
# of data when host writes data into the Flash and Reads data from the Flash
# You can use fifo_generator_0.v which is fifo IP of Xilinx ,or using DATA_Buffer.v

######################################
## AHB_SLAVE.v
######################################
# This Module is interface to AHB host 

######################################
## Register.v
######################################
##   REG MAP
// |主机寻址范围       |说明
// |0x0000——0x03FF    |BUFFER1 数据位宽32，总大小1024 byte
// |0x0500            |存储器时序参数寄存器，高16bit建立时间有关，低16bit保持时间
// |0x0504            |页内地址，colume address
// |0x0508            |块地址，row address
// |0x050C            |第0位表示ecc使能信号，1'b1:ON  ; 1’b0:off
//                    |第1位选择大小页模式， 1'b1:大页; 1'b0:小页
//                    |第2位选择协议模式,    1'b1:ONFI; 1'b0:toggle
//                    |第3位选择row地址长度, 1'b1:3byte; 1'b0:2byte
// |0x0510            |控制器命令寄存器
// |0x0514            |ID REGISTER 1
// |0x0518            |ID REGISTER 2
// |0x051C            |存储器状态寄存器，用于读取存储器状态
// |0x0520            |主控逻辑状态寄存器，用于读取存储器状态

######################################
## Main_Ctroller.v & Timing_Ctroller.v
######################################
# Main FSM-This FSM works together with timing FSM where the module interprets command 
# from the host and passes control signals to the timing FSM which creates all the necessary 
# controls for NAND flash to execute the repeated task with strict timing requirements. 
# Address Counter Module-Generates Address control signals required for the data buffer 
# module based state machine in the main FSM. 

