module dffg
    (
       input i_CLK,
       input i_RST,
       input i_WE,
       input i_D,
       output o_Q
     );
     
     reg s_Q;
     
     
     always @(posedge i_CLK)
     begin
        if( i_RST )
            s_Q <= 1'b0;
        else if( i_WE )
            s_Q <= i_D;
     end
     
     assign o_Q = s_Q;
     
endmodule
