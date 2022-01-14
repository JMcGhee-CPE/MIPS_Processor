module mux4t1(
        input i_A,
        input i_B,
        input i_C,
        input i_D,
        input [1:0] sel,
        output o_O
    );
    
    reg result;
    
    always @*
    begin
        case (sel)
            2'b00 : result = i_A;
            2'b01 : result = i_B;
            2'b10 : result = i_C;
            2'b11 : result = i_D;
        endcase
    end
    
    assign o_O = result;

endmodule
