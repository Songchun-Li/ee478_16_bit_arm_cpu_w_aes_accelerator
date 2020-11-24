module tb ();
  logic reset, clk;
  logic [15:0] pc, Rd_val;
  logic [3:0] Rn, Rm, Rd;


	wire [3:0] rd_addr;
	cpu_pipeline_aes dut
    (.clk_i(clk)
    ,.reset(reset)
    ,.pc_o(pc)
    ,.Rn_o(Rn)
    ,.Rm_o(Rm)
    ,.Rd_o(Rd)
    ,.Rd_val(Rd_val)
    );


  //clock
	initial begin
	clk <=0;
	end

	always #5 clk = ~clk;

	initial begin
    $vcdpluson;
    $sdf_annotate("./cpu_pipeline_aes.syn.sdf",dut);
		reset <= 1;
    @(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		// @(posedge clk);
    @(negedge clk);

		reset <= 0;
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);

		assert (Rd_val == 3) $display("pass I1-add");else $error("error I1-add Rd=%b",Rd_val);
    @(posedge clk);
		assert (Rd_val == 1) $display("pass I2-subtract");else $error("error I2-subtract Rd=%b",Rd_val);
    @(posedge clk);
		assert (Rd_val == 2) $display("pass I3-add");else $error("error I3-add Rd=%b",Rd_val);@(posedge clk);@(posedge clk);
		assert (pc == 6 ) $display("pass I4-branch");else $error("error I4-branch pc=%b",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
		assert (Rd_val ==4) $display("pass I6-move");else $error("error I6-move Rd=%b",Rd_val);
    @(posedge clk);@(posedge clk);
		assert (Rd_val == 4) $display("pass I7 I8-store and load");else $error("error I78-store and load Rd=%b",Rd_val);
    @(posedge clk);@(posedge clk);
		assert (Rd_val == 4) $display("pass I9-and");else $error("error I9-and Rd=%b", Rd_val);
    @(posedge clk);
		assert (Rd_val == 4) $display("pass I10-padz");else $error("error I10-padz Rd=%b",Rd_val);
    @(posedge clk);
		assert (Rd_val == 16384) $display("pass I11-padcircle");else $error("error I11-padcircle Rd =%b", Rd_val);
    @(posedge clk);
		//test sp
		assert (Rd == 13 & Rd_val == 516) $display("pass I12-add_sp");else $error("sp error-I12 Rd address=%b", Rd);
    @(posedge clk);
		assert (Rd_val == 5) $display("pass I13-add");else $error("error I13-add Rd = %b",Rd_val);
    @(posedge clk);
		assert (Rd_val == 0) $display("pass I14-load");else $error("error I14-load Rd = %b", Rd_val);
    @(posedge clk);@(posedge clk);
		//test sp
		assert (Rd == 13  & Rd_val == 512) $display("pass I15-sub_sp");else $error("sp error-I15 Rd address=%b",Rd);
    @(posedge clk);
		assert (Rd_val == 0) $display("pass I16-subtract");else $error("error I16-subtract Rd=%b", Rd_val);
    @(posedge clk);@(posedge clk);@(posedge clk);
		//store
		assert (pc == 20) $display("pass I18-condition branch");else $error("error I18-condition branch");
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
		assert (Rd_val == 5) $display("pass I20-xor");else $error("error I20-xor Rd==", Rd_val);
    @(posedge clk);@(posedge clk);
		assert (pc == 23) $display("pass I21-BL");else $error("error I21-BL pc=",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
		assert (Rd_val == 16'h3243) $display("pass I23-load");else $error("error I23-load Rd = %b", Rd_val);
    @(posedge clk);
		assert (Rd_val == 16'hF6A8) $display("pass I24-load");else $error("error I24-load Rd = %b", Rd_val);
    @(posedge clk);
		assert (Rd_val == 16'h885A) $display("pass I25-load");else $error("error I25-load Rd = %b", Rd_val);
    @(posedge clk);
		assert (Rd_val == 16'h308D) $display("pass I26-load");else $error("error I26-load Rd = %b", Rd_val);
    @(posedge clk);
		assert (Rd_val == 16'h3131) $display("pass I27-load");else $error("error I27-load Rd = %b", Rd_val);
    @(posedge clk);
		assert (Rd_val == 16'h98A2) $display("pass I28-load");else $error("error I28-load Rd = %b", Rd_val);
    @(posedge clk);
		assert (Rd_val == 16'hE037) $display("pass I29-load");else $error("error I29-load Rd = %b", Rd_val);
    @(posedge clk);
		assert (Rd_val == 16'h0734) $display("pass I30-load");else $error("error I30-load Rd = %b", Rd_val);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
		assert (Rd_val == 16'h3925) $display("pass I40-aes");else $error("error I40-aes Rd = %b pc = %b", Rd_val,pc);
  	@(posedge clk);
		assert (Rd_val == 16'h841D) $display("pass I41-aes");else $error("error I41-aes Rd = %b", Rd_val);
  	@(posedge clk);
		assert (Rd_val == 16'h02DC) $display("pass I42-aes");else $error("error I42-aes Rd = %b", Rd_val);
  	@(posedge clk);
		assert (Rd_val == 16'h09FB) $display("pass I43-aes");else $error("error I43-aes Rd = %b", Rd_val);
  	@(posedge clk);
		assert (Rd_val == 16'hDC11) $display("pass I44-aes");else $error("error I44-aes Rd = %b", Rd_val);
  	@(posedge clk);
		assert (Rd_val == 16'h8597) $display("pass I45-aes");else $error("error I45-aes Rd = %b", Rd_val);
  	@(posedge clk);
		assert (Rd_val == 16'h196A) $display("pass I46-aes");else $error("error I46-aes Rd = %b", Rd_val);
  	@(posedge clk);
		assert (Rd_val == 16'h0B32) $display("pass I47-aes");else $error("error I47-aes Rd = %b", Rd_val);
  	@(posedge clk);
    $display("encryption done, start decryption current pc is %b" , pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
  	@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
  	@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
		assert (Rd_val == 16'h3243) $display("pass I40-aes");else $error("error I40-aes Rd = %b pc = %b", Rd_val,pc);
  	@(posedge clk);
		assert (Rd_val == 16'hF6A8) $display("pass I41-aes");else $error("error I41-aes Rd = %b", Rd_val);
  	@(posedge clk);
		assert (Rd_val == 16'h885A) $display("pass I42-aes");else $error("error I42-aes Rd = %b", Rd_val);
  	@(posedge clk);
		assert (Rd_val == 16'h308D) $display("pass I43-aes");else $error("error I43-aes Rd = %b", Rd_val);
  	@(posedge clk);
		assert (Rd_val == 16'h3131) $display("pass I44-aes");else $error("error I44-aes Rd = %b", Rd_val);
  	@(posedge clk);
		assert (Rd_val == 16'h98A2) $display("pass I45-aes");else $error("error I45-aes Rd = %b", Rd_val);
  	@(posedge clk);
		assert (Rd_val == 16'hE037) $display("pass I46-aes");else $error("error I46-aes Rd = %b", Rd_val);
  	@(posedge clk);
		assert (Rd_val == 16'h0734) $display("pass I47-aes");else $error("error I47-aes Rd = %b", Rd_val);
  	@(posedge clk);@(posedge clk);
  	@(posedge clk);

		//assert (pc == 1 ) $display("pass I23-B0");else $error("error I23-B0 pc=",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    $finish;
  end


endmodule
