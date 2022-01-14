module Ripple_Adder
        #(parameter N=32)
        (
            input [N-1:0] i_A,
            input [N-1:0] i_B,
            output [N-1:0] o_S,
            output ovfl
        );
        
        wire [N-1:0] carry_in;
        wire [N-1:0] carry_out;
        wire [N-1:0] result;
        
        assign carry_in[0] = 1'b0;
        assign carry_in[N-1:1] = carry_out[N-2:0];
        
        fullAdder adders [N-1:0] ( i_A, i_B, carry_in, result, carry_out);
        
        assign ovfl = (i_A[N-1] & i_B[N-1] & ~result[N-1]) | (~i_A[N-1] & ~i_B[N-1] & result[N-1]);
        
        assign o_S[N-1:0] = result[N-1:0];
endmodule
