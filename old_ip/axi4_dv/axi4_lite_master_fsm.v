`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: imocanu
// 
// Create Date: 04/03/2022 10:49:01 PM
// Design Name: 
// Module Name: axi4_lite_master_fsm
// 
//////////////////////////////////////////////////////////////////////////////////


module axi4_lite_master_fsm #
(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter STRB_WIDTH = (DATA_WIDTH/8)
)(
    input  wire        ACLK,
    input  wire        ARESETn,

    // WRITE Address Channel
    input wire        			  S_AXI_AWREADY,
    output  wire        		  S_AXI_AWVALID,
    output  wire [ADDR_WIDTH-1:0] S_AXI_AWADDR,
    
    // WRITE Data Channel
    input wire        			  S_AXI_WREADY,
    output  wire                  S_AXI_WVALID,
    output  wire [DATA_WIDTH-1:0] S_AXI_WDATA,  
    output  wire [STRB_WIDTH-1:0] S_AXI_WSTRB, 
                                                
    //WRITE Response Channel
    output  wire        S_AXI_BREADY, 
    input wire          S_AXI_BVALID, 
    input wire [1:0]    S_AXI_BRESP,

    // READ Address Channel
    // S_AXI_ARPROT 
    // S_AXI_ARCACHE
    input wire        			  S_AXI_ARREADY, 
    output  wire        		  S_AXI_ARVALID, 
    output  wire [ADDR_WIDTH-1:0] S_AXI_ARADDR,

    // READ Data Channel	
    output  wire        	     S_AXI_RREADY, 
    input wire        			 S_AXI_RVALID, 
    input wire [1:0]  			 S_AXI_RRESP,  
    input wire [DATA_WIDTH-1:0]  S_AXI_RDATA,

	input wire START_RD,
	input wire START_WR
);

	localparam SET_ADDR = 32'h4
    localparam SET_OK   = 2'b00;
    localparam SET_HIGH = 1'b1;
    localparam SET_LOW  = 1'b0;


	localparam S_IDLE  = 2'd0,
			   S_RDATA = 2'd1,
			   S_RADDR = 2'd2,
			   S_WADDR = 2'd3,
			   S_WDATA = 2'd4,
			   S_WRESP = 2'd5;
	
	//typedef enum logic [2 : 0] {IDLE, RADDR, RDATA, WADDR, WDATA, WRESP} state_type;
	reg [3:0] STATE, NEXTSTATE;

	reg[ADDR_WIDTH-1 : 0] ADDR = SET_ADDR;
	reg[DATA_WIDTH-1 : 0] DATA = 32'hdeadbeef, RDATA;
	reg START_READ, START_WRITE;
	assign START_READ  = START_RD;
	assign START_WRITE = START_WR;
	// AR
	assign S_AXI_ARADDR  = (STATE == S_RADDR) ? ADDR : 32'h0;
	assign S_AXI_ARVALID = (STATE == S_RADDR) ? 1 : 0;

	// R
	assign S_AXI_RREADY = (STATE == S_RDATA) ? 1 : 0;

	// AW
	assign S_AXI_AWVALID = (STATE == S_WADDR) ? 1 : 0;
	assign S_AXI_AWADDR  = (STATE == S_WADDR) ? ADDR : 32'h0;

	// W
	assign S_AXI_WVALID = (STATE == S_WDATA) ? 1 : 0;
	assign S_AXI_WDATA  = (STATE == S_WDATA) ? DATA : 32'h0;
	assign S_AXI_WSTRB  = 4'b0000;

	// B
	assign S_AXI_BREADY = (STATE == S_WRESP) ? 1 : 0;


	always @(posedge ACLK) begin
		if (~areset_n) begin
			rdata <= 0;
		end else begin
			if (state == RDATA) rdata <= m_axi_lite.rdata;
		end
	end

	always @(posedge ACLK) begin
		if (!ARESETn) begin
			start_read_delay  <= 0;
			start_write_delay <= 0;
		end else begin
			start_read_delay  <= start_read;
			start_write_delay <= start_write;
		end
	end

	always_comb begin
		case (state)
			S_IDLE : NEXTSTATE = (START_READ) ? RADDR : ((START_WRITE) ? S_WADDR : S_IDLE);
			S_RADDR : if ( S_AXI_ARVALID && S_AXI_ARREADY ) NEXTSTATE = S_RDATA;
			S_RDATA : if (m_axi_lite.rvalid  && m_axi_lite.rready ) NEXTSTATE = S_IDLE;
			S_WADDR : if (m_axi_lite.awvalid && m_axi_lite.awready) NEXTSTATE = S_WDATA;
			S_WDATA : if (m_axi_lite.wvalid  && m_axi_lite.wready ) NEXTSTATE = S_WRESP;
			S_WRESP : if (m_axi_lite.bvalid  && m_axi_lite.bready ) NEXTSTATE = S_IDLE;
			default : NEXTSTATE = S_IDLE;
		endcase
	end

	always @(posedge ACLK) begin
		if (!ARESETn) begin
			STATE <= S_IDLE;
		end else begin
			STATE <= NEXTSTATE;
		end
	end
	

endmodule 