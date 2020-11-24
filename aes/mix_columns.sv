module  mix_columns(data_i, data_o);
	 input  logic [127:0] data_i;
	 output logic [127:0] data_o;
    logic        [31:0] w0, w1, w2, w3;
	 logic        [31:0]  mw0, mw1, mw2, mw3;

	 assign w0 = data_i[127:96];
    assign w1 = data_i[95:64];
    assign w2 = data_i[63:32];
    assign w3 = data_i[31:0];

	 mixw m0 (.data_i(w0), .data_o(mw0));
	 mixw m1 (.data_i(w1), .data_o(mw1));
	 mixw m2 (.data_i(w2), .data_o(mw2));
	 mixw m3 (.data_i(w3), .data_o(mw3));

   assign data_o = {mw0, mw1, mw2, mw3};
endmodule
