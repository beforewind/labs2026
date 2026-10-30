del sim.out dump.vcd
iverilog  -g2001  -o sim.out  tb_fpga_top.v uart_rx.v uart_tx.v ../../soc/dbg_bridge/src_v/dbg_bridge.v ../../soc/dbg_bridge/src_v/dbg_bridge_fifo.v ../../soc/dbg_bridge/src_v/dbg_bridge_uart.v ../../soc/verilog-axi/rtl/axi_ram.v ../../fpga/uart2mem/fpga_top.v
vvp -n sim.out
del sim.out
pause