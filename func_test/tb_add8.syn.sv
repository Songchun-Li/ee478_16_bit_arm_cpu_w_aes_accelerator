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
    @(posedge clk);

    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    assert (pc == 35) $display("Jump to add4");else $error("Branch Error",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);@(posedge clk);
    assert (pc == 60) $display("Jump to add2");else $error("Branch Error",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);
    assert (pc == 46) $display("Return to add4");else $error("Branch Error",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    assert (pc == 60) $display("Jump to add2");else $error("Branch Error",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);
    assert (pc == 53) $display("Return to add4");else $error("Branch Error",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    assert (pc == 60) $display("Jump to add2");else $error("Branch Error",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);
    assert (pc == 55) $display("Return to add4");else $error("Branch Error",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    assert (pc == 17) $display("Return to add8, finishing adding the first 4 numbers");else $error("Branch Error",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    assert (pc == 35) $display("Jump to add4");else $error("Branch Error",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);@(posedge clk);
    assert (pc == 60) $display("Jump to add2");else $error("Branch Error",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);
    assert (pc == 46) $display("Return to add4");else $error("Branch Error",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    assert (pc == 60) $display("Jump to add2");else $error("Branch Error",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);
    assert (pc == 53) $display("Return to add4");else $error("Branch Error",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    assert (pc == 60) $display("Jump to add2");else $error("Branch Error",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);
    assert (pc == 55) $display("Return to add4");else $error("Branch Error",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    assert (pc == 28) $display("Return to add8, finishing adding the other 4 numbers");else $error("Branch Error",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    assert (pc == 60) $display("Jump to add2, adding the final sum");else $error("Branch Error",pc);
    @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
    $display("Add 8 numbers = ", Rd_val);
    #50
    $finish;
  end


endmodule
