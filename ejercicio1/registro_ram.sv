`timescale 1ns / 1ps

module registro_ram
    #(parameter ANCHO = 8,
                PROFUNDIDAD = 32
     )(
     input  logic                    clk_i,
     input  logic                    reset_i,
     input  logic                    we_i,
     input  logic  [ANCHO-1:0]       data_i,
     input  logic  [PROFUNDIDAD-1:0] addr_i,
     output logic  [PROFUNDIDAD-1:0] data_o
    );
    
    logic [ANCHO-1:0] rf [PROFUNDIDAD-1:0];
    
    always_ff @(negedge clk_i or posedge reset_i) begin
        if (reset_i) begin
            for (int i = 0; i < 32; i++) begin
                rf[i] <= 0;
            end
        end
        
        else if (we_i) begin
            rf [addr_i] <= data_i;
        end
    end
    
    assign data_o = rf[addr_i];
    
endmodule
