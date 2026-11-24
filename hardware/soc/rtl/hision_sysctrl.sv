// HisionArch CPU-only SoC. See docs/architecture/cpu-soc.md.
`default_nettype none
`include "hision_soc_map.vh"
module hision_sysctrl #(parameter integer AXI_CLOCK_HZ=0,
  parameter integer LED_WIDTH=0, parameter integer LED_ACTIVE_LOW=0) (
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk CLK", X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF S_AXI, ASSOCIATED_RESET aresetn" *)
  input wire aclk,
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aresetn RST", X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
  input wire aresetn,
  input wire calibrated,
  input wire cpu_in_reset,
  input wire bus_busy,
  input wire bus_error,
  output reg run_requested,
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
  input wire s_axi_rready
);
  reg aw_pending, w_pending;
  reg [15:0] aw_addr;
  reg [63:0] w_data;
  reg [7:0] w_strb;
  reg b_valid, r_valid;
  reg [1:0] b_resp, r_resp;
  reg [63:0] r_data, scratch;
  assign s_axi_awready = !aw_pending && !b_valid;
  assign s_axi_wready = !w_pending && !b_valid;
  assign s_axi_bvalid = b_valid;
  assign s_axi_bresp = b_resp;
  assign s_axi_arready = !r_valid;
  assign s_axi_rvalid = r_valid;
  assign s_axi_rdata = r_data;
  assign s_axi_rresp = r_resp;
  integer lane;
  always @(posedge aclk) begin
    if (!aresetn) begin
      aw_pending <= 0; w_pending <= 0;
      aw_addr <= 0; w_data <= 0; w_strb <= 0;
      b_valid <= 0; r_valid <= 0;
      b_resp <= 0; r_resp <= 0; r_data <= 0;
      run_requested <= 0; scratch <= 0;
    end else begin
      if (s_axi_awvalid && s_axi_awready) begin
        aw_addr <= s_axi_awaddr[15:0]; aw_pending <= 1;
      end
      if (s_axi_wvalid && s_axi_wready) begin
        w_data <= s_axi_wdata; w_strb <= s_axi_wstrb; w_pending <= 1;
      end
      if (b_valid && s_axi_bready) b_valid <= 0;
      if (aw_pending && w_pending && !b_valid) begin
        aw_pending <= 0; w_pending <= 0; b_valid <= 1; b_resp <= 0;
        case ({48'b0,aw_addr})
          `HISION_SYS_CONTROL_OFFSET: if (w_strb[0]) run_requested <= w_data[0];
          `HISION_SYS_SCRATCH_OFFSET:
            for (lane=0; lane<8; lane=lane+1)
              if (w_strb[lane]) scratch[8*lane +: 8] <= w_data[8*lane +: 8];
          default: b_resp <= 2'b10;
        endcase
      end
      if (r_valid && s_axi_rready) r_valid <= 0;
      if (s_axi_arvalid && s_axi_arready) begin
        r_valid <= 1; r_resp <= 0; r_data <= 0;
        case ({48'b0,s_axi_araddr[15:0]})
          `HISION_SYS_ID_OFFSET: r_data <= `HISION_SYS_ID;
          `HISION_SYS_CONTROL_OFFSET: r_data <= {63'b0,run_requested};
          `HISION_SYS_STATUS_OFFSET:
            r_data <= {59'b0,bus_error,run_requested,bus_busy,cpu_in_reset,calibrated};
          `HISION_SYS_SCRATCH_OFFSET: r_data <= scratch;
          `HISION_SYS_CLOCK_HZ_OFFSET: r_data <= {32'b0,32'(AXI_CLOCK_HZ)};
          `HISION_SYS_BOARD_IO_OFFSET: r_data <= {55'b0,1'(LED_ACTIVE_LOW),8'(LED_WIDTH)};
          default: r_resp <= 2'b10;
        endcase
      end
    end
  end
endmodule
`default_nettype wire
