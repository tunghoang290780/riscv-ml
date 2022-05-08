`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: imocanu
// 
// Create Date: 04/03/2022 10:49:01 PM
// Design Name: 
// Module Name: axi4_lite_slave_fsm
// 
//////////////////////////////////////////////////////////////////////////////////


module axi4_lite_slave_fsm #
(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter STRB_WIDTH = (DATA_WIDTH/8)
)(
    input  wire        ACLK,
    input  wire        ARESETn,

    // WRITE Address Channel
    output wire        			 S_AXI_AWREADY,
    input  wire        			 S_AXI_AWVALID,
    input  wire [ADDR_WIDTH-1:0] S_AXI_AWADDR,
    
    // WRITE Data Channel
    output wire        			 S_AXI_WREADY,
    input  wire                  S_AXI_WVALID,
    input  wire [DATA_WIDTH-1:0] S_AXI_WDATA,  
    input  wire [STRB_WIDTH-1:0] S_AXI_WSTRB, 
                                                
    //WRITE Response Channel
    input  wire        S_AXI_BREADY, 
    output wire        S_AXI_BVALID, 
    output wire [1:0]  S_AXI_BRESP,

    // READ Address Channel
    // S_AXI_ARPROT 
    // S_AXI_ARCACHE
    output wire        			 S_AXI_ARREADY, 
    input  wire        			 S_AXI_ARVALID, 
    input  wire [ADDR_WIDTH-1:0] S_AXI_ARADDR,

    // READ Data Channel	
    input  wire        			 S_AXI_RREADY, 
    output wire        			 S_AXI_RVALID, 
    output wire [1:0]  			 S_AXI_RRESP,  
    output wire [DATA_WIDTH-1:0] S_AXI_RDATA
);

    localparam SET_OK   = 2'b00;
    localparam SET_HIGH = 1'b1;
    localparam SET_LOW  = 1'b0;

     // (* RAM_STYLE="BLOCK" *)
    reg [DATA_WIDTH-1:0] BRAM[(2**6)-1:0];

	// WRITE
	localparam S_WRIDLE = 2'd0,
			   S_WRDATA = 2'd1,
			   S_WRRESP = 2'd2;
	// READ
	localparam S_RDIDLE = 2'd0,
			   S_RDDATA = 2'd1;
	
	// WRITE
	reg [1:0] WRITE_STATE, NEXT_WRITE_STATE;
	reg [ADDR_WIDTH-1:0] WRITE_ADDR;
	wire [ADDR_WIDTH-1:0] MASK;
	wire ADDR_WRITE_EN, WRITE_EN;
	// READ
	reg [1:0] READ_STATE, NEXT_READ_STATE;
	wire [ADDR_WIDTH-1:0] RADDR;
	reg [ADDR_WIDTH-1:0] RDATA;
	wire ar_hs;


    // WRITE
	assign S_AXI_AWREADY = (WRITE_STATE == S_WRIDLE);
	assign S_AXI_WREADY  = (WRITE_STATE == S_WRDATA);
	assign S_AXI_BRESP   = SET_OK;
	assign S_AXI_BVALID  = (WRITE_STATE == S_WRRESP);
	assign MASK = {{8{S_AXI_WSTRB[3]}}, {8{S_AXI_WSTRB[2]}}, {8{S_AXI_WSTRB[1]}}, {8{S_AXI_WSTRB[0]}}};
	assign ADDR_WRITE_EN = S_AXI_AWVALID & S_AXI_AWREADY;
	assign WRITE_EN = S_AXI_WVALID & S_AXI_WREADY;

	// WRITE
	always @(posedge ACLK)
	begin
		if (!ARESETn)
			WRITE_STATE <= S_WRIDLE;
		else
			WRITE_STATE <= NEXT_WRITE_STATE;
	end
	
	// WRITE
	always @(*)
	begin
		case (WRITE_STATE)
			S_WRIDLE:
				if (S_AXI_AWVALID)
					NEXT_WRITE_STATE = S_WRDATA;
				else
					NEXT_WRITE_STATE = S_WRIDLE;
			S_WRDATA:
				if (S_AXI_AWVALID)
					NEXT_WRITE_STATE = S_WRRESP;
				else
					NEXT_WRITE_STATE = S_WRDATA;
			S_WRRESP:
				if (S_AXI_BREADY)
					NEXT_WRITE_STATE = S_WRIDLE;
				else
					NEXT_WRITE_STATE = S_WRRESP;
			default:
				NEXT_WRITE_STATE = S_WRIDLE;
		endcase
	end
	
	// WRITE
	always @(posedge ACLK)
	begin
		if (ADDR_WRITE_EN)
			WRITE_ADDR <= S_AXI_AWADDR[ADDR_WIDTH-1:0];
	end
	
	// READ
	assign S_AXI_ARREADY = (READ_STATE == S_RDIDLE);
	assign S_AXI_RDATA = RDATA;
	assign S_AXI_RRESP = SET_OK;  
	assign S_AXI_RVALID = (READ_STATE == S_RDDATA);
	assign ADDR_READ_EN = S_AXI_ARVALID & S_AXI_ARREADY;
	assign RADDR = S_AXI_ARADDR[ADDR_WIDTH-1:0];
	
	// READ
	always @(posedge ACLK)
	begin
		if (!ARESETn)
			READ_STATE <= S_RDIDLE;
		else
			READ_STATE <= NEXT_READ_STATE;
	end

	// READ
	always @(*) 
	begin
		case (READ_STATE)
			S_RDIDLE:
				if (S_AXI_ARVALID)
					NEXT_READ_STATE = S_RDDATA;
				else
					NEXT_READ_STATE = S_RDIDLE;
			S_RDDATA:
				if (S_AXI_RREADY)
					NEXT_READ_STATE = S_RDIDLE;
				else
					NEXT_READ_STATE = S_RDDATA;
			default:
				NEXT_READ_STATE = S_RDIDLE;
		endcase
	end
	
	// READ
	always @(posedge ACLK)
	begin
	    if (!ARESETn)
	        RDATA <= 0;
		else if (ADDR_READ_EN)
			RDATA <= BRAM[RADDR];
	end

    // WRITE
    always @(posedge ACLK)
	begin
	    if (!ARESETn)
	    begin
            WRITE_ADDR <= 0;
        end
		else if (WRITE_EN)
		begin
			BRAM[WRITE_ADDR] <= S_AXI_WDATA;
	    end
	end
	

endmodule 