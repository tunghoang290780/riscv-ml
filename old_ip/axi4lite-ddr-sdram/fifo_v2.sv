`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: imocanu
// 
// Create Date: 01/14/2022 11:21:04 PM
// Design Name: 
// Module Name: fifo_v2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo_v2
#(
    parameter       DQ_LEVEL           = 1,
    parameter       AXI_DATA_WIDTH     = 16,
    parameter       ADDR_WIDTH         = 10,
    parameter       DATA_WIDTH         = 1 + AXI_DATA_WIDTH
)(
    input  wire                       rready,
    input  reg                        rstn,
    input  reg                        clk,
    input  reg                        input_valid_state,
    input  wire    [AXI_DATA_WIDTH:0] data,
    output wire    [AXI_DATA_WIDTH:0] output_rdata,
    output wire                       output_rlast,
    output wire                       read_valid,
    output wire                       read_accessible, 
    output wire                       read_respdone
);
  
reg  [ADDR_WIDTH-1:0] wpt = '0, rpt = '0;
reg  [DATA_WIDTH-1:0] datareg = '0;
reg  [DATA_WIDTH-1:0] fifo_rdata;
reg  [DATA_WIDTH-1:0] mem [(2**ADDR_WIDTH)];
reg                   dvalid = '0;
reg                   valid = '0;
wire                  rreq;
wire   emptyn  = rpt != wpt;
wire   itready = rpt != (wpt + (ADDR_WIDTH)'(1));


always @ (posedge clk or negedge rstn)
    if(~rstn)
        wpt <= 0;
    else if(input_valid_state & itready)
        wpt <= wpt + (ADDR_WIDTH)'(1);
    
always @ (posedge clk or negedge rstn)
    if(~rstn)
        rpt <= 0;
    else if(rreq & emptyn)
        rpt <= rpt + (ADDR_WIDTH)'(1);

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        dvalid <= 1'b0;
        valid  <= 1'b0;
        datareg <= 0;
    end else begin
        dvalid <= rreq;
        if(dvalid)
            datareg <= fifo_rdata;
        if(rready)
            valid <= 1'b0;
        else if(dvalid)
            valid <= 1'b1;
    end

always @ (posedge clk)
    if(input_valid_state)
        mem[wpt] <= data;

always @ (posedge clk)
    fifo_rdata <= mem[rpt];
 
assign read_valid  = valid | dvalid;
assign rreq        = emptyn & ( rready | ~read_valid );
assign {output_rlast, output_rdata} = dvalid ? fifo_rdata : datareg;

assign read_accessible = ~read_valid;
assign read_respdone   = read_valid;

    
endmodule
