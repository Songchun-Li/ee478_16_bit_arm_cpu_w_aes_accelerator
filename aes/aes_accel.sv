module aes_accel
  ( input clk_i
  , input reset_i

  , input [15:0] data_i
  , input [2:0] fill_addr
  , input data_w_i
  , input aes_issue_i
  , input opcode_i

  , input [2:0] fetch_addr
  , input result_yumi_i

  , output logic [15:0] data_o
  , output logic data_v_o
  , output logic ready_o
  );
  // TODO use a mux to choose data_o from result based on fill_addr
  logic encryptor_ready, decryptor_ready;
  logic encryptor_v_i, decryptor_v_i;
  logic encryptor_v_o, decryptor_v_o;
  logic yumi_to_encry, yumi_to_decry;
  logic [127:0] input_data, data_encrypted, data_decrypted;
  logic [7:0][15:0] result;
  logic [7:0][15:0] input_data_r;

  always_ff @(posedge clk_i) begin
    if (reset_i)
      input_data_r <= '0;
    else if (data_w_i)
      input_data_r[fill_addr] <= data_i;
  end

  typedef enum [1:0] {e_reset, e_ready, e_call_encrypt, e_call_decrypt} state_e;
  state_e state_n, state_r;

  always_ff @(posedge clk_i) begin
    if (reset_i)
      state_r <= e_reset;
    else
      state_r <= state_n;
  end

  always_comb begin
    case(state_r)
      e_reset: begin
        ready_o = 1'b0;
        data_v_o = 1'b0;
        result = 127'd0;
        yumi_to_encry = 1'b0;
        yumi_to_decry = 1'b0;
        state_n = e_ready;
      end
      e_ready: begin
        ready_o = encryptor_ready & decryptor_ready;
        data_v_o = 1'b0;
        result = 127'd0;
        yumi_to_encry = 1'b0;
        yumi_to_decry = 1'b0;
        state_n = aes_issue_i ? (opcode_i ? e_call_decrypt : e_call_encrypt) : e_ready;
      end
      e_call_encrypt: begin
        ready_o = 1'b0;
        data_v_o = encryptor_v_o;
        result = data_encrypted;
        yumi_to_encry = result_yumi_i;
        yumi_to_decry = 1'b0;
        state_n = result_yumi_i ? e_ready : e_call_encrypt;
      end
      e_call_decrypt: begin
        ready_o = 1'b0;
        data_v_o = decryptor_v_o;
        result = data_decrypted;
        yumi_to_encry = 1'b0;
        yumi_to_decry = result_yumi_i;
        state_n = result_yumi_i ? e_ready : e_call_decrypt;
      end
    endcase
  end

  always_comb begin
    input_data = input_data_r;
    if (aes_issue_i) begin
      encryptor_v_i = !opcode_i;
      decryptor_v_i = opcode_i;
    end else begin
      encryptor_v_i = 1'b0;
      decryptor_v_i = 1'b0;
    end
  end

  encryptor the_encryptor
    (.clk_i(clk_i)
    ,.reset_i(reset_i)

    ,.data_i(input_data)
    ,.data_v_i(encryptor_v_i)
    ,.yumi_i(yumi_to_encry)

    ,.data_o(data_encrypted)
    ,.data_v_o(encryptor_v_o)
    ,.ready_o(encryptor_ready)
    );

  decryptor the_decryptor
    (.clk_i(clk_i)
    ,.reset_i(reset_i)

    ,.data_i(input_data)
    ,.data_v_i(decryptor_v_i)
    ,.yumi_i(yumi_to_decry)

    ,.data_o(data_decrypted)
    ,.data_v_o(decryptor_v_o)
    ,.ready_o(decryptor_ready)
    );

  assign data_o = result[fetch_addr];

endmodule
