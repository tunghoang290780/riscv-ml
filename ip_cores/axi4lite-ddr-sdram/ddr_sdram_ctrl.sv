`timescale 1ns / 1ps

`define x8

`include "ddr_parameters.vh"
module ddr_sdram_ctrl #(
    parameter       DQ_LEVEL           = 1,  // DQ_BITS = 8
    parameter       AXI_DATA_WIDTH     = 16,
    parameter [9:0] REFRESH_TIME       = 10'd256,
    parameter [7:0] NOP_WAIT_TIME      = 8'd7
) (
    // TOP clk/rst
    input  wire                                           rstn_async,
    input  wire                                           drv_clk,  
    // AXI4 clk/rst
    output reg                                            rstn,
    output reg                                            clk,    
    // AXI4-lite
    input  wire                                           awvalid,
    output wire                                           awready,
    input  wire                       [full_mem_bits-1:0] awaddr,  
    input  wire                                    [ 7:0] awlen,
    input  wire                                           wvalid,
    output wire                                           wready,
    input  wire                                           wlast,
    input  wire                       [AXI_DATA_WIDTH-1:0] wdata,
    output wire                                           bvalid,
    input  wire                                           bready,
    input  wire                                           arvalid,
    output wire                                           arready,
    input  wire                       [full_mem_bits-1:0] araddr,   
    input  wire                                    [ 7:0] arlen,
    output wire                                           rvalid,
    input  wire                                           rready,
    output wire                                           rlast,
    output wire                       [AXI_DATA_WIDTH-1:0] rdata,
    // DDR
    output wire                                           ddr_ck_p, ddr_ck_n, 
    output wire                                           ddr_cke,
    output reg                                            ddr_cs_n,
    output reg                                            ddr_ras_n,
    output reg                                            ddr_cas_n,
    output reg                                            ddr_we_n,
    output reg                  [            BA_BITS-1:0] ddr_ba,
    output reg                  [          ADDR_BITS-1:0] ddr_a,
    output wire                                           ddr_dm,
    inout                                                 ddr_dqs,
    inout                                   [DQ_BITS-1:0] ddr_dq    
);

localparam [ADDR_BITS-1:0] DDR_A_DEFAULT      = (ADDR_BITS)'('b0100_0000_0000);
localparam [ADDR_BITS-1:0] DDR_A_CLEAN        = (ADDR_BITS)'('b0000_0010_1001);

localparam POWER_ON = 4'd0;
localparam IDLE     = 4'd1;
localparam CLEAN    = 4'd2;
localparam REFRESH  = 4'd3;
localparam WPRE     = 4'd4;
localparam WRITE    = 4'd5;
localparam WRESP    = 4'd6;
localparam NOP_WAIT = 4'd7;
localparam RPRE     = 4'd8;
localparam READ     = 4'd9;
localparam RRESP    = 4'd10;

reg [3:0] STATUS = POWER_ON; 

reg        clk2 = '0;
reg        init_done = '0;
reg  [2:0] ref_idle = 3'd1, ref_real = '0;
reg  [9:0] ref_cnt = '0;
reg  [7:0] cnt = '0;
reg  [7:0] burst_len = '0;
wire       burst_last = cnt==burst_len;
reg  [COL_BITS-2:0] col_addr = '0;

wire [ADDR_BITS-1:0] ddr_a_col;
wire read_accessible; 
wire read_respdone;
reg  output_enable='0; 
reg  output_enable_d1='0; 
reg  output_enable_d2='0;

reg                      write_valid_state_1 = '0; 
reg                      write_valid_state_2 = '0;

reg                      output_dqs          = '0;  
reg  [DQ_BITS-1:0]       output_data_high_1  = '0;
reg  [DQ_BITS-1:0]       output_data_low_1   = '0;
reg  [DQ_BITS-1:0]       output_data_high_2  = '0;
reg  [DQ_BITS-1:0]       output_data_state_3 = '0;
reg  [DQ_BITS-1:0]       output_data_state_4 = '0;

reg                      input_valid_state_1 = '0;
reg                      input_valid_state_2 = '0;
reg                      input_valid_state_3 = '0;
reg                      input_valid_state_4 = '0;
reg                      input_valid_state_5 = '0;

reg                      input_low_1 = '0;
reg                      input_low_2 = '0;
reg                      input_low_3 = '0;
reg                      input_low_4 = '0;
reg                      input_low_5 = '0;

reg                      input_dqs = '0;

reg  [DQ_BITS-1:0]        input_data_state_1 = '0;
reg  [AXI_DATA_WIDTH-1:0] input_data_state_2 = '0;
reg  [AXI_DATA_WIDTH-1:0] input_data_state_3 = '0;

reg       rstn_aclk   = '0;
reg [2:0] rstn_aclk_l = '0;


initial ddr_cs_n = 1'b1;
initial ddr_ras_n = 1'b1;
initial ddr_cas_n = 1'b1;
initial ddr_we_n = 1'b1;
initial ddr_ba = '0;
initial ddr_a = DDR_A_DEFAULT;

initial rstn = '0;
initial clk  = '0;

assign ddr_a_col = {col_addr[COL_BITS-2:9], burst_last, col_addr[8:0], 1'b0};

//   DDR
assign ddr_ck_p = ~clk;
assign ddr_ck_n = clk;
assign ddr_cke = ~ddr_cs_n;
assign ddr_dm  = output_enable ? '0 : 'z;
assign ddr_dqs = output_enable ? {DQS_BITS{output_dqs}} : 'z;
assign ddr_dq  = output_enable ? output_data_state_4 : 'z;

//  AXI4
assign awready = STATUS==IDLE && init_done && ref_real==ref_idle;
assign wready  = STATUS==WRITE;
assign bvalid  = STATUS==WRESP;
assign arready = STATUS==IDLE && init_done && ref_real==ref_idle && ~awvalid && read_accessible;

// SYNC RESET : CLK + CLK2 
sync_output u_sync_rst_clock
(
    .in_rst(rstn_clk),
    .in_clk(drv_clk), 
    .out_clk(clk),
    .out_clk_n(clk2) 
);

// RESET
always @ (posedge clk or negedge rstn_async)
    if(~rstn_async)
        {rstn_aclk, rstn_aclk_l} <= '0;
    else
        {rstn_aclk, rstn_aclk_l} <= {rstn_aclk_l, 1'b1};


//   RESET
always @ (posedge clk or negedge rstn_aclk)
    if(~rstn_aclk)
        rstn <= 1'b0;
    else
        rstn <= init_done;


//   REFRESH
always @ (posedge clk or negedge rstn_aclk)
    if(~rstn_aclk) begin
        ref_cnt <= '0;
        ref_idle <= 3'd1;
    end else begin
        if(init_done) begin
            if(ref_cnt<REFRESH_TIME) begin
                ref_cnt <= ref_cnt + 10'd1;
            end else begin
                ref_cnt <= '0;
                ref_idle <= ref_idle + 3'd1;
            end
        end
    end

//   FSM - DDR
always @ (posedge clk or negedge rstn_aclk)
    if(~rstn_aclk) begin
        ddr_cs_n <= 1'b1;
        ddr_ras_n <= 1'b1;
        ddr_cas_n <= 1'b1;
        ddr_we_n <= 1'b1;
        ddr_ba <= '0;
        ddr_a <= DDR_A_DEFAULT;
        col_addr <= '0;
        burst_len <= '0;
        init_done <= 1'b0;
        ref_real <= 3'd0;
        cnt <= 8'd0;
        STATUS <= POWER_ON;
    end else begin
        case(STATUS)
            POWER_ON: begin
                cnt <= cnt + 8'd1;
                if(cnt<8'd13) begin
                end else if(cnt<8'd50) begin
                    ddr_cs_n <= 1'b0;
                end else if(cnt<8'd51) begin
                    ddr_ras_n <= 1'b0;
                    ddr_we_n <= 1'b0;
                end else if(cnt<8'd53) begin
                    ddr_ras_n <= 1'b1;
                    ddr_we_n <= 1'b1;
                end else if(cnt<8'd54) begin
                    ddr_ras_n <= 1'b0;
                    ddr_cas_n <= 1'b0;
                    ddr_we_n <= 1'b0;
                    ddr_ba <= 'h1;
                    ddr_a <= '0;
                end else begin
                    ddr_ba <= '0;
                    ddr_a <= DDR_A_DEFAULT; 
                    STATUS <= IDLE;
                end
            end
            IDLE: begin
                ddr_ras_n <= 1'b1;
                ddr_cas_n <= 1'b1;
                ddr_we_n <= 1'b1;
                ddr_ba <= '0;
                ddr_a <= DDR_A_DEFAULT;
                cnt <= 8'd0;
                if(ref_real != ref_idle) begin
                    ref_real <= ref_real + 3'd1;
                    STATUS <= REFRESH;
                end else if(~init_done) begin
                    STATUS <= CLEAN;
                end else if(awvalid) begin
                    ddr_ras_n <= 1'b0;
                    {ddr_ba, ddr_a, col_addr} <= awaddr[full_mem_bits-1:DQ_LEVEL];
                    burst_len <= awlen;
                    STATUS <= WPRE;
                end else if(arvalid & read_accessible) begin
                    ddr_ras_n <= 1'b0;
                    {ddr_ba, ddr_a, col_addr} <= araddr[full_mem_bits-1:DQ_LEVEL];
                    burst_len <= arlen;
                    STATUS <= RPRE;
                end
            end
            CLEAN: begin
                ddr_ras_n <= cnt!=8'd0;
                ddr_cas_n <= cnt!=8'd0;
                ddr_we_n <= cnt!=8'd0;
                ddr_a <= cnt!=8'd0 ? DDR_A_DEFAULT : DDR_A_CLEAN;
                cnt <= cnt + 8'd1;
                if(cnt==8'd255) begin
                    init_done <= 1'b1;
                    STATUS <= IDLE;
                end
            end
            REFRESH: begin
                cnt <= cnt + 8'd1;
                if(cnt<8'd1) begin
                    ddr_ras_n <= 1'b0;
                    ddr_we_n <= 1'b0;
                end else if(cnt<8'd3) begin
                    ddr_ras_n <= 1'b1;
                    ddr_we_n <= 1'b1;
                end else if(cnt<8'd4) begin
                    ddr_ras_n <= 1'b0;
                    ddr_cas_n <= 1'b0;
                end else if(cnt<8'd10) begin
                    ddr_ras_n <= 1'b1;
                    ddr_cas_n <= 1'b1;
                end else if(cnt<8'd11) begin
                    ddr_ras_n <= 1'b0;
                    ddr_cas_n <= 1'b0;
                end else if(cnt<8'd17) begin
                    ddr_ras_n <= 1'b1;
                    ddr_cas_n <= 1'b1;
                end else begin
                    STATUS <= IDLE;
                end
            end
            WPRE: begin
                ddr_ras_n <= 1'b1;
                cnt <= 8'd0;
                STATUS <= WRITE;
            end
            WRITE: begin
                ddr_a <= ddr_a_col;
                if(wvalid) begin
                    ddr_cas_n <= 1'b0;
                    ddr_we_n <= 1'b0;
                    col_addr <= col_addr + {{(COL_BITS-2){1'b0}}, 1'b1};
                    if(burst_last | wlast) begin
                        cnt <= '0;
                        STATUS <= WRESP;
                    end else begin
                        cnt <= cnt + 8'd1;
                    end
                end else begin
                    ddr_cas_n <= 1'b1;
                    ddr_we_n <= 1'b1;
                end
            end
            WRESP: begin
                ddr_cas_n <= 1'b1;
                ddr_we_n <= 1'b1;
                cnt <= cnt + 8'd1;
                if(bready)
                    STATUS <= NOP_WAIT;
            end
            RPRE: begin
                ddr_ras_n <= 1'b1;
                cnt <= 8'd0;
                STATUS <= READ;
            end
            READ: begin
                ddr_cas_n <= 1'b0;
                ddr_a <= ddr_a_col;
                col_addr <= col_addr + {{(COL_BITS-2){1'b0}}, 1'b1};
                if(burst_last) begin
                    cnt <= '0;
                    STATUS <= RRESP;
                end else begin
                    cnt <= cnt + 8'd1;
                end
            end
            RRESP: begin 
                ddr_cas_n <= 1'b1;
                cnt <= cnt + 8'd1;
                if(read_respdone)
                    STATUS <= NOP_WAIT;
            end
            NOP_WAIT: begin
                cnt <= cnt + 8'd1;
                if(cnt>=NOP_WAIT_TIME)
                    STATUS <= IDLE;
            end
            default: STATUS <= IDLE;
        endcase
    end

//  WRITE
always @ (posedge clk or negedge rstn)
if(~rstn) begin
    output_enable <= 1'b0;
    output_enable_d1 <= 1'b0;
    output_enable_d2 <= 1'b0;
end else begin
    output_enable <= STATUS==WRITE || output_enable_d1 || output_enable_d2;
    output_enable_d1 <= STATUS==WRITE;
    output_enable_d2 <= output_enable_d1;
end

//  WRITE
always @ (posedge clk or negedge rstn)
if(~rstn) begin
    write_valid_state_1 <= 1'b0;
    {output_data_high_1, output_data_low_1} <= '0;
end else begin
    write_valid_state_1 <= (STATUS==WRITE && wvalid);
    {output_data_high_1, output_data_low_1} <= wdata;
end

//  WRITE
always @ (posedge clk or negedge rstn)
if(~rstn) begin
    write_valid_state_2 <= 1'b0;
    output_data_high_2 <= '0;
end else begin
    write_valid_state_2 <= write_valid_state_1;
    output_data_high_2 <= output_data_high_1;
end


//  WRITE : DQ and DQS
always @ (posedge clk2)
if(~clk) begin
    output_dqs <= 1'b0;
    output_data_state_3 <= write_valid_state_1 ? output_data_low_1  : '0;
end else begin
    output_dqs <= write_valid_state_2;
    output_data_state_3 <= write_valid_state_2 ? output_data_high_2 : '0;
end


//  WRITE : DQ delay
always @ (posedge drv_clk)
    output_data_state_4 <= output_data_state_3;

//  READ : DDR
always @ (posedge clk2) begin
    input_dqs <= ddr_dqs;
    input_data_state_1 <= ddr_dq;
end

always @ (posedge clk2)
    if(input_dqs)
        input_data_state_2 <= {ddr_dq, input_data_state_1};

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        input_valid_state_1 <= '0;
        input_valid_state_2 <= '0;
        input_valid_state_3 <= '0;
        input_valid_state_4 <= '0;
        input_low_1 <= '0;
        input_low_2 <= '0;
        input_low_3 <= '0;
        input_low_4 <= '0;
    end else begin
        input_valid_state_1 <= STATUS==READ ? 1'b1 : 1'b0;
        input_low_1 <= burst_last;
        
        input_low_2 <= input_low_1 & input_valid_state_1;
        input_low_3 <= input_low_2;
        input_low_4 <= input_low_3;
        
        input_valid_state_2 <= input_valid_state_1;
        input_valid_state_3 <= input_valid_state_2;
        input_valid_state_4 <= input_valid_state_3;
    end

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        input_valid_state_5 <= 1'b0;
        input_low_5 <= 1'b0;
        input_data_state_3 <= '0;
    end else begin
        input_valid_state_5 <= input_valid_state_4;
        input_low_5 <= input_low_4;
        input_data_state_3 <= input_data_state_2;
    end

fifo_v1 read_fifo
(
    .rvalid(rvalid),
    .rready(rready),
    .rstn(rstn),
    .clk(clk),
    .input_valid_state(input_valid_state_5),
    .data({input_low_5, input_data_state_3}),
    .output_rdata(rdata),
    .output_rlast(rlast),
    .read_accessible(read_accessible),
    .read_respdone(read_respdone)
);

//fifo_v2 read_fifo
//(
//    .rvalid(rvalid),
//    .rready(rready),
//    .rstn(rstn),
//    .clk(clk),
//    .input_valid_state(input_valid_state_5),
//    .data({input_low_5, input_data_state_3}),
//    .output_rdata(rdata),
//    .output_rlast(rlast),
//    .read_accessible(read_accessible),
//    .read_respdone(read_respdone)
//);

//assign rvalid          = input_valid_state_5;
//assign rlast           = input_low_5;
//assign rdata           = input_data_state_3;
//assign read_accessible = 1'b1;
//assign read_respdone   = input_low_5;

endmodule
