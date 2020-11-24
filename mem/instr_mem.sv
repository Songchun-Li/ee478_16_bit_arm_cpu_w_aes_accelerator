module instr_mem
  ( input CLK
  , input WEN
  , input [8:0] A
  , input [15:0] D
  , output logic [15:0] Q
  );
  //
  reg [15:0] instr_mem [0:511]; // instruction memory with width of 16 bits,  read initial data to read data into instr memory

  initial $readmemb("../../src/verilog/instr_mem.txt", instr_mem); // read

  always_ff @(posedge CLK) begin
    Q[15:0] <= instr_mem[A];
  end


endmodule
