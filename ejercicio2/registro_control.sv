`timescale 1ns / 1ps

`timescale 1ns / 1ps

module registro_control 
    #(
        parameter N = 32
    )
    (
        input logic            clk_i,
        input logic            rst_i,
        input logic [N-1:0]    in1,
        input logic [N-1:0]    in2,
        input logic            WR1,
        input logic            WR2,
        
        output logic [N-1:0]   control_o
    );
    
    always @(posedge clk_i) begin
        if (rst_i) 
            control_o <= 'b0;
            
        else if (WR1) 
            control_o <= in1;
            
        else if (WR2) 
            control_o <= in2;  
            
        else 
            control_o <= control_o;
            
    end

endmodule
