module forwarding_unit
    #(parameter ADDR_LEN = 5)
    (
        input [ADDR_LEN-1:0] wb_mem_addr,
        input [ADDR_LEN-1:0] wb_wb_addr,
        input [ADDR_LEN-1:0] wb_ex_addr,
        
        input                reg_write_mem,
        input                reg_write_ex,
        input                reg_reg_wb,
        
        input [ADDR_LEN-1:0] rs_addr,
        input [ADDR_LEN-1:0] rt_addr,
        
        output [1:0]         rs_select,
        output [1:0]         rt_select
    );
    
    assign rs_select = reg_write_ex  && (wb_ex_addr  == rs_addr) ? 2'b11 :
                       reg_write_mem && (wb_mem_addr == rs_addr) ? 2'b01 :
                       reg_reg_wb    && (wb_wb_addr  == rs_addr) ? 2'b10 :
                       2'b00;

    assign rt_select = reg_write_ex  && (wb_ex_addr  == rt_addr) ? 2'b11 :
                       reg_write_mem && (wb_mem_addr == rt_addr) ? 2'b01 :
                       reg_reg_wb    && (wb_wb_addr  == rt_addr) ? 2'b10 :
                       2'b00;

endmodule
