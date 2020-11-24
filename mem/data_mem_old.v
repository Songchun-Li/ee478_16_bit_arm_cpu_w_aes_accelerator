module data_mem
  ( input clk_i

  , input [15:0] addr_i
  , input [15:0] wr_data_i
  , input wr_en_i

  , output logic [15:0] rd_data_o
  );

  reg [15:0] data_memory [0:511];

  initial $readmemb("data_mem.txt", data_memory); // read initial data to read data into data memory

  //write op
  always_ff @(posedge clk_i) begin
    if (wr_en_i) begin
      data_memory[addr_i] <= wr_data_i[15:0];
      //data_memory[addr_i] <= wr_data_i[7:0];
    end
  end

  //read
  always_ff @(posedge clk_i) begin
    rd_data_o[15:0] <= data_memory[addr_i];
   // rd_data_o[7:0] <= data_memory[addr_i];
  end
  endmodule
