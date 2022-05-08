import uvm_pkg::*;
`include "uvm_macros.svh"

module tb;
  logic        clk;
  logic        rst;

  dut_if axi4_if();
  axi4_slave dut(.dif(axi4_if));

  initial begin
    axi4_if.clk=0;
  end

  always begin
    #10 axi4_if.clk = ~axi4_if.clk;
  end

  initial begin
    axi4_if.rst=0;
    repeat (1) @(posedge axi4_if.clk);
    axi4_if.rst=1;
  end

  initial begin
    uvm_config_db#(virtual dut_if)::set( null, "uvm_test_top", "vif", axi4_if);
    run_test();
  end

endmodule
