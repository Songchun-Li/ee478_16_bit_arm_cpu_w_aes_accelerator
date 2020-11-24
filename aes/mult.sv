module mult2 (data_i, data_o);
	input  logic [7:0] data_i;
	output logic [7:0] data_o;

	assign data_o = {data_i[6:0], 1'b0} ^ (8'h1b & {8{data_i[7]}});
endmodule

module mult3(data_i, data_o);
	input  logic [7:0] data_i;
	output logic [7:0] data_o;
	logic        [7:0] mult2_r;

	mult2 m2 (.*, .data_o(mult2_r));
	assign data_o = mult2_r ^ data_i;
endmodule

module mult4(data_i, data_o);
	input  logic [7:0] data_i;
	output logic [7:0] data_o;
	logic        [7:0] mult2_r;

	mult2 m2 (.*, .data_o(mult2_r));
	mult2 m22(.data_i(mult2_r), .data_o(data_o));
endmodule

module mult8(data_i, data_o);
	input  logic [7:0] data_i;
	output logic [7:0] data_o;
	logic        [7:0] mult4_r;

	mult4 m4 (.*, .data_o(mult4_r));
	mult2 m2 (.data_i(mult4_r), .data_o(data_o));
endmodule

module mult9(data_i, data_o);
	input  logic [7:0] data_i;
	output logic [7:0] data_o;
	logic        [7:0] mult8_r;

	mult8 m8 (.*, .data_o(mult8_r));
	assign data_o = mult8_r ^ data_i;
endmodule

module mult11(data_i, data_o);
	input  logic [7:0] data_i;
	output logic [7:0] data_o;
	logic        [7:0] mult8_r;
	logic			 [7:0] mult2_r;

	mult8 m8 (.*, .data_o(mult8_r));
	mult2 m2 (.*, .data_o(mult2_r));
	assign data_o = mult8_r ^ mult2_r ^ data_i;
endmodule

module mult13(data_i, data_o);
	input  logic [7:0] data_i;
	output logic [7:0] data_o;
	logic        [7:0] mult8_r;
	logic			 [7:0] mult4_r;

	mult8 m8 (.*, .data_o(mult8_r));
	mult4 m4 (.*, .data_o(mult4_r));
	assign data_o = mult8_r ^ mult4_r ^ data_i;
endmodule

module mult14(data_i, data_o);
	input  logic [7:0] data_i;
	output logic [7:0] data_o;
	logic        [7:0] mult8_r;
	logic			 [7:0] mult4_r;
	logic        [7:0] mult2_r;

	mult8 m8 (.*, .data_o(mult8_r));
	mult4 m4 (.*, .data_o(mult4_r));
	mult2 m2 (.*, .data_o(mult2_r));
	assign data_o = mult8_r ^ mult4_r ^ mult2_r;
endmodule
