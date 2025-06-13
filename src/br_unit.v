`timescale 1ns/1ps

module BRANCH (
    input wire [31:0] data1,
    input wire [31:0] data2,
    input wire [2:0] op,  
    output reg out
);

    // Define comparison wires
    wire BEQ, BNE, BLT, BGE, BLTU, BGEU;

    assign BEQ  = (data1 == data2);
    assign BNE  = (data1 != data2);
    assign BLT  = ($signed(data1) < $signed(data2));
    assign BGE  = ($signed(data1) >= $signed(data2));
    assign BLTU = ($unsigned(data1) < $unsigned(data2));
    assign BGEU = ($unsigned(data1) >= $unsigned(data2));

    always @(*) begin
        #2 
        case (op[2:0])
            3'b010: out = 1'b1; 
            3'b000: out = BEQ;
            3'b001: out = BNE;
            3'b100: out = BLT;
            3'b101: out = BGE;
            3'b110: out = BLTU;
            3'b111: out = BGEU;
            default: out = 1'b0;
        endcase
    end


endmodule
