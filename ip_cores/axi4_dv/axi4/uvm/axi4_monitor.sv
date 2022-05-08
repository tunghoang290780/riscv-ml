class axi4_monitor extends uvm_monitor;

  uvm_analysis_port#(axi4_transaction) ap;
  virtual dut_if vif;

  `uvm_component_utils(axi4_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif)) begin
      `uvm_error("[axi4_monitor]", "No virtual interface !")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      axi4_transaction tr;
      do begin
        @ (this.vif.monitor_cb);
      end
      while (this.vif.monitor_cb.dw_strb !== 1'b1 || this.vif.monitor_cb.aw_len !== 1'b0 || this.vif.monitor_cb.ar_len !== 1'b0);
      tr = axi4_transaction::type_id::create("tr", this);

      tr.dw_valid = (this.vif.monitor_cb.dw_valid) ? axi4_transaction::WRITE : axi4_transaction::READ;
      tr.ar_valid = (this.vif.monitor_cb.ar_valid) ? axi4_transaction::WRITE : axi4_transaction::READ;
      tr.addr = this.vif.monitor_cb.aw_addr;

      @ (this.vif.monitor_cb);
      if (this.vif.monitor_cb.aw_len !== 1'b1 || this.vif.monitor_cb.ar_len !== 1'b1) begin
        `uvm_error("[axi4_monitor]", "SETUP not followed by ENABLE !");
      end

      if (tr.ar_valid == axi4_transaction::READ) begin
        tr.data = this.vif.monitor_cb.dr_data;
      end
      else if (tr.dw_valid == axi4_transaction::WRITE) begin
        tr.data = this.vif.monitor_cb.dw_data;
      end

      uvm_report_info("[axi4_monitor]", $sformatf("Got Transaction %s",tr.convert2string()));
      ap.write(tr);
    end
  endtask
endclass
