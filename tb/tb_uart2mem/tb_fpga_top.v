
`timescale  1 ns / 1 ps

module tb_fpga_top;

localparam CLK_FREQ            = 50000000;
localparam UART_BAUD_RATE      = 115200;
localparam UART_PARITY         = "NONE";

reg clk;
reg rst;

initial
begin
    $display("Starting bench");

    //if (`TRACE)
    begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_fpga_top);
        $dumpvars(0, u_top);
    end

    // Reset
    clk = 0;
    rst = 1;
    repeat (5) @(posedge clk);
    rst = 0;	
	
	#100000000
	$finish;
	
end

initial
begin
    forever
    begin 
        clk = #10 ~clk;  // 50Mhz
    end
end

//wire dbg_rxd_w;
//wire dbg_txd_w;
wire [1:0] sw = 2'b01;
wire [3:0] led;

wire uart_from_dut;
wire uart_to_dut;

wire        en_from_dut;
wire [ 7:0] byte_from_dut;

reg         en_to_dut   = 1'b0;
reg  [ 7:0] byte_to_dut = 8'h0;

always @ (posedge clk)
    if (en_from_dut)
        $write("received byte: %02x\n", byte_from_dut);

//-----------------------------------------------------------------------------------------------------------------------------
// generate data to DUT
//-----------------------------------------------------------------------------------------------------------------------------
initial begin
    while  (rst) @(posedge clk);
    repeat (10000) @(posedge clk);


    // write gpio
    @(posedge clk) en_to_dut   <= 1'b1;
                   byte_to_dut <= 8'h10;
    @(posedge clk) byte_to_dut <= 8'h04;
    @(posedge clk) byte_to_dut <= 8'hF0;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h55;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) en_to_dut   <= 1'b0;
    repeat (10000) @(posedge clk);

    // read gpio
    @(posedge clk) en_to_dut   <= 1'b1;
                   byte_to_dut <= 8'h11;
    @(posedge clk) byte_to_dut <= 8'h04;
    @(posedge clk) byte_to_dut <= 8'hF0;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) en_to_dut   <= 1'b0;
    repeat (10000) @(posedge clk);

    // write memory
    @(posedge clk) en_to_dut   <= 1'b1;
                   byte_to_dut <= 8'h10;
    @(posedge clk) byte_to_dut <= 8'h04;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h04;
    @(posedge clk) byte_to_dut <= 8'h12;
    @(posedge clk) byte_to_dut <= 8'h34;
    @(posedge clk) byte_to_dut <= 8'h56;
    @(posedge clk) byte_to_dut <= 8'h78;
    @(posedge clk) en_to_dut   <= 1'b0;
    repeat (10000) @(posedge clk);

    // read memory
    @(posedge clk) en_to_dut   <= 1'b1;
                   byte_to_dut <= 8'h11;
    @(posedge clk) byte_to_dut <= 8'h04;
    @(posedge clk) byte_to_dut <= 8'hF0;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h04;
    @(posedge clk) en_to_dut   <= 1'b0;
    repeat (10000) @(posedge clk);
    
    repeat (10000) @(posedge clk);
    $stop;
end


fpga_top
#(
    .CLK_FREQ(CLK_FREQ)
   ,.UART_SPEED(UART_BAUD_RATE) // Debug bridge UART baud (should match BAUDRATE)
)
u_top
(
     .clk_i(clk)
    ,.rst_i(rst)

    ,.fpga_rxd_i(uart_to_dut)
    ,.fpga_txd_o(uart_from_dut)
	
	,.sw(sw)
	,.led(led)
);

uart_tx #(
    .CLK_FREQ                  ( CLK_FREQ             ),
    .BAUD_RATE                 ( UART_BAUD_RATE       ),
    .PARITY                    ( "NONE"               ),
    .STOP_BITS                 ( 1                    ),
    .BYTE_WIDTH                ( 1                    ),
    .FIFO_EA                   ( 18                   ),
    .EXTRA_BYTE_AFTER_TRANSFER ( ""                   ),
    .EXTRA_BYTE_AFTER_PACKET   ( ""                   )
) u_uart_tx (
    .rstn                      ( !rst                 ),
    .clk                       ( clk                  ),
    .i_tready                  (                      ),
    .i_tvalid                  ( en_to_dut            ),
    .i_tdata                   ( byte_to_dut          ),
    .i_tkeep                   ( 1'b1                 ),
    .i_tlast                   ( 1'b0                 ),
    .o_uart_tx                 ( uart_to_dut          )
);

uart_rx #(
    .CLK_FREQ                  ( CLK_FREQ             ),
    .BAUD_RATE                 ( UART_BAUD_RATE       ),
    .PARITY                    ( "NONE"               ),
    .FIFO_EA                   ( 0                    )
) u_uart_rx (
    .rstn                      ( !rst                 ),
    .clk                       ( clk                  ),
    .i_uart_rx                 ( uart_from_dut        ),
    .o_tready                  ( 1'b1                 ),
    .o_tvalid                  ( en_from_dut          ),
    .o_tdata                   ( byte_from_dut        ),
    .o_overflow                (                      )
);


endmodule