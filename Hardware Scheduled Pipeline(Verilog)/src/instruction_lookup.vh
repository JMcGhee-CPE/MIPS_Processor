// Opcodes

parameter op_r_type = 6'b000000;
parameter op_addi = 6'b001000;
parameter op_addiu = 6'b001001;
parameter op_andi = 6'b001100;
parameter op_lui = 6'b001111;
parameter op_xori = 6'b001110;
parameter op_ori = 6'b001101;
parameter op_lw = 6'b100011;
parameter op_sw = 6'b101011;
parameter op_beq = 6'b000100;
parameter op_bne = 6'b000101;
parameter op_slti = 6'b001010;
parameter op_sltiu = 6'b001011;
parameter op_jc = 6'b000010;
parameter op_jal = 6'b000011;
parameter op_quad = 6'b011111;
parameter op_halt = 6'b010100;

// Function Codes

parameter func_add = 6'b100000;
parameter func_addu = 6'b100001;
parameter func_and = 6'b100100;
parameter func_nor = 6'b100111;
parameter func_xor = 6'b100110;
parameter func_or = 6'b100101;
parameter func_slt = 6'b101010;
parameter func_sll = 6'b000000;
parameter func_srl = 6'b000010;
parameter func_sra = 6'b000011;
parameter func_sub = 6'b100010;
parameter func_subu = 6'b100011;
parameter func_jr = 6'b001000;
parameter func_quad = 6'b010010;
parameter func_syscall = 6'b001100;

// ALU Encoding

parameter alu_add = 4'b0000;
parameter alu_sub = 4'b0001;
parameter alu_sll = 4'b0010;
parameter alu_and = 4'b0011;
parameter alu_srl = 4'b0100;
parameter alu_nor = 4'b0101;
parameter alu_sra = 4'b0110;
parameter alu_xor = 4'b0111;
parameter alu_quad = 4'b1000;
parameter alu_lui = 4'b1001;
parameter alu_or = 4'b1010;
parameter alu_slt = 4'b1011;
