module mux6_3 (zero_input, one_input, sel, out);
	input logic [2:0] one_input, zero_input;
	input logic sel;
	output logic [2:0] out;

	genvar i;
	
	generate 
		for (i = 0; i < 3; i++) begin : gen1
			mux2_1 mux21 (.in({one_input[i], zero_input[i]}), .sel(sel), .out(out[i]));
		end
	endgenerate 
endmodule