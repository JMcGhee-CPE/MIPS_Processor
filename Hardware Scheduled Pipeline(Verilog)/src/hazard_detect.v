module hazard_detect
        #(parameter ADDR_LEN = 5)
        (
            input [ADDR_LEN-1:0] rs_addr,
            input [ADDR_LEN-1:0] rt_addr,
            
            input [ADDR_LEN-1:0] wb_addr_MEM,
            input [ADDR_LEN-1:0] wb_addr_EX,
            
            input                mem_to_reg_MEM,
            input                mem_to_reg_EX,
            
            input                jump_reg,
            input                jump_addr,
            input                branch,
            
            input                i_CLK,
            
            output               flush,
            output               stall
        );
        
        assign flush = (jump_reg || jump_addr || branch);
        
        assign stall = (((rs_addr == wb_addr_EX) | (rt_addr == wb_addr_EX)) && mem_to_reg_EX) ||
                       (((rs_addr == wb_addr_MEM) | (rt_addr == wb_addr_MEM)) && mem_to_reg_MEM);
                       
endmodule
