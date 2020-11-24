module inv_sub_byte(data_i,data_o);
	input  logic [127:0] data_i;
	output logic [127:0] data_o;

	inv_sbox sb1  (.x(data_i[3:0]),     .y(data_i[7:4]),    .sbout(data_o[7:0]));
	inv_sbox sb2  (.x(data_i[11:8]),    .y(data_i[15:12]),  .sbout(data_o[15:8]));
	inv_sbox sb3  (.x(data_i[19:16]),   .y(data_i[23:20]),  .sbout(data_o[23:16]));
	inv_sbox sb4  (.x(data_i[27:24]),   .y(data_i[31:28]),  .sbout(data_o[31:24]));
	inv_sbox sb5  (.x(data_i[35:32]),   .y(data_i[39:36]),  .sbout(data_o[39:32]));
	inv_sbox sb6  (.x(data_i[43:40]),   .y(data_i[47:44]),  .sbout(data_o[47:40]));
	inv_sbox sb7  (.x(data_i[51:48]),   .y(data_i[55:52]),  .sbout(data_o[55:48]));
	inv_sbox sb8  (.x(data_i[59:56]),   .y(data_i[63:60]),  .sbout(data_o[63:56]));
	inv_sbox sb9  (.x(data_i[67:64]),	  .y(data_i[71:68]),  .sbout(data_o[71:64]));
	inv_sbox sb10 (.x(data_i[75:72]),   .y(data_i[79:76]),  .sbout(data_o[79:72]));
	inv_sbox sb11 (.x(data_i[83:80]),	  .y(data_i[87:84]),  .sbout(data_o[87:80]));
	inv_sbox sb12 (.x(data_i[91:88]),   .y(data_i[95:92]),  .sbout(data_o[95:88]));
	inv_sbox sb13 (.x(data_i[99:96]),   .y(data_i[103:100]),.sbout(data_o[103:96]));
	inv_sbox sb14 (.x(data_i[107:104]), .y(data_i[111:108]),.sbout(data_o[111:104]));
	inv_sbox sb15 (.x(data_i[115:112]), .y(data_i[119:116]),.sbout(data_o[119:112]));
	inv_sbox sb16 (.x(data_i[123:120]), .y(data_i[127:124]),.sbout(data_o[127:120]));
endmodule
