

module fpga_top
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
     parameter CLK_FREQ         = 50000000
    ,parameter BAUDRATE         = 115200
    ,parameter UART_SPEED       = 115200
    ,parameter C_SCK_RATIO      = 50
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     input           clk_i
    ,input           rst_i

    ,input  [ 31:0]  gpio_input_i

    ,output [ 31:0]  gpio_output_o
    ,output [ 31:0]  gpio_output_enable_o

    ,input           dbg_txd_i
    ,output          dbg_rxd_o

    ,input           uart_txd_i
    ,output          uart_rxd_o

    ,input           spi_miso_i    
    ,output          spi_clk_o
    ,output          spi_mosi_o
    ,output          spi_cs_o
);

//-------------------------------------------------------------
// Debug
//-------------------------------------------------------------
`define DBG_BIT_RELEASE_RESET 0
`define DBG_BIT_ENABLE_DEBUG  1
`define DBG_BIT_CAPTURE_HI    2
`define DBG_BIT_CAPTURE_LO    3
`define DBG_BIT_DEBUG_WRITE   4

// dbg
wire  [  3:0]  axi_dbg_awid_w;
wire  [ 31:0]  axi_dbg_wdata_w;
wire           axi_dbg_rlast_w;
wire  [ 31:0]  axi_dbg_rdata_w;
wire           axi_dbg_bvalid_w;
wire           axi_dbg_awready_w;
wire  [  3:0]  axi_dbg_arid_w;
wire  [ 31:0]  axi_dbg_awaddr_w;
wire  [  7:0]  axi_dbg_arlen_w;
wire           axi_dbg_wvalid_w;
wire  [ 31:0]  axi_dbg_araddr_w;
wire  [  1:0]  axi_dbg_rresp_w;
wire           axi_dbg_wlast_w;
wire           axi_dbg_rvalid_w;
wire           axi_dbg_arvalid_w;
wire           axi_dbg_arready_w;
wire           axi_dbg_awvalid_w;
wire  [  7:0]  axi_dbg_awlen_w;
wire  [  1:0]  axi_dbg_arburst_w;
wire  [  1:0]  axi_dbg_awburst_w;
wire  [  3:0]  axi_dbg_bid_w;
wire           axi_dbg_wready_w;
wire  [  3:0]  axi_dbg_rid_w;
wire           axi_dbg_bready_w;
wire  [  3:0]  axi_dbg_wstrb_w;
wire  [  1:0]  axi_dbg_bresp_w;
wire           axi_dbg_rready_w;

//wire  [31:0]   gpio_inputs_w;
//wire  [31:0]   gpio_outputs_w;

wire  [ 31:0]  enable_w;
wire  [ 31:0]  reset_vector_w = 32'h00000000;
wire           rst_cpu_w;

// 从uart复位cpu，上电rst_cpu_w=1，处于复位状态，通过向寄存器0xF000_0000写入0x1，使cpu脱离复位 //
assign rst_cpu_w       = ~enable_w[`DBG_BIT_RELEASE_RESET];

dbg_bridge
#(
     .CLK_FREQ  (CLK_FREQ)
    ,.UART_SPEED(UART_SPEED)
)
u_dbg
(
     .clk_i        (clk_i)
    ,.rst_i        (rst_i)

    ,.uart_rxd_i   (dbg_txd_i)
    ,.uart_txd_o   (dbg_rxd_o)

    ,.gpio_inputs_i(32'h12345678)  // magic number
    ,.gpio_outputs_o(enable_w)     // 用于复位CPU //

    ,.mem_awready_i(axi_dbg_awready_w)
    ,.mem_wready_i (axi_dbg_wready_w)
    ,.mem_bvalid_i (axi_dbg_bvalid_w)
    ,.mem_bresp_i  (axi_dbg_bresp_w)
    ,.mem_bid_i    (4'b0000)
    ,.mem_arready_i(axi_dbg_arready_w)
    ,.mem_rvalid_i (axi_dbg_rvalid_w)
    ,.mem_rdata_i  (axi_dbg_rdata_w)
    ,.mem_rresp_i  (axi_dbg_rresp_w)
    ,.mem_rid_i    (4'b0000)
    ,.mem_rlast_i  (1'b0)
    ,.mem_awvalid_o(axi_dbg_awvalid_w)
    ,.mem_awaddr_o (axi_dbg_awaddr_w)
    ,.mem_awid_o   (axi_dbg_awid_w)
    ,.mem_awlen_o  (axi_dbg_awlen_w)
    ,.mem_awburst_o(axi_dbg_awburst_w)
    ,.mem_wvalid_o (axi_dbg_wvalid_w)
    ,.mem_wdata_o  (axi_dbg_wdata_w)
    ,.mem_wstrb_o  (axi_dbg_wstrb_w)
    ,.mem_wlast_o  (axi_dbg_wlast_w)
    ,.mem_bready_o (axi_dbg_bready_w)
    ,.mem_arvalid_o(axi_dbg_arvalid_w)
    ,.mem_araddr_o (axi_dbg_araddr_w)
    ,.mem_arid_o   (axi_dbg_arid_w)
    ,.mem_arlen_o  (axi_dbg_arlen_w)
    ,.mem_arburst_o(axi_dbg_arburst_w)
    ,.mem_rready_o (axi_dbg_rready_w)
);


wire           axi_mem_awready_w;
wire           axi_mem_wready_w;
wire           axi_mem_bvalid_w;
wire  [  1:0]  axi_mem_bresp_w;
wire  [  3:0]  axi_mem_bid_w;
wire           axi_mem_arready_w;
wire           axi_mem_rvalid_w;
wire  [ 31:0]  axi_mem_rdata_w;
wire  [  1:0]  axi_mem_rresp_w;
wire  [  3:0]  axi_mem_rid_w;
wire           axi_mem_rlast_w;
wire           axi_mem_awvalid_w;
wire  [ 31:0]  axi_mem_awaddr_w;
wire  [  3:0]  axi_mem_awid_w;
wire  [  7:0]  axi_mem_awlen_w;
wire  [  1:0]  axi_mem_awburst_w;
wire           axi_mem_wvalid_w;
wire  [ 31:0]  axi_mem_wdata_w;
wire  [  3:0]  axi_mem_wstrb_w;
wire           axi_mem_wlast_w;
wire           axi_mem_bready_w;
wire           axi_mem_arvalid_w;
wire  [ 31:0]  axi_mem_araddr_w;
wire  [  3:0]  axi_mem_arid_w;
wire  [  7:0]  axi_mem_arlen_w;
wire  [  1:0]  axi_mem_arburst_w;
wire           axi_mem_rready_w;


axi_ram #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(16),
    .STRB_WIDTH(32/8),
    .ID_WIDTH(4),
    .PIPELINE_OUTPUT(0)
)
axi_ram (
    .clk          (clk_i),
    .rst          (rst_i),
    .s_axi_awid   (axi_mem_awid_w),
    .s_axi_awaddr (axi_mem_awaddr_w),
    .s_axi_awlen  (axi_mem_awlen_w),
    .s_axi_awsize (3'b010),
    .s_axi_awburst(axi_mem_awburst_w),
    .s_axi_awlock (1'b0),
    .s_axi_awcache(4'b0000),
    .s_axi_awprot (3'b000),
    .s_axi_awvalid(axi_mem_awvalid_w),
    .s_axi_awready(axi_mem_awready_w),

    .s_axi_wdata  (axi_mem_wdata_w),
    .s_axi_wstrb  (axi_mem_wstrb_w),
    .s_axi_wlast  (axi_mem_wlast_w),
    .s_axi_wvalid (axi_mem_wvalid_w),
    .s_axi_wready (axi_mem_wready_w),

    .s_axi_bid    (axi_mem_bid_w),
    .s_axi_bresp  (axi_mem_bresp_w),
    .s_axi_bvalid (axi_mem_bvalid_w),
    .s_axi_bready (axi_mem_bready_w),

    .s_axi_arid   (axi_mem_arid_w),
    .s_axi_araddr (axi_mem_araddr_w),
    .s_axi_arlen  (axi_mem_arlen_w),
    .s_axi_arsize (3'b010),
    .s_axi_arburst(axi_mem_arburst_w),
    .s_axi_arlock (1'b0),
    .s_axi_arcache(4'b0000),
    .s_axi_arprot (3'b000),
    .s_axi_arvalid(axi_mem_arvalid_w),
    .s_axi_arready(axi_mem_arready_w),
    .s_axi_rid    (axi_mem_rid_w),
    .s_axi_rdata  (axi_mem_rdata_w),
    .s_axi_rresp  (axi_mem_rresp_w),
    .s_axi_rlast  (axi_mem_rlast_w),
    .s_axi_rvalid (axi_mem_rvalid_w),
    .s_axi_rready (axi_mem_rready_w)
);


riscv_soc
#(
     .CLK_FREQ(CLK_FREQ)
    ,.BAUDRATE(BAUDRATE)
    ,.C_SCK_RATIO(C_SCK_RATIO)
)
 u_soc
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
	
    ,.reset_vector_i(reset_vector_w)
	
    ,.inport_awvalid_i(axi_dbg_awvalid_w)
    ,.inport_awaddr_i (axi_dbg_awaddr_w )
    ,.inport_wvalid_i (axi_dbg_wvalid_w )
    ,.inport_wdata_i  (axi_dbg_wdata_w  )
    ,.inport_wstrb_i  (axi_dbg_wstrb_w  )
    ,.inport_bready_i (axi_dbg_bready_w )
    ,.inport_arvalid_i(axi_dbg_arvalid_w)
    ,.inport_araddr_i (axi_dbg_araddr_w )
    ,.inport_rready_i (axi_dbg_rready_w )
    ,.inport_awready_o(axi_dbg_awready_w)
    ,.inport_wready_o (axi_dbg_wready_w )
    ,.inport_bvalid_o (axi_dbg_bvalid_w )
    ,.inport_bresp_o  (axi_dbg_bresp_w  )
    ,.inport_arready_o(axi_dbg_arready_w)
    ,.inport_rvalid_o (axi_dbg_rvalid_w )
    ,.inport_rdata_o  (axi_dbg_rdata_w  )
    ,.inport_rresp_o  (axi_dbg_rresp_w  )

    ,.mem_awready_i(axi_mem_awready_w)
    ,.mem_wready_i (axi_mem_wready_w )
    ,.mem_bvalid_i (axi_mem_bvalid_w )
    ,.mem_bresp_i  (axi_mem_bresp_w  )
    ,.mem_bid_i    (axi_mem_bid_w    )
    ,.mem_arready_i(axi_mem_arready_w)
    ,.mem_rvalid_i (axi_mem_rvalid_w )
    ,.mem_rdata_i  (axi_mem_rdata_w  )
    ,.mem_rresp_i  (axi_mem_rresp_w  )
    ,.mem_rid_i    (axi_mem_rid_w    )
    ,.mem_rlast_i  (axi_mem_rlast_w  )
    ,.mem_awvalid_o(axi_mem_awvalid_w)
    ,.mem_awaddr_o (axi_mem_awaddr_w )
    ,.mem_awid_o   (axi_mem_awid_w   )
    ,.mem_awlen_o  (axi_mem_awlen_w  )
    ,.mem_awburst_o(axi_mem_awburst_w)
    ,.mem_wvalid_o (axi_mem_wvalid_w )
    ,.mem_wdata_o  (axi_mem_wdata_w  )
    ,.mem_wstrb_o  (axi_mem_wstrb_w  )
    ,.mem_wlast_o  (axi_mem_wlast_w  )
    ,.mem_bready_o (axi_mem_bready_w )
    ,.mem_arvalid_o(axi_mem_arvalid_w)
    ,.mem_araddr_o (axi_mem_araddr_w )
    ,.mem_arid_o   (axi_mem_arid_w   )
    ,.mem_arlen_o  (axi_mem_arlen_w  )
    ,.mem_arburst_o(axi_mem_arburst_w)
    ,.mem_rready_o (axi_mem_rready_w )

    ,.rst_cpu_i    (rst_cpu_w)
    ,.spi_miso_i   (spi_miso_i)
    ,.uart_txd_i   (uart_txd_i)
    ,.gpio_input_i (gpio_input_i)
    ,.spi_clk_o    (spi_clk_o)
    ,.spi_mosi_o   (spi_mosi_o)
    ,.spi_cs_o     (spi_cs_o)
    ,.uart_rxd_o   (uart_rxd_o)
    ,.gpio_output_o(gpio_output_o)
    ,.gpio_output_enable_o(gpio_output_enable_o)
);



endmodule
