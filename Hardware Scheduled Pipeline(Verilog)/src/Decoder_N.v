module decoder_N
    #(parameter N = 32)
    (
        input [$clog2(N)-1:0] i_A,
        input OE,
        output [N-1:0] o_O
    );
    
    reg [N-1:0] s_O;
    
    integer i;
    always @*
    begin
    
        for( i = 0; i < N; i = i+1 ) begin
        
            if( i_A == i && OE ) begin
            
                s_O[i] <= 1'b1;
            
            end else begin
            
                s_O[i] <= 1'b0;
            
            end
        
        
        end
    
    end
    
    assign o_O = s_O;
endmodule
