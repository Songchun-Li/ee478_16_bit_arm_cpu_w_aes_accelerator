module counter_down_en
  ( input clk_i
  , input reset_i
  , input en_i
  , output logic [3:0] count_o
  , output logic underflow_o
  );

  logic [3:0] cnt_next;
  assign cnt_next = reset_i ?  4'ha : count_o - 1'b1;
  assign underflow_o = (count_o == 0);


  always_ff @(posedge clk_i or posedge reset_i)
    begin
      if (reset_i)
        begin
          count_o <= 4'ha;
        end
      else
        begin
          if (underflow_o)
            count_o <= 4'ha;
          else if(en_i)
            count_o <= cnt_next;
          else
            count_o <= count_o;
        end
    end

endmodule
