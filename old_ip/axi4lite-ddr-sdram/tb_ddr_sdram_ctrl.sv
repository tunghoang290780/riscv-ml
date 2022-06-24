`timescale 1ps/1ps

module tb_ddr_sdram_ctrl();

wire               error;

initial begin
    #200000000; 
    @(posedge clk);
    $finish;
end

localparam  BA_BITS  = 2;
localparam  ROW_BITS = 13;
localparam  COL_BITS = 11;
localparam  DQ_LEVEL = 1;
localparam  DQ_BITS  = (4<<DQ_LEVEL);
localparam  DQS_BITS = ((1<<DQ_LEVEL)+1)/2;
localparam [7:0] WBURST_LEN = 8'd7;
localparam [7:0] RBURST_LEN = 8'd7;
localparam  A_WIDTH = BA_BITS+ROW_BITS+COL_BITS+DQ_LEVEL-1;
localparam  D_WIDTH = (8<<DQ_LEVEL);

reg rstn_async=1'b0, clk300m=1'b1;
always #1667 clk300m = ~clk300m;
initial begin repeat(4) @(posedge clk300m); rstn_async<=1'b1; end

wire                ddr_ck_p, ddr_ck_n;
wire                ddr_cke;
wire                ddr_cs_n, ddr_ras_n, ddr_cas_n, ddr_we_n;
wire [         1:0] ddr_ba;
wire [ROW_BITS-1:0] ddr_a;
wire [DQS_BITS-1:0] ddr_dm;
tri  [DQS_BITS-1:0] ddr_dqs;
tri  [ DQ_BITS-1:0] ddr_dq;


wire               rstn;
wire               clk;
wire               awvalid;
wire               awready;
wire [A_WIDTH-1:0] awaddr;
wire [        7:0] awlen;
wire               wvalid;
wire               wready;
wire               wlast;
wire [D_WIDTH-1:0] wdata;
wire               bvalid;
wire               bready;
wire               arvalid;
wire               arready;
wire [A_WIDTH-1:0] araddr;
wire [        7:0] arlen;
wire               rvalid;
wire               rready;
wire               rlast;
wire [D_WIDTH-1:0] rdata;

//   axi4 master
axi_master #(
    .A_WIDTH_TEST( 12          ),
    .A_WIDTH     ( A_WIDTH     ),
    .D_WIDTH     ( D_WIDTH     ),
    .D_LEVEL     ( DQ_LEVEL    ),
    .WBURST_LEN  ( WBURST_LEN  ),
    .RBURST_LEN  ( RBURST_LEN  )
) axi_test (
    .rstn        ( rstn        ),
    .clk         ( clk         ),
    .awvalid     ( awvalid     ),
    .awready     ( awready     ),
    .awaddr      ( awaddr      ),
    .awlen       ( awlen       ),
    .wvalid      ( wvalid      ),
    .wready      ( wready      ),
    .wlast       ( wlast       ),
    .wdata       ( wdata       ),
    .bvalid      ( bvalid      ),
    .bready      ( bready      ),
    .arvalid     ( arvalid     ),
    .arready     ( arready     ),
    .araddr      ( araddr      ),
    .arlen       ( arlen       ),
    .rvalid      ( rvalid      ),
    .rready      ( rready      ),
    .rlast       ( rlast       ),
    .rdata       ( rdata       ),
    .error       ( error       ),
    .error_cnt   (             )
);

//   ddr
ddr_sdram_ctrl #(
    .READ_BUFFER ( 0           ),
    .BA_BITS     ( BA_BITS     ),
    .ROW_BITS    ( ROW_BITS    ),
    .COL_BITS    ( COL_BITS    ),
    .DQ_LEVEL    ( DQ_LEVEL    ), 
    .tREFC       ( 10'd512     ),
    .tW2I        ( 8'd6        ),
    .tR2I        ( 8'd6        )
) ddr_sdram_ctrl_i (
    .rstn_async  ( rstn_async  ),
    .drv_clk     ( clk300m     ),
    .rstn        ( rstn        ),
    .clk         ( clk         ),
    .awvalid     ( awvalid     ),
    .awready     ( awready     ),
    .awaddr      ( awaddr      ),
    .awlen       ( awlen       ),
    .wvalid      ( wvalid      ),
    .wready      ( wready      ),
    .wlast       ( wlast       ),
    .wdata       ( wdata       ),
    .bvalid      ( bvalid      ),
    .bready      ( bready      ),
    .arvalid     ( arvalid     ),
    .arready     ( arready     ),
    .araddr      ( araddr      ),
    .arlen       ( arlen       ),
    .rvalid      ( rvalid      ),
    .rready      ( rready      ),
    .rlast       ( rlast       ),
    .rdata       ( rdata       ),
    .ddr_ck_p    ( ddr_ck_p    ),
    .ddr_ck_n    ( ddr_ck_n    ),
    .ddr_cke     ( ddr_cke     ),
    .ddr_cs_n    ( ddr_cs_n    ),
    .ddr_ras_n   ( ddr_ras_n   ),
    .ddr_cas_n   ( ddr_cas_n   ),
    .ddr_we_n    ( ddr_we_n    ),
    .ddr_ba      ( ddr_ba      ),
    .ddr_a       ( ddr_a       ),
    .ddr_dm      ( ddr_dm      ),
    .ddr_dqs     ( ddr_dqs     ),
    .ddr_dq      ( ddr_dq      )    
);

//  micron
ddr ddr_model    (
    .Clk         ( ddr_ck_p    ),
    .Clk_n       ( ddr_ck_n    ),
    .Cke         ( ddr_cke     ),
    .Cs_n        ( ddr_cs_n    ),
    .Ras_n       ( ddr_ras_n   ),
    .Cas_n       ( ddr_cas_n   ),
    .We_n        ( ddr_we_n    ),
    .Ba          ( ddr_ba      ),
    .Addr        ( ddr_a       ),
    .Dm          ( ddr_dm      ),
    .Dqs         ( ddr_dqs     ),
    .Dq          ( ddr_dq      )
);

endmodule
