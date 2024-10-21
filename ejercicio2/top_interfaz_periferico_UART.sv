`timescale 1ns / 1ps

module top_interfaz_periferico_UART(
    input logic clk_in1, //ya
    input logic reset_pi, //ya
    input logic [7:0] sw_pi, //ya
    input logic inicio_pi, //ya
    input logic enviar_dato_pi,
    input logic rx,
    
    output logic tx,
    output logic [7:0] dato_pc //ya
    );
    
    logic [31:0] entrada_perif_UART;
    logic reg_sel;
    logic wr;
    logic [7:0] dato_recibido;
    logic [31:0] salida_perif_UART;
    logic clk_out1;
    logic boton_antirebote;
    logic boton_sincronizado;
    
      clk_wiz_0 reloj(
        .clk_out1(clk_out1),     // output clk_out1
        .clk_in1(clk_in1)
    );
    
      control_UART_FSM generador_datos_control(
        .clk_i(clk_out1),
        .reset_i(reset_pi),
        .salida_perif_UART_i(salida_perif_UART),
        .sw_i(sw_pi),
        .inicio_i(inicio_pi),
        .enviar_dato_i(boton_sincronizado),
        .wr_o(wr),
        .reg_sel_o(reg_sel),
        .entrada_perif_UART_o(entrada_perif_UART),
        .dato_recibido_o(dato_recibido)
    );
    
      top_UART control_interfaz_UART(
        .clk_i(clk_out1),
        .reset_i(reset_pi),
        .entrada_perif_UART_i(entrada_perif_UART),
        .rx(rx),
        .reg_sel_i(reg_sel),
        .wr_i(wr),
        .tx(tx),
        .salida_o(salida_perif_UART)
    );
    
      debouncer antirebotes(
        .clk_i(clk_out1),
        .boton_pi(enviar_dato_pi),
        .boton_debounce_o(boton_antirebote)
      );
      
      sincronizador sincroniza(
        .clk_i(clk_out1),
        .button_i(boton_antirebote),
        .button_o(boton_sincronizado)
      );
    
    assign dato_pc = dato_recibido;
endmodule
