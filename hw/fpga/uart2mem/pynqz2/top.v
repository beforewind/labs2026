//-----------------------------------------------------------------
// TOP
//-----------------------------------------------------------------

`define PYNQ_Z2

module top
(
     input           board_clk_i
    ,input           board_rst_i
	
    // UART
    ,input           uart_txd_i
    ,output          uart_rxd_o
`ifdef PYNQ_Z2
    ,input  [ 1:0]   sw
`else
    ,input  [ 3:0]   sw
`endif
    ,output [ 3:0]   led
);

//-----------------------------------------------------------------
// clock & reset
//-----------------------------------------------------------------
wire clk;
wire rst;

`ifdef PYNQ_Z2

pynqz2_pll
u_pll
(
    .clkref_i(board_clk_i),  // 125Mhz
    .clkout0_o(clk)          // 50Mhz
);

/*
reset_gen
u_rst
(
    .clk_i(clk),
    .rst_o(rst)
);
*/

assign rst = board_rst_i;

`else

artix7_pll
u_pll
(
    .clkref_i(board_clk_i),  // 100Mhz
    .clkout0_o(clk)          // 50Mhz
);

/*
reset_gen
u_rst
(
    .clk_i(clk),
    .rst_o(rst)
);
*/

assign rst = board_rst_i;

`endif




//-----------------------------------------------------------------
// Core
//-----------------------------------------------------------------

fpga_top
#(
    .CLK_FREQ(50000000)
   ,.UART_SPEED(115200)    // Debug bridge UART baud (should match BAUDRATE)
)
u_top
(
     .clk_i(clk)
    ,.rst_i(rst)

    ,.fpga_rxd_i(uart_txd_i)
    ,.fpga_txd_o(uart_rxd_o)  // 命名变化
`ifdef PYNQ_Z2
    ,.sw({2'b00,sw[1:0]})
`else
    ,.sw(sw[3:0])
`endif
    ,.led(led[3:0])
);

endmodule
