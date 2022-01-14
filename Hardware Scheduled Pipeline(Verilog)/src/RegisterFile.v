module register_file
    #(parameter DATA_WIDTH = 32,
      parameter NUM_REGISTERS = 32)
      (
          input [DATA_WIDTH-1:0] i_D,
          input i_WE,
          input i_CLK,
          input i_RST,
          input [$clog2(NUM_REGISTERS)-1:0] i_WA,
          input [$clog2(NUM_REGISTERS)-1:0] i_RA0,
          input [$clog2(NUM_REGISTERS)-1:0] i_RA1,
          output [DATA_WIDTH-1:0] o_D0,
          output [DATA_WIDTH-1:0] o_D1
      );
      
      wire [NUM_REGISTERS-1:0] reg_write;
      wire [(DATA_WIDTH*NUM_REGISTERS) - 1:0] reg_output;
      
      decoder_N #( .N(NUM_REGISTERS) ) write_decoder
                                       (
                                        .i_A(i_WA),
                                        .OE(i_WE),
                                        .o_O(reg_write)
                                       );
      
      dffg_N #(.N(NUM_REGISTERS)) register [NUM_REGISTERS-1:0]
                                  (
                                    .i_CLK(i_CLK),
                                    .i_RST(i_RST),
                                    .i_WE(reg_write),
                                    .i_D(i_D),
                                    .o_Q(reg_output)
                                  );

      variable_mux #(.DATA_WIDTH(DATA_WIDTH), .NUM_INPUTS(NUM_REGISTERS)) read_0
                     (
                     .i_D(reg_output),
                     .i_S(i_RA0),
                     .o_O(o_D0)
                     );

      variable_mux #(.DATA_WIDTH(DATA_WIDTH), .NUM_INPUTS(NUM_REGISTERS)) read_1
                     (
                     .i_D(reg_output),
                     .i_S(i_RA1),
                     .o_O(o_D1)
                     );    
                     
      
endmodule
