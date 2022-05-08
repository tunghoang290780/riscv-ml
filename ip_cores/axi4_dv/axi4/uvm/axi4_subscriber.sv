class axi4_subscriber extends uvm_subscriber#(axi4_transaction);
  `uvm_component_utils(axi4_subscriber)
  
  bit [31:0] addr;
  bit [31:0] data;
  
  covergroup cover_bus;
    coverpoint addr {
      bins a[16] = {[0:255]};
    }
    coverpoint data {
      bins d[16] = {[0:255]};
    }
  endgroup
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
    cover_bus=new;
  endfunction
  
  function void write(axi4_transaction t);
    `uvm_info("[axi4_subscriber]", $sformatf("Subscriber received tx %s", t.convert2string()), UVM_NONE);
   
    addr = t.addr;
    data = t.data;

    cover_bus.sample();
  endfunction
endclass
