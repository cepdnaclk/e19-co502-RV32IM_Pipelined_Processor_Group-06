`timescale 1ns/1ps

module TRI_MUX (
    input  [31:0] Input1,
    input  [31:0] Input2,
    input  [31:0] Input3,
    input  [1:0]  Select,
    output reg [31:0] Answer
);

    always @(*) begin
        case (Select)
            2'b00: Answer = Input1;
            2'b01: Answer = Input2;
            2'b10: Answer = Input3;
            2'b11: Answer = 32'd0;
            default: Answer = 32'd0;
        endcase
    end

endmodule



