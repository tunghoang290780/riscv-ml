# SDIO
set_property -dict {PACKAGE_PIN L4 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports sdio_clk]
set_property -dict {PACKAGE_PIN J8 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports sdio_cmd]
set_property -dict {PACKAGE_PIN M5 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {sdio_dat[0]}]
set_property -dict {PACKAGE_PIN M7 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {sdio_dat[1]}]
set_property -dict {PACKAGE_PIN H6 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {sdio_dat[2]}]
set_property -dict {PACKAGE_PIN J6 IOSTANDARD LVCMOS33 IOB TRUE} [get_ports {sdio_dat[3]}]
set_property -dict {PACKAGE_PIN R1 IOSTANDARD LVCMOS33} [get_ports sdio_reset]
set_property -dict {PACKAGE_PIN N6 IOSTANDARD LVCMOS33} [get_ports sdio_cd]


