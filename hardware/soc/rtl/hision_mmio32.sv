// HisionArch CPU-only SoC. See docs/architecture/cpu-soc.md.
`default_nettype none
module hision_mmio32 #(parameter integer REGISTER_COUNT=4) (
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk CLK", X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF S_AXI:M_AXI, ASSOCIATED_RESET aresetn" *)
  input wire aclk,
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aresetn RST", X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
  input wire aresetn,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWADDR" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI, PROTOCOL AXI4LITE, ADDR_WIDTH 64, DATA_WIDTH 64, READ_WRITE_MODE READ_WRITE, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1" *)
  input wire [63:0] s_axi_awaddr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWPROT" *)
  input wire [2:0] s_axi_awprot,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWVALID" *)
  input wire s_axi_awvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWREADY" *)
  output wire s_axi_awready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WDATA" *)
  input wire [63:0] s_axi_wdata,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WSTRB" *)
  input wire [7:0] s_axi_wstrb,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WVALID" *)
  input wire s_axi_wvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WREADY" *)
  output wire s_axi_wready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BRESP" *)
  output wire [1:0] s_axi_bresp,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BVALID" *)
  output wire s_axi_bvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BREADY" *)
  input wire s_axi_bready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARADDR" *)
  input wire [63:0] s_axi_araddr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARPROT" *)
  input wire [2:0] s_axi_arprot,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARVALID" *)
  input wire s_axi_arvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARREADY" *)
  output wire s_axi_arready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RDATA" *)
  output wire [63:0] s_axi_rdata,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RRESP" *)
  output wire [1:0] s_axi_rresp,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RVALID" *)
  output wire s_axi_rvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RREADY" *)
  input wire s_axi_rready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWADDR" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI, PROTOCOL AXI4LITE, ADDR_WIDTH 32, DATA_WIDTH 32, READ_WRITE_MODE READ_WRITE, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1" *)
  output wire [31:0] m_axi_awaddr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWPROT" *)
  output wire [2:0] m_axi_awprot,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWVALID" *)
  output wire m_axi_awvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWREADY" *)
  input wire m_axi_awready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WDATA" *)
  output wire [31:0] m_axi_wdata,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WSTRB" *)
  output wire [3:0] m_axi_wstrb,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WVALID" *)
  output wire m_axi_wvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WREADY" *)
  input wire m_axi_wready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BRESP" *)
  input wire [1:0] m_axi_bresp,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BVALID" *)
  input wire m_axi_bvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BREADY" *)
  output wire m_axi_bready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARADDR" *)
  output wire [31:0] m_axi_araddr,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARPROT" *)
  output wire [2:0] m_axi_arprot,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARVALID" *)
  output wire m_axi_arvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARREADY" *)
  input wire m_axi_arready,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RDATA" *)
  input wire [31:0] m_axi_rdata,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RRESP" *)
  input wire [1:0] m_axi_rresp,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RVALID" *)
  input wire m_axi_rvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RREADY" *)
  output wire m_axi_rready
);
  reg aw_pending, w_pending, write_active, aw_sent, w_sent;
  reg [15:0] aw_addr;
  reg [63:0] w_data;
  reg [7:0] w_strb;
  reg [2:0] aw_prot;
  reg b_valid;
  reg [1:0] b_resp;
  reg read_active, ar_sent, r_valid;
  reg [15:0] ar_addr;
  reg [2:0] ar_prot;
  reg [63:0] r_data;
  reg [1:0] r_resp;
  assign s_axi_awready = !aw_pending && !write_active && !b_valid;
  assign s_axi_wready = !w_pending && !write_active && !b_valid;
  assign s_axi_bvalid = b_valid;
  assign s_axi_bresp = b_resp;
  assign s_axi_arready = !read_active && !r_valid;
  assign s_axi_rvalid = r_valid;
  assign s_axi_rresp = r_resp;
  assign s_axi_rdata = r_data;
  assign m_axi_awaddr = {17'b0,aw_addr[15:3],2'b0};
  assign m_axi_awprot = aw_prot;
  assign m_axi_awvalid = write_active && !aw_sent;
  assign m_axi_wdata = w_data[31:0];
  assign m_axi_wstrb = 4'hf;
  assign m_axi_wvalid = write_active && !w_sent;
  assign m_axi_bready = write_active && !b_valid;
  assign m_axi_araddr = {17'b0,ar_addr[15:3],2'b0};
  assign m_axi_arprot = ar_prot;
  assign m_axi_arvalid = read_active && !ar_sent;
  assign m_axi_rready = read_active && !r_valid;
  always @(posedge aclk) begin
    if (!aresetn) begin
      aw_pending<=0; w_pending<=0; write_active<=0; aw_sent<=0; w_sent<=0;
      aw_addr<=0; w_data<=0; w_strb<=0; aw_prot<=0;
      b_valid<=0; b_resp<=0;
      read_active<=0; ar_sent<=0; r_valid<=0;
      ar_addr<=0; ar_prot<=0; r_data<=0; r_resp<=0;
    end else begin
      if (s_axi_awvalid && s_axi_awready) begin
        aw_pending<=1; aw_addr<=s_axi_awaddr[15:0]; aw_prot<=s_axi_awprot;
      end
      if (s_axi_wvalid && s_axi_wready) begin
        w_pending<=1; w_data<=s_axi_wdata; w_strb<=s_axi_wstrb;
      end
      if (b_valid && s_axi_bready) b_valid<=0;
      if (aw_pending && w_pending && !write_active && !b_valid) begin
        aw_pending<=0; w_pending<=0;
        aw_sent<=0; w_sent<=0;
        if (aw_addr[2:0] != 0 || {16'b0,aw_addr} >= REGISTER_COUNT*8 || w_strb != 8'h0f) begin
          b_valid<=1; b_resp<=2'b10;
        end else write_active<=1;
      end
      if (m_axi_awvalid && m_axi_awready) aw_sent<=1;
      if (m_axi_wvalid && m_axi_wready) w_sent<=1;
      if (m_axi_bvalid && m_axi_bready) begin
        write_active<=0; b_valid<=1; b_resp<=m_axi_bresp;
      end
      if (r_valid && s_axi_rready) r_valid<=0;
      if (s_axi_arvalid && s_axi_arready) begin
        ar_addr<=s_axi_araddr[15:0]; ar_prot<=s_axi_arprot; ar_sent<=0;
        if (s_axi_araddr[2:0] != 0 || {16'b0,s_axi_araddr[15:0]} >= REGISTER_COUNT*8) begin
          r_valid<=1; r_data<=0; r_resp<=2'b10;
        end else read_active<=1;
      end
      if (m_axi_arvalid && m_axi_arready) ar_sent<=1;
      if (m_axi_rvalid && m_axi_rready) begin
        read_active<=0; r_valid<=1;
        r_data<={32'b0,m_axi_rdata}; r_resp<=m_axi_rresp;
      end
    end
  end
endmodule
`default_nettype wire
