`timescale 1ns / 1ps

module cuenta_direccion(
  input logic tx_done_o,
  input logic reset_i,
  output logic [7:0] direccion_o
);

  logic [7:0] cuenta = 8'b0000_0000;

  always @(negedge tx_done_o or posedge reset_i) begin
    if (reset_i) begin
      cuenta <= 8'b0000_0000;
    end else if (cuenta == 8'b1111_1111) begin
      cuenta <= 8'b0000_0000;
    end else begin
      cuenta <= cuenta + 1;
    end
  end
  
  assign direccion_o = cuenta;
  
endmodule


/*module cuenta_direccion(
  input logic tx_done_o,
  output logic [5:0] direccion_o
);

  logic [5:0] cuenta = -1;

  always @(negedge tx_done_o) begin
    cuenta <= cuenta + 1;
  end
  
  assign direccion_o = cuenta;
  
endmodule*/
