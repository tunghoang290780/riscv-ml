class axi4_env extends uvm_env;
  `uvm_component_utils(axi4_env);

  axi4_agent agt;
  axi4_scoreboard scb;
  axi4_subscriber axi4_subscriber_h;

  virtual dut_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = axi4_agent::type_id::create("agt", this);
    scb = axi4_scoreboard::type_id::create("scb", this);
    axi4_subscriber_h=axi4_subscriber::type_id::create("apn_subscriber_h",this);
    if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("[axi4_env]", "No virtual interface !")
    end
    uvm_config_db#(virtual dut_if)::set( this, "agt", "vif", vif);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt.mon.ap.connect(scb.mon_export);
    agt.mon.ap.connect(axi4_subscriber_h.analysis_export);
  endfunction
endclass
