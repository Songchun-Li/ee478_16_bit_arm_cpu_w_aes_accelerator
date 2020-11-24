module fullAdder_16 (a, b, out);
	input logic  [15:0] a, b;
	output logic [15:0] out;
	logic [15:0] carry_out;
	
	fullAdder adder1(.a(a[0]), .b(b[0]), .out(out[0]), .Cin(1'b0), .Cout(carry_out[0]));
	genvar i;
	generate
		for (i = 1; i < 16; i++) begin: gen1
			fullAdder adder (.a(a[i]), .b(b[i]), .out(out[i]), .Cin(carry_out[i-1]), .Cout(carry_out[i]));
		end
	endgenerate
endmodule