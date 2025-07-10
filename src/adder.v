`timescale 1ns/1ps

module ADDER(
    input [31:0] DATA,
    output [31:0] OUT
);

    assign #1 OUT = DATA + 4;

endmodule