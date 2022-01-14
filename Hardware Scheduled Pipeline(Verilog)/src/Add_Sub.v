module Add_Sub
    #(parameter N = 32)
    (
        input [N-1:0] i_A,
        input [N-1:0] i_B,
        input nAdd_Sub,
        output ovfl,
        output [N-1:0] o_S
    );
    
    wire [N-1:0] two_comp_B;
    reg [N-1:0] alu_b;
    
    wire [N-1:0] one_value = { {N-1{1'b0}}, 1'b1 } ;
    
    wire two_comp_ovfl;

    
    Ripple_Adder #( .N(N) ) two_comp
    (
        .i_A(one_value),
        .i_B(~i_B),
        .o_S(two_comp_B),
        .ovfl(two_comp_ovfl)
    );
    
    always @*
    begin
        if( nAdd_Sub )
            alu_b <= two_comp_B;
        else
            alu_b <= i_B;
    end
    
    Ripple_Adder #( .N(N) ) adder
    (
        .i_A(i_A),
        .i_B(alu_b),
        .o_S(o_S),
        .ovfl(ovfl)
    );
    
    
endmodule
