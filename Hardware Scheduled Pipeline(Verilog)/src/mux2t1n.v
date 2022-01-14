module mux2t1_N
    #(parameter N = 32)
    (
        input [N-1:0] i_A,
        input [N-1:0] i_B,
        input sel,
        output [N-1:0] o_O
    );
    
    
    assign o_O = (i_A & {N{~sel}}) | (i_B & {N{sel}});

endmodule
