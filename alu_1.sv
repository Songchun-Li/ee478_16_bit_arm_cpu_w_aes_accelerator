module alu_1 (a, b, Cin, Cout, sel, result);
		input logic [2:0] sel;
		input logic a, b, Cin;
		output logic Cout, result;
		logic [3:0] w;
		logic negB, outB;

		/*and #5 and1 (w[0], a, b);
		or  #5 or1  (w[1], a, b);
		xor #5 xor1 (w[2], a, b);
		not #5 not1 (negB, b);*/
		assign w[0] = a & b;
		assign w[1] = a | b;
		assign w[2] = a ^ b;
		assign negB = ~b;

		mux2_1 mux21   (.in({negB, b}), .sel(sel[0]), .out(outB));
		fullAdder add1 (.a, .b(outB), .out(w[3]), .Cin, .Cout);
		mux8_1 mux81 (.in({negB, w[2],w[1],w[0],w[3],w[3],1'b0,b}), .out(result),.*);
endmodule

