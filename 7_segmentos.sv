`timescale 1ns / 1ps

module display_7seg(
    input logic [7:0]      dato_i,
    input logic             clk_i,
    output logic [6:0]      seg_o,
    output logic [3:0]      an_o 
    );
    
    logic [3:0]             numHex;
    logic [1:0]             display_2;
    
    always@(posedge clk_i)begin
        display_2 = display_2 + 1'b1;
    end
    
    always@(*)begin
        case(display_2)
            2'b00: begin
                an_o = 4'b1110;
                numHex = dato_i[3:0];
            end           
            2'b01: begin
                an_o = 4'b1101;
                numHex = dato_i[7:4];
            end            
            2'b10: begin
                an_o = 4'b1011;
                numHex = 0;
            end         
            2'b11: begin
                an_o = 4'b0111;
                numHex = 0;
            end
        endcase
    end
    
    always_comb begin
        begin
            case(numHex)
                4'b0000: seg_o = 7'b1000000; // "0"  
                4'b0001: seg_o = 7'b1111001; // "1"
                4'b0010: seg_o = 7'b0100100; // "2"
                4'b0011: seg_o = 7'b0110000; // "3"
                4'b0100: seg_o = 7'b0011001; // "4"
                4'b0101: seg_o = 7'b0010010; // "5"
                4'b0110: seg_o = 7'b0000010; // "6"
                4'b0111: seg_o = 7'b1111000; // "7"
                4'b1000: seg_o = 7'b0000000; // "8"
                4'b1001: seg_o = 7'b0010000; // "9" 
                4'b1010: seg_o = 7'b0001000; // "10 = A"
                4'b1011: seg_o = 7'b0000011; // "11 = B"
                4'b1100: seg_o = 7'b1000110; // "12 = C"
                4'b1101: seg_o = 7'b0100001; // "13 = D"
                4'b1110: seg_o = 7'b0000110; // "14 = E"
                4'b1111: seg_o = 7'b0001110; // "15 = F"
                default: seg_o = 7'b1000000; // "0"
            endcase
        end
    end
endmodule
