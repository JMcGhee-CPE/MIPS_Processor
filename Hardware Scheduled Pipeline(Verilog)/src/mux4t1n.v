module mux4t1_N
    #( parameter N = 32)
    (
        input  [N-1:0] i_D0,
        input  [N-1:0] i_D1,
        input  [N-1:0] i_D2,
        input  [N-1:0] i_D3,
        input  [1:0]   i_S,
        output [N-1:0] o_O
    );
    
    reg [N-1:0] result;
    
    always @*
    begin
        case (i_S)
            2'b00 : result = i_D0;
            2'b01 : result = i_D1;
            2'b10 : result = i_D2;
            2'b11 : result = i_D3;
        endcase
    end
    
    assign o_O = result;

endmodule
