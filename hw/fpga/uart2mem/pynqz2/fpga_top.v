
module fpga_top
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
     parameter CLK_FREQ         = 50000000  // 外部时钟：125M-pynq-z2, 100M-arty-A7，逻辑跑不了这么高的频率? //
    ,parameter UART_SPEED       = 115200   // 1000000
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           fpga_rxd_i  // pc端的txd, fpga的rxd //
    ,input  [ 3:0]   sw          // 4个switches

    // Outputs
    ,output          fpga_txd_o  // pc端的rxd, fpga的txd //
    ,output [ 3:0]   led
);

wire  [  3:0]  axi_t_awid_w;
wire  [ 31:0]  axi_t_wdata_w;
wire           axi_t_rlast_w;
wire  [ 31:0]  axi_t_rdata_w;
wire           axi_t_bvalid_w;
wire           axi_t_awready_w;
wire  [  3:0]  axi_t_arid_w;
wire  [ 31:0]  axi_t_awaddr_w;
wire  [  7:0]  axi_t_arlen_w;
wire           axi_t_wvalid_w;
wire  [ 31:0]  axi_t_araddr_w;
wire  [  1:0]  axi_t_rresp_w;
wire           axi_t_wlast_w;
wire           axi_t_rvalid_w;
wire           axi_t_arvalid_w;
wire           axi_t_arready_w;
wire           axi_t_awvalid_w;
wire  [  7:0]  axi_t_awlen_w;
wire  [  1:0]  axi_t_arburst_w;
wire  [  1:0]  axi_t_awburst_w;
wire  [  3:0]  axi_t_bid_w;
wire           axi_t_wready_w;
wire  [  3:0]  axi_t_rid_w;
wire           axi_t_bready_w;
wire  [  3:0]  axi_t_wstrb_w;
wire  [  1:0]  axi_t_bresp_w;
wire           axi_t_rready_w;

wire  [31:0]   gpio_inputs_w;
wire  [31:0]   gpio_outputs_w;

assign gpio_inputs_w = {28'h0, sw[3:0]};
assign led[3:0] = gpio_outputs_w[3:0];

dbg_bridge
#(
     .CLK_FREQ(CLK_FREQ)
    ,.UART_SPEED(UART_SPEED)
)
u_dbg
(
    // Inputs
     .clk_i        (clk_i)
    ,.rst_i        (rst_i)
    ,.uart_rxd_i   (fpga_rxd_i)
    ,.mem_awready_i(axi_t_awready_w)
    ,.mem_wready_i (axi_t_wready_w)
    ,.mem_bvalid_i (axi_t_bvalid_w)
    ,.mem_bresp_i  (axi_t_bresp_w)
    ,.mem_bid_i    (axi_t_bid_w)
    ,.mem_arready_i(axi_t_arready_w)
    ,.mem_rvalid_i (axi_t_rvalid_w)
    ,.mem_rdata_i  (axi_t_rdata_w)
    ,.mem_rresp_i  (axi_t_rresp_w)
    ,.mem_rid_i    (axi_t_rid_w)
    ,.mem_rlast_i  (axi_t_rlast_w)
    ,.gpio_inputs_i(gpio_inputs_w)

    // Outputs
    ,.uart_txd_o   (fpga_txd_o)
    ,.mem_awvalid_o(axi_t_awvalid_w)
    ,.mem_awaddr_o (axi_t_awaddr_w)
    ,.mem_awid_o   (axi_t_awid_w)
    ,.mem_awlen_o  (axi_t_awlen_w)
    ,.mem_awburst_o(axi_t_awburst_w)
    ,.mem_wvalid_o (axi_t_wvalid_w)
    ,.mem_wdata_o  (axi_t_wdata_w)
    ,.mem_wstrb_o  (axi_t_wstrb_w)
    ,.mem_wlast_o  (axi_t_wlast_w)
    ,.mem_bready_o (axi_t_bready_w)
    ,.mem_arvalid_o(axi_t_arvalid_w)
    ,.mem_araddr_o (axi_t_araddr_w)
    ,.mem_arid_o   (axi_t_arid_w)
    ,.mem_arlen_o  (axi_t_arlen_w)
    ,.mem_arburst_o(axi_t_arburst_w)
    ,.mem_rready_o (axi_t_rready_w)
    ,.gpio_outputs_o(gpio_outputs_w)
);

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
    .s_axi_awid   (axi_t_awid_w),
    .s_axi_awaddr (axi_t_awaddr_w),
    .s_axi_awlen  (axi_t_awlen_w),
    .s_axi_awsize (3'b010),
    .s_axi_awburst(axi_t_awburst_w),
    .s_axi_awlock (1'b0),
    .s_axi_awcache(4'b0000),
    .s_axi_awprot (3'b000),
    .s_axi_awvalid(axi_t_awvalid_w),
    .s_axi_awready(axi_t_awready_w),
    .s_axi_wdata  (axi_t_wdata_w),
    .s_axi_wstrb  (axi_t_wstrb_w),
    .s_axi_wlast  (axi_t_wlast_w),
    .s_axi_wvalid (axi_t_wvalid_w),
    .s_axi_wready (axi_t_wready_w),
    .s_axi_bid    (axi_t_bid_w),
    .s_axi_bresp  (axi_t_bresp_w),
    .s_axi_bvalid (axi_t_bvalid_w),
    .s_axi_bready (axi_t_bready_w),
    .s_axi_arid   (axi_t_arid_w),
    .s_axi_araddr (axi_t_araddr_w),
    .s_axi_arlen  (axi_t_arlen_w),
    .s_axi_arsize (3'b010),
    .s_axi_arburst(axi_t_arburst_w),
    .s_axi_arlock (1'b0),
    .s_axi_arcache(4'b0000),
    .s_axi_arprot (3'b000),
    .s_axi_arvalid(axi_t_arvalid_w),
    .s_axi_arready(axi_t_arready_w),
    .s_axi_rid    (axi_t_rid_w),
    .s_axi_rdata  (axi_t_rdata_w),
    .s_axi_rresp  (axi_t_rresp_w),
    .s_axi_rlast  (axi_t_rlast_w),
    .s_axi_rvalid (axi_t_rvalid_w),
    .s_axi_rready (axi_t_rready_w)
);

endmodule
