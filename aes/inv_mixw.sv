module inv_mixw(data_i, data_o);
	 input  logic [31:0] data_i;
	 output logic [31:0] data_o;
    logic [7:0] b0, b1, b2, b3;
    logic [7:0] mb0, mb1, mb2, mb3;
	 logic [7:0] m14b0, m11b1, m13b2, m9b3, m9b0, m14b1, m11b2, m13b3;
	 logic [7:0] m13b0, m9b1, m14b2, m11b3, m11b0, m13b1, m9b2, m14b3;

    assign b0 = data_i[31:24];
    assign b1 = data_i[23:16];
    assign b2 = data_i[15:8];
    assign b3 = data_i[7:0];
	 
	 mult14 m140 (.data_i(b0), .data_o(m14b0));
	 mult11 m111 (.data_i(b1), .data_o(m11b1));
	 mult13 m132 (.data_i(b2), .data_o(m13b2));
	 mult9  m93  (.data_i(b3), .data_o(m9b3));
	 mult9  m90  (.data_i(b0), .data_o(m9b0));
	 mult14 m141 (.data_i(b1), .data_o(m14b1));
	 mult11 m112 (.data_i(b2), .data_o(m11b2));
	 mult13 m133 (.data_i(b3), .data_o(m13b3));
	 mult13 m130 (.data_i(b0), .data_o(m13b0));
	 mult9  m91  (.data_i(b1), .data_o(m9b1));
	 mult14 m142 (.data_i(b2), .data_o(m14b2));
	 mult11 m113 (.data_i(b3), .data_o(m11b3));
	 mult11 m110 (.data_i(b0), .data_o(m11b0));
	 mult13 m131 (.data_i(b1), .data_o(m13b1));
	 mult9  m92  (.data_i(b2), .data_o(m9b2));
	 mult14 m143 (.data_i(b3), .data_o(m14b3));

    assign mb0 = m14b0 ^ m11b1 ^ m13b2 ^ m9b3;
    assign mb1 = m9b0  ^ m14b1 ^ m11b2 ^ m13b3;
    assign mb2 = m13b0 ^ m9b1  ^ m14b2 ^ m11b3;
    assign mb3 = m11b0 ^ m13b1 ^ m9b2  ^ m14b3;

    assign data_o = {mb0, mb1, mb2, mb3};
endmodule
