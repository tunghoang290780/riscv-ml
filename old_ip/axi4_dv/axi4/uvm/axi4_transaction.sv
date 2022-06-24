import uvm_pkg::*;
`include "uvm_macros.svh"

class axi4_transaction extends uvm_sequence_item;
  `uvm_object_utils(axi4_transaction)

  typedef enum {READ, WRITE} kind_e;

  rand bit [31:0] addr;  
  rand bit [31:0] data;  

  rand kind_e dw_valid;  
  rand kind_e ar_valid;  

  constraint c1{addr[31:0]>=32'd0; addr[31:0] <32'd256;};
  constraint c2{data[31:0]>=32'd0; data[31:0] <32'd256;};

  function new (string name = "axi4_transaction");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("pwrite=%s pwrite=%s paddr=%0h data=%0h",dw_valid,ar_valid,addr,data);
  endfunction
endclass
