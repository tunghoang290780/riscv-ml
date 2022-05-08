`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: imocanu
// 
// Create Date: 01/14/2022 01:19:52 PM
// Design Name: 
// Module Name: fifo_v1
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


module fifo_v1
#(
    parameter       DQ_LEVEL           = 1,
    parameter       AXI_DATA_WIDTH     = 16
)(
    output wire                       rvalid,
    input  wire                       rready,
    input  reg                        rstn,
    input  reg                        clk,
    input  reg                        input_valid_state,
    input  wire    [AXI_DATA_WIDTH:0] data,
    output wire    [AXI_DATA_WIDTH:0] output_rdata,
    output wire                       output_rlast,
    output wire                       read_accessible, 
    output wire                       read_respdone
);


localparam AWIDTH = 10;
localparam DWIDTH = 1 + (8<<DQ_LEVEL);
  

reg  [AWIDTH-1:0] wpt = '0, rpt = '0;
reg               dvalid = '0, valid = '0;
reg  [DWIDTH-1:0] datareg = '0;

wire              rreq;
reg  [DWIDTH-1:0] fifo_rdata;

wire   emptyn  = rpt != wpt;

wire   itready = rpt != (wpt + (AWIDTH)'(1));
assign rvalid  = valid | dvalid;
assign rreq    = emptyn & ( rready | ~rvalid );
assign {output_rlast, output_rdata} = dvalid ? fifo_rdata : datareg;

reg [DWIDTH-1:0] mem [(2**AWIDTH)];

always @ (posedge clk or negedge rstn)
    if(~rstn)
        wpt <= 0;
    else if(input_valid_state & itready)
        wpt <= wpt + (AWIDTH)'(1);
    
always @ (posedge clk or negedge rstn)
    if(~rstn)
        rpt <= 0;
    else if(rreq & emptyn)
        rpt <= rpt + (AWIDTH)'(1);

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

assign read_accessible = ~rvalid;
assign read_respdone = rvalid;

    
endmodule
