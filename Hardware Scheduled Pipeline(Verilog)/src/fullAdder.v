module fullAdder
        (
            input i_A,
            input i_B,
            input i_C,
            output o_S,
            output o_C
        );
        
        wire sum_ab;
        wire carry_ab;
        wire carry_abc;
        
        // Layer 0
        
        assign sum_ab = i_A ^ i_B;
        assign carry_ab = i_A & i_B;
        
        // Layer 1
        
        
        assign o_S = sum_ab ^ i_C;
        assign carry_abc = sum_ab & i_C;
        
        // Layer 2
        
        assign o_C = carry_ab | carry_abc;

endmodule
