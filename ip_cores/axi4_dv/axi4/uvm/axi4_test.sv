class axi4_test extends uvm_test;

  `uvm_component_utils(axi4_test);

  axi4_env env;
  virtual dut_if vif;

  function new(string name = "axi4_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    env = axi4_env::type_id::create("env", this);

    if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("[axi4_test]", "No virtual interface !")
    end 
    uvm_config_db#(virtual dut_if)::set( this, "env", "vif", vif);
  endfunction

  task run_phase( uvm_phase phase );
    axi4_sequence axi4_seq;
    axi4_seq = axi4_sequence::type_id::create("axi4_seq");
    phase.raise_objection( this, "START Sequence" );
    $display("%t RUN Sequence >",$time);
    axi4_seq.start(env.agt.sqr);
    //#100ns;
    phase.drop_objection( this , "FINISH Sequence" );
  endtask
endclass
