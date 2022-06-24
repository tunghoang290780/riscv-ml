class axi4_agent extends uvm_agent;

  axi4_sequencer sqr;
  axi4_driver drv;
  axi4_monitor mon;

  virtual dut_if vif;

  `uvm_component_utils_begin(axi4_agent)
  `uvm_field_object(sqr, UVM_ALL_ON)
  `uvm_field_object(drv, UVM_ALL_ON)
  `uvm_field_object(mon, UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    sqr = axi4_sequencer::type_id::create("sqr", this);
    drv = axi4_driver::type_id::create("drv", this);
    mon = axi4_monitor::type_id::create("mon", this);

    if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("[axi4_agent]", "No virtual interface !")
    end
    uvm_config_db#(virtual dut_if)::set( this, "sqr", "vif", vif);
    uvm_config_db#(virtual dut_if)::set( this, "drv", "vif", vif);
    uvm_config_db#(virtual dut_if)::set( this, "mon", "vif", vif);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
    uvm_report_info("[axi4_agent]", "Connected driver to sequencer !");
  endfunction
endclass
