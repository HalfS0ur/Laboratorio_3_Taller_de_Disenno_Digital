`timescale 1ns / 1ps

module control_UART_FSM(
    input logic clk_i,
    input logic reset_i,
    input logic [31:0] salida_perif_UART_i,
    input logic [7:0] sw_i,
    input logic inicio_i,
    input logic enviar_dato_i,
    
    output logic wr_o,
    output logic reg_sel_o,
    output logic [31:0] entrada_perif_UART_o,
    output logic [7:0] dato_recibido_o
    );
    
    localparam [2:0]
        IDLE = 3'b000,
        LEER_INSTRUCCION = 3'b001,
        ENVIAR_DATO = 3'b010,
        DATO_ENTRANTE = 3'b011,
        DATO_SALIENTE = 3'b100,
        MOSTRAR_DATO = 3'b101,
        REESCRIBIR_INSTRUCCION = 3'b110;
        
    logic [2:0] state;
    logic [7:0] dato_salida;
        
    always @(posedge clk_i) begin
        if(reset_i) begin
            state <= IDLE;
            wr_o <= 0;
            reg_sel_o <= 0;
            entrada_perif_UART_o <= 0;
            dato_salida <= 0;
        end
        
        else begin
            case(state)
                IDLE: begin
                    if (inicio_i == 1) begin
                        state <= LEER_INSTRUCCION;
                    end
                    
                    else begin
                        state <= IDLE;
                        wr_o <= 0;
                        reg_sel_o <= 0;
                        entrada_perif_UART_o <= 0;
                        dato_salida <= 0;
                    end
                end
                
                LEER_INSTRUCCION: begin
                    entrada_perif_UART_o <= 0;
                    wr_o <= 0;
                    reg_sel_o <= 0;
                    if (salida_perif_UART_i [1] == 1) begin
                        state <= DATO_ENTRANTE;
                    end
                    
                    else if (enviar_dato_i == 1) begin
                       state <= DATO_SALIENTE; 
                    end
                    
                    else begin
                        state <= LEER_INSTRUCCION;
                    end
                end
                
                DATO_ENTRANTE: begin
                    wr_o <= 0;
                    reg_sel_o <= 1;
                    state <= MOSTRAR_DATO;
                end
                
                MOSTRAR_DATO: begin
                    wr_o <= 0;
                    reg_sel_o <= 1;
                    dato_salida <= salida_perif_UART_i [7:0];
                    state <= REESCRIBIR_INSTRUCCION;
                end
                
                REESCRIBIR_INSTRUCCION: begin
                    reg_sel_o <= 0;
                    wr_o <= 1;
                    entrada_perif_UART_o <= 32'b0;
                    state <= LEER_INSTRUCCION;
                end
                
                DATO_SALIENTE: begin
                    reg_sel_o <= 1;
                    wr_o <= 1;
                    entrada_perif_UART_o <= sw_i;
                    state <= ENVIAR_DATO;
                end
                
                ENVIAR_DATO: begin
                    reg_sel_o <= 0;
                    wr_o <= 1;
                    entrada_perif_UART_o <= {31'b0, 1'b1};
                    state <= LEER_INSTRUCCION;
                end
            endcase
        end
        
        dato_recibido_o <= dato_salida;
    end
endmodule
