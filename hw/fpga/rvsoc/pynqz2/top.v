//-----------------------------------------------------------------
// TOP
//-----------------------------------------------------------------
module top
(
    input                   board_clk_i,  // 125Mhz
	input                   board_rst_i,
    output [3:0]            led,
	input  [1:0]            sw,
    output                  uart_rxd_o,
    input                   uart_txd_i

    // output                  qspi_sck,
    // output                  qspi_cs,
    // inout [3:0]             qspi_dq
);

//-----------------------------------------------------------------
// Implementation
//-----------------------------------------------------------------
wire           clk100;
wire           clk50;
wire           clk25;


pynqz2_pll
u_pll
(
    .clkref_i (board_clk_i),  // 125Mhz
    .clkout0_o(clk100), // 100Mhz
    .clkout1_o(clk50),  // 50Mhz
    .clkout2_o(clk25)   // 25Mhz
);

wire clk_i = clk50;
//wire clk_i = clk25;
wire rst_i = board_rst_i;



wire dbg_txd_w;
wire uart_txd_w;
wire [31:0] gpio_output_w;
assign led[3:0] = gpio_output_w[3:0];

fpga_top
#(
    .CLK_FREQ(50000000)  // 50Mhz
//    .CLK_FREQ(25000000)  // 25Mhz
    ,.BAUDRATE(115200)
    ,.UART_SPEED(115200)    // Debug bridge UART baud (should match BAUDRATE)
    ,.C_SCK_RATIO(50)
)
u_fpga_top
(
    .clk_i(clk_i),
    .rst_i(rst_i),      // (rst_sys_w),

    // GPIO
    .gpio_input_i ({30'b0, sw[1:0]}),
    .gpio_output_o(gpio_output_w),
    .gpio_output_enable_o(),

    // UART
    .dbg_rxd_o(dbg_txd_w),
    .dbg_txd_i(uart_txd_i),

    .uart_rxd_o(uart_txd_w),
    .uart_txd_i(uart_txd_i),

    // SPI
    .spi_miso_i(1'b0),
    .spi_clk_o(),
    .spi_mosi_o(),
    .spi_cs_o()
);

// Xilinx placement pragmas:
//synthesis attribute IOB of txd_q is "TRUE"
reg txd_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    txd_q <= 1'b1;
else
    txd_q <= dbg_txd_w & uart_txd_w;

// 'OR' two UARTs together
assign uart_rxd_o  = txd_q;


// assign led[0] = 1'b1;
// assign led[1] = 1'b0;
// assign led[2] = 1'b1;
// assign led[3] = 1'b0;

// assign qspi_dq[2] = 1'bz;
// assign qspi_dq[3] = 1'bz;
// assign qspi_dq[0] = 1'bz;
// assign qspi_dq[1] = 1'bz;

// assign qspi_sck = 1'b0;
// assign qspi_cs = 1'b0;

endmodule
