module dffg_N_with_reset
    #(parameter N = 8)
    (
     input i_CLK,
     input i_RST,
     input i_WE,
     input [N-1:0] reset_value,
     input [N-1:0] i_D,
     output [N-1:0] o_Q
    );
    
    wire [N-1:0] reg_input;
    
    assign reg_input =  i_RST ? reset_value : i_D;
    
    
    dffg registers [N-1:0] ( .i_CLK(i_CLK), .i_RST(1'b0), .i_WE(i_WE | i_RST), .i_D(reg_input), .o_Q(o_Q) );

    

endmodule
