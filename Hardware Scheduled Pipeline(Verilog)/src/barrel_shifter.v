module barrel_shifter
    #(parameter WORD_SIZE = 32)
    (
        input  [WORD_SIZE-1:0]           i_src,
        input  [1:0]                     i_shift_type,
        input  [$clog2(WORD_SIZE)-1:0]   i_shamt,
        output [WORD_SIZE-1:0]           o_shift_out
    );
    
    wire [(32 * $clog2(WORD_SIZE)) - 1:0] shift_layer_input_no_shift;
    
    wire [(32 * $clog2(WORD_SIZE)) - 1:0] shift_layer_output;
    wire [( 2 * $clog2(WORD_SIZE)) - 1:0] layer_select;
    
    assign shift_layer_input_no_shift[(WORD_SIZE * $clog2(WORD_SIZE)) - 1:WORD_SIZE] = shift_layer_output[(WORD_SIZE * $clog2(WORD_SIZE)) - WORD_SIZE - 1:0];
    
    assign shift_layer_input_no_shift[WORD_SIZE-1:0] = i_src[WORD_SIZE-1:0];
    
    genvar i;
    genvar j;
    generate
    
        for( i = 0; i < $clog2(WORD_SIZE); i = i+1 ) begin
        
            mux2t1_N #( .N(2) ) shift_select
                                (
                                    .i_A(2'b00),
                                    .i_B(i_shift_type),
                                    .sel(i_shamt[i]),
                                    .o_O(layer_select[ 2*i +:2 ])
                                    
                                );
                                
             for ( j = 0; j < WORD_SIZE; j = j + 1 ) begin
             
                if( j < 2 ** i && j > (WORD_SIZE - 1 - (2**i))) begin// This shouldn't be possible but just to cover all the bases
                    mux4t1 layer 
                           (
                                .i_A(shift_layer_input_no_shift[(WORD_SIZE * i) + j]),
                                .i_B(1'b0),
                                .i_C(1'b0),
                                .i_D(shift_layer_input_no_shift[(WORD_SIZE * (i+1)) -1]),
                                .sel(layer_select[ 2*i +: 2 ]),
                                .o_O(shift_layer_output[(WORD_SIZE * i) + j])
                            );
                end else if (j < 2 ** i) begin                          // Shift left, fill in zeros

                    mux4t1 layer 
                           (
                                .i_A(shift_layer_input_no_shift[(WORD_SIZE * i) + j]),
                                .i_B(1'b0),
                                .i_C(shift_layer_input_no_shift[(WORD_SIZE * i) + j + 2**i]),
                                .i_D(shift_layer_input_no_shift[(WORD_SIZE * i) + j + 2**i]),
                                .sel(layer_select[ 2*i +: 2 ]),
                                .o_O(shift_layer_output[(WORD_SIZE * i) + j])
                            );

                end else if (j > (WORD_SIZE - 1 - (2**i))) begin        // Shift right, fill in zero or sign extend
      
                      mux4t1 layer 
                       (
                            .i_A(shift_layer_input_no_shift[(WORD_SIZE * i) + j]),
                            .i_B(shift_layer_input_no_shift[(WORD_SIZE * i) + j - 2**i]),
                            .i_C(1'b0),
                            .i_D(shift_layer_input_no_shift[(WORD_SIZE * (i+1)) -1]),
                            .sel(layer_select[ 2*i +: 2 ]),
                            .o_O(shift_layer_output[(WORD_SIZE * i) + j])
                        );
                
                end else begin                                         // Normal operation
 
                       mux4t1 layer 
                       (
                            .i_A(shift_layer_input_no_shift[(WORD_SIZE * i) + j]),
                            .i_B(shift_layer_input_no_shift[(WORD_SIZE * i) + j - 2**i]),
                            .i_C(shift_layer_input_no_shift[(WORD_SIZE * i) + j + 2**i]),
                            .i_D(shift_layer_input_no_shift[(WORD_SIZE * i) + j + 2**i]),
                            .sel(layer_select[ 2*i +: 2 ]),
                            .o_O(shift_layer_output[(WORD_SIZE * i) + j])
                        );       
                                
                end
             
             end
            
        end
    endgenerate
    
    
    
    assign o_shift_out = shift_layer_output[(WORD_SIZE * $clog2(WORD_SIZE)) - 1:(WORD_SIZE * $clog2(WORD_SIZE)) - WORD_SIZE];
    
endmodule
