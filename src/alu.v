`timescale 1ns/1ps

module ALU (
    input CLK,
    input RESET,
    input [31:0] DATA1,
    input [31:0] DATA2,
    input [4:0] SELECT,       // Matches ALUOP from control unit
    output reg [31:0] RESULT
);

    always @(*) begin
        case (SELECT)
            5'b00001: RESULT = DATA1 + DATA2;                // ADD
            5'b00010: RESULT = DATA1 - DATA2;                // SUB
            5'b00011: RESULT = DATA1 << DATA2[4:0];          // SLL
            5'b00100: RESULT = ($signed(DATA1) < $signed(DATA2)) ? 1 : 0;  // SLT
            5'b00101: RESULT = (DATA1 < DATA2) ? 1 : 0;      // SLTU
            5'b00110: RESULT = DATA1 ^ DATA2;                // XOR
            5'b00111: RESULT = DATA1 >> DATA2[4:0];          // SRL
            5'b01000: RESULT = $signed(DATA1) >>> DATA2[4:0];// SRA
            5'b01001: RESULT = DATA1 | DATA2;                // OR
            5'b01010: RESULT = DATA1 & DATA2;                // AND
            5'b01011: RESULT = DATA1 * DATA2;                // MUL
            5'b01100: RESULT = ($signed(DATA1) * $signed(DATA2)) >>> 32; // MULH
            5'b01101: RESULT = ($signed(DATA1) * DATA2) >>> 32; // MULHSU
            5'b01110: RESULT = (DATA1 * DATA2) >> 32;        // MULHU
            5'b01111: RESULT = (DATA2 != 0) ? ($signed(DATA1) / $signed(DATA2)) : 0; // DIV
            5'b10000: RESULT = (DATA2 != 0) ? (DATA1 / DATA2) : 0;          // DIVU
            5'b10001: RESULT = (DATA2 != 0) ? ($signed(DATA1) % $signed(DATA2)) : 0; // REM
            5'b10010: RESULT = (DATA2 != 0) ? (DATA1 % DATA2) : 0;          // REMU
            default: RESULT = 32'b0; // Reserved
        endcase
    end

endmodule
