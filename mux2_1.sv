module mux2_1 (in, sel, out);
	input logic [1:0] in;
	input logic sel;
	output logic out;
	logic [2:0]w;

	assign w[0] = ~sel;
	assign w[1] = w[0] & in[0];
	assign w[2] = sel & in[1];
	assign out  = w[1] | w[2];
endmodule
