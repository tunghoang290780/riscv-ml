`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: imocanu
// 
// Create Date: 04/03/2022 10:49:01 PM
// Design Name: 
// Module Name: axi_lite_slave
//
//////////////////////////////////////////////////////////////////////////////////


module axi4_lite_slave #
(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter STRB_WIDTH = (DATA_WIDTH/8)
)(
    input  wire        ACLK,
    input  wire        ARESET,

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

    reg WRITE_EN;
    reg READ_EN;

    // reg for output signals 
    reg S_AXI_AWREADY_REG = SET_LOW, AWREADY_NEXT;  // WRITE flag - output ADDRESS
    reg S_AXI_WREADY_REG  = SET_LOW, WREADY_NEXT;   // WRITE flag - output DATA 
    reg S_AXI_BVALID_REG  = SET_LOW, BVALID_NEXT;   // WRITE output RESPONSE
    reg S_AXI_ARREADY_REG = SET_LOW, ARREADY_NEXT;  // READ  output ADDRESS 
    reg S_AXI_RVALID_REG  = SET_LOW, RVALID_NEXT;   // READ  output DATA

    reg [DATA_WIDTH-1:0] S_AXI_RDATA_REG = {DATA_WIDTH{SET_LOW}};
    reg [DATA_WIDTH-1:0] RDATA_NEXT;

    // wire for INPUTs : addr 
    wire [ADDR_WIDTH-1:0] S_AXI_AWADDR_WIRE = S_AXI_AWADDR;  // WRITE input ADDRESS
    wire [ADDR_WIDTH-1:0] S_AXI_ARADDR_WIRE = S_AXI_ARADDR;  // READ  input ADDRESS

    // assign signals to AXI interface
    assign S_AXI_AWREADY = S_AXI_AWREADY_REG;  // WRITE output ADDRESS
    assign S_AXI_WREADY  = S_AXI_WREADY_REG;   // WRITE output DATA
    assign S_AXI_BVALID  = S_AXI_BVALID_REG;   // WRITE output RESPONSE
    assign S_AXI_ARREADY = S_AXI_ARREADY_REG;  // READ output ADDRESS
    assign S_AXI_RDATA   = S_AXI_RDATA_REG;    // READ output DATA
    assign S_AXI_RVALID  = S_AXI_RVALID_REG;   // READ output DATA 

    // WRITE response
    assign S_AXI_BRESP = SET_OK;   // WRITE
    assign S_AXI_RRESP = SET_OK;   // READ

    reg READ_STATUS;
    reg WRITE_STATUS;

    reg LAST_READ_REG = SET_LOW, LAST_READ_NEXT;

 
always @* begin
    WRITE_EN     = SET_LOW;
    AWREADY_NEXT = SET_LOW;
    WREADY_NEXT  = SET_LOW;
    ARREADY_NEXT = SET_LOW;

    // READ output DATA && !READ input DATA
    RVALID_NEXT = S_AXI_RVALID_REG && !S_AXI_RREADY;

    LAST_READ_NEXT = LAST_READ_REG;

    // WRITE output RESPONSE && !WRITE input RESPONSE
    BVALID_NEXT  = S_AXI_BVALID_REG && !S_AXI_BREADY;

    // WRITE input ADDRESS && WRITE input DATA
    // && (!WRITE output RESPONSE || WRITE input RESPONSE)
    // && (!WRITE output ADDRESS && WRITE output DATA)
    READ_STATUS  = S_AXI_AWVALID && S_AXI_WVALID && ( !S_AXI_BVALID || S_AXI_BREADY ) && ( !S_AXI_AWREADY && !S_AXI_WREADY );
    // READ input ADDRESS 
    // && (READ output DATA || READ input DATA )
    // && READ ouput ADDRESS
    WRITE_STATUS = S_AXI_ARVALID && ( S_AXI_RVALID || S_AXI_RREADY) && S_AXI_ARREADY; 


    if ( WRITE_STATUS && (!READ_STATUS || LAST_READ_REG) ) begin
        WRITE_EN       = SET_LOW;
        AWREADY_NEXT   = SET_LOW;
        WREADY_NEXT    = SET_LOW;
        BVALID_NEXT    = SET_LOW;
        LAST_READ_NEXT = SET_LOW;
    end else if ( READ_STATUS ) begin
        READ_EN        = SET_HIGH;
        LAST_READ_NEXT = SET_HIGH;
        ARREADY_NEXT   = SET_HIGH;
        RVALID_NEXT    = SET_HIGH;
    end
end

always @(posedge ACLK) begin
    LAST_READ_REG <= LAST_READ_NEXT;

    S_AXI_AWREADY_REG <= AWREADY_NEXT;  
    S_AXI_WREADY_REG  <= WREADY_NEXT;  
    S_AXI_BVALID_REG  <= BVALID_NEXT;

    S_AXI_ARREADY_REG <= ARREADY_NEXT; 
    S_AXI_RVALID_REG  <= RVALID_NEXT;  

    if( READ_EN ) begin
                S_AXI_RDATA_REG  <= BRAM[S_AXI_ARADDR];
    end else begin
            if(WRITE_EN) begin
                // WRITE
                BRAM[S_AXI_AWADDR] <= S_AXI_WDATA;
            end
        end

    if( ARESET ) begin
        LAST_READ_REG <= SET_LOW;

        S_AXI_AWREADY_REG <= SET_LOW;
        S_AXI_WREADY_REG  <= SET_LOW;
        S_AXI_BVALID_REG  <= SET_LOW;

        S_AXI_ARREADY_REG <= SET_LOW;
        S_AXI_RVALID_REG  <= SET_LOW;
    end

end

endmodule 