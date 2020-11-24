module bit8to16SE (Rin, Rout);
	input logic [7:0] Rin;
	output logic [15:0] Rout;

	genvar i;
	generate
		for(i=0;i<8;i++) begin:transfer1
			assign Rout[i]=Rin[i];
		end
		for(i=8;i<16;i++)begin:movz1
			assign Rout[i]=Rin[7];
		end
	endgenerate

endmodule

module bit8to16ZE (Rin, Rout);
	input logic [7:0] Rin;
	output logic [15:0] Rout;

	genvar i;
	generate
		for(i=0;i<8;i++) begin:transfer2
			assign Rout[i]=Rin[i];
		end
		for(i=8;i<16;i++)begin:movz2
			assign Rout[i]=1'b0;
		end
	endgenerate

endmodule

module bit3to16ZE (Rin, Rout);
	input logic [2:0] Rin;
	output logic [15:0] Rout;

	genvar i;
	generate
		for(i=0;i<3;i++) begin:transfer3
			assign Rout[i]=Rin[i];
		end
		for(i=3;i<16;i++)begin:movz3
			assign Rout[i]=1'b0;
		end
	endgenerate

endmodule


module bit7to16ZE (Rin, Rout);
	input logic [6:0] Rin;
	output logic [15:0] Rout;

	genvar i;
	generate
		for(i=0;i<7;i++) begin:transfer4
			assign Rout[i]=Rin[i]; //Rout[i]=1'b0;
		end
		for(i=7;i<16;i++)begin:movz4
			assign Rout[i]=1'b0; //Rout[i]=Rin[6];
		end
	endgenerate
	endmodule

module bit5to16ZE (Rin, Rout);
	input logic [4:0] Rin;
	output logic [15:0] Rout;

	genvar i;
	generate
		for(i=0;i<5;i++) begin:transfer5
			assign Rout[i]=Rin[i];
		end
		for(i=5;i<16;i++)begin:movz5
			assign Rout[i]=1'b0;
		end
	endgenerate
	endmodule

module bit6to16SE (Rin, Rout);
	input logic [5:0] Rin;
	output logic [15:0] Rout;

	genvar i;
	generate
		for(i=0;i<6;i++) begin:transfer6
			assign Rout[i]=Rin[i];
		end
		for(i=6;i<16;i++)begin:movz6
			assign Rout[i]=Rin[5];
		end
	endgenerate
endmodule

module bit11to16SE (Rin, Rout);
	input logic [10:0] Rin;
	output logic [15:0] Rout;

	genvar i;
	generate
		for(i=0;i<11;i++) begin:transfer7
			assign Rout[i]=Rin[i];
		end
		for(i=11;i<16;i++)begin:movz7
			assign Rout[i]=Rin[10];
		end
	endgenerate

endmodule
