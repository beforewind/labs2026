
//`define DBG_READ_MEMORY 1
//`define DBG_CONTROL_CPU 1

`timescale  1 ns / 1 ps

module tb_top;

localparam CLK_FREQ            = 50000000;
localparam UART_BAUD_RATE      = 115200;
localparam UART_PARITY         = "NONE";

reg clk125mhz;
initial
begin
	clk125mhz = 0;
    forever
    begin 
        clk125mhz = #4 ~clk125mhz;  // 125Mhz board clock
    end
end

reg  clk; //  = u_board.clk_i;
initial
begin
	clk = 0;
    forever
	begin
		clk = #10 ~clk;  // 50Mhz
	end
end

reg  rst;


reg [7:0] mem[131072:0];
integer i;
integer f;
integer file_size;


initial
begin
    $display("Starting bench");

`ifdef TRACE
    begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_top);
		$dumpvars(0, u_board);
    end
`endif

    // Reset
    rst = 1;
    repeat (10) @(posedge clk);
    rst = 0;

	$display("Load program into memory");
    for (i=0;i<131072;i=i+1)
        mem[i] = 0;
	
    //f = $fopen("./build/hello_world.bin", "rb");
    f = $fopen("../../../../../../../sw/build.riscv.hello_world/hello_world.bin", "rb");
    file_size = $fread(mem, f);
    $fclose(f);
	$display("read size:%8x\n", file_size);
    for (i=0;i<file_size;i=i+4)
	begin
        u_top.u_fpga_top.axi_ram.mem[i>>2] = {mem[i+3],mem[i+2],mem[i+1],mem[i]};
		$display("write mem[%08x]=%08x, byte:%02x_%02x_%02x_%02x\n", i, u_top.u_fpga_top.axi_ram.mem[i>>2], mem[i+3],mem[i+2],mem[i+1],mem[i]);
	end
	//file_size = $fread(u_top.u_fpga_top.axi_ram.mem, f);
	//$display("read size2:%8x\n", file_size);

end



wire  [3:0]   led;

wire uart_from_dut;
wire uart_to_dut;

wire        en_from_dut;
wire [ 7:0] byte_from_dut;

reg         en_to_dut   = 1'b0;
reg  [ 7:0] byte_to_dut = 8'h0;


integer file_log;

initial begin
    file_log=0;
	file_log = $fopen("./uart.log", "w");  // 文本方式写log //
end

always @ (posedge clk)
begin
    if (en_from_dut)
	begin
        $write("received byte: %02x\n", byte_from_dut);
		$fwrite(file_log, "%c", byte_from_dut);
	end
end

//-----------------------------------------------------------------------------------------------------------------------------
// generate data to DUT
//-----------------------------------------------------------------------------------------------------------------------------
initial begin
    while  (rst) @(posedge clk);
    repeat (100) @(posedge clk);

`ifdef DBG_READ_MEMORY
    // read memory to check $readmem read .bin ok
    $write("check the fist instruction:\n");
    @(posedge clk) en_to_dut   <= 1'b1;
                   byte_to_dut <= 8'h11;
    @(posedge clk) byte_to_dut <= 8'h04;
    @(posedge clk) byte_to_dut <= 8'h00;  // memory add:0x0
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) en_to_dut   <= 1'b0;
    repeat (10000) @(posedge clk);
`endif

`ifdef DBG_CONTROL_CPU  // 从dbg_bridge发送脱离复位命令启动CPU工作 //
    // write 1 to de-reset u_cpu, cpu脱离复位，开始取指令执行 //
    @(posedge clk) en_to_dut   <= 1'b1;
                   byte_to_dut <= 8'h10;
    @(posedge clk) byte_to_dut <= 8'h04;
    @(posedge clk) byte_to_dut <= 8'hF0;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h01;  // 1-de-reset u_cpu
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) en_to_dut   <= 1'b0;
    repeat (10000) @(posedge clk);
    
`else  // 强行驱动cpu脱离复位
    force u_top.u_fpga_top.u_soc.rst_cpu_i = 1'b0;
`endif

/*
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
*/

/*
    // write 0x00 reset cpu
    @(posedge clk) en_to_dut   <= 1'b1;
                   byte_to_dut <= 8'h10;
    @(posedge clk) byte_to_dut <= 8'h04;
    @(posedge clk) byte_to_dut <= 8'hF0;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) byte_to_dut <= 8'h00;
    @(posedge clk) en_to_dut   <= 1'b0;
    repeat (10000) @(posedge clk);
*/

    repeat (10000000) @(posedge clk);
    
    // close file
    if (file_log) begin
        $fclose(file_log);
    end
    $stop;
end



// stop simulation
// 自循环指令 //
localparam [31:0] INST_JAL_X0_0 = 32'h0000_006f;
localparam [31:0] INST_JAL_X1_0 = 32'h0000_00ef;
wire [31:0] inst_if = u_top.u_fpga_top.u_soc.u_core.u_core.u_fetch.fetch_instr_o;
wire inst_valid = u_top.u_fpga_top.u_soc.u_core.u_core.u_fetch.fetch_valid_o;
wire is_self_jal = inst_valid & (inst_if == INST_JAL_X0_0) || (inst_if == INST_JAL_X1_0);

always @ (posedge clk)
begin
    if (is_self_jal)
	begin
        $write("Stop sim at self jal instruction\n");
        // close file
        if (file_log) begin
            $fclose(file_log);
        end
        $stop;
	end
end



top u_top
(
    .board_clk_i  (clk125mhz),
	.board_rst_i  (rst),
    .led          (led),
	.sw           (2'b01),
    .uart_rxd_o   (uart_from_dut),
    .uart_txd_i   (uart_to_dut)
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