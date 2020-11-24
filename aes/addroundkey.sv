module addroundkey (data_i, rkey, data_o);
	input  logic[127:0] data_i, rkey;
	output logic[127:0] data_o;
	
   assign data_o = data_i ^ rkey;
endmodule
