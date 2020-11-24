module shiftrows(data_i, data_o);
	input  logic [127:0] data_i;
	output logic [127:0] data_o;
   logic [31:0] w0, w1, w2, w3;
   logic [31:0] ws0, ws1, ws2, ws3;

	always @(data_i) begin
		w0 = data_i[127:96];
		w1 = data_i[95:64];
		w2 = data_i[63:32];
		w3 = data_i[31:0];
		ws0 = {w0[31:24], w1[23:16], w2[15:08], w3[7:0]};
		ws1 = {w1[31:24], w2[23:16], w3[15:08], w0[7:0]};
		ws2 = {w2[31:24], w3[23:16], w0[15:08], w1[7:0]};
		ws3 = {w3[31:24], w0[23:16], w1[15:08], w2[7:0]};
		data_o = {ws0, ws1, ws2, ws3};
	end
endmodule