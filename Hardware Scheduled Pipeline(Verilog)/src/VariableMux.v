module variable_mux
    #(parameter DATA_WIDTH = 32,
      parameter NUM_INPUTS = 32)
      
      (
        input  [(DATA_WIDTH*NUM_INPUTS) - 1:0] i_D,
        input  [$clog2(NUM_INPUTS)-1:0]        i_S,
        output [DATA_WIDTH-1:0]                o_O
      
      );
      
    assign o_O = i_D[(i_S * DATA_WIDTH) +: DATA_WIDTH ];
      
endmodule
