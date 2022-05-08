class axi4_sequence extends uvm_sequence#(axi4_transaction);
  `uvm_object_utils(axi4_sequence)

  function new (string name = "");
    super.new(name);
  endfunction

  task body();
    axi4_transaction rw_trans;
    repeat (100) begin
      rw_trans=new();
      start_item(rw_trans);
      assert(rw_trans.randomize());
      finish_item(rw_trans);
    end
  endtask
endclass
