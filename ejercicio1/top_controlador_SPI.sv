`timescale 1ns / 1ps

module top_controlador_SPI(
  input logic               clk_i,     // System clock
  input logic               rst_i,   // Asynchronous active-high reset
  input logic               MISO,    // Master in, slave out
  input logic               reg_sel_i,
  input logic               wr_i,
  input logic     [31:0]    entrada_i,
  input logic     [31:0]    addr_i,
  
  
  output logic              cs_ctrl_o,       // Chip select (active low)
  output logic              MOSI,           // Master out, slave in
  output logic              sclk_i,           // Serial clock
  output logic              tx_done_o,  // Transmission complete flag
  output logic    [31:0]    bits_salida,
  output logic [7:0] testmemo, //quitar
  output logic [7:0] memdir
  );
  
  logic [31:0]  control;
  logic [31:0]  instruccion_spi;
  logic [7:0]   dato_memoria;
  logic [7:0]   direccion;
  logic [7:0]   control_dir;
  logic         wr1_control;
  logic         wr1_datos;
  logic         wr2;
  logic [7:0]  puente_datos;
  logic [7:0]   rx_data;
  logic [9:0]  n_rx_end;
  logic         control_we;
  
   
 controlador_SPI SPI (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .MISO(MISO), //check
    .tx_data_i(dato_memoria),
    .send_i(control[0]),
    .n_tx_end_i(control [12:4]),
    .rx_data_o(rx_data),
    .cs_ctrl_o(cs_ctrl_o),
    .MOSI(MOSI),
    .sclk_i(sclk_i),
    .tx_done_o(tx_done_o),
    .n_rx_end_o(n_rx_end),
    .all_1s_i(control[2]),
    .all_0s_i(control[3]),
    .instruccion_o(instruccion_spi),
    .we_2(wr2)
  );
  
  registro_control reg_control (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .in1(entrada_i),
        .in2(instruccion_spi),
        .WR1(wr1_control),
        .WR2(tx_done_o),
        .control_o(control)
    );
    
    mux_2_a_1 #(1) write_enable_RAM(
        .seleccion_i(control[0]),
        .entrada0_i(wr1_datos),
        .entrada1_i(wr2),
        .salida_o(control_we)
    );
    
    mux_2_a_1 #(32) carga_datos(
        .seleccion_i(control[0]),
        .entrada0_i(entrada_i),
        .entrada1_i(rx_data),
        .salida_o(puente_datos)
    );
    
    registro_ram ram_replacement(
        .clk_i(clk_i),
        .reset_i(rst_i),
        .we_i(control_we),
        .data_i(puente_datos),
        .addr_i(control_dir),
        .data_o(dato_memoria)
    );

    cuenta_direccion direcciones(
        .tx_done_o(tx_done_o),
        .reset_i(rst_i),
        .direccion_o(direccion)
    );
    
    mux_2_a_1 #(32) direccion_datos(
        .seleccion_i(control[0]),
        .entrada0_i(addr_i),
        .entrada1_i(direccion),
        .salida_o(control_dir)
    );
    
    mux_2_a_1 #(32) salida(
        .seleccion_i(reg_sel_i),
        .entrada0_i(control),
        .entrada1_i(dato_memoria),
        .salida_o(bits_salida)
    );
    
    demux_1_a_2 write_enable_1(
        .en_i(wr_i),
        .sel_i(reg_sel_i),
        .reg1_o (wr1_control),
        .reg2_o (wr1_datos)
    );
    
    assign testmemo = dato_memoria;
    assign memdir = control_dir;
    
endmodule
