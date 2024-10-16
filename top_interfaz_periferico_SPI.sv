`timescale 1ns / 1ps

module top_interfaz_periferico_SPI(
    input logic clk_in1, //ya
    input logic reset_pi, //ya
    input logic inicio_pi, //ya
    input logic MISO,
    input logic ones_pi,
    input logic ceros_pi,
    
    output logic MOSI, //ya
    output logic sclk_o, //ya
    output logic cs_ctrl_o, //ya
    output logic done_o, //ya
    //output logic [7:0] salida_test,
    output logic [7:0] memtest, //ya
    output logic [6:0] seg_o, //ya
    output logic [3:0] an_o //ya
    //output logic [7:0] testmemo, //sacar por el 7 segmentos
    );
    
    logic clk_i;
    logic [31:0] salida;
    logic wr_1;
    logic reg_sel;
    logic [31:0] addr;
    logic [31:0] entrada;
    logic [7:0] testmemo;
    logic clk_1kHz;
    
    clk_wiz_0 instance_name(
    .clk_out1(clk_i),     // output clk_out1
    .clk_in1(clk_in1)
    );      // input clk_in1
    
    generador_datos_control generador_dat_cont (
        .clk_i(clk_i),
        .reset_i(reset_pi),
        .inicio_i(inicio_pi),
        .salida_i(salida),
        .ones_i(ones_pi),
        .ceros_i(ceros_pi),
        .wr_o(wr_1),
        .reg_sel_o(reg_sel),
        .entrada_o(entrada),
        .addr_o(addr)
        //.salida_test(salida_test)
    );
   
    top control_interfaz_spi(
        .clk(clk_i),   
        .rst_i(reset_pi),  
        .MISO(MISO),    
        .reg_sel_i(reg_sel),
        .wr_i(wr_1),
        .entrada_i(entrada),
        .addr1(entrada), //aver
        .cs_ctrl_o(cs_ctrl_o),  
        .MOSI(MOSI),      
        .sclk(sclk_o),       
        .tx_done_o(done_o),  
        .bits_salida(salida),
        .testmemo(testmemo),
        .memdir(memtest)
    );
    
    display_7seg disp_7segmentos (
        .dato_i(testmemo),
        .clk_i(clk_1kHz),
        .seg_o(seg_o),
        .an_o(an_o)
    );
    
    clk_7_segmentos reloj_display(
        .clk_i(clk_i),
        .reset_i(reset_pi),
        .clk_1kHz_o(clk_1kHz)
    );
    //assign memtest = addr;
endmodule
