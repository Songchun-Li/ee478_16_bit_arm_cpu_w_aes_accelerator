module instr_mem
  ( input clk_i
  , input [15:0] pc_i
  , output logic [15:0] instr_o
  );
  //
  reg [15:0] instr_mem [0:511]; // instruction memory with width of 16 bits,  read initial data to read data into instr memory

  initial $readmemh("instr_mem_hex.hex", instr_mem); // read

  always_ff @(posedge clk_i) begin
    instr_o[15:0] <= instr_mem[pc_i];
 //   instr_o[7:0] <= instr_mem[pc_i];
  end


endmodule
