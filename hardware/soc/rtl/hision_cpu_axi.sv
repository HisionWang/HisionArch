// HisionArch CPU-only SoC. See docs/architecture/cpu-soc.md.
`default_nettype none
module hision_cpu_axi (
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk CLK", X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF M_AXI, ASSOCIATED_RESET aresetn" *)
  input wire aclk,
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aresetn RST", X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
  input wire aresetn,
  input wire run_requested,
  input wire calibrated,
  output wire cpu_in_reset,
  output wire bus_busy,
  output reg bus_error,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWID" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI, PROTOCOL AXI4, ADDR_WIDTH 64, DATA_WIDTH 64, READ_WRITE_MODE READ_WRITE, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, ID_WIDTH 4, HAS_BURST 1, HAS_LOCK 1, HAS_CACHE 1, HAS_QOS 1, HAS_PROT 1, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1" *)
  output wire [3:0] m_axi_awid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWADDR" *)
  output wire [63:0] m_axi_awaddr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWLEN" *)
  output wire [7:0] m_axi_awlen,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWSIZE" *)
  output wire [2:0] m_axi_awsize,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWBURST" *)
  output wire [1:0] m_axi_awburst,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWLOCK" *)
  output wire m_axi_awlock,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWCACHE" *)
  output wire [3:0] m_axi_awcache,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWPROT" *)
  output wire [2:0] m_axi_awprot,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWQOS" *)
  output wire [3:0] m_axi_awqos,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWVALID" *)
  output wire m_axi_awvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWREADY" *)
  input wire m_axi_awready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WDATA" *)
  output wire [63:0] m_axi_wdata,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WSTRB" *)
  output wire [7:0] m_axi_wstrb,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WLAST" *)
  output wire m_axi_wlast,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WVALID" *)
  output wire m_axi_wvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WREADY" *)
  input wire m_axi_wready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BID" *)
  input wire [3:0] m_axi_bid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BRESP" *)
  input wire [1:0] m_axi_bresp,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BVALID" *)
  input wire m_axi_bvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BREADY" *)
  output wire m_axi_bready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARID" *)
  output wire [3:0] m_axi_arid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARADDR" *)
  output wire [63:0] m_axi_araddr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARLEN" *)
  output wire [7:0] m_axi_arlen,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARSIZE" *)
  output wire [2:0] m_axi_arsize,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARBURST" *)
  output wire [1:0] m_axi_arburst,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARLOCK" *)
  output wire m_axi_arlock,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARCACHE" *)
  output wire [3:0] m_axi_arcache,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARPROT" *)
  output wire [2:0] m_axi_arprot,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARQOS" *)
  output wire [3:0] m_axi_arqos,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARVALID" *)
  output wire m_axi_arvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARREADY" *)
  input wire m_axi_arready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RID" *)
  input wire [3:0] m_axi_rid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RDATA" *)
  input wire [63:0] m_axi_rdata,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RRESP" *)
  input wire [1:0] m_axi_rresp,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RLAST" *)
  input wire m_axi_rlast,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RVALID" *)
  input wire m_axi_rvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RREADY" *)
  output wire m_axi_rready
);
  localparam IDLE=2'd0, READ=2'd1, WRITE=2'd2;
  reg [1:0] state;
  reg ar_sent, aw_sent, w_done;
  reg [1:0] release_pipe;
  wire core_resetn = release_pipe[1];
  assign cpu_in_reset = !core_resetn;
  assign bus_busy = (state != IDLE);

  // A stop request drains the selected external transaction before resetting
  // the core. This is cold restart, not architectural halt or cache writeback.
  always @(posedge aclk) begin
    if (!aresetn) release_pipe <= 2'b00;
    else if (!run_requested && state == IDLE) release_pipe <= 2'b00;
    else if (run_requested && calibrated) release_pipe <= {release_pipe[0],1'b1};
  end
  wire [3:0] c_awid;
  wire [63:0] c_awaddr;
  wire [7:0] c_awlen;
  wire [2:0] c_awsize;
  wire [1:0] c_awburst;
  wire c_awlock;
  wire [3:0] c_awcache;
  wire [2:0] c_awprot;
  wire [3:0] c_awqos;
  wire c_awvalid;
  wire c_awready;
  wire [63:0] c_wdata;
  wire [7:0] c_wstrb;
  wire c_wlast;
  wire c_wvalid;
  wire c_wready;
  wire [3:0] c_bid;
  wire [1:0] c_bresp;
  wire c_bvalid;
  wire c_bready;
  wire [3:0] c_arid;
  wire [63:0] c_araddr;
  wire [7:0] c_arlen;
  wire [2:0] c_arsize;
  wire [1:0] c_arburst;
  wire c_arlock;
  wire [3:0] c_arcache;
  wire [2:0] c_arprot;
  wire [3:0] c_arqos;
  wire c_arvalid;
  wire c_arready;
  wire [3:0] c_rid;
  wire [63:0] c_rdata;
  wire [1:0] c_rresp;
  wire c_rlast;
  wire c_rvalid;
  wire c_rready;

  always @(posedge aclk) begin
    if (!aresetn) begin
      state <= IDLE;
      ar_sent <= 1'b0;
      aw_sent <= 1'b0;
      w_done <= 1'b0;
      bus_error <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          ar_sent <= 1'b0;
          aw_sent <= 1'b0;
          w_done <= 1'b0;
          if (run_requested && calibrated && core_resetn) begin
            if (c_awvalid || c_wvalid) state <= WRITE;
            else if (c_arvalid) state <= READ;
          end
        end
        READ: begin
          if (m_axi_arvalid && m_axi_arready) ar_sent <= 1'b1;
          if (m_axi_rvalid && m_axi_rready) begin
            if (m_axi_rresp != 2'b00) bus_error <= 1'b1;
            if (m_axi_rlast) state <= IDLE;
          end
        end
        WRITE: begin
          if (m_axi_awvalid && m_axi_awready) aw_sent <= 1'b1;
          if (m_axi_wvalid && m_axi_wready && m_axi_wlast) w_done <= 1'b1;
          if (m_axi_bvalid && m_axi_bready) begin
            if (m_axi_bresp != 2'b00) bus_error <= 1'b1;
            state <= IDLE;
          end
        end
        default: state <= IDLE;
      endcase
    end
  end
  assign m_axi_awid = c_awid;
  assign m_axi_awaddr = c_awaddr;
  assign m_axi_awlen = c_awlen;
  assign m_axi_awsize = c_awsize;
  assign m_axi_awburst = c_awburst;
  assign m_axi_awlock = c_awlock;
  assign m_axi_awcache = c_awcache;
  assign m_axi_awprot = c_awprot;
  assign m_axi_awqos = c_awqos;
  assign m_axi_awvalid = (state == WRITE && !aw_sent) && c_awvalid;
  assign c_awready = (state == WRITE && !aw_sent) && m_axi_awready;
  assign m_axi_wdata = c_wdata;
  assign m_axi_wstrb = c_wstrb;
  assign m_axi_wlast = c_wlast;
  assign m_axi_wvalid = (state == WRITE && !w_done) && c_wvalid;
  assign c_wready = (state == WRITE && !w_done) && m_axi_wready;
  assign c_bid = m_axi_bid;
  assign c_bresp = m_axi_bresp;
  assign c_bvalid = (state == WRITE) && m_axi_bvalid;
  assign m_axi_bready = (state == WRITE) && c_bready;
  assign m_axi_arid = c_arid;
  assign m_axi_araddr = c_araddr;
  assign m_axi_arlen = c_arlen;
  assign m_axi_arsize = c_arsize;
  assign m_axi_arburst = c_arburst;
  assign m_axi_arlock = c_arlock;
  assign m_axi_arcache = c_arcache;
  assign m_axi_arprot = c_arprot;
  assign m_axi_arqos = c_arqos;
  assign m_axi_arvalid = (state == READ && !ar_sent) && c_arvalid;
  assign c_arready = (state == READ && !ar_sent) && m_axi_arready;
  assign c_rid = m_axi_rid;
  assign c_rdata = m_axi_rdata;
  assign c_rresp = m_axi_rresp;
  assign c_rlast = m_axi_rlast;
  assign c_rvalid = (state == READ) && m_axi_rvalid;
  assign m_axi_rready = (state == READ) && c_rready;

  core_top core (
    .aclk(aclk),
    .aresetn(core_resetn),
    .intrpt(8'b0),
    .break_point(1'b0),
    .infor_flag(1'b0),
    .reg_num(5'b0),
    .awid(c_awid),
    .awaddr(c_awaddr),
    .awlen(c_awlen),
    .awsize(c_awsize),
    .awburst(c_awburst),
    .awlock(c_awlock),
    .awcache(c_awcache),
    .awprot(c_awprot),
    .awqos(c_awqos),
    .awvalid(c_awvalid),
    .awready(c_awready),
    .wdata(c_wdata),
    .wstrb(c_wstrb),
    .wlast(c_wlast),
    .wvalid(c_wvalid),
    .wready(c_wready),
    .bid(c_bid),
    .bresp(c_bresp),
    .bvalid(c_bvalid),
    .bready(c_bready),
    .arid(c_arid),
    .araddr(c_araddr),
    .arlen(c_arlen),
    .arsize(c_arsize),
    .arburst(c_arburst),
    .arlock(c_arlock),
    .arcache(c_arcache),
    .arprot(c_arprot),
    .arqos(c_arqos),
    .arvalid(c_arvalid),
    .arready(c_arready),
    .rid(c_rid),
    .rdata(c_rdata),
    .rresp(c_rresp),
    .rlast(c_rlast),
    .rvalid(c_rvalid),
    .rready(c_rready),
    .awuser(),
    .aruser(),
    .wuser(),
    .buser(1'b0),
    .ruser(1'b0),
    .ws_valid(),
    .rf_rdata(),
    .debug0_wb_pc(),
    .debug0_wb_rf_wen(),
    .debug0_wb_rf_wnum(),
    .debug0_wb_rf_wdata(),
    .debug0_wb_inst(),
    .commit_valid_0(),
    .commit_valid_1(),
    .commit_valid_2(),
    .commit_pc_0(),
    .commit_pc_1(),
    .commit_pc_2(),
    .commit_inst_0(),
    .commit_inst_1(),
    .commit_inst_2()
  );
endmodule
`default_nettype wire
