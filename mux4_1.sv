module mux4_1(in, sel, out);
	input logic [3:0] in;
	input logic [1:0] sel;
	output logic out;
	logic[5:0] w;


	assign w[0] = ~sel[0];
	assign w[1] = ~sel[1];
	assign w[2] = in[0] & w[0] & w[1];
	assign w[3] = in[1] & sel[0] & w[1];
	assign w[4] = in[2] & w[0] & sel[1];
	assign w[5] = in[3] & sel[0] & sel[1];
	assign out  = w[2] | w[3] | w[4] | w[5];
endmodule
