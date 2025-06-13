`timescale 1ns/1ps

module IF_EX (
    input CLK,
    input RESET,

    // IF Stage inputs
    input [31:0] IF_PC,
    input [4:0]  IF_ADD,
    input [31:0] IF_D1,
    input [31:0] IF_D2,
    input [31:0] IF_SIGN,
    input        IF_OP1,
    input        IF_OP2,
    input [4:0]  IF_ALU,
    input [2:0]  IF_BS,
    input [1:0]  IF_MW,
    input [1:0]  IF_MR,
    input [1:0]  IF_W_REG,
    input        IF_REG_EN,

    // EX Stage outputs
    output reg [31:0] EX_PC,
    output reg [4:0]  EX_ADD,
    output reg [31:0] EX_D1,
    output reg [31:0] EX_D2,
    output reg [31:0] EX_SIGN,
    output reg        EX_OP1,
    output reg        EX_OP2,
    output reg [4:0]  EX_ALU,
    output reg [2:0]  EX_BS,
    output reg [1:0]  EX_MW,
    output reg [1:0]  EX_MR,
    output reg [1:0]  EX_W_REG,
    output reg        EX_REG_EN
);

    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            EX_PC      <= 32'd0;
            EX_ADD     <= 5'd0;
            EX_D1      <= 32'd0;
            EX_D2      <= 32'd0;
            EX_SIGN    <= 32'd0;
            EX_OP1     <= 1'b0;
            EX_OP2     <= 1'b0;
            EX_ALU     <= 5'd0;
            EX_BS      <= 3'd0;
            EX_MW      <= 2'd0;
            EX_MR      <= 2'd0;
            EX_W_REG   <= 2'd0;
            EX_REG_EN  <= 1'b0;
        end else begin
            EX_PC      <= IF_PC;
            EX_ADD     <= IF_ADD;
            EX_D1      <= IF_D1;
            EX_D2      <= IF_D2;
            EX_SIGN    <= IF_SIGN;
            EX_OP1     <= IF_OP1;
            EX_OP2     <= IF_OP2;
            EX_ALU     <= IF_ALU;
            EX_BS      <= IF_BS;
            EX_MW      <= IF_MW;
            EX_MR      <= IF_MR;
            EX_W_REG   <= IF_W_REG;
            EX_REG_EN  <= IF_REG_EN;
        end
    end

endmodule
