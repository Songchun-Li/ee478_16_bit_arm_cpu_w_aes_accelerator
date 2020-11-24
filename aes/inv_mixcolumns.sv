module inv_mixcolumns(data_i, data_o);
	 input  logic [127:0] data_i;
	 output logic [127:0] data_o;
    logic        [31:0] w0, w1, w2, w3;
    logic        [31:0] invm0, invm1, invm2, invm3;

    assign w0 = data_i[127:96];
    assign w1 = data_i[95:64];
    assign w2 = data_i[63:32];
    assign w3 = data_i[31:0];

	 inv_mixw im0 (.data_i(w0), .data_o(invm0));
	 inv_mixw im1 (.data_i(w1), .data_o(invm1));
	 inv_mixw im2 (.data_i(w2), .data_o(invm2));
	 inv_mixw im3 (.data_i(w3), .data_o(invm3));

    assign data_o = {invm0, invm1, invm2, invm3};
endmodule