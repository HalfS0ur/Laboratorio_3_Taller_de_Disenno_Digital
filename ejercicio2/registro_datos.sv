`timescale 1ns / 1ps

module registro_datos(
  input logic clk_i,
  input logic [7:0] data_in1,
  input logic [7:0] data_in2,
  input logic we1_i,
  input logic we2_i,
  input logic reset_i,
  output logic [7:0] data_out
);

  logic [31:0] data_reg [0:1]; // 2 addressable registers
  logic [7:0] stored_data_out; // additional register to hold output value
  
  always @(posedge clk_i) begin
    if (reset_i) begin
      data_reg[0] <= 8'h0;
      data_reg[1] <= 8'h0;
      stored_data_out <= 8'h0;
    end else begin
      if (we1_i) begin
        data_reg[0] <= data_in1;
        stored_data_out <= data_in1;
      end
      if (we2_i) begin
        data_reg[1] <= data_in2;
        stored_data_out <= data_in2;
      end
      data_out <= stored_data_out;
    end
  end
  
endmodule