`timescale 1ns / 1ps

module clk_7_segmentos(
    input logic clk_i,
    input logic reset_i,
    output logic clk_1kHz_o
    );
    
    logic [18:0] ctr_reg = 0; // 19 bits to cover 50,000
    logic clk_out_reg = 0;
    
    always_ff @(posedge clk_i or posedge reset_i)
        if(reset_i) begin
            ctr_reg <= 0;
            clk_out_reg <= 0;
        end
        else
            if(ctr_reg == 4999) begin  // 100MHz / 1kHz / 2 = 50,000
                ctr_reg <= 0;
                clk_out_reg <= ~clk_out_reg;
            end
            else
                ctr_reg <= ctr_reg + 1;
    
    assign clk_1kHz_o = clk_out_reg;
    
endmodule
