module data_reg_2r1w(
    input clk_i
  , input reset_i
  , input [3:0] rd_addr1_i
  , input [3:0] rd_addr2_i
  , input rd_en_i

  , input [3:0] wr_addr_i
  , input [15:0] wr_data_i
  , input wr_en_i

  , output logic [15:0] rd_data1_o
  , output logic [15:0] rd_data2_o
  );

  // this is the data register with 2 read and 1 write
 reg [15:0] data_reg [0:15];

  always_ff @ (posedge clk_i)
    begin
      if (reset_i)
        begin
          data_reg[4'd0] <= 16'b0000000000000000;
          data_reg[4'd1] <= 16'b0000000000000001;
          data_reg[4'd2] <= 16'b0000000000000010;
          data_reg[4'd3] <= 16'b0000000000000011;
          data_reg[4'd4] <= 16'b0000000000000100;
          data_reg[4'd5] <= 16'b0000000000000101;
          data_reg[4'd6] <= 16'b0000000000000110;
          data_reg[4'd7] <= 16'b0000000000000111;
          data_reg[4'd8] <= 16'b0000000000001000;
          data_reg[4'd9] <= 16'b0000000000001001;
          data_reg[4'd10] <= 16'b0000000000001010;
          data_reg[4'd11] <= 16'b0000000000001011;
          data_reg[4'd12] <= 16'b0000000000001100;
          data_reg[4'd13] <= 16'b0000000111111111;
          data_reg[4'd14] <= 16'b0000000000000000;
          data_reg[4'd15] <= 16'b0000000000000000;
        end
      else
        begin
          if (wr_en_i)
            begin
              data_reg[wr_addr_i] <= wr_data_i;
            end
          if (rd_en_i)
            begin
              rd_data1_o <= data_reg[rd_addr1_i];
              rd_data2_o <= data_reg[rd_addr2_i];
            end
        end
    end


endmodule
