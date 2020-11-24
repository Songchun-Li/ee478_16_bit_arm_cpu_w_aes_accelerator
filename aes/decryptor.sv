module decryptor
  ( input clk_i
  , input reset_i

  , input [127:0] data_i
  , input data_v_i
  , input yumi_i

  , output logic [127:0] data_o
  , output logic data_v_o
  , output logic ready_o
  );


  logic [127:0] data_n, data_r;
  logic [127:0] data_inv_byte_subed, data_inv_row_shifted, data_inv_col_mixed;
  logic [127:0] data_to_add_roundkey, data_roundkey_added;

  logic [3:0] decry_cnt;
  logic cnt_en, decry_done, data_sel, data_n_sel;
  // state_machine
  typedef enum [1:0] {e_reset, e_ready, e_busy, e_output} state_e;
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
        data_v_o = 1'b0;
        ready_o = 1'b0;
        cnt_en = 1'b0;
        data_sel = 1'b0;
        state_n = e_ready;
      end
      e_ready: begin
        data_v_o = 1'b0;
        ready_o = 1'b1;
        cnt_en = 1'b0;
        data_sel = 1'b1;
        state_n = data_v_i ? e_busy : e_ready;
      end
      e_busy: begin
        data_v_o = 1'b0;
        ready_o = 1'b0;
        cnt_en = 1'b1;
        data_sel = 1'b0;
        state_n = decry_done ? e_output : e_busy;
      end
      e_output: begin
        data_v_o = 1'b1;
        ready_o = 1'b0;
        cnt_en = 1'b0;
        data_sel = 1'b0;
        state_n = yumi_i ? e_ready : e_output;
      end
      default: begin
        data_v_o = 1'b0;
        ready_o = 1'b0;
        cnt_en = 1'b0;
        data_sel = 1'b0;
        state_n = e_reset;
      end
    endcase
  end

  assign data_n_sel = (decry_cnt == 4'ha);

  counter_down_en the_counter
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    ,.en_i(cnt_en | data_v_i)
    ,.count_o(decry_cnt)
    ,.underflow_o(decry_done)
    );

  always_ff @ (posedge clk_i or posedge reset_i) begin
    if (reset_i)
      data_r <= 128'd0;
    else
      data_r <= data_n;
  end
  inv_shiftrows the_inv_shiftrows
    (.data_i(data_r)
    ,.data_o(data_inv_row_shifted)
    );

  inv_sub_byte the_inv_sub_byte
    (.data_i(data_inv_row_shifted)
    ,.data_o(data_inv_byte_subed)
    );

  assign data_to_add_roundkey = data_sel ? data_i : data_inv_byte_subed;

  logic [127:0] round_key;
  key_mem the_key_mem
    (.round_i(decry_cnt)
    ,.key_o(round_key)
    );

  addroundkey the_addroundkey
    (.data_i(data_to_add_roundkey)
    ,.rkey(round_key)
    ,.data_o(data_roundkey_added)
    );

  inv_mixcolumns the_inv_mixcolumns
    (.data_i(data_roundkey_added)
    ,.data_o(data_inv_col_mixed)
    );

  assign data_n = data_n_sel? data_roundkey_added : data_inv_col_mixed;

  always_ff @(posedge clk_i) begin
    if (reset_i)
      data_o <= '0;
    else if(decry_done)
      data_o <= data_roundkey_added;
  end

endmodule //
