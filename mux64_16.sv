module mux64_16 (zero_input, one_input, two_input, three_input, sel, out);
	input logic [15:0] one_input, zero_input, two_input, three_input;
	input logic [1:0] sel;
	output logic [15:0] out;

	genvar i;
	
	generate 
		for (i = 0; i < 16; i++) begin : gen1
			mux4_1 mux41 (.in({three_input[i], two_input[i], one_input[i], zero_input[i]}), .sel(sel), .out(out[i]));
		end
	endgenerate 
endmodule
