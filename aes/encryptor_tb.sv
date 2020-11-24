module encryptor_tb ();
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
    input_data = 128'h3243F6A8885A308D313198A2E0370734;
    valid = 1'b1;
    #10;
    input_data = '0;
    valid = '0;
    #1000;
    $finish;
  end

  always #5 clk = ~clk;
  encryptor the_encryptor
    (.clk_i(clk)
    ,.reset_i(reset)
    ,.data_i(input_data)
    ,.data_v_i(valid)
    ,.yumi_i(yumi)
    ,.data_o(rece_data)
    ,.data_v_o()
    ,.ready_o()
    );
endmodule // encryptor_tb
