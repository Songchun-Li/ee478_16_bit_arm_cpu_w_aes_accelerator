module counter_up_en
  ( input clk_i
  , input reset_i
  , input en_i
  , output logic [3:0] count_o
  , output logic overflow_o
  );

  logic [3:0] cnt_next;
  assign cnt_next = reset_i ?  4'b0000 : count_o + 1'b1;
  assign overflow_o = (count_o == 10);

  always_ff @(posedge clk_i or posedge reset_i)
    begin
      if (reset_i)
        begin
          count_o <= 4'b0000;
        end
      else
        begin
          if (overflow_o)
            count_o <= 4'b0000;
          else if (en_i)
            count_o <= cnt_next;
          else
            count_o <= count_o;
        end
    end

endmodule
