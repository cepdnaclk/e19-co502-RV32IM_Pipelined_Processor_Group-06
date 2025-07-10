`timescale 1ns/1ps

module MA_WB(CLK,RESET,MA_PC,MA_ADD,MA_DATA,MA_MEM_OUT,MA_W_REG,MA_REG_EN,WB_PC,
WB_ADD,WB_DATA,WB_MEM_OUT,WB_W_REG,WB_REG_EN);

    input CLK;
    input RESET;

    // Inputs from MA stage
    input [31:0] MA_PC;
    input [4:0] MA_ADD;
    input [31:0] MA_DATA;
    input [31:0] MA_MEM_OUT;
    input [1:0]  MA_W_REG;
    input        MA_REG_EN;

    // Outputs to WB stage
    output reg [31:0] WB_PC;
    output reg [4:0] WB_ADD;
    output reg [31:0] WB_DATA;
    output reg [31:0] WB_MEM_OUT;
    output reg [1:0]  WB_W_REG;
    output reg        WB_REG_EN;

    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            WB_PC       <= 32'd0;
            WB_ADD      <= 5'd0;
            WB_DATA     <= 32'd0;
            WB_MEM_OUT  <= 32'd0;
            WB_W_REG    <= 2'b0;
            WB_REG_EN   <= 1'b0;
        end else begin
            WB_PC       <= MA_PC;
            WB_ADD      <= MA_ADD;
            WB_DATA     <= MA_DATA;
            WB_MEM_OUT  <= MA_MEM_OUT;
            WB_W_REG    <= MA_W_REG;
            WB_REG_EN   <= MA_REG_EN;
        end
    end

endmodule