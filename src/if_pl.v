`timescale 1ns / 1ps

module IF_ID(CLK, RESET, IF_PC, IF_INSTR, ID_PC, ID_INSTR);
    input CLK, RESET;
    input [31:0] IF_PC;
    input [31:0] IF_INSTR;
    output reg [31:0] ID_PC;
    output reg [31:0] ID_INSTR;

    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            ID_PC <= 0;
            ID_INSTR <= 0;
        end else begin
            ID_PC <= IF_PC;
            ID_INSTR <= IF_INSTR;
        end
    end
endmodule
