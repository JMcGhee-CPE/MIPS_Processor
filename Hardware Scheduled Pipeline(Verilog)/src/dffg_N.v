module dffg_N
    #(parameter N = 8)
    (
     input i_CLK,
     input i_RST,
     input i_WE,
     input [N-1:0] i_D,
     output [N-1:0] o_Q
    );
    
    dffg registers [N-1:0] ( .i_CLK(i_CLK), .i_RST(i_RST), .i_WE(i_WE), .i_D(i_D), .o_Q(o_Q) );

endmodule
