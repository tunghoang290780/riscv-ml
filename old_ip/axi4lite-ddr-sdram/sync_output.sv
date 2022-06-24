`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/12/2022 10:28:18 AM
// Design Name: 
// Module Name: sync_output
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

module sync_output #(
    parameter   GEN_CLOCK   = 0
) (
    input  wire                                           in_rst,
    input  wire                                           in_clk, 

    output reg                                            out_clk,
    output reg                                            out_clk_n 
);


reg out_clk_low = '0;
reg new_clk = '0;
reg new_clk_n = '0;

reg rstn_clk_l = '0;
reg rstn_clk   = '0;

always @ (posedge in_clk or negedge in_rst)
    if(!in_rst) begin
        rstn_clk   <= '0;
        rstn_clk_l <= '0;
    end
    else begin
        rstn_clk   <= rstn_clk_l;
        rstn_clk_l <= 1'b1;
    end


// OUTPUT CLOCK
always @ (posedge in_clk or negedge in_rst)
    if(!in_rst) begin
        out_clk   <= 2'b00;
        out_clk_n <= 2'b00;
    end
    else begin
        //out_clk   <= ~out_clk_n;
        //out_clk_n <= ~out_clk;
        {out_clk,out_clk_n} <= {out_clk,out_clk_n} + 2'b01;
    end
    
assign out_clk   = new_clk;
assign out_clk_n = new_clk_n;    


endmodule

