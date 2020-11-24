module cpu_pipeline
  ( input clk_i
  , input reset
  , output logic [3:0] Rn_o
  , output logic [3:0] Rm_o
  , output logic [3:0] Rd_o
  , output logic [15:0] Rd_val
  , output logic [15:0] pc_o
  );

  logic [15:0] writeback_data, pc_plus1, branchAddr, newPC, alu_op1, alu_op2, aluResult, shiftResult, compResult, dataMemOut, newAddr;
  logic [15:0] rd_data1, rd_data2;
  logic [15:0] instruction, imm8_SExtd, imm8_ZExtd, imm3_ZExtd, imm7_ZExtd, imm5_ZExtd, imm6_SExtd, imm11_SExtd, alu_imm;
  logic [2:0]  imm3;
  logic [4:0]  imm5;
  logic [5:0]  imm6;
  logic [6:0]  imm7;
  logic [7:0]  imm8;
  logic [10:0] imm11;
  logic [3:0]  Rd, Rn, Rm;
  logic rd_addr1_sel, rd_addr2_sel;
  logic [2:0]  ALUOP;
  logic [1:0]  immSel, shifter_type;
  logic MemWrite, reg2loc, reg3loc, alu_src, RegWrite, flagSet, writeback_sel, alu_shift_sel, using_rd1, using_rd2;
  logic is_branch, is_branch_cond, is_branch_x, is_branch_lr;

  wire negative_n, zero_n, overflow_n, carry_n;
  wire [3:0] nzcv_n;
  logic [3:0] nzcv_r;

  logic [15:0] pc_r;
  logic reset_1_r, reset_2_r;
  always_ff @(posedge clk_i) begin
      reset_1_r <= reset;
      reset_2_r <= reset_1_r;
  end


  // Pipeline control signal
  logic IFID_forward_en, IDEXEC_forward_en, EXECMEM_forward_en, rd_data1_use_wb_data_forward, rd_data2_use_wb_data_forward, rd_data1_use_alu_forward, rd_data2_use_alu_forward;
  logic pc_update_en, stall_at_IFID, stall_at_EXECMEM;
  logic pipeline_flush, pipeline_flush_r;

  //////////////////////////////////////////////////////////////////////////////
  logic MemWrite_MEM, flagSet_MEM;
  logic [15:0] rd_data2_MEM;
  logic [8:0] compResult_MEM;
  logic [15:0] writeback_data_WB;
  logic [3:0] Rd_WB;
  logic RegWrite_WB;

  //////////////////////////////////////////////////////////////////////////////
  // Instruction Fetch Stage
  //////////////////////////////////////////////////////////////////////////////
  /********************Instructmem*******************/
  logic [15:0] pc_IF_r;
  always_ff @(posedge clk_i) begin
      if (pc_update_en) pc_IF_r <= pc_r;
      else pc_IF_r <= pc_IF_r;
  end
  logic [8:0] instr_addr;
  assign instr_addr = pc_update_en? pc_r[8:0]:pc_IF_r[8:0];
  instr_mem instr_mem
    (.CLK(clk_i)
    ,.WEN(1'b0)
    ,.reset(1'b0)
    ,.A(instr_addr)
    ,.D(16'd0)
    ,.Q(instruction)
    ,.reset2(reset_2_r)
    );

  assign imm3  =   instruction[8:6];
  assign imm5  =   instruction[10:6];
  assign imm6  =   instruction[5:0];
  assign imm7  =   instruction[6:0];
  assign imm8  =   instruction[7:0];
  assign imm11 =   instruction[10:0];

  /********************Control Logic*****************/
  controlLogic_pipeline the_controlLogic
    (.instr_i(instruction)
    ,.alu_src(alu_src)              // alu opernd source 0: use rd_data_2 1: use immediate
    ,.writeback_sel(writeback_sel)  // select the writeback value to regfile 0: alu/shifter 1:memory
    ,.RegWrite(RegWrite)            // write the register or not
    ,.MemWrite(MemWrite)            // write the memory or not
    ,.ALUOP(ALUOP)                  // opcode to alu unit
    ,.ImmSel(immSel)                //an additional mux，decide on imm3,imm5，imm7, imm8
    ,.flagSet(flagSet)              // update cpsr register or not
    ,.shifter_type(shifter_type)    // opcode to shifter
    ,.alu_shift_sel(alu_shift_sel)  // sel execute stage output 0: alu res, 1: shifter res
    ,.Rd(Rd)
    ,.Rn(Rn)
    ,.Rm(Rm)
    ,.rd_addr1_sel(rd_addr1_sel)    // 0: Rn 1:Rd
    ,.rd_addr2_sel(rd_addr2_sel)    // 0: Rm 1:Rd
    ,.using_rd1(using_rd1)          // for detecting data dependency in pipeline
    ,.using_rd2(using_rd2)
    ,.is_branch(is_branch)
    ,.is_branch_lr(is_branch_lr)
    ,.is_branch_cond(is_branch_cond)
    ,.is_branch_x(is_branch_x)
    );
  // Rm goes to read addr2
  // Rd goes to write addr,  or read addr1 (as opernd) or read addr2 (for store only)
  // Rn goes to read addr1
  logic [3:0] rd_addr1, rd_addr2;
  assign rd_addr1 = rd_addr1_sel ? Rd : Rn;
  assign rd_addr2 = rd_addr2_sel ? Rd : Rm;

  //////////////////////////////////////////////////////////////////////////////
  // Instruction Decode Stage
  //////////////////////////////////////////////////////////////////////////////
  logic [15:0] pc_ID_r;
  logic [3:0] Rd_ID_r, rd_addr1_ID_r, rd_addr2_ID_r;
  logic [2:0] ALUOP_ID_r;
  logic [1:0] immSel_ID_r, shifter_type_ID_r;
  logic writeback_sel_ID_r, RegWrite_ID_r, MemWrite_ID_r, flagSet_ID_r;
  logic alu_shift_sel_ID_r, alu_src_ID_r, using_rd1_ID_r, using_rd2_ID_r;
  logic is_branch_ID_r, is_branch_lr_ID_r, is_branch_cond_ID_r, is_branch_x_ID_r;

  logic [2:0]  imm3_ID_r;
  logic [4:0]  imm5_ID_r;
  logic [5:0]  imm6_ID_r;
  logic [6:0]  imm7_ID_r;
  logic [7:0]  imm8_ID_r;
  logic [10:0] imm11_ID_r;
  always_ff @(posedge clk_i) begin
    // pipeline_flush_r is used here to clean the instr newly read at the cycle the PC jumps, so it store in the FF to get extra cycles
    if (stall_at_IFID || pipeline_flush_r || pipeline_flush) begin
      MemWrite_ID_r <= '0;
      RegWrite_ID_r <= '0;
      flagSet_ID_r <= '0;
      is_branch_ID_r <= '0;
      is_branch_lr_ID_r <= '0;
      is_branch_cond_ID_r <= '0;
      is_branch_x_ID_r <= '0;
    end
    else if (IFID_forward_en) begin
      Rd_ID_r <= Rd;
      rd_addr1_ID_r <= rd_addr1;
      rd_addr2_ID_r <= rd_addr2;
      ALUOP_ID_r <= ALUOP;
      immSel_ID_r <= immSel;
      shifter_type_ID_r <= shifter_type;
      writeback_sel_ID_r <= writeback_sel;
      RegWrite_ID_r <= RegWrite;
      MemWrite_ID_r <= MemWrite;
      flagSet_ID_r <= flagSet;
      alu_shift_sel_ID_r <= alu_shift_sel;
      alu_src_ID_r <= alu_src;
      using_rd1_ID_r <= using_rd1;
      using_rd2_ID_r <= using_rd2;
      is_branch_ID_r <= is_branch;
      is_branch_lr_ID_r <= is_branch_lr;
      is_branch_cond_ID_r <= is_branch_cond;
      is_branch_x_ID_r <= is_branch_x;
      pc_ID_r <= pc_IF_r;

      imm3_ID_r <= imm3;
      imm5_ID_r <= imm5;
      imm6_ID_r <= imm6;
      imm7_ID_r <= imm7;
      imm8_ID_r <= imm8;
      imm11_ID_r <= imm11;
    end
    else begin     // Increase Part
      Rd_ID_r <= Rd_ID_r;
      rd_addr1_ID_r <= rd_addr1_ID_r;
      rd_addr2_ID_r <= rd_addr2_ID_r;
      ALUOP_ID_r <= ALUOP_ID_r;
      immSel_ID_r <= immSel_ID_r;
      shifter_type_ID_r <= shifter_type_ID_r;
      writeback_sel_ID_r <= writeback_sel_ID_r;
      RegWrite_ID_r <= RegWrite_ID_r;
      MemWrite_ID_r <= MemWrite_ID_r;
      flagSet_ID_r <= flagSet_ID_r;
      alu_shift_sel_ID_r <= alu_shift_sel_ID_r;
      alu_src_ID_r <= alu_src_ID_r;
      using_rd1_ID_r <= using_rd1_ID_r;
      using_rd2_ID_r <= using_rd2_ID_r;
      is_branch_ID_r <= is_branch_ID_r;
      is_branch_lr_ID_r <= is_branch_lr_ID_r;
      is_branch_cond_ID_r <= is_branch_cond_ID_r;
      is_branch_x_ID_r <= is_branch_x_ID_r;
      pc_ID_r <= pc_ID_r;

      imm3_ID_r <= imm3_ID_r;
      imm5_ID_r <= imm5_ID_r;
      imm6_ID_r <= imm6_ID_r;
      imm7_ID_r <= imm7_ID_r;
      imm8_ID_r <= imm8_ID_r;
      imm11_ID_r <= imm11_ID_r;
   end
  end

  data_reg_2r1w regfile
    (.clk_i(clk_i)
    ,.rd_addr1_i(rd_addr1)
    ,.rd_addr2_i(rd_addr2)
    ,.rd_en_i(IFID_forward_en)
    ,.wr_addr_i(Rd_WB)
    ,.wr_data_i(writeback_data_WB)
    ,.wr_en_i(RegWrite_WB)
    ,.rd_data1_o(rd_data1)
    ,.rd_data2_o(rd_data2)
    );

  /*****************Sign Extend*******************/
	bit8to16SE SE1
    (.Rin(imm8_ID_r)
    ,.Rout(imm8_SExtd)
    );
  bit6to16SE SE2
    (.Rin(imm6_ID_r)
    ,.Rout(imm6_SExtd)
    );
  bit11to16SE SE3
    (.Rin(imm11_ID_r)
    ,.Rout(imm11_SExtd)
    );
  logic [15:0] branch_imm;
  always_comb begin
    if (is_branch_ID_r)
      branch_imm = imm11_SExtd;
    else if (is_branch_cond_ID_r)
      branch_imm = imm8_SExtd;
    else if (is_branch_lr_ID_r)
      branch_imm = imm6_SExtd;
    else
      branch_imm = 16'd1;
  end
  /*****************Zero Extend*******************/
	bit8to16ZE ZE1
    (.Rin(imm8_ID_r)
    ,.Rout(imm8_ZExtd)
    );
	bit3to16ZE ZE2
    (.Rin(imm3_ID_r)
    ,.Rout(imm3_ZExtd)
    );
	bit7to16ZE ZE3
    (.Rin(imm7_ID_r)
    ,.Rout(imm7_ZExtd)
    );
	bit5to16ZE ZE4
    (.Rin(imm5_ID_r)
    ,.Rout(imm5_ZExtd)
    );
  // immediate choose
  mux64_16 immChoose
    (.three_input(imm8_ZExtd)
    ,.two_input(imm7_ZExtd)
    ,.one_input(imm5_ZExtd)
    ,.zero_input(imm3_ZExtd)
    ,.sel(immSel_ID_r)
    ,.out(alu_imm)
    );


  //////////////////////////////////////////////////////////////////////////////
  // Execution Stage
  //////////////////////////////////////////////////////////////////////////////
	/***********************ALU/shifter***********************/
  logic [15:0] alu_imm_EXEC_r, rd_data1_EXEC_r, rd_data2_EXEC_r, branch_imm_EXEC_r, pc_EXEC_r;
  logic [15:0] data_forwarded_from_alu_r, data_forwarded_from_wb_data_r;
  logic [3:0] Rd_EXEC_r,rd_addr1_EXEC_r, rd_addr2_EXEC_r;
  logic [2:0] ALUOP_EXEC_r;
  logic [1:0] shifter_type_EXEC_r;
  logic alu_shift_sel_EXEC_r, writeback_sel_EXEC_r, RegWrite_EXEC_r, MemWrite_EXEC_r, alu_src_EXEC_r;
  logic flagSet_EXEC_r, using_rd1_EXEC_r, using_rd2_EXEC_r;
  logic is_branch_EXEC_r, is_branch_lr_EXEC_r, is_branch_cond_EXEC_r, is_branch_x_EXEC_r;

  always_ff @(posedge clk_i) begin
    if (pipeline_flush) begin
      MemWrite_EXEC_r <= '0;
      RegWrite_EXEC_r <= '0;
      flagSet_EXEC_r <= '0;
      is_branch_EXEC_r <= '0;
      is_branch_lr_EXEC_r <= '0;
      is_branch_cond_EXEC_r <= '0;
      is_branch_x_EXEC_r <= '0;
    end
    else if (IDEXEC_forward_en) begin
        rd_data1_EXEC_r <= rd_data1;
        rd_data2_EXEC_r <= rd_data2;
        alu_imm_EXEC_r <= alu_imm;
        ALUOP_EXEC_r <= ALUOP_ID_r;
        shifter_type_EXEC_r <= shifter_type_ID_r;
        alu_shift_sel_EXEC_r <= alu_shift_sel_ID_r;
        alu_src_EXEC_r <= alu_src_ID_r;

        Rd_EXEC_r <= Rd_ID_r;
        rd_addr1_EXEC_r <= rd_addr1_ID_r;
        rd_addr2_EXEC_r <= rd_addr2_ID_r;
        writeback_sel_EXEC_r <= writeback_sel_ID_r;
        RegWrite_EXEC_r <= RegWrite_ID_r;
        MemWrite_EXEC_r <= MemWrite_ID_r;
        flagSet_EXEC_r <= flagSet_ID_r;
        using_rd1_EXEC_r <= using_rd1_ID_r;
        using_rd2_EXEC_r <= using_rd2_ID_r;
        is_branch_EXEC_r <= is_branch_ID_r;
        is_branch_lr_EXEC_r <= is_branch_lr_ID_r;
        is_branch_cond_EXEC_r <= is_branch_cond_ID_r;
        is_branch_x_EXEC_r <= is_branch_x_ID_r;
        pc_EXEC_r <= pc_ID_r;

        branch_imm_EXEC_r <= branch_imm;
    end
    else begin   // Increase Part
	rd_data1_EXEC_r <= rd_data1_EXEC_r;
        rd_data2_EXEC_r <= rd_data2_EXEC_r;
        alu_imm_EXEC_r <= alu_imm_EXEC_r;
        ALUOP_EXEC_r <= ALUOP_EXEC_r;
        shifter_type_EXEC_r <= shifter_type_EXEC_r;
        alu_shift_sel_EXEC_r <= alu_shift_sel_EXEC_r;
        alu_src_EXEC_r <= alu_src_EXEC_r;

        Rd_EXEC_r <= Rd_EXEC_r;
        rd_addr1_EXEC_r <= rd_addr1_EXEC_r;
        rd_addr2_EXEC_r <= rd_addr2_EXEC_r;
        writeback_sel_EXEC_r <= writeback_sel_EXEC_r;
        RegWrite_EXEC_r <= RegWrite_EXEC_r;
        MemWrite_EXEC_r <= MemWrite_EXEC_r;
        flagSet_EXEC_r <= flagSet_EXEC_r;
        using_rd1_EXEC_r <= using_rd1_EXEC_r;
        using_rd2_EXEC_r <= using_rd2_EXEC_r;
        is_branch_EXEC_r <= is_branch_EXEC_r;
        is_branch_lr_EXEC_r <= is_branch_lr_EXEC_r;
        is_branch_cond_EXEC_r <= is_branch_cond_EXEC_r;
        is_branch_x_EXEC_r <= is_branch_x_EXEC_r;
        pc_EXEC_r <= pc_EXEC_r;

        branch_imm_EXEC_r <= branch_imm;
   end
    data_forwarded_from_alu_r <= compResult;
    data_forwarded_from_wb_data_r <= writeback_data_WB;
  end

  // override the alu/shifter input accordng to pipeline control
  reg [15:0] rd_data1_override, rd_data2_override;
  always_comb begin // overwrite the two register
    rd_data1_override = rd_data1_EXEC_r;
    rd_data2_override = rd_data2_EXEC_r;
    if (rd_data1_use_alu_forward) begin
      rd_data1_override = data_forwarded_from_alu_r;
    end
    else if (rd_data1_use_wb_data_forward) begin
      rd_data1_override = data_forwarded_from_wb_data_r;
    end 
    else begin  //Increased Part
      rd_data1_override = rd_data1_override;
    end
    if (rd_data2_use_alu_forward) begin
      rd_data2_override = data_forwarded_from_alu_r;
    end
    else if (rd_data2_use_wb_data_forward) begin
      rd_data2_override = data_forwarded_from_wb_data_r;
    end
    else begin //Increased Part
      rd_data2_override = rd_data2_override;
    end
    alu_op2 = alu_src_EXEC_r ? alu_imm_EXEC_r : rd_data2_override;

    end

  logic alu_negative_n, alu_zero_n, alu_carry_n, alu_overflow_n;
  alu_16 the_alu
    (.A(rd_data1_override)
    ,.B(alu_op2)
    ,.cntrl(ALUOP_EXEC_r)
    ,.result(aluResult)
    ,.negative(alu_negative_n)
    ,.zero(alu_zero_n)
    ,.carry_out(alu_carry_n)
    ,.overflow(alu_overflow_n)
    );


  logic shifter_negative_n, shifter_zero_n, shifter_carry_n, shifter_overflow_n;
  assign shifter_overflow_n = nzcv_r[0]; // will not update overflow
  shifter the_shifter
    (.rd_data_i(rd_data1_override) //rd_data1_EXEC_r
  	,.rm_data_i(rd_data2_override) //rd_data2_EXEC_r
  	,.shift_type_i(shifter_type_EXEC_r)
  	,.data_shifted_o(shiftResult)
    ,.negative_o(shifter_negative_n)
    ,.zero_o(shifter_zero_n)
  	,.carry_o(shifter_carry_n)
    );

  // 0: use alu result, 1: use shifter result
  mux32_16 exec_Out
    (.one_input(shiftResult)
    ,.zero_input(aluResult)
    ,.sel(alu_shift_sel_EXEC_r)
    ,.out(compResult)
    );

  assign nzcv_n = alu_shift_sel_EXEC_r ? {shifter_negative_n, shifter_zero_n, shifter_carry_n, shifter_overflow_n}
                                       : {alu_negative_n, alu_zero_n, alu_carry_n, alu_overflow_n};

  // used for conditional branch
  wire [3:0] cond;
  assign cond = instruction[11:8];
  logic cond_matched;

  cond_matcher the_cond_matcher
    (.negative_i(nzcv_r[3])
    ,.zero_i(nzcv_r[2])
    ,.carry_i(nzcv_r[1])
    ,.overflow_i(nzcv_r[0])
    ,.cond_i(cond)
    ,.cond_matched_o(cond_matched)
    );

  always_comb begin
    flagSet_MEM = flagSet_EXEC_r;
    MemWrite_MEM = MemWrite_EXEC_r;
    rd_data2_MEM = rd_data2_override;
    compResult_MEM = compResult[8:0];
  end
  //////////////////////////////////////////////////////////////////////////////
  // Memory Stage
  //////////////////////////////////////////////////////////////////////////////
  logic [15:0] compResult_MEM_r, rd_data2_MEM_r, branch_imm_MEM_r, pc_MEM_r;
  logic [3:0] Rd_MEM_r;
  logic cond_matched_MEM_r, writeback_sel_MEM_r, RegWrite_MEM_r;
  logic is_branch_MEM_r, is_branch_lr_MEM_r,is_branch_cond_MEM_r, is_branch_x_MEM_r;
  always_ff @(posedge clk_i) begin
    if (stall_at_EXECMEM || pipeline_flush) begin
      RegWrite_MEM_r <= '0;
      cond_matched_MEM_r <= '0;
      is_branch_MEM_r <= '0;
      is_branch_lr_MEM_r <= '0;
      is_branch_cond_MEM_r <= '0;
      is_branch_x_MEM_r <= '0;
    end
    else if (EXECMEM_forward_en) begin
      compResult_MEM_r <= compResult;
      cond_matched_MEM_r <= cond_matched;
      rd_data2_MEM_r <= rd_data2_EXEC_r;
      Rd_MEM_r <= Rd_EXEC_r;
      writeback_sel_MEM_r <= writeback_sel_EXEC_r;
      RegWrite_MEM_r <= RegWrite_EXEC_r;
      is_branch_MEM_r <= is_branch_EXEC_r;
      is_branch_lr_MEM_r <= is_branch_lr_EXEC_r;
      is_branch_cond_MEM_r <= is_branch_cond_EXEC_r;
      is_branch_x_MEM_r <= is_branch_x_EXEC_r;
      pc_MEM_r <= pc_EXEC_r;

      branch_imm_MEM_r <= branch_imm_EXEC_r;
    end
    else begin   //Increased Part
      compResult_MEM_r <= compResult_MEM_r;
      cond_matched_MEM_r <= cond_matched_MEM_r;
      rd_data2_MEM_r <= rd_data2_MEM_r;
      Rd_MEM_r <= Rd_MEM_r;
      writeback_sel_MEM_r <= writeback_sel_MEM_r;
      RegWrite_MEM_r <= RegWrite_MEM_r;
      is_branch_MEM_r <= is_branch_MEM_r;
      is_branch_lr_MEM_r <= is_branch_lr_MEM_r;
      is_branch_cond_MEM_r <= is_branch_cond_MEM_r;
      is_branch_x_MEM_r <= is_branch_x_MEM_r;
      pc_MEM_r <= pc_MEM_r;

      branch_imm_MEM_r <= branch_imm_MEM_r;
    end
  end

  data_mem the_data_mem
    (.CLK(clk_i)
    ,.WEN(MemWrite_MEM)
    ,.reset(reset_2_r)
    ,.A(compResult_MEM)
    ,.D(rd_data2_MEM)
    ,.Q(dataMemOut)
    ,.reset2(1'b0)
    );

  // 0: alu/shifter result, 1: data mem data
  mux32_16 dataChoose
    (.one_input(dataMemOut)
    ,.zero_input(compResult_MEM_r)
    ,.sel(writeback_sel_MEM_r)
    ,.out(writeback_data));

  always_comb begin
    RegWrite_WB = RegWrite_MEM_r;
    Rd_WB = Rd_MEM_r;
    writeback_data_WB = is_branch_lr_MEM_r ? pc_plus1 : writeback_data; // 0: general write back, 1: writing the link register
  end

  /********************NCZV register********************/
  always_ff @ (posedge clk_i) begin
    if (reset_2_r)
      nzcv_r <= 4'h0;
    else if (flagSet_MEM)
      nzcv_r <= nzcv_n;
  end

	/**********************Address********************/
  // conditoinal branch override
  always_comb begin
    branchAddr = pc_MEM_r + branch_imm_MEM_r; // calculate jump target addr
    pc_plus1 = pc_r + 16'd1;     // pc+1
  end

  always_comb begin
    if (is_branch_x_MEM_r)
      newAddr = rd_data2_MEM_r;
    else if (is_branch_MEM_r | is_branch_lr_MEM_r | (is_branch_cond_MEM_r & cond_matched_MEM_r))
      newAddr = branchAddr;
    else
      newAddr = pc_plus1;
  end
  // checking whether we take a branch
  // If a branch is taken, flush the pipeline
  assign pipeline_flush = is_branch_MEM_r | is_branch_lr_MEM_r | (is_branch_cond_MEM_r & cond_matched_MEM_r) | is_branch_x_MEM_r;
  //////////////////////////////////////////////////////////////////////////////
  // Writeback stage (Writeback to data_reg, and update PC) //TODO
  //////////////////////////////////////////////////////////////////////////////
  logic [3:0] Rd_WB_r;
  logic RegWrite_WB_r;
  always_ff @(posedge clk_i or posedge reset_2_r) begin // Increased posedge reset_2_r
    Rd_WB_r <= Rd_MEM_r;
    RegWrite_WB_r <= RegWrite_MEM_r;
    if (reset_2_r) begin
      pc_r <= 16'd0;
      pipeline_flush_r <= 0;
    end
    else if (pc_update_en) begin
      pc_r <= newAddr;
      pipeline_flush_r <= pipeline_flush;
    end
  end

  //////////////////////////////////////////////////////////////////////////////
  // Pipelien Control logic
  //////////////////////////////////////////////////////////////////////////////
  logic consecutive_dependency, one_instr_dependency, two_instr_dependency;
  always_comb begin
    consecutive_dependency = (((rd_addr1_EXEC_r == Rd_MEM_r) && using_rd1_EXEC_r) || ((rd_addr2_EXEC_r == Rd_MEM_r) && using_rd2_EXEC_r)) &&  RegWrite_MEM_r;
    one_instr_dependency = (((rd_addr1_EXEC_r == Rd_WB_r) && using_rd1_EXEC_r) || ((rd_addr2_EXEC_r == Rd_WB_r) && using_rd2_EXEC_r)) &&  RegWrite_WB_r;
    two_instr_dependency = (((rd_addr1 == Rd_MEM_r) && using_rd1) || ((rd_addr2 == Rd_MEM_r) && using_rd2)) &&  RegWrite_MEM_r;
  end

  always_comb begin
    //default value
    pc_update_en = reset_2_r ? 1'b0 : 1'b1;
    IFID_forward_en = reset_2_r ? 1'b0 : 1'b1;
    IDEXEC_forward_en = reset_2_r ? 1'b0 : 1'b1;
    EXECMEM_forward_en = reset_2_r ? 1'b0 : 1'b1;
    rd_data1_use_wb_data_forward = 1'b0;
    rd_data2_use_wb_data_forward = 1'b0;
    rd_data1_use_alu_forward = 1'b0;
    rd_data2_use_alu_forward = 1'b0;
    stall_at_IFID = 1'b0;
    stall_at_EXECMEM = 1'b0;

    // consecutive
    if (consecutive_dependency)  begin
      // check data is forwarded from alu result or data memory
      if (writeback_sel_MEM_r) begin
        // Forwarded data comes from data memory, stall for one cycle
        pc_update_en = 1'b0;
        IFID_forward_en = 1'b0;
        IDEXEC_forward_en = 1'b0;
        EXECMEM_forward_en = 1'b0;
        stall_at_EXECMEM = 1;
        // forward data is not ready, do not use them yet
        rd_data1_use_wb_data_forward = 0;
        rd_data2_use_wb_data_forward = 0;
        // after stalling for one cycle, the formal instr moves forward, then the situation became one_instr dependency
      end
      else begin
        // from alu result, no need to stall
        rd_data1_use_alu_forward = (rd_addr1_EXEC_r == Rd_MEM_r) && using_rd1_EXEC_r && RegWrite_MEM_r;
        rd_data2_use_alu_forward = (rd_addr2_EXEC_r == Rd_MEM_r) && using_rd2_EXEC_r && RegWrite_MEM_r;
        end
    end

    if (one_instr_dependency) begin
      // one instr away, no stall required for either forwarded from data mem or from alu result
      rd_data1_use_wb_data_forward = (rd_addr1_EXEC_r == Rd_WB_r) && using_rd1_EXEC_r && RegWrite_WB_r;
      rd_data2_use_wb_data_forward = (rd_addr2_EXEC_r == Rd_WB_r) && using_rd2_EXEC_r && RegWrite_WB_r;
    end
    if (two_instr_dependency && !stall_at_EXECMEM) begin
      // two instr away (stall the pipeline before data reg (instruction decode stage))
      // write back and read the same address
      // stall for one cycle
      pc_update_en = 1'b0;
      // instr_mem_read_en = 1'b0;
      IFID_forward_en = 1'b0;
      stall_at_IFID = 1;
    end
  end
  //////////////////////////////////////////////////////////////////////////////
  // output for assertion
  assign Rd_o = Rd_WB;
  assign Rn_o = Rn;
  assign Rm_o = Rm;
  assign pc_o = pc_r;
  assign Rd_val = writeback_data_WB;

endmodule
