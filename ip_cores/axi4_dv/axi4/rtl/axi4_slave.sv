module axi4_slave(dut_if dif);
  logic [31:0] mem [0:256];
  logic [ 1:0] axi4_st;

  const logic [1:0] SETUP=0;
  const logic [1:0] W_ENABLE=1;
  const logic [1:0] R_ENABLE=2;
  
  always @(posedge dif.clk or negedge dif.rst) begin
    if (dif.rst==0) begin
      axi4_st      <=0;
      dif.dr_data  <=0;
      dif.dr_ready <=1;
      dif.b_ready  <=1;
      for(int i=0;i<256;i++) mem[i]=i;
    end
    else begin
      case (axi4_st)
        SETUP: begin
          dif.dr_data <= 0;
          if (dif.dw_strb && !dif.aw_len && !dif.ar_len) begin
            if (dif.dw_valid || dif.ar_valid) begin
              axi4_st <= W_ENABLE;
            end
            else begin
              axi4_st <= R_ENABLE;
              dif.dr_data <= mem[dif.ar_addr];
            end
          end
        end
        W_ENABLE: begin
          if (dif.dw_strb && dif.aw_len && dif.ar_len && dif.dw_valid && dif.ar_valid) begin
            mem[dif.aw_addr] <= dif.dw_data;
          end
          axi4_st <= SETUP;
        end
        R_ENABLE: begin
          axi4_st <= SETUP;
        end
      endcase
    end
  end
endmodule