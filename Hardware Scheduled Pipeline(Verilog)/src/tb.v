`timescale 100 ns/ 1 ns

module tb();
    reg i_CLK = 1'b0;
    wire load_ins =1'b0;
    reg reset = 1'b1;
    wire [31:0] alu_out;
    wire [31:0] addr_setup = 32'h00000000;
    wire [31:0] ext_ins = 32'h20010001;
    
    MIPS_Processor MyMips
                    (
                        .iInstAddr(addr_setup),
                        .iInstExt(ext_ins),
                        .i_CLK(i_CLK),
                        .i_RST(reset),
                        .iInstLd(load_ins),
                        .o_ALUOut(alu_out)
                    );

    always
    begin
        i_CLK <= ~i_CLK;
        #10;
    end

    initial begin
      reset <= 1'b0;
      #5;
      reset <= 1'b1;
      #20;
      reset <= 1'b0;
    end
    
    integer f = 0;
    integer exit = 0;
    integer cycle_cnt = 0;

    initial begin
      f = $fopen("dump.txt","w");
      
      
      while( exit == 0) begin
      
        @(posedge i_CLK) begin
            if (~reset) begin
                if (MyMips.s_RegWr) begin
                    $fdisplay(f,"In clock cycle: %d", cycle_cnt);
                    $fdisplay(f,"Register Write to Reg: 0x%H Val: 0x%H", MyMips.s_RegWrAddr, MyMips.s_RegWrData);
                end
                if (MyMips.s_DMemWr) begin
                    $fdisplay(f,"In clock cycle: %d", cycle_cnt);
                    $fdisplay(f,"Memory Write to Addr: 0x%H Val: 0x%H", MyMips.s_DMemAddr, MyMips.s_DMemData);
                end
                if (MyMips.s_Ovfl) begin
                    $fdisplay(f,"Arithmetic overflow occurred!");
                end
                
                cycle_cnt = cycle_cnt + 1;
                
                if (MyMips.s_Halt) begin
                    $fdisplay(f,"Execution is stopping!");
                    exit = 1;
                end
                
            end
            
        end
      
      end

      $fclose(f);  
      
      $stop;
    end


endmodule

