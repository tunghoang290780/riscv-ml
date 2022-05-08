class axi4_driver extends uvm_driver#(axi4_transaction);
  `uvm_component_utils(axi4_driver)
  
  virtual dut_if vif;
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual dut_if)::get(this,"","vif",vif)) begin
      `uvm_error("[axi4_driver]","No virtual interface !")
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    this.vif.master_cb.dw_strb <= 0;
    this.vif.master_cb.aw_len  <= 0;
    this.vif.master_cb.ar_len  <= 0;

    forever begin
      axi4_transaction tr;
      @ (this.vif.master_cb);
      seq_item_port.get_next_item(tr);
      @ (this.vif.master_cb);
      uvm_report_info("[axi4_driver]", $sformatf("Got Transaction %s",tr.convert2string()));
      case (tr.dw_valid)
        axi4_transaction::READ:  drive_read(tr.addr, tr.data);  
        axi4_transaction::WRITE: drive_write(tr.addr, tr.data);
      endcase

      case (tr.ar_valid)
        axi4_transaction::READ:  drive_read(tr.addr, tr.data);  
        axi4_transaction::WRITE: drive_write(tr.addr, tr.data);
      endcase
      seq_item_port.item_done();
    end
  endtask

  virtual protected task drive_read(input bit [31:0] addr, output logic [31:0] data);
    this.vif.master_cb.aw_addr  <= addr;
    this.vif.master_cb.ar_addr  <= addr;
    this.vif.master_cb.dw_valid <= 0;
    this.vif.master_cb.ar_valid <= 0;
    this.vif.master_cb.dw_strb  <= 1;
    @ (this.vif.master_cb);
    this.vif.master_cb.aw_len <= 1;
    this.vif.master_cb.ar_len <= 1;
    @ (this.vif.master_cb);
    data = this.vif.master_cb.dr_data;
    this.vif.master_cb.dw_strb <= 0;
    this.vif.master_cb.aw_len  <= 0;
    this.vif.master_cb.ar_len  <= 0;
  endtask

  virtual protected task drive_write(input bit [31:0] addr, input bit [31:0] data);
    this.vif.master_cb.aw_addr  <= addr;
    this.vif.master_cb.ar_addr  <= addr;
    this.vif.master_cb.dw_data  <= data;
    this.vif.master_cb.dw_valid <= 1;
    this.vif.master_cb.ar_valid <= 1;
    this.vif.master_cb.dw_strb  <= 1;
    @ (this.vif.master_cb);
    this.vif.master_cb.aw_len <= 1;
    this.vif.master_cb.ar_len <= 1;
    @ (this.vif.master_cb);
    this.vif.master_cb.dw_strb <= 0;
    this.vif.master_cb.aw_len  <= 0;
    this.vif.master_cb.ar_len  <= 0;
  endtask
endclass
