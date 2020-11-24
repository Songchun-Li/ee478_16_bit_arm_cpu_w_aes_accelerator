module controlLogic
  ( input [15:0] instr_i
  , output logic alu_src                    // alu opernd source 0: use rd_data_2 1: use immediate
  , output logic writeback_sel              // select the writeback value to regfile 0: alu/shifter 1:memory
  , output logic RegWrite                   // write the register or not
  , output logic MemWrite                   // write the memory or not
  , output logic BrTaken                    // indicate B, Cond B, BL
  , output logic [1:0] branch_imm_sel // select the immediate used for branching address
  , output logic IsBX                 // indicate a BX command
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
  );

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

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110, ALU_NOT=3'b111;
  parameter SHIFTER_LSLS = 2'b00, SHIFTER_LSRS = 2'b01,  SHIFTER_ASRS = 2'b10, SHIFTER_RORS = 2'b11;

	always_comb begin
		casex(instr_code)
			MOVS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b00100xx;
        ALUOP = ALU_PASS_B;
        {ImmSel, IsBX, flagSet} = 4'b1101;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[10:8]};
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
      end
			MOV: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b00100xx;
        ALUOP = ALU_PASS_B;
        {ImmSel, IsBX, flagSet} = 4'bxx00;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};
        Rm = instr_i[6:3];
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
      end
			ADDI: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b10100xx;
        ALUOP = ALU_ADD;
        {ImmSel, IsBX, flagSet} = 4'b0001;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = {1'b0, instr_i[5:3]};
        Rd = {1'b0, instr_i[2:0]};
        Rm = 4'd0;
        rd_addr1_sel =1'b0 ;
        rd_addr2_sel = 1'b0;
      end
			ADDS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b00100xx;
        ALUOP = ALU_ADD;
        {ImmSel, IsBX, flagSet} = 4'bxx01;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = {1'b0, instr_i[5:3]};
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[8:6]};
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
      end
			ADD: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b00100xx;
        ALUOP = ALU_ADD;
        {ImmSel, IsBX, flagSet} = 4'b1000;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        // Let Rn = SP (r13)
        Rn = 4'b1101;
        Rd = 4'b1101;
        Rm = 4'd0;
        rd_addr1_sel = 0;
        rd_addr2_sel = 0;
      end
			SUBS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b00100xx;
        ALUOP = ALU_SUBTRACT;
        {ImmSel, IsBX, flagSet} = 4'bxx01;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = {1'b0, instr_i[5:3]};
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[8:6]};
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
      end
			SUBI: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b10100xx;
        ALUOP = ALU_SUBTRACT;
        {ImmSel, IsBX, flagSet} = 4'b0001;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = {1'b0, instr_i[5:3]};
        Rd = {1'b0, instr_i[2:0]};
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
      end
			SUB: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b10100xx;
        ALUOP = ALU_SUBTRACT;
        {ImmSel, IsBX, flagSet} = 4'b1100;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        // Let Rn = SP (r13)
        Rn = 4'b1101;
        Rd = 4'b1101;
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
      end
			CMP: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b00000xx;
        ALUOP = ALU_SUBTRACT;
        {ImmSel, IsBX, flagSet} = 4'bxx01;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = {1'b0, instr_i[2:0]};
        Rd = 4'd0;
        Rm = {1'b0, instr_i[5:3]};
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
      end
			ANDS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b00100xx;
        ALUOP = ALU_AND;
        {ImmSel, IsBX, flagSet} = 4'bxx01;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[5:3]};
        rd_addr1_sel = 1'b1;
        rd_addr2_sel = 1'b0;
      end
			EORS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b00100xx;
        ALUOP = ALU_OR;
        {ImmSel, IsBX, flagSet} = 4'bxx01;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[5:3]};
        rd_addr1_sel = 1'b1;
        rd_addr2_sel = 1'b0;
      end
      ORRS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b00100xx;
        ALUOP = ALU_XOR;
        {ImmSel, IsBX, flagSet} = 4'bxx01;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[5:3]};
        rd_addr1_sel = 1'b1;
        rd_addr2_sel = 1'b0;
      end
      MVNS: begin // TODO ???
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b00100xx;
        ALUOP = ALU_NOT;
        {ImmSel, IsBX, flagSet} = 4'bxx01;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[5:3]};
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
      end
      LSLS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b00100xx;
        ALUOP = 3'bxxx;
        {ImmSel, IsBX, flagSet} = 4'bxx01;
        shifter_type = SHIFTER_LSLS;
        alu_shift_sel = 1'b1;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[5:3]};
        rd_addr1_sel = 1'b1;
        rd_addr2_sel = 1'b0;
      end
    	LSRS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b00100xx;
        ALUOP = 3'bxxx;
        {ImmSel, IsBX, flagSet} = 4'bxx01;
        shifter_type = SHIFTER_LSRS;
        alu_shift_sel = 1'b1;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[5:3]};
        rd_addr1_sel = 1'b1;
        rd_addr2_sel = 1'b0;
      end
    	ASRS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b00100xx;
        ALUOP = 3'bxxx;
        {ImmSel, IsBX, flagSet} = 4'bxx01;
        shifter_type = SHIFTER_ASRS;
        alu_shift_sel = 1'b1;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[5:3]};
        rd_addr1_sel = 1'b1;
        rd_addr2_sel = 1'b0;
      end
    	RORS: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b00100xx;
        ALUOP = 3'bxxx;
        {ImmSel, IsBX, flagSet} = 4'bxx01;
        shifter_type = SHIFTER_RORS;
        alu_shift_sel = 1'b1;
        Rn = 4'd0;
        Rd = {1'b0, instr_i[2:0]};
        Rm = {1'b0, instr_i[5:3]};
        rd_addr1_sel = 1'b1;
        rd_addr2_sel = 1'b0;
      end

			B: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'bxx00110;
        ALUOP = 3'bxxx;
        {ImmSel, IsBX, flagSet} = 4'bxx00;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = 4'd0;
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
      end
			CB: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b0XX0101;
        ALUOP = 3'b000;
        {ImmSel, IsBX, flagSet} = 4'bxx00;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = 4'd0;
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
      end
			BL: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'bx110100;
        ALUOP = 3'bxxx;
        {ImmSel, IsBX, flagSet} = 4'bxx00;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = 4'd0;
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
      end
			BX: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b0x00xxx;
        ALUOP = 3'bxxx;
        {ImmSel, IsBX, flagSet} = 4'bxx10;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = 4'd0;
        Rd = 4'd0;
        Rm = instr_i[6:3];
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
      end
			LDUR: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b11100xx;
        ALUOP = ALU_ADD;
        {ImmSel, IsBX, flagSet} = 4'b0000;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = {1'b0, instr_i[5:3]};
        Rd = {1'b0, instr_i[2:0]};
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
  			//重点检查
      end
			STUR: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'b1x010xx;
        ALUOP = ALU_ADD;
        {ImmSel, IsBX, flagSet} = 4'b0100;
        shifter_type = 2'b00;
        alu_shift_sel = 1'b0;
        Rn = {1'b0, instr_i[5:3]};
        Rd = {1'b0, instr_i[2:0]};
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b1;
      end

			NOOP: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'd0;
        ALUOP = 3'd0;
        {ImmSel, IsBX, flagSet} = 4'd0;
        shifter_type = 2'd0;
        alu_shift_sel = 1'd0;
        Rn = 4'd0;
        Rd = 4'd0;
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
      end
			default: begin
        {alu_src, writeback_sel, RegWrite, MemWrite, BrTaken, branch_imm_sel} = 7'd0;
        ALUOP = 3'd0;
        {ImmSel, IsBX, flagSet} = 4'd0;
        shifter_type = 2'd0;
        alu_shift_sel = 1'd0;
        Rn = 4'd0;
        Rd = 4'd0;
        Rm = 4'd0;
        rd_addr1_sel = 1'b0;
        rd_addr2_sel = 1'b0;
      end
		endcase
	end
endmodule
