class axi4_sequencer extends uvm_sequencer#(axi4_transaction);
  `uvm_component_utils(axi4_sequencer)

  function new ( string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass
