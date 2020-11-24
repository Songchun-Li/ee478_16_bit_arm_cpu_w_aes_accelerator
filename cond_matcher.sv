module cond_matcher
  ( input negative_i
  , input zero_i
  , input carry_i
  , input overflow_i
  , input [3:0] cond_i

  , output logic cond_matched_o
  );
  //condition check up
  always_comb begin
   case(cond_i)
     4'b0000:	cond_matched_o = zero_i;                      //	euqal Z=1
     4'b0001:	cond_matched_o = ~zero_i;                     //	not equal Z=0
     4'b0010:	cond_matched_o = carry_i;                     //	C=1
     4'b0011:	cond_matched_o = ~carry_i;                     //	C=0
     4'b0100:	cond_matched_o = negative_i;                  //	negative N=1
     4'b0101:	cond_matched_o = ~negative_i;                  //	nonnegative N=0
     4'b0110:	cond_matched_o = overflow_i;                  // overflow_i V=1
     4'b0111:	cond_matched_o = ~overflow_i;                 //	no overflow_i	V=0
     4'b1000:	cond_matched_o = carry_i && ~zero_i;            // unsigned number larger	C=1 and Z=0
     4'b1001:	cond_matched_o = ~carry_i && zero_i;            // unsigned number small/euqal	C=0 and Z=1
     4'b1010:	cond_matched_o = ~(negative_i ^ overflow_i);    // signed number larger/equal	N=1_and_V=1 or N=0_and_V=0
     4'b1011:	cond_matched_o = negative_i ^ overflow_i;       // signed number smaller	N=1_and_V=0 or N=0_and_V=1
     4'b1100:	cond_matched_o = ~zero_i && ~(negative_i ^ overflow_i);  // signed number larger	Z=0_and_N=V
     4'b1101:	cond_matched_o = zero_i || (negative_i ^ overflow_i);    // signed number smaller/equal	Z=1 or N!=V
     4'b1110:	cond_matched_o = 1'b1;
     4'b1111:	cond_matched_o = 1'b0;
     default: cond_matched_o = 1'b0;
     endcase
   end
 endmodule
