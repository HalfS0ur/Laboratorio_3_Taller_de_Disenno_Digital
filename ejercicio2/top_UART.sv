`timescale 1ns / 1ps

module top_UART(
    input  logic        clk_i,
    input  logic        reset_i,
    input  logic        rx,
    input  logic        reg_sel_i, 
    input  logic        wr_i, 
    input  logic        addr_i,
    input  logic [31:0] entrada_i,
      
    output logic        tx,
    output logic [31:0] salida_o 
    );
    
    logic [31:0] instruccion_UART;
    logic bit_send;
    logic bit_new;
    logic wr2_test;
    logic tx_rdy;
    logic rx_data_rdy;
    logic [31:0] control;
    logic wr1;
    logic wr1_datos;
    logic [7:0] data_out;
    logic [7:0] data_test;
    
    UART UART(
        .clk(clk_i),
        .reset(reset_i),
        .tx_start(control [0]),
        .tx_rdy(tx_rdy),
        .rx_data_rdy(rx_data_rdy),
        .data_in(data_test),//cambio
        .data_out(data_out),
        .rx(rx),
        .tx(tx),
        .bit_send(bit_send),
        .bit_new(bit_new) 
    );
    
    registro_control reg_control (
        .clk_i(clk_i),
        .rst_i(reset_i),
        .in1(entrada_i),
        .in2(instruccion_UART),
        .WR1(wr1),
        .WR2(wr2_test), //wr2_test
        .control_o(control)
    );
    
    registro_datos reg_datos(
        .clk_i(clk_i),
        .reset_i(reset_i),
        .data_in1(entrada_i),
        .data_in2(data_out),
        .we1_i(wr1_datos),
        .we2_i(rx_data_rdy),
        .data_out(data_test)
    );
    
    mux_2_a_1 control_salida(
        .seleccion_i(reg_sel_i),
        .entrada0_i(control[1:0]),
        .entrada1_i(data_test),
        .salida_o(salida_o)//instruccion_test
    );
    
    demux_1_a_2 demux_wr(
        .en_i(wr_i),
        .sel_i(reg_sel_i),
        .reg1_o(wr1),
        .reg2_o(wr1_datos)
    );
    
    always_ff @(posedge clk_i) begin
        if (tx_rdy == 1) begin
            instruccion_UART = 32'b0;
        end
        
        if (rx_data_rdy == 1) begin
            instruccion_UART = {30'b0, 1'b1, 1'b0};
        end
    end
    
    assign wr2_test = {bit_new || !bit_send}; //mantener por si acaso
    
endmodule
