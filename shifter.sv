module shifter
	( input [15:0] rd_data_i
	, input [15:0] rm_data_i
	, input [1:0] shift_type_i

	, output logic [15:0] data_shifted_o
	, output logic negative_o
	, output logic zero_o
	, output logic carry_o
	);

	// This shifter supports
	// LSLS: logical left shift
	// LSRS: logical right shift
	// ASRS: arithmetic right shift
	// RORS: rontational right shift
	// Only need to support Rd by Rm, no immediate input

	logic [15:0] out, unused;

	always_comb begin
		data_shifted_o = out;
		negative_o = out[15];
	  if (out == 16'd0)
			zero_o = 1;
		else
			zero_o = 0;
	end

	always_comb begin
		case (shift_type_i)
			2'b00: begin // logical left shift
							{carry_o, out} = rd_data_i << rm_data_i;
							unused = 15'd0;
						end
			2'b01: begin // logical right shift
							{out, carry_o} = rd_data_i >> rm_data_i;
							unused = 15'd0;
						end
			2'b10: begin // arithmetic right shift
							if (rd_data_i[15]) // if negative pad 1
								{unused, out, carry_o} = {16'hffff, rd_data_i} >> rm_data_i;
							else  //pad 0
								{out, carry_o} = rd_data_i >> rm_data_i;
						end
			2'b11: begin // rontational right shift
							// {unused, out, carry_o} = {rd_data_i, rd_data_i} >> rm_data_i;
							{unused, out} = {rd_data_i, rd_data_i} >> rm_data_i;
							carry_o = out[15];
						end
			default: out = rd_data_i;
		endcase
		end

	endmodule
