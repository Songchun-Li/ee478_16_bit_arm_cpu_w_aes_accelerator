module mixw(data_i, data_o);
	 input  logic [31:0] data_i;
	 output logic [31:0] data_o;
    logic [7:0] b0, b1, b2, b3;
    logic [7:0] mb0, mb1, mb2, mb3;
	 logic [7:0] m2b0, m3b0, m2b1, m3b1, m2b2, m3b2, m2b3, m3b3;
	 
	 mult2 m20 (.data_i(b0), .data_o(m2b0)); 
	 mult2 m21 (.data_i(b1), .data_o(m2b1));
	 mult2 m22 (.data_i(b2), .data_o(m2b2));
	 mult2 m23 (.data_i(b3), .data_o(m2b3));
	 
	 mult3 m30 (.data_i(b0), .data_o(m3b0)); 
	 mult3 m31 (.data_i(b1), .data_o(m3b1));
	 mult3 m32 (.data_i(b2), .data_o(m3b2));
	 mult3 m33 (.data_i(b3), .data_o(m3b3));
	
      assign b0 = data_i[31:24];
      assign b1 = data_i[23:16];
      assign b2 = data_i[15:8];
      assign b3 = data_i[7:0];

      assign mb0 = m2b0 ^ m3b1 ^ b2   ^ b3;
      assign mb1 = b0   ^ m2b1 ^ m3b2 ^ b3;
      assign mb2 = b0   ^ b1   ^ m2b2 ^ m3b3;
      assign mb3 = m3b0 ^ b1   ^ b2   ^ m2b3;

      assign data_o = {mb0, mb1, mb2, mb3};
endmodule
