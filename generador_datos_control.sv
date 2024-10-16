`timescale 1ns / 1ps

module generador_datos_control(
    input logic             clk_i,
    input logic             reset_i,
    input logic             inicio_i,
    input logic     [31:0]  salida_i,
    input logic             ones_i,
    input logic             ceros_i,
    
    output logic            wr_o,
    output logic            reg_sel_o,
    output logic    [31:0]  entrada_o,
    output logic    [31:0]   addr_o
    //output logic [7:0] salida_test
    );
    
    localparam [2:0]
        IDLE = 3'b000,
        ESCRIBIR_DATOS = 3'b001,
        ESCRIBIR_INSTRUCCION = 3'b010,
        LEER_INSTRUCCION = 3'b011,
        LEER_DATOS = 3'b100;
        
    logic [2:0] state;
    logic [7:0] cuenta_dato_dir;
    logic [24:0] cuenta_clk;
    
    always @(posedge clk_i) begin
        if (reset_i) begin
            state <= IDLE;
            wr_o <= 0;
            reg_sel_o <= 0;
            entrada_o <= 0;
            cuenta_dato_dir <= 0;
            cuenta_clk <= 0;
            addr_o <= 0;
        end
        
        else begin
            case (state)
                IDLE: begin
                    if (inicio_i) begin
                        state <= ESCRIBIR_DATOS;    
                    end
                    
                    else begin
                        state <= IDLE;
                        wr_o <= 0;
                        reg_sel_o <= 0;
                        entrada_o <= 0;
                        cuenta_dato_dir <= 0;
                        cuenta_clk <= 0;
                        addr_o <= 0;
                    end
                end
                
                ESCRIBIR_DATOS: begin
                    wr_o <= 1;
                    reg_sel_o <= 1;
                                
                    if (clk_i == 1'b1) begin
                        if (cuenta_clk == 1'b0) begin //aumentar las cuentas si hay errores
                            entrada_o <= cuenta_dato_dir;
                            addr_o <= cuenta_dato_dir;
                        end
                        
                        cuenta_clk <= cuenta_clk + 1; // moved here
                                    
                        if (cuenta_clk == 10) begin                   
                            cuenta_clk <= 0;
                            
                            if (cuenta_dato_dir == 8'hFF) begin
                                state <= ESCRIBIR_INSTRUCCION;
                                cuenta_dato_dir <= 0;
                                entrada_o <= 0;
                                addr_o <= 0;
                            end
                            
                            else begin
                                cuenta_dato_dir <= cuenta_dato_dir + 1;
                            end
                        end
                    end
                                
                end
                
                ESCRIBIR_INSTRUCCION: begin
                    wr_o <= 1;
                    reg_sel_o <= 0;
                    
                    if (clk_i == 1'b1) begin
                        if (cuenta_clk == 5) begin //aumentar las cuentas si hay errores
                            //entrada_o <= 32'b00000000000000000000111111010001;
                            entrada_o <= {28'b0000000000000000000011111101,ceros_i,ones_i,2'b01};
                        end
                        
                        if (cuenta_clk == 12) begin //aumentar las cuentas si hay errores
                            state <= LEER_INSTRUCCION;
                        end
                        
                        cuenta_clk <= cuenta_clk + 1;
                        
                    end
                end
                
                LEER_INSTRUCCION: begin
                    wr_o <= 0;
                    reg_sel_o <= 0;
                    
                    if (salida_i[0] == 0) begin
                        cuenta_clk <= 0;
                        cuenta_dato_dir = 0;
                        state <= LEER_DATOS;
                    end
                    
                    else begin
                        state <= LEER_INSTRUCCION;
                    end
                end
                
                LEER_DATOS: begin
                    wr_o <= 0;
                    reg_sel_o <= 1;
                    entrada_o <= addr_o;
                    
                    if (ceros_i == 1) begin
                        addr_o <= 0;
                    end
                    
                    if (ones_i == 1) begin
                        addr_o <= 1;
                    end
                    
                    if (clk_i == 1'b1) begin
                        if (cuenta_clk == 1'b0) begin //aumentar las cuentas si hay errores
                            //salida_test <= salida_i[7:0];
                            addr_o <= cuenta_dato_dir;
                        end
                        
                        cuenta_clk <= cuenta_clk + 1; // moved here
                                    
                        if (cuenta_clk == 10000000) begin                   
                            cuenta_clk <= 0;
                            
                            if (cuenta_dato_dir == 8'hFF) begin
                                state <= IDLE;
                                cuenta_dato_dir <= 0;
                                addr_o <= 0;
                            end
                            
                            else begin
                                cuenta_dato_dir <= cuenta_dato_dir + 1;
                            end
                        end
                    end
                end
            endcase
        end
    end
    
    //assign salida_test = entrada_o [7:0]; 
    
endmodule
