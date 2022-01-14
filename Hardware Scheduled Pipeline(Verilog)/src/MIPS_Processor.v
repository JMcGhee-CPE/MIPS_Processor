module MIPS_Processor
       #( parameter WORD_SIZE     = 32,
          parameter OP_CODE_SIZE  = 6,
          parameter IMM_LENGTH    = 16,
          parameter NUM_REGISTERS = 32
        )
        (
            input [WORD_SIZE-1:0]  iInstAddr,
            input [WORD_SIZE-1:0]  iInstExt,
            input                  i_CLK,
            input                  i_RST,
            input                  iInstLd,
            output [WORD_SIZE-1:0] o_ALUOut
        );
        
        // Data memory signals
        
        wire                 s_DMemWr;
        wire [WORD_SIZE-1:0] s_DMemAddr;
        wire [WORD_SIZE-1:0] s_DMemData;
        wire [WORD_SIZE-1:0] s_DMemOut;
        
        // Register File signals
        
        wire                              s_RegWr;
        wire [$clog2(NUM_REGISTERS)-1:0]  s_RegWrAddr;
        wire [WORD_SIZE-1:0]              s_RegWrData;
        
        // Instruction memory signals
        
        wire [WORD_SIZE-1:0] s_IMemAddr;
        wire [WORD_SIZE-1:0] s_NextInstAddr;
        wire [WORD_SIZE-1:0] s_Inst;
        
        // halt signal      ------------------------------------------------------------
        
        wire s_Halt;
        
        // overflow signal   ------------------------------------------------------------
        
        wire s_Ovfl;
        
        // flush and stall signals ------------------------------------------------------------
        
        wire flush;
        wire stall;
        
        //Fetch signals      ------------------------------------------------------------
        
        wire [WORD_SIZE-1:0] next_ins_F;
        wire [WORD_SIZE-1:0] jal_return_F;
        wire [WORD_SIZE-1:0] raw_ins_F;
        
        wire [(3*WORD_SIZE)-1:0] fetch_stage_reg;
        
        //Decode signals     ------------------------------------------------------------
        
        wire [WORD_SIZE-1:0] next_ins_D;
        wire [WORD_SIZE-1:0] jal_return_D;
        wire [WORD_SIZE-1:0] raw_ins_D;
        wire [30:0]          control_sigs_D;
        
        wire [WORD_SIZE-1:0] reg_file_rs;
        wire [WORD_SIZE-1:0] reg_file_rt;
        
        wire [WORD_SIZE-1:0] rs_D;
        wire [WORD_SIZE-1:0] rt_D;
        
        wire [190:0] decode_values;
        wire [190:0] decode_stage_input;
        wire [190:0] decode_stage_reg;
        
        //Execute signals    ------------------------------------------------------------
        
        wire [WORD_SIZE-1:0] next_ins_EX;
        wire [WORD_SIZE-1:0] jal_return_EX;
        wire [WORD_SIZE-1:0] raw_ins_EX;
        wire [WORD_SIZE-1:0] alu_out_EX;
        wire [WORD_SIZE-1:0] wb_data_EX;
        wire [30:0]          control_sigs_EX;
        
        wire [WORD_SIZE-1:0] rs_EX;
        wire [WORD_SIZE-1:0] rt_EX;
        wire [WORD_SIZE-1:0] sign_ext_imm;
        
        wire [1:0] alu_select_a;
        wire [1:0] alu_select_b;
        
        wire [WORD_SIZE-1:0] alu_b;
        
        wire [WORD_SIZE-1:0] branch_immediate;
        wire [WORD_SIZE-1:0] branch_addr;
        wire [WORD_SIZE-1:0] branch_result_addr;
        
        wire [WORD_SIZE-1:0] jump_calc_addr;
        wire [WORD_SIZE-1:0] jump_result_addr;
        wire [WORD_SIZE-1:0] final_addr;
        
        wire [$clog2(NUM_REGISTERS)-1:0] wb_addr_EX;
        wire [$clog2(NUM_REGISTERS)-1:0] final_wb_addr_EX;
        
        wire ALU_zero;
        wire ALU_not_zero;
        wire branch_pass;
        wire take_branch;
        wire branch_delay;
        
        wire [72:0] execute_stage_reg;
        
        //Memory signals     ------------------------------------------------------------
        
        wire [WORD_SIZE-1:0]         wb_data_MEM;
        wire [$clog2(WORD_SIZE)-1:0] wb_addr_MEM;
        
        wire mem_write_MEM;
        wire mem_to_reg_MEM;
        wire halt_MEM;
        wire reg_write_MEM;
        
        //Write back signals ------------------------------------------------------------
        
        wire [38:0] mem_stage_reg;
        
        // Hazard Detect
        
        hazard_detect #(.ADDR_LEN($clog2(WORD_SIZE)) )hazard_control
                      (
                        .rs_addr(raw_ins_D[25:21]),
                        .rt_addr(raw_ins_D[20:16]),
                        
                        .wb_addr_MEM(wb_addr_MEM),
                        .wb_addr_EX(final_wb_addr_EX),
                        
                        .mem_to_reg_MEM(mem_to_reg_MEM),
                        .mem_to_reg_EX(control_sigs_EX[2]),
                        
                        .jump_reg(control_sigs_EX[0]),
                        .jump_addr(control_sigs_EX[10]),
                        .branch(take_branch),
                        
                        .i_CLK(i_CLK),
                        
                        .flush(flush),
                        .stall(stall)
                      
                      );
                      
        assign s_NextInstAddr = final_addr;
        
        dffg_N_with_reset #( .N(WORD_SIZE) ) PC
                            (
                                .i_CLK(i_CLK),
                                .i_RST(i_RST),
                                .i_WE(~stall),
                                .reset_value(32'h00400000),
                                .i_D(s_NextInstAddr),
                                .o_Q(s_IMemAddr)
                            );
                            
        Ripple_Adder #(.N(WORD_SIZE)) next_ins
                       (
                        .i_A(s_IMemAddr),
                        .i_B(32'h00000004),
                        .o_S(next_ins_F),
                        .ovfl()
                       );
                       
         assign jal_return_F = next_ins_F;
         
         assign raw_ins_F = s_Inst;
         
         mem #( .ADDR_WIDTH(10),
                .DATA_WIDTH(WORD_SIZE)) IMem
              (
                .i_CLK(i_CLK),
                .addr(s_IMemAddr[11:2]),
                .data(iInstExt),
                .we(iInstLd),
                .q(s_Inst)
              
              );
              
         dffg_N #( .N(96) ) IF_ID_Reg
                (
                    .i_CLK( ~i_CLK ),
                    .i_RST( i_RST | flush ),
                    .i_WE( ~stall ),
                    .i_D({next_ins_F,jal_return_F,raw_ins_F}),
                    .o_Q(fetch_stage_reg)
                );
                
         assign next_ins_D = fetch_stage_reg[95:64];
         assign jal_return_D = fetch_stage_reg[63:32];
         assign raw_ins_D = fetch_stage_reg[31:0];
         
         assign control_sigs_D[8:7] = 2'b00;
         
         instruction_decoder ins_decode
                            (
                            .i_instruction(raw_ins_D),
                            .o_jump_reg(control_sigs_D[10]),
                            .o_jump_addr(control_sigs_D[0]),
                            .o_branch(control_sigs_D[1]),
                            .o_memToReg(control_sigs_D[2]),
                            .o_ALUOP(control_sigs_D[6:3]),
                            .o_ALUSrc(control_sigs_D[9]),
                            .o_regWrite(control_sigs_D[11]),
                            .o_extType(control_sigs_D[28]),
                            .o_regDst(control_sigs_D[25]),
                            .o_shamt(control_sigs_D[24:20]),
                            .o_qByte(control_sigs_D[19:12]),
                            .o_memWrite(control_sigs_D[26]),
                            .o_link(control_sigs_D[27]),
                            .o_bne(control_sigs_D[29]),
                            .o_halt(control_sigs_D[30])
                            );
              
      register_file RegFile
                    (
                        .i_D(s_RegWrData),
                        .i_WE(s_RegWr),
                        .i_CLK(i_CLK),
                        .i_RST(i_RST),
                        .i_WA(s_RegWrAddr),
                        .i_RA0(raw_ins_D[25:21]),
                        .i_RA1(raw_ins_D[20:16]),
                        .o_D0(reg_file_rs),
                        .o_D1(reg_file_rt)
                    );
                    
                    
       forwarding_unit ForwardingUnit
                       (
                       
                        .wb_mem_addr(wb_addr_MEM),
                        .wb_wb_addr(s_RegWrAddr),
                        .wb_ex_addr(final_wb_addr_EX),
                        
                        .reg_write_mem(reg_write_MEM),
                        .reg_write_ex(control_sigs_EX[11]),
                        .reg_reg_wb(s_RegWr),
                        
                        .rs_addr(raw_ins_D[25:21]),
                        .rt_addr(raw_ins_D[20:16]),
                        
                        .rs_select(alu_select_a),
                        .rt_select(alu_select_b)
                        
                       );
                       
       mux4t1_N #( .N(WORD_SIZE) ) alu_a_select
                                   (
                                    .i_D0(reg_file_rs),
                                    .i_D1(wb_data_MEM),
                                    .i_D2(s_RegWrData),
                                    .i_D3(wb_data_EX),
                                    .i_S(alu_select_a),
                                    .o_O(rs_D)
                                   
                                   );

       mux4t1_N #( .N(WORD_SIZE) ) alu_b_select
                                   (
                                    .i_D0(reg_file_rt),
                                    .i_D1(wb_data_MEM),
                                    .i_D2(s_RegWrData),
                                    .i_D3(wb_data_EX),
                                    .i_S(alu_select_b),
                                    .o_O(rt_D)
                                   );
                                   
      // ID_EX State registers
      
      assign decode_values = {rt_D,rs_D,control_sigs_D,next_ins_D,jal_return_D,raw_ins_D};
      
      assign decode_stage_input = (stall | i_RST ) ? {191{1'b0}} : decode_values;
 
      dffg_N #( .N(191) ) ID_EX_Reg
            (
                .i_CLK( i_CLK ),
                .i_RST( i_RST ),
                .i_WE( 1'b1 ),
                .i_D(decode_stage_input),
                .o_Q(decode_stage_reg)
            );
      
      // Execute stage
      
      assign raw_ins_EX = decode_stage_reg[31:0];
      assign jal_return_EX = decode_stage_reg[63:32];
      assign next_ins_EX = decode_stage_reg[95:64];
      assign control_sigs_EX = decode_stage_reg[126:96];
      
      assign rs_EX = decode_stage_reg[158:127];
      assign rt_EX = decode_stage_reg[190:159];
      
      
      assign wb_addr_EX = control_sigs_EX[25] ? raw_ins_EX[20:16] : raw_ins_EX[15:11];      
      assign final_wb_addr_EX = control_sigs_EX[27] ? 5'b11111 : wb_addr_EX;
      
      extender sign_extend
                (
                    .i_A(raw_ins_EX[15:0]),
                    .type_select(control_sigs_EX[28]),
                    .o_Q( sign_ext_imm )
                );
                
      assign alu_b = control_sigs_EX[9] ? sign_ext_imm : rt_EX;
      
      ALU MIPS_ALU
          (
            .i_A(rs_EX),
            .i_B(alu_b),
            .i_Shamt(raw_ins_EX[10:6]),
            .i_qByte(control_sigs_EX[19:12]),
            .i_ALUOP(control_sigs_EX[6:3]),
            .o_Zero(ALU_zero),
            .ovfl(s_Ovfl),
            .o_S(alu_out_EX)
          );
          
      assign oALUOut = alu_out_EX;
      
      assign ALU_not_zero = ~ALU_zero;
      
      assign wb_data_EX = control_sigs_EX[27] ? jal_return_EX : alu_out_EX;
      
      
      // Address Calcualtion --------------------------------------------
      
      assign branch_immediate = {sign_ext_imm[29:0], {2{1'b0}}}; // Soft shift
      
      Ripple_Adder branch_address
                   (
                    .i_A(next_ins_EX),
                    .i_B(branch_immediate),
                    .o_S(branch_addr),
                    .ovfl()
                   );
                   
      assign branch_pass = control_sigs_EX[29] ? ALU_not_zero : ALU_zero;
      
      assign take_branch = control_sigs_EX[1] && branch_pass;
      
      assign branch_result_addr = take_branch ? branch_addr : next_ins_F;
      
      assign jump_calc_addr = { next_ins_EX[31:28], raw_ins_EX[25:0], {2{1'b0}}};
      
      assign jump_result_addr = control_sigs_EX[0] ? jump_calc_addr : branch_result_addr;
      
      assign final_addr = control_sigs_EX[10] ? rs_EX : jump_result_addr;
      
      // Execute state registers ------------------------------------------------------
      
      dffg_N #( .N(73) ) EX_MEM_Reg
                        (
                            .i_CLK(i_CLK),
                            .i_RST(i_RST),
                            .i_WE(1'b1),
                            .i_D({ control_sigs_EX[11],
                                   control_sigs_EX[30],
                                   control_sigs_EX[2],
                                   control_sigs_EX[26],
                                   final_wb_addr_EX,
                                   rt_EX,
                                   wb_data_EX
                                  }),
                             .o_Q(execute_stage_reg)
                                  
                        );
                        
     // Memory stage
     
     assign mem_write_MEM  = execute_stage_reg[69];
     assign mem_to_reg_MEM = execute_stage_reg[70];
     assign halt_MEM       = execute_stage_reg[71];
     assign reg_write_MEM  = execute_stage_reg[72];
     
     assign wb_addr_MEM = execute_stage_reg[68:64];
     
     assign s_DMemWr = mem_write_MEM;
     assign s_DMemAddr = execute_stage_reg[31:0];
     assign s_DMemData = execute_stage_reg[63:32];
     
     mem #( .ADDR_WIDTH(10),
            .DATA_WIDTH(WORD_SIZE)) DMem
          (
            .i_CLK(i_CLK),
            .addr(s_DMemAddr[11:2]),
            .data(s_DMemData),
            .we(s_DMemWr),
            .q(s_DMemOut)
          
          );
          
     assign wb_data_MEM = mem_to_reg_MEM ? s_DMemOut : execute_stage_reg[31:0];
     
     // Memory state registers
     
      dffg_N #( .N(39) ) MEM_WB_Reg
                        (
                            .i_CLK(i_CLK),
                            .i_RST(i_RST),
                            .i_WE(1'b1),
                            .i_D({ reg_write_MEM,
                                   halt_MEM,
                                   wb_addr_MEM,
                                   wb_data_MEM
                                  }),
                             .o_Q(mem_stage_reg)
                                  
                        );
                        
     // Write back stage
     
     assign s_RegWr     = mem_stage_reg[38];
     assign s_RegWrAddr = mem_stage_reg[36:32];
     assign s_RegWrData = mem_stage_reg[31:0];
     assign s_Halt      = mem_stage_reg[37];
        
endmodule
