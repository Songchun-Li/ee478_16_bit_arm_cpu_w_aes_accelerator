module data_mem
  ( input CLK
  , input WEN
  , input [8:0] A
  , input [15:0] D
  , output logic [15:0] Q
  );

  reg [15:0] data_memory [0:511];

  initial $readmemb("../../src/verilog/data_mem.txt", data_memory); // read initial data to read data into data memory


  always @(posedge CLK) begin
    //write op
    if (WEN) begin
      data_memory[A] <= D[15:0];
    end
    //read op
    Q[15:0] <= data_memory[A];

  end


  endmodule
