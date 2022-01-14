module ALU
    #( parameter WORD_SIZE = 32,
       parameter IMM_SIZE = 16 )
    (
        input [WORD_SIZE-1:0] i_A,
        input [WORD_SIZE-1:0] i_B,
        input [$clog2(WORD_SIZE)-1:0] i_Shamt,
        input [(WORD_SIZE/4)-1:0] i_qByte,
        input [3:0] i_ALUOP,
        output o_Zero,
        output ovfl,
        output [WORD_SIZE-1:0] o_S
    );
    
    wire [WORD_SIZE-1:0] adder_op;
    wire [WORD_SIZE-1:0] shift_op;
    wire [WORD_SIZE-1:0] and_op;
    wire [WORD_SIZE-1:0] or_op;
    wire [WORD_SIZE-1:0] nor_op;
    wire [WORD_SIZE-1:0] xor_op;
    wire [WORD_SIZE-1:0] quad_op;
    wire [WORD_SIZE-1:0] lui_op;
    wire slt_op;
    
    Add_Sub #( .N(WORD_SIZE) ) adder
                                (
                                
                                .i_A(i_A),
                                .i_B(i_B),
                                .nAdd_Sub(i_ALUOP[0]),
                                .ovfl(ovfl),
                                .o_S(adder_op)
                                
                                );
    barrel_shifter #( .WORD_SIZE(WORD_SIZE) ) shifter
                                      (
                                      
                                        .i_src(i_B),
                                        .i_shift_type(i_ALUOP[2:1]),
                                        .i_shamt(i_Shamt),
                                        .o_shift_out(shift_op)
                                      
                                      );
                                      
    assign and_op = i_A & i_B;
    assign or_op = i_A | i_B;
    assign nor_op = ~(i_A | i_B);
    assign xor_op = i_A ^ i_B;
    
    assign quad_op = {4{i_qByte}};
    assign lui_op = {{i_B[IMM_SIZE:0]},{(WORD_SIZE-IMM_SIZE){1'b0}}};
    
    
    assign o_Zero = ~(|adder_op); // invert reduction or
    
    assign slt_op = adder_op[31];
    
    
    
    variable_mux #(.DATA_WIDTH(WORD_SIZE), .NUM_INPUTS(16) ) alu_select
                                                             (
                                                             .i_D( 
                                                                   {
                                                                    {(WORD_SIZE){1'bx}},
                                                                    {(WORD_SIZE){1'bx}},
                                                                    {(WORD_SIZE){1'bx}},
                                                                    {(WORD_SIZE){1'bx}},
                                                                    {{(WORD_SIZE-1){1'b0}},slt_op},
                                                                    or_op,
                                                                    lui_op,
                                                                    quad_op,
                                                                    xor_op,
                                                                    shift_op, //sra
                                                                    nor_op,
                                                                    shift_op, //srl
                                                                    and_op,
                                                                    shift_op, //sll
                                                                    adder_op, //Sub
                                                                    adder_op //Add
                                                                  } 
                                                                 ),
                                                             .i_S(i_ALUOP),
                                                             .o_O(o_S)
                                                             );
    
    
    
endmodule
