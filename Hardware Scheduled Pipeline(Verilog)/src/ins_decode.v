module instruction_decoder
       #(parameter INSTRUCTION_LENGTH = 32,
         parameter OPCODE_SIZE = 6,
         parameter FUNC_CODE_SIZE = 6,
         parameter MAX_SHIFT = 5,
         parameter NUM_ALU_OPS = 16,
         parameter WORD_SIZE = 32)
         (
            input [INSTRUCTION_LENGTH-1:0]      i_instruction,
            output                              o_jump_reg,
            output                              o_jump_addr,
            output                              o_branch,
            output                              o_memToReg,
            output [$clog2(NUM_ALU_OPS) - 1:0]  o_ALUOP,
            output                              o_ALUSrc,
            output                              o_regWrite,
            output                              o_extType,
            output                              o_regDst,
            output [MAX_SHIFT-1:0]              o_shamt,
            output [(WORD_SIZE/4)-1:0]          o_qByte,
            output                              o_memWrite,
            output                              o_link,
            output                              o_bne,
            output                              o_halt    
            
         );
         
         `include "instruction_lookup.vh"
         
         wire [OPCODE_SIZE-1:0] op_code = i_instruction[INSTRUCTION_LENGTH-1 -: OPCODE_SIZE];
         wire [FUNC_CODE_SIZE-1:0] func_code = i_instruction[0 +: OPCODE_SIZE];
         
        assign o_qByte = i_instruction[23:16];
        
        assign o_halt = op_code == op_halt;
        
        assign o_jump_addr = op_code == op_jc ? 1'b1 : op_code == op_jal;
        
        assign o_jump_reg = (op_code == op_r_type) && (func_code == func_jr);
        
        assign o_branch = op_code == op_beq ? 1'b1 : op_code == op_bne;
        
        assign o_memToReg = op_code == op_lw;
        
        assign o_memWrite = op_code == op_sw;
        
        assign o_link = op_code == op_jal;
        
        assign o_bne = op_code == op_bne;
        
        assign o_shamt = i_instruction[10:6];
        
        assign o_extType = op_code == op_beq   ? 1'b1 :
                           op_code == op_bne   ? 1'b1 :
                           op_code == op_addi  ? 1'b1 :
                           op_code == op_addiu ? 1'b1 :
                           op_code == op_slti  ? 1'b1 :
                           op_code == op_sltiu ? 1'b1 :
                           op_code == op_lw    ? 1'b1 :
                           op_code == op_sw;

        assign o_ALUOP   = (op_code == op_r_type) & (func_code == func_add)    ? alu_add  :
                           (op_code == op_r_type) & (func_code == func_addu)   ? alu_add  :
                           (op_code == op_r_type) & (func_code == func_sub)    ? alu_sub  :
                           (op_code == op_r_type) & (func_code == func_subu)   ? alu_sub  :
                           (op_code == op_r_type) & (func_code == func_and)    ? alu_and  :
                           (op_code == op_r_type) & (func_code == func_or)     ? alu_or   :
                           (op_code == op_r_type) & (func_code == func_nor)    ? alu_nor  :
                           (op_code == op_r_type) & (func_code == func_xor)    ? alu_xor  :
                           (op_code == op_r_type) & (func_code == func_slt)    ? alu_slt  :
                           (op_code == op_r_type) & (func_code == func_sll)    ? alu_sll  :
                           (op_code == op_r_type) & (func_code == func_srl)    ? alu_srl  :
                           (op_code == op_r_type) & (func_code == func_sra)    ? alu_sra  :
                           (op_code == op_quad)   & (func_code == func_quad)   ? alu_quad :
                           (op_code == op_addi)  ? alu_add :
                           (op_code == op_addiu) ? alu_add :
                           (op_code == op_beq)   ? alu_sub :
                           (op_code == op_bne)   ? alu_sub :
                           (op_code == op_andi)  ? alu_and :
                           (op_code == op_ori)   ? alu_or  :
                           (op_code == op_xori)  ? alu_xor :
                           (op_code == op_slti)  ? alu_slt :
                           (op_code == op_sltiu) ? alu_slt :
                           (op_code == op_lui)   ? alu_lui :
                           (op_code == op_sw)    ? alu_add :
                           (op_code == op_lw)    ? alu_add :
                           {$clog2(NUM_ALU_OPS){1'b0}};
                           
        assign o_ALUSrc  = op_code == op_addi   ? 1'b1 :
                           op_code == op_addiu  ? 1'b1 :
                           op_code == op_andi   ? 1'b1 :
                           op_code == op_ori    ? 1'b1 :
                           op_code == op_xori   ? 1'b1 :
                           op_code == op_lui    ? 1'b1 :
                           op_code == op_sw     ? 1'b1 :
                           op_code == op_lw     ? 1'b1 :
                           op_code == op_slti   ? 1'b1 :
                           op_code == op_sltiu;
                           
        assign o_regDst  = op_code == op_addi   ? 1'b1 :
                           op_code == op_addiu  ? 1'b1 :
                           op_code == op_andi   ? 1'b1 :
                           op_code == op_ori    ? 1'b1 :
                           op_code == op_xori   ? 1'b1 :
                           op_code == op_lui    ? 1'b1 :
                           op_code == op_lw     ? 1'b1 :
                           op_code == op_slti   ? 1'b1 :
                           op_code == op_sltiu;
        
        assign o_regWrite  = op_code == op_addi   ? 1'b1 :
                             op_code == op_addiu  ? 1'b1 :
                             op_code == op_andi   ? 1'b1 :
                             op_code == op_ori    ? 1'b1 :
                             op_code == op_xori   ? 1'b1 :
                             op_code == op_lui    ? 1'b1 :
                             op_code == op_lw     ? 1'b1 :
                             op_code == op_slti   ? 1'b1 :
                             op_code == op_sltiu  ? 1'b1 :
                             op_code == op_jal    ? 1'b1 :
                             op_code == op_quad   ? 1'b1 :
                            (op_code == op_r_type) && (func_code == func_jr)      ? 1'b0 :
                            (op_code == op_r_type) && (func_code == func_syscall) ? 1'b0 :
                             op_code == op_r_type;
        
        
        
        
        
        
        
         
endmodule
