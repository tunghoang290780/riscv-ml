library ieee;
use ieee.std_logic_1164.all;

entity synchronizer is
    port (
        clock    : in std_logic;
        dinp     : in std_logic;
        dout     : out std_logic);
end synchronizer;

architecture Behaviour of synchronizer is

    signal shreg : std_logic_vector(2 downto 0);

    -- This property instructs the synthesis tool to infer shift registers.
    attribute SHREG_EXTRACT : string;
    attribute SHREG_EXTRACT of shreg : signal is "no";

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of shreg: signal is "TRUE";
begin
    dout <= shreg(2);
    process (clock)
    begin
        if clock'event and clock = '1' then
            shreg <= shreg(1 downto 0) & dinp;
        end if;
    end process;
end Behaviour;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Rocket64b1j is
port (
    clock      : in std_logic;
    clock_ok   : in std_logic;
    mem_ok     : in std_logic;
    io_ok      : in std_logic;
    sys_reset  : in std_logic;
    aresetn    : out std_logic;

    interrupts: in std_logic_vector(7 downto 0);

    mem_axi4_awready: in  std_logic;
    mem_axi4_awvalid: out std_logic;
    mem_axi4_awid   : out std_logic_vector(3 downto 0);
    mem_axi4_awaddr : out std_logic_vector(31 downto 0);
    mem_axi4_awlen  : out std_logic_vector(7 downto 0);
    mem_axi4_awsize : out std_logic_vector(2 downto 0);
    mem_axi4_awburst: out std_logic_vector(1 downto 0);
    mem_axi4_awlock : out std_logic;
    mem_axi4_awcache: out std_logic_vector(3 downto 0);
    mem_axi4_awprot : out std_logic_vector(2 downto 0);
    mem_axi4_awqos  : out std_logic_vector(3 downto 0);
    mem_axi4_wready : in  std_logic;
    mem_axi4_wvalid : out std_logic;
    mem_axi4_wdata  : out std_logic_vector(63 downto 0);
    mem_axi4_wstrb  : out std_logic_vector(7 downto 0);
    mem_axi4_wlast  : out std_logic;
    mem_axi4_bready : out std_logic;
    mem_axi4_bvalid : in  std_logic;
    mem_axi4_bid    : in  std_logic_vector(3 downto 0);
    mem_axi4_bresp  : in  std_logic_vector(1 downto 0);
    mem_axi4_arready: in  std_logic;
    mem_axi4_arvalid: out std_logic;
    mem_axi4_arid   : out std_logic_vector(3 downto 0);
    mem_axi4_araddr : out std_logic_vector(31 downto 0);
    mem_axi4_arlen  : out std_logic_vector(7 downto 0);
    mem_axi4_arsize : out std_logic_vector(2 downto 0);
    mem_axi4_arburst: out std_logic_vector(1 downto 0);
    mem_axi4_arlock : out std_logic;
    mem_axi4_arcache: out std_logic_vector(3 downto 0);
    mem_axi4_arprot : out std_logic_vector(2 downto 0);
    mem_axi4_arqos  : out std_logic_vector(3 downto 0);
    mem_axi4_rready : out std_logic;
    mem_axi4_rvalid : in  std_logic;
    mem_axi4_rid    : in  std_logic_vector(3 downto 0);
    mem_axi4_rdata  : in  std_logic_vector(63 downto 0);
    mem_axi4_rresp  : in  std_logic_vector(1 downto 0);
    mem_axi4_rlast  : in  std_logic;

    io_axi4_awready : in  std_logic;
    io_axi4_awvalid : out std_logic;
    io_axi4_awid    : out std_logic_vector(3 downto 0);
    io_axi4_awaddr  : out std_logic_vector(30 downto 0);
    io_axi4_awlen   : out std_logic_vector(7 downto 0);
    io_axi4_awsize  : out std_logic_vector(2 downto 0);
    io_axi4_awburst : out std_logic_vector(1 downto 0);
    io_axi4_awlock  : out std_logic;
    io_axi4_awcache : out std_logic_vector(3 downto 0);
    io_axi4_awprot  : out std_logic_vector(2 downto 0);
    io_axi4_awqos   : out std_logic_vector(3 downto 0);
    io_axi4_wready  : in  std_logic;
    io_axi4_wvalid  : out std_logic;
    io_axi4_wdata   : out std_logic_vector(63 downto 0);
    io_axi4_wstrb   : out std_logic_vector(7 downto 0);
    io_axi4_wlast   : out std_logic;
    io_axi4_bready  : out std_logic;
    io_axi4_bvalid  : in  std_logic;
    io_axi4_bid     : in  std_logic_vector(3 downto 0);
    io_axi4_bresp   : in  std_logic_vector(1 downto 0);
    io_axi4_arready : in  std_logic;
    io_axi4_arvalid : out std_logic;
    io_axi4_arid    : out std_logic_vector(3 downto 0);
    io_axi4_araddr  : out std_logic_vector(30 downto 0);
    io_axi4_arlen   : out std_logic_vector(7 downto 0);
    io_axi4_arsize  : out std_logic_vector(2 downto 0);
    io_axi4_arburst : out std_logic_vector(1 downto 0);
    io_axi4_arlock  : out std_logic;
    io_axi4_arcache : out std_logic_vector(3 downto 0);
    io_axi4_arprot  : out std_logic_vector(2 downto 0);
    io_axi4_arqos   : out std_logic_vector(3 downto 0);
    io_axi4_rready  : out std_logic;
    io_axi4_rvalid  : in  std_logic;
    io_axi4_rid     : in  std_logic_vector(3 downto 0);
    io_axi4_rdata   : in  std_logic_vector(63 downto 0);
    io_axi4_rresp   : in  std_logic_vector(1 downto 0);
    io_axi4_rlast   : in  std_logic;

    dma_axi4_awready: out std_logic;
    dma_axi4_awvalid: in  std_logic;
    dma_axi4_awid   : in  std_logic_vector(7 downto 0);
    dma_axi4_awaddr : in  std_logic_vector(31 downto 0);
    dma_axi4_awlen  : in  std_logic_vector(7 downto 0);
    dma_axi4_awsize : in  std_logic_vector(2 downto 0);
    dma_axi4_awburst: in  std_logic_vector(1 downto 0);
    dma_axi4_awlock : in  std_logic;
    dma_axi4_awcache: in  std_logic_vector(3 downto 0);
    dma_axi4_awprot : in  std_logic_vector(2 downto 0);
    dma_axi4_awqos  : in  std_logic_vector(3 downto 0);
    dma_axi4_wready : out std_logic;
    dma_axi4_wvalid : in  std_logic;
    dma_axi4_wdata  : in  std_logic_vector(63 downto 0);
    dma_axi4_wstrb  : in  std_logic_vector(7 downto 0);
    dma_axi4_wlast  : in  std_logic;
    dma_axi4_bready : in  std_logic;
    dma_axi4_bvalid : out std_logic;
    dma_axi4_bid    : out std_logic_vector(7 downto 0);
    dma_axi4_bresp  : out std_logic_vector(1 downto 0);
    dma_axi4_arready: out std_logic;
    dma_axi4_arvalid: in  std_logic;
    dma_axi4_arid   : in  std_logic_vector(7 downto 0);
    dma_axi4_araddr : in  std_logic_vector(31 downto 0);
    dma_axi4_arlen  : in  std_logic_vector(7 downto 0);
    dma_axi4_arsize : in  std_logic_vector(2 downto 0);
    dma_axi4_arburst: in  std_logic_vector(1 downto 0);
    dma_axi4_arlock : in  std_logic;
    dma_axi4_arcache: in  std_logic_vector(3 downto 0);
    dma_axi4_arprot : in  std_logic_vector(2 downto 0);
    dma_axi4_arqos  : in  std_logic_vector(3 downto 0);
    dma_axi4_rready : in  std_logic;
    dma_axi4_rvalid : out std_logic;
    dma_axi4_rid    : out std_logic_vector(7 downto 0);
    dma_axi4_rdata  : out std_logic_vector(63 downto 0);
    dma_axi4_rresp  : out std_logic_vector(1 downto 0);
    dma_axi4_rlast  : out std_logic;

    jtag_tck: in  std_logic;
    jtag_tms: in  std_logic;
    jtag_tdi: in  std_logic;
    jtag_tdo: out std_logic;
    jtag_tdt: out std_logic);
end Rocket64b1j;

architecture Behavioral of Rocket64b1j is
    ATTRIBUTE X_INTERFACE_INFO : STRING;
    ATTRIBUTE X_INTERFACE_PARAMETER : STRING;

    ATTRIBUTE X_INTERFACE_INFO of sys_reset: SIGNAL is "xilinx.com:signal:reset:1.0 sys_reset RST";
    ATTRIBUTE X_INTERFACE_PARAMETER of sys_reset: SIGNAL is "POLARITY ACTIVE_HIGH";
    ATTRIBUTE X_INTERFACE_INFO of aresetn: SIGNAL is "xilinx.com:signal:reset:1.0 aresetn RST";
    ATTRIBUTE X_INTERFACE_PARAMETER of aresetn: SIGNAL is "POLARITY ACTIVE_LOW";
    ATTRIBUTE X_INTERFACE_INFO of clock: SIGNAL is "xilinx.com:signal:clock:1.0 clock CLK";
    ATTRIBUTE X_INTERFACE_PARAMETER of clock: SIGNAL is "ASSOCIATED_RESET aresetn, ASSOCIATED_BUSIF MEM_AXI4:DMA_AXI4:IO_AXI4";

    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_awready: SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 AWREADY";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_awvalid: SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 AWVALID";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_awid   : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 AWID";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_awaddr : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 AWADDR";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_awlen  : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 AWLEN";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_awsize : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 AWSIZE";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_awburst: SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 AWBURST";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_awlock : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 AWLOCK";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_awcache: SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 AWCACHE";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_awprot : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 AWPROT";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_awqos  : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 AWQOS";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_wready : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 WREADY";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_wvalid : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 WVALID";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_wdata  : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 WDATA";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_wstrb  : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 WSTRB";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_wlast  : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 WLAST";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_bready : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 BREADY";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_bvalid : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 BVALID";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_bid    : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 BID";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_bresp  : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 BRESP";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_arready: SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 ARREADY";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_arvalid: SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 ARVALID";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_arid   : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 ARID";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_araddr : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 ARADDR";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_arlen  : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 ARLEN";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_arsize : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 ARSIZE";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_arburst: SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 ARBURST";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_arlock : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 ARLOCK";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_arcache: SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 ARCACHE";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_arprot : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 ARPROT";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_arqos  : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 ARQOS";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_rready : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 RREADY";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_rvalid : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 RVALID";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_rid    : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 RID";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_rdata  : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 RDATA";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_rresp  : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 RRESP";
    ATTRIBUTE X_INTERFACE_INFO of mem_axi4_rlast  : SIGNAL is "xilinx.com:interface:aximm:1.0 MEM_AXI4 RLAST";
    ATTRIBUTE X_INTERFACE_PARAMETER of mem_axi4_awready: SIGNAL is "CLK_DOMAIN clock, PROTOCOL AXI4, ADDR_WIDTH 32, DATA_WIDTH 64";

    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_awready: SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 AWREADY";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_awvalid: SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 AWVALID";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_awid   : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 AWID";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_awaddr : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 AWADDR";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_awlen  : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 AWLEN";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_awsize : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 AWSIZE";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_awburst: SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 AWBURST";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_awlock : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 AWLOCK";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_awcache: SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 AWCACHE";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_awprot : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 AWPROT";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_awqos  : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 AWQOS";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_wready : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 WREADY";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_wvalid : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 WVALID";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_wdata  : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 WDATA";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_wstrb  : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 WSTRB";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_wlast  : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 WLAST";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_bready : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 BREADY";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_bvalid : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 BVALID";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_bid    : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 BID";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_bresp  : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 BRESP";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_arready: SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 ARREADY";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_arvalid: SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 ARVALID";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_arid   : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 ARID";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_araddr : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 ARADDR";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_arlen  : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 ARLEN";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_arsize : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 ARSIZE";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_arburst: SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 ARBURST";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_arlock : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 ARLOCK";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_arcache: SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 ARCACHE";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_arprot : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 ARPROT";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_arqos  : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 ARQOS";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_rready : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 RREADY";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_rvalid : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 RVALID";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_rid    : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 RID";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_rdata  : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 RDATA";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_rresp  : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 RRESP";
    ATTRIBUTE X_INTERFACE_INFO of dma_axi4_rlast  : SIGNAL is "xilinx.com:interface:aximm:1.0 DMA_AXI4 RLAST";
    ATTRIBUTE X_INTERFACE_PARAMETER of dma_axi4_awready: SIGNAL is "CLK_DOMAIN clock, PROTOCOL AXI4, ADDR_WIDTH 32, DATA_WIDTH 64";

    ATTRIBUTE X_INTERFACE_INFO of io_axi4_awready : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 AWREADY";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_awvalid : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 AWVALID";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_awid    : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 AWID";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_awaddr  : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 AWADDR";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_awlen   : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 AWLEN";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_awsize  : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 AWSIZE";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_awburst : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 AWBURST";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_awlock  : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 AWLOCK";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_awcache : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 AWCACHE";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_awprot  : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 AWPROT";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_awqos   : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 AWQOS";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_wready  : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 WREADY";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_wvalid  : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 WVALID";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_wdata   : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 WDATA";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_wstrb   : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 WSTRB";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_wlast   : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 WLAST";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_bready  : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 BREADY";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_bvalid  : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 BVALID";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_bid     : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 BID";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_bresp   : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 BRESP";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_arready : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 ARREADY";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_arvalid : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 ARVALID";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_arid    : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 ARID";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_araddr  : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 ARADDR";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_arlen   : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 ARLEN";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_arsize  : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 ARSIZE";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_arburst : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 ARBURST";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_arlock  : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 ARLOCK";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_arcache : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 ARCACHE";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_arprot  : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 ARPROT";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_arqos   : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 ARQOS";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_rready  : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 RREADY";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_rvalid  : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 RVALID";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_rid     : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 RID";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_rdata   : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 RDATA";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_rresp   : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 RRESP";
    ATTRIBUTE X_INTERFACE_INFO of io_axi4_rlast   : SIGNAL is "xilinx.com:interface:aximm:1.0 IO_AXI4 RLAST";
    ATTRIBUTE X_INTERFACE_PARAMETER of io_axi4_awready: SIGNAL is "CLK_DOMAIN clock, PROTOCOL AXI4, ADDR_WIDTH 31, DATA_WIDTH 64";

    ATTRIBUTE X_INTERFACE_INFO of jtag_tck : SIGNAL is "xilinx.com:interface:jtag:1.0 JTAG TCK";
    ATTRIBUTE X_INTERFACE_INFO of jtag_tms : SIGNAL is "xilinx.com:interface:jtag:1.0 JTAG TMS";
    ATTRIBUTE X_INTERFACE_INFO of jtag_tdi : SIGNAL is "xilinx.com:interface:jtag:1.0 JTAG TD_I";
    ATTRIBUTE X_INTERFACE_INFO of jtag_tdo : SIGNAL is "xilinx.com:interface:jtag:1.0 JTAG TD_O";
    ATTRIBUTE X_INTERFACE_INFO of jtag_tdt : SIGNAL is "xilinx.com:interface:jtag:1.0 JTAG TD_T";

    component RocketSystem is
    port (
        clock                               : in  std_logic;
        reset                               : in  std_logic;
        mem_axi4_0_aw_ready                 : in  std_logic;
        mem_axi4_0_aw_valid                 : out std_logic;
        mem_axi4_0_aw_bits_id               : out std_logic_vector(3 downto 0);
        mem_axi4_0_aw_bits_addr             : out std_logic_vector(31 downto 0);
        mem_axi4_0_aw_bits_len              : out std_logic_vector(7 downto 0);
        mem_axi4_0_aw_bits_size             : out std_logic_vector(2 downto 0);
        mem_axi4_0_aw_bits_burst            : out std_logic_vector(1 downto 0);
        mem_axi4_0_aw_bits_lock             : out std_logic;
        mem_axi4_0_aw_bits_cache            : out std_logic_vector(3 downto 0);
        mem_axi4_0_aw_bits_prot             : out std_logic_vector(2 downto 0);
        mem_axi4_0_aw_bits_qos              : out std_logic_vector(3 downto 0);
        mem_axi4_0_w_ready                  : in  std_logic;
        mem_axi4_0_w_valid                  : out std_logic;
        mem_axi4_0_w_bits_data              : out std_logic_vector(63 downto 0);
        mem_axi4_0_w_bits_strb              : out std_logic_vector(7 downto 0);
        mem_axi4_0_w_bits_last              : out std_logic;
        mem_axi4_0_b_ready                  : out std_logic;
        mem_axi4_0_b_valid                  : in  std_logic;
        mem_axi4_0_b_bits_id                : in  std_logic_vector(3 downto 0);
        mem_axi4_0_b_bits_resp              : in  std_logic_vector(1 downto 0);
        mem_axi4_0_ar_ready                 : in  std_logic;
        mem_axi4_0_ar_valid                 : out std_logic;
        mem_axi4_0_ar_bits_id               : out std_logic_vector(3 downto 0);
        mem_axi4_0_ar_bits_addr             : out std_logic_vector(31 downto 0);
        mem_axi4_0_ar_bits_len              : out std_logic_vector(7 downto 0);
        mem_axi4_0_ar_bits_size             : out std_logic_vector(2 downto 0);
        mem_axi4_0_ar_bits_burst            : out std_logic_vector(1 downto 0);
        mem_axi4_0_ar_bits_lock             : out std_logic;
        mem_axi4_0_ar_bits_cache            : out std_logic_vector(3 downto 0);
        mem_axi4_0_ar_bits_prot             : out std_logic_vector(2 downto 0);
        mem_axi4_0_ar_bits_qos              : out std_logic_vector(3 downto 0);
        mem_axi4_0_r_ready                  : out std_logic;
        mem_axi4_0_r_valid                  : in  std_logic;
        mem_axi4_0_r_bits_id                : in  std_logic_vector(3 downto 0);
        mem_axi4_0_r_bits_data              : in  std_logic_vector(63 downto 0);
        mem_axi4_0_r_bits_resp              : in  std_logic_vector(1 downto 0);
        mem_axi4_0_r_bits_last              : in  std_logic;
        mmio_axi4_0_aw_ready                : in  std_logic;
        mmio_axi4_0_aw_valid                : out std_logic;
        mmio_axi4_0_aw_bits_id              : out std_logic_vector(3 downto 0);
        mmio_axi4_0_aw_bits_addr            : out std_logic_vector(30 downto 0);
        mmio_axi4_0_aw_bits_len             : out std_logic_vector(7 downto 0);
        mmio_axi4_0_aw_bits_size            : out std_logic_vector(2 downto 0);
        mmio_axi4_0_aw_bits_burst           : out std_logic_vector(1 downto 0);
        mmio_axi4_0_aw_bits_lock            : out std_logic;
        mmio_axi4_0_aw_bits_cache           : out std_logic_vector(3 downto 0);
        mmio_axi4_0_aw_bits_prot            : out std_logic_vector(2 downto 0);
        mmio_axi4_0_aw_bits_qos             : out std_logic_vector(3 downto 0);
        mmio_axi4_0_w_ready                 : in  std_logic;
        mmio_axi4_0_w_valid                 : out std_logic;
        mmio_axi4_0_w_bits_data             : out std_logic_vector(63 downto 0);
        mmio_axi4_0_w_bits_strb             : out std_logic_vector(7 downto 0);
        mmio_axi4_0_w_bits_last             : out std_logic;
        mmio_axi4_0_b_ready                 : out std_logic;
        mmio_axi4_0_b_valid                 : in  std_logic;
        mmio_axi4_0_b_bits_id               : in  std_logic_vector(3 downto 0);
        mmio_axi4_0_b_bits_resp             : in  std_logic_vector(1 downto 0);
        mmio_axi4_0_ar_ready                : in  std_logic;
        mmio_axi4_0_ar_valid                : out std_logic;
        mmio_axi4_0_ar_bits_id              : out std_logic_vector(3 downto 0);
        mmio_axi4_0_ar_bits_addr            : out std_logic_vector(30 downto 0);
        mmio_axi4_0_ar_bits_len             : out std_logic_vector(7 downto 0);
        mmio_axi4_0_ar_bits_size            : out std_logic_vector(2 downto 0);
        mmio_axi4_0_ar_bits_burst           : out std_logic_vector(1 downto 0);
        mmio_axi4_0_ar_bits_lock            : out std_logic;
        mmio_axi4_0_ar_bits_cache           : out std_logic_vector(3 downto 0);
        mmio_axi4_0_ar_bits_prot            : out std_logic_vector(2 downto 0);
        mmio_axi4_0_ar_bits_qos             : out std_logic_vector(3 downto 0);
        mmio_axi4_0_r_ready                 : out std_logic;
        mmio_axi4_0_r_valid                 : in  std_logic;
        mmio_axi4_0_r_bits_id               : in  std_logic_vector(3 downto 0);
        mmio_axi4_0_r_bits_data             : in  std_logic_vector(63 downto 0);
        mmio_axi4_0_r_bits_resp             : in  std_logic_vector(1 downto 0);
        mmio_axi4_0_r_bits_last             : in  std_logic;
        l2_frontend_bus_axi4_0_aw_ready     : out std_logic;
        l2_frontend_bus_axi4_0_aw_valid     : in  std_logic;
        l2_frontend_bus_axi4_0_aw_bits_id   : in  std_logic_vector(7 downto 0);
        l2_frontend_bus_axi4_0_aw_bits_addr : in  std_logic_vector(31 downto 0);
        l2_frontend_bus_axi4_0_aw_bits_len  : in  std_logic_vector(7 downto 0);
        l2_frontend_bus_axi4_0_aw_bits_size : in  std_logic_vector(2 downto 0);
        l2_frontend_bus_axi4_0_aw_bits_burst: in  std_logic_vector(1 downto 0);
        l2_frontend_bus_axi4_0_aw_bits_lock : in  std_logic;
        l2_frontend_bus_axi4_0_aw_bits_cache: in  std_logic_vector(3 downto 0);
        l2_frontend_bus_axi4_0_aw_bits_prot : in  std_logic_vector(2 downto 0);
        l2_frontend_bus_axi4_0_aw_bits_qos  : in  std_logic_vector(3 downto 0);
        l2_frontend_bus_axi4_0_w_ready      : out std_logic;
        l2_frontend_bus_axi4_0_w_valid      : in  std_logic;
        l2_frontend_bus_axi4_0_w_bits_data  : in  std_logic_vector(63 downto 0);
        l2_frontend_bus_axi4_0_w_bits_strb  : in  std_logic_vector(7 downto 0);
        l2_frontend_bus_axi4_0_w_bits_last  : in  std_logic;
        l2_frontend_bus_axi4_0_b_ready      : in  std_logic;
        l2_frontend_bus_axi4_0_b_valid      : out std_logic;
        l2_frontend_bus_axi4_0_b_bits_id    : out std_logic_vector(7 downto 0);
        l2_frontend_bus_axi4_0_b_bits_resp  : out std_logic_vector(1 downto 0);
        l2_frontend_bus_axi4_0_ar_ready     : out std_logic;
        l2_frontend_bus_axi4_0_ar_valid     : in  std_logic;
        l2_frontend_bus_axi4_0_ar_bits_id   : in  std_logic_vector(7 downto 0);
        l2_frontend_bus_axi4_0_ar_bits_addr : in  std_logic_vector(31 downto 0);
        l2_frontend_bus_axi4_0_ar_bits_len  : in  std_logic_vector(7 downto 0);
        l2_frontend_bus_axi4_0_ar_bits_size : in  std_logic_vector(2 downto 0);
        l2_frontend_bus_axi4_0_ar_bits_burst: in  std_logic_vector(1 downto 0);
        l2_frontend_bus_axi4_0_ar_bits_lock : in  std_logic;
        l2_frontend_bus_axi4_0_ar_bits_cache: in  std_logic_vector(3 downto 0);
        l2_frontend_bus_axi4_0_ar_bits_prot : in  std_logic_vector(2 downto 0);
        l2_frontend_bus_axi4_0_ar_bits_qos  : in  std_logic_vector(3 downto 0);
        l2_frontend_bus_axi4_0_r_ready      : in  std_logic;
        l2_frontend_bus_axi4_0_r_valid      : out std_logic;
        l2_frontend_bus_axi4_0_r_bits_id    : out std_logic_vector(7 downto 0);
        l2_frontend_bus_axi4_0_r_bits_data  : out std_logic_vector(63 downto 0);
        l2_frontend_bus_axi4_0_r_bits_resp  : out std_logic_vector(1 downto 0);
        l2_frontend_bus_axi4_0_r_bits_last  : out std_logic;
        resetctrl_hartIsInReset_0           : in  std_logic;
        debug_clock                         : in  std_logic;
        debug_reset                         : in  std_logic;
        debug_systemjtag_jtag_TCK           : in  std_logic;
        debug_systemjtag_jtag_TMS           : in  std_logic;
        debug_systemjtag_jtag_TDI           : in  std_logic;
        debug_systemjtag_jtag_TDO_data      : out std_logic;
        debug_systemjtag_jtag_TDO_driven    : out std_logic;
        debug_systemjtag_reset              : in  std_logic;
        debug_systemjtag_mfr_id             : in  std_logic_vector(10 downto 0);
        debug_systemjtag_part_number        : in  std_logic_vector(15 downto 0);
        debug_systemjtag_version            : in  std_logic_vector(3 downto 0);
        debug_ndreset                       : out std_logic;
        debug_dmactive                      : out std_logic;
        debug_dmactiveAck                   : in  std_logic;
        interrupts                          : in  std_logic_vector(7 downto 0));
    end component RocketSystem;

    attribute ASYNC_REG : string;

    signal reset       : std_logic := '1';
    signal debug_reset : std_logic;
    signal riscv_reset : std_logic;
    signal enable_tdo  : std_logic;

    signal debug_dmactive : std_logic;

    signal reset_cnt : unsigned(4 downto 0) := "00000";
    signal reset_inp : std_logic;
    signal reset_sync: std_logic;

    signal interrupts_ss1 : std_logic_vector(7 downto 0);
    signal interrupts_ss2 : std_logic_vector(7 downto 0);
    signal interrupts_sync: std_logic_vector(7 downto 0);
    attribute ASYNC_REG of interrupts_ss1 : signal is "TRUE";
    attribute ASYNC_REG of interrupts_ss2 : signal is "TRUE";
    attribute ASYNC_REG of interrupts_sync: signal is "TRUE";


begin

    reset_inp <= sys_reset or not clock_ok or not mem_ok or not io_ok;

    syn_reset : entity work.synchronizer
    port map (
        clock => clock,
        dinp  => reset_inp,
        dout  => reset_sync);

    process (clock)
    begin
        if clock'event and clock = '1' then
            if reset_sync = '1' then
                reset_cnt <= (others => '0');
                aresetn <= '0';
                reset <= '1';
            elsif reset_cnt < "01111" then
                reset_cnt <= reset_cnt + 1;
                aresetn <= '0';
                reset <= '1';
            elsif reset_cnt < "11111" then
                reset_cnt <= reset_cnt + 1;
                aresetn <= '1';
                reset <= '1';
            else
                aresetn <= '1';
                reset <= '0';
            end if;
        end if;
    end process;

    riscv_reset <= reset or debug_reset;

    process (clock)
    begin
        if clock'event and clock = '1' then
            interrupts_ss1 <= interrupts;
            interrupts_ss2 <= interrupts_ss1;
            interrupts_sync <= interrupts_ss2;
        end if;
    end process;
    jtag_tdt <= not enable_tdo;


    rocket_system : component RocketSystem
    port map (
        clock                                => clock,
        reset                                => riscv_reset,
        mem_axi4_0_aw_ready                  => mem_axi4_awready,
        mem_axi4_0_aw_valid                  => mem_axi4_awvalid,
        mem_axi4_0_aw_bits_id                => mem_axi4_awid,
        mem_axi4_0_aw_bits_addr              => mem_axi4_awaddr,
        mem_axi4_0_aw_bits_len               => mem_axi4_awlen,
        mem_axi4_0_aw_bits_size              => mem_axi4_awsize,
        mem_axi4_0_aw_bits_burst             => mem_axi4_awburst,
        mem_axi4_0_aw_bits_lock              => mem_axi4_awlock,
        mem_axi4_0_aw_bits_cache             => mem_axi4_awcache,
        mem_axi4_0_aw_bits_prot              => mem_axi4_awprot,
        mem_axi4_0_aw_bits_qos               => mem_axi4_awqos,
        mem_axi4_0_w_ready                   => mem_axi4_wready,
        mem_axi4_0_w_valid                   => mem_axi4_wvalid,
        mem_axi4_0_w_bits_data               => mem_axi4_wdata,
        mem_axi4_0_w_bits_strb               => mem_axi4_wstrb,
        mem_axi4_0_w_bits_last               => mem_axi4_wlast,
        mem_axi4_0_b_ready                   => mem_axi4_bready,
        mem_axi4_0_b_valid                   => mem_axi4_bvalid,
        mem_axi4_0_b_bits_id                 => mem_axi4_bid,
        mem_axi4_0_b_bits_resp               => mem_axi4_bresp,
        mem_axi4_0_ar_ready                  => mem_axi4_arready,
        mem_axi4_0_ar_valid                  => mem_axi4_arvalid,
        mem_axi4_0_ar_bits_id                => mem_axi4_arid,
        mem_axi4_0_ar_bits_addr              => mem_axi4_araddr,
        mem_axi4_0_ar_bits_len               => mem_axi4_arlen,
        mem_axi4_0_ar_bits_size              => mem_axi4_arsize,
        mem_axi4_0_ar_bits_burst             => mem_axi4_arburst,
        mem_axi4_0_ar_bits_lock              => mem_axi4_arlock,
        mem_axi4_0_ar_bits_cache             => mem_axi4_arcache,
        mem_axi4_0_ar_bits_prot              => mem_axi4_arprot,
        mem_axi4_0_ar_bits_qos               => mem_axi4_arqos,
        mem_axi4_0_r_ready                   => mem_axi4_rready,
        mem_axi4_0_r_valid                   => mem_axi4_rvalid,
        mem_axi4_0_r_bits_id                 => mem_axi4_rid,
        mem_axi4_0_r_bits_data               => mem_axi4_rdata,
        mem_axi4_0_r_bits_resp               => mem_axi4_rresp,
        mem_axi4_0_r_bits_last               => mem_axi4_rlast,
        mmio_axi4_0_aw_ready                 => io_axi4_awready,
        mmio_axi4_0_aw_valid                 => io_axi4_awvalid,
        mmio_axi4_0_aw_bits_id               => io_axi4_awid,
        mmio_axi4_0_aw_bits_addr             => io_axi4_awaddr,
        mmio_axi4_0_aw_bits_len              => io_axi4_awlen,
        mmio_axi4_0_aw_bits_size             => io_axi4_awsize,
        mmio_axi4_0_aw_bits_burst            => io_axi4_awburst,
        mmio_axi4_0_aw_bits_lock             => io_axi4_awlock,
        mmio_axi4_0_aw_bits_cache            => io_axi4_awcache,
        mmio_axi4_0_aw_bits_prot             => io_axi4_awprot,
        mmio_axi4_0_aw_bits_qos              => io_axi4_awqos,
        mmio_axi4_0_w_ready                  => io_axi4_wready,
        mmio_axi4_0_w_valid                  => io_axi4_wvalid,
        mmio_axi4_0_w_bits_data              => io_axi4_wdata,
        mmio_axi4_0_w_bits_strb              => io_axi4_wstrb,
        mmio_axi4_0_w_bits_last              => io_axi4_wlast,
        mmio_axi4_0_b_ready                  => io_axi4_bready,
        mmio_axi4_0_b_valid                  => io_axi4_bvalid,
        mmio_axi4_0_b_bits_id                => io_axi4_bid,
        mmio_axi4_0_b_bits_resp              => io_axi4_bresp,
        mmio_axi4_0_ar_ready                 => io_axi4_arready,
        mmio_axi4_0_ar_valid                 => io_axi4_arvalid,
        mmio_axi4_0_ar_bits_id               => io_axi4_arid,
        mmio_axi4_0_ar_bits_addr             => io_axi4_araddr,
        mmio_axi4_0_ar_bits_len              => io_axi4_arlen,
        mmio_axi4_0_ar_bits_size             => io_axi4_arsize,
        mmio_axi4_0_ar_bits_burst            => io_axi4_arburst,
        mmio_axi4_0_ar_bits_lock             => io_axi4_arlock,
        mmio_axi4_0_ar_bits_cache            => io_axi4_arcache,
        mmio_axi4_0_ar_bits_prot             => io_axi4_arprot,
        mmio_axi4_0_ar_bits_qos              => io_axi4_arqos,
        mmio_axi4_0_r_ready                  => io_axi4_rready,
        mmio_axi4_0_r_valid                  => io_axi4_rvalid,
        mmio_axi4_0_r_bits_id                => io_axi4_rid,
        mmio_axi4_0_r_bits_data              => io_axi4_rdata,
        mmio_axi4_0_r_bits_resp              => io_axi4_rresp,
        mmio_axi4_0_r_bits_last              => io_axi4_rlast,
        l2_frontend_bus_axi4_0_aw_ready      => dma_axi4_awready,
        l2_frontend_bus_axi4_0_aw_valid      => dma_axi4_awvalid,
        l2_frontend_bus_axi4_0_aw_bits_id    => dma_axi4_awid,
        l2_frontend_bus_axi4_0_aw_bits_addr  => dma_axi4_awaddr,
        l2_frontend_bus_axi4_0_aw_bits_len   => dma_axi4_awlen,
        l2_frontend_bus_axi4_0_aw_bits_size  => dma_axi4_awsize,
        l2_frontend_bus_axi4_0_aw_bits_burst => dma_axi4_awburst,
        l2_frontend_bus_axi4_0_aw_bits_lock  => dma_axi4_awlock,
        l2_frontend_bus_axi4_0_aw_bits_cache => dma_axi4_awcache,
        l2_frontend_bus_axi4_0_aw_bits_prot  => dma_axi4_awprot,
        l2_frontend_bus_axi4_0_aw_bits_qos   => dma_axi4_awqos,
        l2_frontend_bus_axi4_0_w_ready       => dma_axi4_wready,
        l2_frontend_bus_axi4_0_w_valid       => dma_axi4_wvalid,
        l2_frontend_bus_axi4_0_w_bits_data   => dma_axi4_wdata,
        l2_frontend_bus_axi4_0_w_bits_strb   => dma_axi4_wstrb,
        l2_frontend_bus_axi4_0_w_bits_last   => dma_axi4_wlast,
        l2_frontend_bus_axi4_0_b_ready       => dma_axi4_bready,
        l2_frontend_bus_axi4_0_b_valid       => dma_axi4_bvalid,
        l2_frontend_bus_axi4_0_b_bits_id     => dma_axi4_bid,
        l2_frontend_bus_axi4_0_b_bits_resp   => dma_axi4_bresp,
        l2_frontend_bus_axi4_0_ar_ready      => dma_axi4_arready,
        l2_frontend_bus_axi4_0_ar_valid      => dma_axi4_arvalid,
        l2_frontend_bus_axi4_0_ar_bits_id    => dma_axi4_arid,
        l2_frontend_bus_axi4_0_ar_bits_addr  => dma_axi4_araddr,
        l2_frontend_bus_axi4_0_ar_bits_len   => dma_axi4_arlen,
        l2_frontend_bus_axi4_0_ar_bits_size  => dma_axi4_arsize,
        l2_frontend_bus_axi4_0_ar_bits_burst => dma_axi4_arburst,
        l2_frontend_bus_axi4_0_ar_bits_lock  => dma_axi4_arlock,
        l2_frontend_bus_axi4_0_ar_bits_cache => dma_axi4_arcache,
        l2_frontend_bus_axi4_0_ar_bits_prot  => dma_axi4_arprot,
        l2_frontend_bus_axi4_0_ar_bits_qos   => dma_axi4_arqos,
        l2_frontend_bus_axi4_0_r_ready       => dma_axi4_rready,
        l2_frontend_bus_axi4_0_r_valid       => dma_axi4_rvalid,
        l2_frontend_bus_axi4_0_r_bits_id     => dma_axi4_rid,
        l2_frontend_bus_axi4_0_r_bits_data   => dma_axi4_rdata,
        l2_frontend_bus_axi4_0_r_bits_resp   => dma_axi4_rresp,
        l2_frontend_bus_axi4_0_r_bits_last   => dma_axi4_rlast,
        resetctrl_hartIsInReset_0            => '0',
        debug_clock                          => clock,
        debug_reset                          => debug_reset,
        debug_systemjtag_jtag_TCK            => jtag_tck,
        debug_systemjtag_jtag_TMS            => jtag_tms,
        debug_systemjtag_jtag_TDI            => jtag_tdi,
        debug_systemjtag_jtag_TDO_data       => jtag_tdo,
        debug_systemjtag_jtag_TDO_driven     => enable_tdo,
        debug_systemjtag_reset               => '0',
        debug_systemjtag_mfr_id              => "10010001001",
        debug_systemjtag_part_number         => "0000000000000000",
        debug_systemjtag_version             => "0000",
        debug_ndreset                        => debug_reset,
        debug_dmactive                       => debug_dmactive,
        debug_dmactiveAck                    => debug_dmactive,
        interrupts                           => interrupts_sync);

end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity plusarg_reader is
    generic (FORMAT : string := ""; DEFAULT : integer := 0; WIDTH : integer := 32);
    port (\out\: out std_logic_vector(WIDTH-1 downto 0));
end plusarg_reader;

architecture Behavioral of plusarg_reader is
begin
    \out\ <= std_logic_vector(to_unsigned(DEFAULT, WIDTH));
end Behavioral;
