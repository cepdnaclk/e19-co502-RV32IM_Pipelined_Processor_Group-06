`timescale 1ns/1ps

module EX_MA (
    input CLK,
    input RESET,
    // Inputs from EX stage
    input [31:0] EX_PC,
    input [4:0]  EX_ADD,
    input [31:0] EX_DATA,
    input [31:0] EX_SIGN,
    input [1:0]  EX_MR,
    input [1:0]  EX_MW,
    input [1:0]  EX_W_REG,
    input        EX_REG_EN,

    // Outputs to MA stage
    output reg [31:0] MA_PC,
    output reg [4:0]  MA_ADD,
    output reg [31:0] MA_DATA,
    output reg [31:0] MA_SIGN,
    output reg [1:0]  MA_MR,
    output reg [1:0]  MA_MW,
    output reg [1:0]  MA_W_REG,
    output reg        MA_REG_EN
);

    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            MA_PC     <= 32'd0;
            MA_ADD    <= 5'd0;
            MA_DATA   <= 32'd0;
            MA_SIGN   <= 32'd0;
            MA_MR     <= 2'd0;
            MA_MW     <= 2'd0;
            MA_W_REG  <= 2'd0;
            MA_REG_EN <= 1'b0;
        end else begin
            MA_PC     <= EX_PC;
            MA_ADD    <= EX_ADD;
            MA_DATA   <= EX_DATA;
            MA_SIGN   <= EX_SIGN;
            MA_MR     <= EX_MR;
            MA_MW     <= EX_MW;
            MA_W_REG  <= EX_W_REG;
            MA_REG_EN <= EX_REG_EN;
        end
    end 
endmodule
