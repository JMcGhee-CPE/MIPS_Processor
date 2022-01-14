module mem
    #(parameter DATA_WIDTH = 32,
      parameter ADDR_WIDTH = 10)
      (
        input i_CLK,
        input [ADDR_WIDTH-1:0] addr,
        input [DATA_WIDTH-1:0] data,
        input we,
        output [DATA_WIDTH-1:0] q
      );
      
      reg [DATA_WIDTH:0] ram [2** ADDR_WIDTH:0];
      
      always @(posedge i_CLK)
      begin
        if (we) begin
            ram[addr] <= data;
        end
      end
      
      assign q = ram[addr];
      
endmodule
