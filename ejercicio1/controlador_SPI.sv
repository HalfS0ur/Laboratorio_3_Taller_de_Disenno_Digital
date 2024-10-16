`timescale 1ns / 1ps

module controlador_SPI (
  input logic           clk_i,        // System clock
  input logic           rst_i,      // Asynchronous active-high reset
  input logic           MISO,       // Master in, slave out
  input logic   [7:0]   tx_data_i,  // Data to transmit
  input logic           send_i,     // Start transmission (active high)
  input logic   [8:0]   n_tx_end_i, // Direccion del ultimo dato a enviar
  input logic           all_1s_i,   // When high, always output 1 on MOSI
  input logic           all_0s_i,   // When high, always output 0 on MOSI
  
  output logic          cs_ctrl_o,  // Chip select (active low)
  output logic          MOSI,       // Master out, slave in
  output logic          sclk_i,       // Serial clock
  output logic          tx_done_o,  // Transmission complete flag
  output logic  [7:0]   rx_data_o,  // Received data
  output logic  [9:0]   n_rx_end_o, // Transaction end count
  output logic          we_2,
  output logic  [31:0]  instruccion_o
);

  localparam [1:0]
    IDLE = 2'b00,
    START = 2'b01,
    TRANSMIT = 2'b10,
    REESCRIBIR = 2'b11;

  logic [1:0] state;
  logic [4:0] bit_count;
  logic control_transmision;
  logic [1:0] last_state = IDLE;
  logic [4:0] trans_count;
  logic [6:0] cuenta_sclk_i = 0;

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      state <= IDLE;
      last_state <= IDLE;
      bit_count <= 5'b0;
      tx_done_o <= 1'b0;
      cs_ctrl_o <= 1'b1;
      MOSI <= 1'b0;
      sclk_i <= 1'b0;
      n_rx_end_o <= 10'b0; //check # bits
      rx_data_o <= 8'b0;
      we_2 <= 0;
      control_transmision <= 0;
      trans_count <= 0;
    end
    
    
    else begin
      case (state)
        IDLE: begin
          MOSI <= 0;
          if (send_i) begin
            state <= START;
            cs_ctrl_o <= 1'b0;
            
                if (all_1s_i) begin
                  MOSI <= 1'b1;
                end 
                
                else if (all_0s_i) begin
                  MOSI <= 1'b0;
                end 
                
            else begin
              MOSI <= tx_data_i[7];
            end
            
            tx_done_o <= 1'b0;
            last_state <= START;
            
          end
        end

        START: begin
          sclk_i <= 1'b1; //cambiar a 1
          MOSI <= 0;
          if (bit_count == 7) begin
                bit_count <= 5'b0;
                state <= TRANSMIT;
                last_state <= TRANSMIT;
          end
          
          else begin
                bit_count <= bit_count + 1;
          end
        end

        TRANSMIT: begin               
          sclk_i <= ~sclk_i;
          if (sclk_i == 1'b1) begin
                if (all_1s_i) begin
                  MOSI <= 1'b1;
                end 
                
                else if (all_0s_i) begin
                  MOSI <= 1'b0;
                end 
                
                else begin
                  MOSI <= tx_data_i[7-bit_count];
                end
                
            bit_count <= bit_count + 1;
            
            if (bit_count == 8) begin
              bit_count <= 5'b0;
              state <= REESCRIBIR;
              tx_done_o <= 1'b1;
              cs_ctrl_o <= 1'b1;
              n_rx_end_o <= n_rx_end_o + 1;
              last_state <= REESCRIBIR; //?
            end
            
            if (n_rx_end_o < n_tx_end_i + 1) begin
                control_transmision = send_i;
            end
            
            else if (n_rx_end_o > n_tx_end_i + 1) begin
                control_transmision = !send_i;
            end
            
          end
          
          else begin
                if (last_state == TRANSMIT && sclk_i == 1'b1) begin
                  rx_data_o <= {rx_data_o[6:0], MISO}; //NO NEGADO
                end
                 
                else if (last_state == TRANSMIT && sclk_i == 1'b0) begin
                  rx_data_o <= {rx_data_o[6:0], MISO}; //NO NEGADO
                end
          end
        end
        
        REESCRIBIR: begin
      if (clk_i == 1'b1) begin
        if (trans_count == 1) begin
          we_2 <= 1;
        end else if (trans_count == 14) begin
          we_2 <= 0;
          state <= IDLE; // Return to IDLE state
          last_state <= IDLE;
          trans_count <= 0; // Reset trans_count
        end
                    
        trans_count <= trans_count + 1;
      end
    end
        
        
        
        default: state <= IDLE;
      endcase
      
      end      
  end
  
  assign instruccion_o = {6'b000000, n_rx_end_o, 3'b000, n_tx_end_i, all_0s_i, all_1s_i, 1'b0, control_transmision};
  
endmodule