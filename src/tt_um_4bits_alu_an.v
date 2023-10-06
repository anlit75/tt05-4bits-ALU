// `default_nettype none
`timescale 1ns / 1ps

module tt_um_4bits_alu_an (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 output pin
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Set all bidirectional pins as inputs
    assign uio_oe = 8'b0;

    // Initialize unused outputs of the BIDIRECTIONAL path to 0 for posterity (otherwise Yosys fails)
    assign uio_out = 8'b0;

    alu alu (
      .clk(clk),
      .rst(!rst_n),
      .A(ui_in[7:4]),
      .B(ui_in[3:0]),
      .opcode(uio_in[3:0]),
      .out(uo_out)
    );

endmodule

module alu(
    input wire clk,
    input wire rst,
    input wire [3:0] A,
    input wire [3:0] B,
    input wire [3:0] opcode,
    output reg [7:0] out
);

    always @(posedge clk) begin
      if (rst) begin
          out <= 8'b0; // Reset the output to 0 when reset signal is active
      end 
      else begin
        case(opcode)
          4'h0: out <= A + B;         // Addition
          4'h1: out <= A - B;         // Subtraction
          4'h2: out <= A * B;         // Multiplication
          4'h3: out <= A / B;         // Division
          4'h4: out <= A << B;        // Logical shift left B times
          4'h5: out <= A >> B;        // Logical shift right B times
          4'h6: out <= ~A + 1'b1;     // 2's complement of A
          4'h7: out <= ~B + 1'b1;     // 2's complement of B
          4'h8: out <= A & B;         // Bitwise and
          4'h9: out <= A | B;         // Bitwise or
          4'ha: out <= A ^ B;         // Bitwise xor
          4'hb: out <= ~(A | B);      // Bitwise nor
          4'hc: out <= ~(A & B);      // Bitwise nand
          4'hd: out <= ~(A ^ B);      // Bitwise xnor
          4'he: out <= A == B;        // Check for equality
          4'hf: out <= (A > B) ? 1'b1 : 1'b0; // Compare A and B, output 1 if A > B, else 0
          default: out <= A + B;      // Default to addition if opcode is not recognized
        endcase
      end
    end

endmodule
