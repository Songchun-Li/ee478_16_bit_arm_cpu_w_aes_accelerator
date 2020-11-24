module fullAdder (a, b, out, Cin, Cout);
	input logic a, b, Cin;
	output logic out, Cout;
	logic [2:0] w;

	/*xor #5 xor1 (out, a, b, Cin);
	and #5 and1 (w[0], a, b);
	and #5 and2 (w[1], a, Cin);
	and #5 and3 (w[2], b, Cin);
	or  #5 or1  (Cout, w[0], w[1], w[2]);*/
	assign out = a ^ b^ Cin;
	assign w[0] = a & b;
	assign w[1] = a & Cin;
	assign w[2] = b & Cin;
	assign Cout = w[0] | w[1] | w[2];
endmodule

