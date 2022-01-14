module extender
    #(parameter SRC_LENGTH=16,
      parameter TARGET_LENGTH=32) (
      
      input [SRC_LENGTH-1:0] i_A,
      input type_select,
      output [TARGET_LENGTH-1:0] o_Q
      
      );
      
      reg[TARGET_LENGTH-SRC_LENGTH-1:0] extended;
      
      always @*
      begin
        extended <= {(TARGET_LENGTH-SRC_LENGTH){ type_select & i_A[SRC_LENGTH-1]}};
      end
      
      assign o_Q[TARGET_LENGTH-1:0] = {extended, i_A};
      
      
endmodule
