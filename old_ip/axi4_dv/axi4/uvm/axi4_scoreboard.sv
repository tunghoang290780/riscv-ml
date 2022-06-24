class axi4_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi4_scoreboard)
  
  uvm_analysis_imp#(axi4_transaction, axi4_scoreboard) mon_export;
  axi4_transaction exp_queue[$];
  bit [31:0] sc_mem [0:256];
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
    mon_export = new("mon_export", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    foreach(sc_mem[i]) sc_mem[i] = i;
  endfunction
  
  function void write(axi4_transaction tr);
    exp_queue.push_back(tr);
  endfunction 
  
  virtual task run_phase(uvm_phase phase);
    axi4_transaction expdata;
    
    forever begin
      wait(exp_queue.size() > 0);
      expdata = exp_queue.pop_front();
      
      if(expdata.dw_valid == axi4_transaction::WRITE) begin
        sc_mem[expdata.addr] = expdata.data;
        `uvm_info("[axi4_scoreboard]",$sformatf("WR DATA"),UVM_LOW)
        `uvm_info("*",$sformatf("ADDR: %0h",expdata.addr),UVM_LOW)
        `uvm_info("*",$sformatf("DATA: %0h",expdata.data),UVM_LOW)        
      end
      else if(expdata.dw_valid == axi4_transaction::READ) begin
        if(sc_mem[expdata.addr] == expdata.data) begin
          `uvm_info("[axi4_scoreboard]",$sformatf("RD DATA"),UVM_LOW)
          `uvm_info("*",$sformatf("Addr: %0h",expdata.addr),UVM_LOW)
          `uvm_info("*",$sformatf("Expect : %0h Got: %0h",sc_mem[expdata.addr],expdata.data),UVM_LOW)
        end
        else begin
          `uvm_error("[axi4_scoreboard]","RD ERROR")
          `uvm_info("*",$sformatf("Addr: %0h",expdata.addr),UVM_LOW)
          `uvm_info("*",$sformatf("Expect : %0h Got: %0h",sc_mem[expdata.addr],expdata.data),UVM_LOW)
        end
      end
      
      if(expdata.ar_valid == axi4_transaction::WRITE) begin
        sc_mem[expdata.addr] = expdata.data;
        `uvm_info("[axi4_scoreboard]",$sformatf("WR DATA"),UVM_LOW)
        `uvm_info("*",$sformatf("Addr: %0h",expdata.addr),UVM_LOW)
        `uvm_info("*",$sformatf("Data: %0h",expdata.data),UVM_LOW)        
      end
      else if(expdata.ar_valid == axi4_transaction::READ) begin
        if(sc_mem[expdata.addr] == expdata.data) begin
          `uvm_info("[axi4_scoreboard]",$sformatf("RD ERROR"),UVM_LOW)
          `uvm_info("*",$sformatf("ADDR: %0h",expdata.addr),UVM_LOW)
          `uvm_info("*",$sformatf("Expect : %0h Got: %0h",sc_mem[expdata.addr],expdata.data),UVM_LOW)
        end
        else begin
          `uvm_error("[axi4_scoreboard]","RD ERROR")
          `uvm_info("*",$sformatf("ADDR: %0h",expdata.addr),UVM_LOW)
          `uvm_info("*",$sformatf("Expect : %0h Got: %0h",sc_mem[expdata.addr],expdata.data),UVM_LOW)
        end
      end
    end
  endtask 
endclass
