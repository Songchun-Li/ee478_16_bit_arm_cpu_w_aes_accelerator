module decryptor_tb ();
  logic [127:0] input_data, rece_data;
  logic valid, yumi;
  logic clk, reset;

  initial begin
    $vcdpluson;
    clk = 1'b0;
    reset = 1'b1;
    #30;
    reset = 1'b0;
    #10;
    input_data = 128'h3925841D02DC09FBDC118597196A0B32;
    valid = 1'b1;
    #10;
    input_data = '0;
    valid = '0;
    #500;
    $finish;
  end

  always #5 clk = ~clk;
  decryptor the_decryptor
    (.clk_i(clk)
    ,.reset_i(reset)
    ,.data_i(input_data)
    ,.data_v_i(valid)
    ,.yumi_i(yumi)
    ,.data_o(rece_data)
    ,.data_v_o()
    ,.ready_o()
    );
endmodule // decryptor_tb
