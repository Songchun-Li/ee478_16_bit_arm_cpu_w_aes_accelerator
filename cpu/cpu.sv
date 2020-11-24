module cpu
  ( input clk_i
  , input reset
  , output logic [3:0] Rn_o
  , output logic [3:0] Rm_o
  , output logic [3:0] Rd_o
  , output logic [15:0] Rd_val
  , output logic [15:0] pc_o
  );

  typedef enum [2:0] { eFetch, eDecode, eExecute, eMemory, eWriteback, eReset } state_e;
  state_e state_n, state_r;
  /*
  state summary
  000: instr fetch
  001: instr decode
  010: execution
  011: memory
  100: write back
  101:reset
  */
  // fsm
  logic state_pc_en, state_data_reg_wr_en, state_mem_wr_en, state_nzcv_en;

  always_ff @ (posedge clk_i) begin
    if (reset)
      state_r <= eReset; // if reset
    else
      state_r <= state_n; //else goes to next state
  end

  always_comb begin
    case (state_r)
      eFetch:     state_n = eDecode;
      eDecode:    state_n = eExecute;
      eExecute:   state_n = eMemory;
      eMemory:    state_n = eWriteback;
      eWriteback: state_n = eFetch;
      eReset:     state_n = eDecode;
      default:    state_n = state_r;
    endcase
  end

  always_comb begin
    case (state_r)
      eFetch: begin  // instr fetch
        state_pc_en = 1'b0;
        state_data_reg_wr_en = 1'b0;
        state_mem_wr_en = 1'b0;
        state_nzcv_en = 1'b0;
        end
      eDecode: begin  //instr decode
        state_pc_en = 1'b0;
        state_data_reg_wr_en = 1'b0;
        state_mem_wr_en = 1'b0;
        state_nzcv_en = 1'b0;
        end
      eExecute: begin // execution
        state_pc_en = 1'b0;
        state_data_reg_wr_en = 1'b0;
        state_mem_wr_en = 1'b1;
        state_nzcv_en = 1'b0;
        end
      eMemory: begin // memory
        state_pc_en = 1'b1;
        state_data_reg_wr_en = 1'b1;
        state_mem_wr_en = 1'b0;
        state_nzcv_en = 1'b1;
        end
      eWriteback: begin  //write back
        state_pc_en = 1'b0;
        state_data_reg_wr_en = 1'b0;
        state_mem_wr_en = 1'b0;
        state_nzcv_en = 1'b0;
        end
      eReset: begin  //reset
        state_pc_en = 1'b0;
        state_data_reg_wr_en = 1'b0;
        state_mem_wr_en = 1'b0;
        state_nzcv_en = 1'b0;
        end
      default: begin
        state_pc_en = 1'b0;
        state_data_reg_wr_en = 1'b0;
        state_mem_wr_en = 1'b0;
        state_nzcv_en = 1'b0;
      end
    endcase
  end


  logic [15:0] writeback_data, pc_plus2, branchAddr, newPC, alu_op1, alu_op2, aluResult, shiftResult, compResult, dataMemOut, newAddr;
  logic [15:0] rd_data1, rd_data2;
  logic [15:0] instruction, imm8_SExtd, imm8_ZExtd, imm3_ZExtd, imm7_ZExtd, imm5_ZExtd, imm6_SExtd, imm11_SExtd, alu_imm;
  logic [7:0]  imm8;
  logic [2:0]  imm3;
  logic [6:0]  imm7;
  logic [4:0]  imm5;
  logic [5:0]  imm6;
  logic [10:0] imm11;
  logic [3:0]  Rd, Rn, Rm;
  logic rd_addr1_sel, rd_addr2_sel;
  logic [2:0]  ALUOP;
  logic [1:0]  immSel;
  logic [1:0]  shifter_type, branch_imm_sel;
  logic MemWrite, reg2loc, reg3loc, alu_src, BrTaken, RegWrite, IsBX, flagSet, writeback_sel, alu_shift_sel;

  wire negative_n, zero_n, overflow_n, carry_n;
  wire [3:0] nzcv_n;
  logic [3:0] nzcv_r;

  logic [15:0] pc_r;
  ///////////////////////////////////////////////////////////////
  // output for assertion
  assign Rd_o = Rd;
  assign Rn_o = Rn;
  assign Rm_o = Rm;
  assign pc_o = pc_r;
  assign Rd_val = writeback_data;
  ///////////////////////////////////////////////////////////////


  /**********************TO DO LIST******************************/
  /*
    1. replace instr mem and data mem

  /********************Instructmem*******************/
  instr_mem instr_mem
    (.CLK(clk_i)
    ,.WEN(1'b0)
    ,.reset(1'b0)
    ,.A(pc_r[8:0])
    ,.D(16'd0)
    ,.Q(instruction)
    ,.reset2(reset)
    );
    /*
    (.CLK(clk_i)
    ,.WEN(1'b0)
    ,.A(pc_r[8:0])
    ,.D(16'd0)
    ,.Q(instruction)
    );*/

  assign imm3  =   instruction[8:6];
  assign imm8  =   instruction[7:0];
  assign imm7  =   instruction[6:0];
  assign imm5  =   instruction[10:6];
  assign imm6  =   instruction[5:0];
  assign imm11 =   instruction[10:0];

  /********************Control Logic*****************/
  controlLogic the_controlLogic
    (.instr_i(instruction)
    ,.alu_src(alu_src)              // alu opernd source 0: use rd_data_2 1: use immediate
    ,.writeback_sel(writeback_sel)  // select the writeback value to regfile 0: alu/shifter 1:memory
    ,.RegWrite(RegWrite)            // write the register or not
    ,.MemWrite(MemWrite)            // write the memory or not
    ,.BrTaken(BrTaken)              // indicate B, Cond B, BL
    ,.branch_imm_sel(branch_imm_sel)// select the immediate used for branching address
    ,.IsBX(IsBX)                    // indicate a BX command
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
    );
  /********************RegFile***********************/
  // Rm goes to read addr2
  // Rd goes to write addr,  or read addr1 (as opernd) or read addr2 (for store only)
  // Rn goes to read addr1
  logic [3:0] rd_addr1, rd_addr2;
  assign rd_addr1 = rd_addr1_sel ? Rd : Rn;
  assign rd_addr2 = rd_addr2_sel ? Rd : Rm;

  logic data_reg_wr_en;
  assign data_reg_wr_en = state_data_reg_wr_en && RegWrite;
  data_reg_2r1w regfile
    (.clk_i(clk_i)
    ,.rd_addr1_i(rd_addr1)
    ,.rd_addr2_i(rd_addr2)
    ,.wr_addr_i(Rd)
    ,.wr_data_i(writeback_data)
    ,.wr_en_i(data_reg_wr_en)
    ,.rd_data1_o(rd_data1)
    ,.rd_data2_o(rd_data2)
    );


	/***********************ALU/shifter***********************/
  // immediate choose
  mux64_16 immChoose
    (.three_input(imm8_ZExtd)
    ,.two_input(imm7_ZExtd)
    ,.one_input(imm5_ZExtd)
    ,.zero_input(imm3_ZExtd)
    ,.sel(immSel)
    ,.out(alu_imm)
    );

  assign alu_op2 = alu_src ? alu_imm : rd_data2;

  logic alu_negative_n, alu_zero_n, alu_carry_n, alu_overflow_n;
  alu_16 the_alu
    (.A(rd_data1)
    ,.B(alu_op2)
    ,.cntrl(ALUOP)
    ,.result(aluResult)
    ,.negative(alu_negative_n)
    ,.zero(alu_zero_n)
    ,.carry_out(alu_carry_n)
    ,.overflow(alu_overflow_n)
    ,.*
    );

  logic shifter_negative_n, shifter_zero_n, shifter_carry_n, shifter_overflow_n;
  assign shifter_overflow_n = nzcv_r[0]; // will not update overflow
  shifter the_shifter
    (.rd_data_i(rd_data1)
  	,.rm_data_i(rd_data2)
  	,.shift_type_i(shifter_type)
  	,.data_shifted_o(shiftResult)
    ,.negative_o(shifter_negative_n)
    ,.zero_o(shifter_zero_n)
  	,.carry_o(shifter_carry_n)
    );

  // 0: use alu result, 1: use shifter result
  mux32_16 exec_Out
    (.one_input(shiftResult)
    ,.zero_input(aluResult)
    ,.out(compResult)
    ,.sel(alu_shift_sel)
    );

  assign nzcv_n = alu_shift_sel ? {shifter_negative_n, shifter_zero_n, shifter_carry_n, shifter_overflow_n}
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
  /******************Datamem************************/
  wire mem_wr_en;
  assign mem_wr_en = state_mem_wr_en & MemWrite;
  data_mem the_data_mem
  (.CLK(clk_i)
  ,.WEN(mem_wr_en)
  ,.reset(reset)
  ,.A(compResult[8:0])
  ,.D(rd_data2)
  ,.Q(dataMemOut)
  ,.reset2(1'b0)
  );
  /*
    (.CLK(clk_i)
    ,.WEN(mem_wr_en)
    ,.A(compResult[8:0])
    ,.D(rd_data2)
    ,.Q(dataMemOut)
    );*/
  // 0: alu/shifter result, 1: data mem data
  mux32_16 dataChoose
    (.one_input(dataMemOut)
    ,.zero_input(compResult)
    ,.sel(writeback_sel)
    ,.out(writeback_data));

	/**********************Address********************/
  // pc+2
  assign pc_plus2 = pc_r + 16'd2;

  logic [15:0] cond_branch_target;
  logic [15:0] bToAddr;
  assign cond_branch_target = cond_matched ? imm8_SExtd : 16'd2;
  // branching immediate sel
  mux64_16 addr_imm_Mux
    (.three_input(16'b0)
    ,.two_input(imm11_SExtd)
    ,.one_input(cond_branch_target)
    ,.zero_input(imm6_SExtd)
    ,.sel(branch_imm_sel)
    ,.out(bToAddr)
    );

  // calculate jump target addr
  assign branchAddr = pc_r + bToAddr;

  mux32_16 branchMux
    (.one_input(branchAddr)
    ,.zero_input(pc_plus2)
    ,.sel(BrTaken)
    ,.out(newPC)
    );

  mux32_16 BXMux
    (.one_input(rd_data2)
    ,.zero_input(newPC)
    ,.sel(IsBX)
    ,.out(newAddr)
    );

	/********************NCZV register and PC********************/
  // This part is done
  wire nzcv_en;
  assign nzcv_en  = state_nzcv_en & flagSet;
  always_ff @ (posedge clk_i) begin
    if (reset)
      nzcv_r <= 4'h0;
    else if (nzcv_en)
      nzcv_r <= nzcv_n;
  end

  always_ff @(posedge clk_i) begin
    if (reset)
      pc_r <= 16'd0;
    else if (state_pc_en)
      pc_r <= newAddr;
    end

	/*****************signExtend*******************/
	bit8to16SE SE1
    (.Rin(imm8)
    ,.Rout(imm8_SExtd)
    );
	bit8to16ZE ZE1
    (.Rin(imm8)
    ,.Rout(imm8_ZExtd)
    );
	bit3to16ZE ZE2
    (.Rin(imm3)
    ,.Rout(imm3_ZExtd)
    );
	bit7to16ZE ZE3
    (.Rin(imm7)
    ,.Rout(imm7_ZExtd)
    );
	bit5to16ZE ZE4
    (.Rin(imm5)
    ,.Rout(imm5_ZExtd)
    );
	bit6to16SE SE2
    (.Rin(imm6)
    ,.Rout(imm6_SExtd)
    );
	bit11to16SE SE3
    (.Rin(imm11)
    ,.Rout(imm11_SExtd)
    );

endmodule
