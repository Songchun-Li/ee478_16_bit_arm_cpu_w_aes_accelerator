module key_mem(round_i, key_o);
	input  logic [3:0] round_i;
	output logic [127:0] key_o;

	always @(*) begin
		case(round_i)
			4'd0: begin
				key_o = 128'h2B7E151628AED2A6ABF7158809CF4F3C;
			end

			4'd1: begin
				key_o = 128'hA0FAFE1788542CB123A339392A6C7605;
			end

			4'd2: begin
				key_o = 128'hF2C295F27A96B9435935807A7359F67F;
			end

			4'd3: begin
				key_o = 128'h3D80477D4716FE3E1E237E446D7A883B;
			end

			4'd4: begin
				key_o = 128'hEF44A541A8525B7FB671253BDB0BAD00;
			end

			4'd5: begin
				key_o = 128'hD4D1C6F87C839D87CAF2B8BC11F915BC;
			end

			4'd6: begin
				key_o = 128'h6D88A37A110B3EFDDBF98641CA0093FD;
			end

			4'd7: begin
				key_o = 128'h4E54F70E5F5FC9F384A64FB24EA6DC4F;
			end

			4'd8: begin
				key_o = 128'hEAD27321B58DBAD2312BF5607F8D292F;
			end

			4'd9: begin
				key_o = 128'hAC7766F319FADC2128D12941575C006E;
			end

			4'd10: begin
				key_o = 128'hD014F9A8C9EE2589E13F0CC8B6630CA6;
			end

			default: begin
				key_o = 128'h2B7E151628AED2A6ABF7158809CF4F3C;
			end
		endcase
	end
endmodule