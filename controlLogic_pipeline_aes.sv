module controlLogic_pipeline_aes
  ( input [15:0] instr_i
  , output logic alu_src              // alu opernd source 0: use rd_data_2 1: use immediate
  , output logic writeback_sel        // select the writeback value to regfile 0: alu/shifter 1:memory
  , output logic RegWrite             // write the register or not
  , output logic MemWrite             // write the memory or not
  , output logic [2:0] ALUOP          // opcode to alu unit
  , output logic [1:0] ImmSel         //an additional mux，decide on imm3,imm5，imm7, imm8
  , output logic flagSet              // update cpsr register or not
  , output logic [1:0] shifter_type   // opcode to shifter
  , output logic alu_shift_sel        // sel execute stage output 0: alu res, 1: shifter res
  , output logic [3:0] Rd
  , output logic [3:0] Rn
  , output logic [3:0] Rm
  , output logic rd_addr1_sel         // 0: Rn 1:Rd
  , output logic rd_addr2_sel         // 0: Rm 1:Rd
  , output logic using_rd1
  , output logic using_rd2
  , output logic is_branch
  , output logic is_branch_lr
  , output logic is_branch_cond
  , output logic is_branch_x
  , output logic aes_op
  , output logic aes_commit
  , output logic aes_yumi
  , output logic aes_reg_fill
  , output logic aes_reg_fetch          // 1: aes_result 0: alu/shifter result
  );
  // Job pending: adding 3 instruction for AES bp_accelerator
  // 1. Fill 16 bit data to AES register                          2 4-bit address
  // 2. Send a valid signal to AES module to start AES_FILLption     1 bit opcode
  // 3. Fetch 16 bit data from AES register                       2 4-bit address
  logic [9:0] instr_code;
  assign instr_code = instr_i[6+:10];

	parameter MOVS = 10'b00100xxxxx;
	parameter MOV  = 10'b010001100x;
	parameter ADDI = 10'b0001110xxx;
	parameter ADDS = 10'b0001100xxx;
	parameter ADD  = 10'b101100000x;
	parameter SUBS = 10'b0001101xxx;
	parameter SUBI = 10'b0001111xxx;
	parameter SUB  = 10'b101100001x;
	parameter CMP  = 10'b0100001010;
	parameter ANDS = 10'b0100000000;
	parameter EORS = 10'b0100000001;
	parameter ORRS = 10'b0100001100;
	parameter MVNS = 10'b0100001111;
	parameter LSLS = 10'b0100000010;
	parameter LSRS = 10'b0100000011;
	parameter ASRS = 10'b0100000100;
	parameter RORS = 10'b0100000111;
	parameter B    = 10'b11100xxxxx;
	parameter CB =   10'b1101xxxxxx;
	parameter BL =   10'b0100010100;
	parameter BX =   10'b010001110x;
	parameter LDUR = 10'b01101xxxxx;
	parameter STUR = 10'b01100xxxxx;
	parameter NOOP = 10'b1011111100;
  parameter AES_FILL  = 10'b1011010000;
  parameter AES_FETCH = 10'b1011011000;
  parameter AES_ISSUE = 10'b101110000x;
  parameter AES_YUMI  = 10'b1011110000;

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110, ALU_NOT=3'b111;
  parameter SHIFTER_LSLS = 2'b00, SHIFTER_LSRS = 2'b01,  SHIFTER_ASRS = 2'b10, SHIFTER_RORS = 2'b11;

	always_comb begin
    is_branch = 1'b0;
    is_branch_lr = 1'b0;
    is_branch_cond = 1'b0;
    is_branch_x = 1'b0;
    MemWrite = 1'b0;
    RegWrite = 1'b0;
    flagSet = 1'b0;
    aes_commit = 1'b0;
    aes_yumi = 1'b0;
    aes_reg_fill = 1'b0;
    aes_reg_fetch = 1'b0;

		casex(instr_code)
			MOVS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b0010;
        ALUOP = ALU_PASS_B;
        {ImmSel, flagSet} = 3'b111;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[10:8]};
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b0;
        using_rd2 = 1'b0;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
			MOV: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b0010;
        ALUOP = ALU_PASS_B;
        {ImmSel, flagSet} = 3'bxx0;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};
        Rm = instr_i[6:3];
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b0;
        using_rd2 = 1'b1;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
			ADDI: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b1010;
        ALUOP = ALU_ADD;
        {ImmSel, flagSet} = 3'b001;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = {1'b0, instr_i[5:3]};
        Rd = {1'b0, instr_i[2:0]};
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b1;
        using_rd2 = 1'b0;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
			ADDS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b0010;
        ALUOP = ALU_ADD;
        {ImmSel, flagSet} = 3'bxx1;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = {1'b0, instr_i[5:3]};
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[8:6]};
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b1;
        using_rd2 = 1'b1;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
			ADD: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b1010;
        ALUOP = ALU_ADD;
        {ImmSel, flagSet} = 3'b100;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        // Let Rn = SP (r13)
        Rn = 4'b1101;
        Rd = 4'b1101;
        Rm = 4'd0;
        rd_addr1_sel = 0;
        rd_addr2_sel = 0;
        using_rd1 = 1'b1;
        using_rd2 = 1'b0;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
			SUBS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b0010;
        ALUOP = ALU_SUBTRACT;
        {ImmSel, flagSet} = 3'bxx1;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = {1'b0, instr_i[5:3]};
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[8:6]};
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b1;
        using_rd2 = 1'b1;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
			SUBI: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b1010;
        ALUOP = ALU_SUBTRACT;
        {ImmSel, flagSet} = 3'b001;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = {1'b0, instr_i[5:3]};
        Rd = {1'b0, instr_i[2:0]};
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b1;
        using_rd2 = 1'b0;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
			SUB: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b1010;
        ALUOP = ALU_SUBTRACT;
        {ImmSel, flagSet} = 3'b100;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        // Let Rn = SP (r13)
        Rn = 4'b1101;
        Rd = 4'b1101;
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b1;
        using_rd2 = 1'b0;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
			CMP: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b0000;
        ALUOP = ALU_SUBTRACT;
        {ImmSel, flagSet} = 3'bxx1;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = {1'b0, instr_i[2:0]};
        Rd = 4'd0;
        Rm = {1'b0, instr_i[5:3]};
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b1;
        using_rd2 = 1'b1;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
			ANDS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b0010;
        ALUOP = ALU_AND;
        {ImmSel, flagSet} = 3'bxx1;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[5:3]};
        rd_addr1_sel = 1'b1;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b1;
        using_rd2 = 1'b1;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
			EORS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b0010;
        ALUOP = ALU_OR;
        {ImmSel, flagSet} = 3'bxx1;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[5:3]};
        rd_addr1_sel = 1'b1;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b1;
        using_rd2 = 1'b1;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
      ORRS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b0010;
        ALUOP = ALU_XOR;
        {ImmSel, flagSet} = 3'bxx1;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[5:3]};
        rd_addr1_sel = 1'b1;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b1;
        using_rd2 = 1'b1;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
      MVNS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b0010;
        ALUOP = ALU_NOT;
        {ImmSel, flagSet} = 3'bxx1;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[5:3]};
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b0;
        using_rd2 = 1'b1;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
      LSLS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b0010;
        ALUOP = 3'bxxx;
        {ImmSel, flagSet} = 3'bxx1;
        shifter_type = SHIFTER_LSLS;
        alu_shift_sel = 1'b1;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[5:3]};
        rd_addr1_sel = 1'b1;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b1;
        using_rd2 = 1'b1;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
    	LSRS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b0010;
        ALUOP = 3'bxxx;
        {ImmSel, flagSet} = 3'bxx1;
        shifter_type = SHIFTER_LSRS;
        alu_shift_sel = 1'b1;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[5:3]};
        rd_addr1_sel = 1'b1;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b1;
        using_rd2 = 1'b1;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
    	ASRS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b0010;
        ALUOP = 3'bxxx;
        {ImmSel, flagSet} = 3'bxx1;
        shifter_type = SHIFTER_ASRS;
        alu_shift_sel = 1'b1;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[5:3]};
        rd_addr1_sel = 1'b1;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b1;
        using_rd2 = 1'b1;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
    	RORS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b0010;
        ALUOP = 3'bxxx;
        {ImmSel, flagSet} = 3'bxx1;
        shifter_type = SHIFTER_RORS;
        alu_shift_sel = 1'b1;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[5:3]};
        rd_addr1_sel = 1'b1;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b1;
        using_rd2 = 1'b1;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end

			B: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'bxx00;
        ALUOP = 3'bxxx;
        {ImmSel, flagSet} = 3'bxx0;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = 4'd0;
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b0;
        using_rd2 = 1'b0;
        is_branch = 1'b1;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
			CB: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b0XX0;
        ALUOP = 3'b000;
        {ImmSel, flagSet} = 3'bxx0;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = 4'd0;
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b0;
        using_rd2 = 1'b0;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b1;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
			BL: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'bx110;
        ALUOP = 3'bxxx;
        {ImmSel, flagSet} = 3'bxx0;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = 4'b1110; // Let Rd = LR(r14)
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b0;
        using_rd2 = 1'b0;
        is_branch = 1'b0;
        is_branch_lr = 1'b1;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
			BX: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 5'b0x00;
        ALUOP = 3'bxxx;
        {ImmSel, flagSet} = 3'bxx0;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = 4'd0;
        Rm = instr_i[6:3];
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b0;
        using_rd2 = 1'b1; //using Rn
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b1;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
			LDUR: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b1110;
        ALUOP = ALU_ADD;
        {ImmSel, flagSet} = 3'b010;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = {1'b0, instr_i[5:3]};
        Rd = {1'b0, instr_i[2:0]};
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b1; //using Rn
        using_rd2 = 1'b0;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
			STUR: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b1x01;
        ALUOP = ALU_ADD;
        {ImmSel, flagSet} = 3'b010;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = {1'b0, instr_i[5:3]};
        Rd = {1'b0, instr_i[2:0]};
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b1;
        using_rd1 = 1'b1;
        using_rd2 = 1'b1;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
      AES_FILL: begin // Same as alu/shifter op without writing back
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'd0;
        ALUOP = 3'd0;
        {ImmSel, flagSet} = 3'd0;
        shifter_type = 2'd0;
        alu_shift_sel = 1'd0;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};   // aes register address
        Rm = {1'b0, instr_i[5:3]};   // data reg address for aes op
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b0;
        using_rd2 = 1'b1;   // using Rm to fill the aes register
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b1;
        aes_reg_fetch = 1'b0;
      end
      AES_FETCH: begin  // Same as alu/shifter op with writing back, no opernd
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'b0010;
        ALUOP = 3'd0;
        {ImmSel, flagSet} = 3'd0;
        shifter_type = 2'd0;
        alu_shift_sel = 1'd0;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]}; // write-back address
        Rm = {1'b0, instr_i[5:3]}; // aes fetch address
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b0;
        using_rd2 = 1'b0;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b1;
      end
      AES_ISSUE: begin  // Send out a valid, stall when the AES is not ready
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'd0;
        ALUOP = 3'd0;
        {ImmSel, flagSet} = 3'd0;
        shifter_type = 2'd0;
        alu_shift_sel = 1'd0;
        Rn = 4'd0;
        Rd = 4'd0;
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b0;
        using_rd2 = 1'b0;
        is_branch = 1'b0;
        aes_commit = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = instr_i[6];  // 0: encrypt 1:decrypt
        aes_commit = 1'b1;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
      AES_YUMI: begin  //  Send out a yumi, stall when the AES is not valid
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'd0;
        ALUOP = 3'd0;
        {ImmSel, flagSet} = 3'd0;
        shifter_type = 2'd0;
        alu_shift_sel = 1'd0;
        Rn = 4'd0;
        Rd = 4'd0;
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b0;
        using_rd2 = 1'b0;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b1;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
      NOOP: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'd0;
        ALUOP = 3'd0;
        {ImmSel, flagSet} = 3'd0;
        shifter_type = 2'd0;
        alu_shift_sel = 1'd0;
        Rn = 4'd0;
        Rd = 4'd0;
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b0;
        using_rd2 = 1'b0;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
			default: begin
        {alu_src, writeback_sel, RegWrite, MemWrite} = 4'd0;
        ALUOP = 3'd0;
        {ImmSel, flagSet} = 3'd0;
        shifter_type = 2'd0;
        alu_shift_sel = 1'd0;
        Rn = 4'd0;
        Rd = 4'd0;
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
        using_rd1 = 1'b0;
        using_rd2 = 1'b0;
        is_branch = 1'b0;
        is_branch_lr = 1'b0;
        is_branch_cond = 1'b0;
        is_branch_x = 1'b0;
        aes_op = 1'b0;
        aes_commit = 1'b0;
        aes_yumi = 1'b0;
        aes_reg_fill = 1'b0;
        aes_reg_fetch = 1'b0;
      end
		endcase
	end
endmodule
