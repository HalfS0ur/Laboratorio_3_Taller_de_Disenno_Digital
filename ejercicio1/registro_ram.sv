`timescale 1ns / 1ps

module registro_ram
    #(parameter ANCHO = 32,
                PROFUNDIDAD = 8
     )(
     input  logic                    clk_i,
     input  logic                    reset_i,
     input  logic                    we_i,
     input  logic  [ANCHO-1:0]      data_i,
     input  logic  [PROFUNDIDAD-1:0]            addr_i,  // Change addr_i size if necessary
     output logic  [PROFUNDIDAD-1:0]       data_o   // Change output size to match ANCHO
    );
    
    logic [ANCHO-1:0] rf [(2**PROFUNDIDAD-1):0];
    
    always_ff @(negedge clk_i or posedge reset_i) begin
        if (reset_i) begin
            for (int i = 0; i < 2**PROFUNDIDAD; i++) begin
                rf[i] <= 0;
            end
        end 
        
        else if (we_i) begin
            rf[addr_i] <= data_i;
        end
    end

    always_ff @(posedge clk_i) begin
        data_o <= rf[addr_i];  // Sequential read of the output
    end
    
endmodule
