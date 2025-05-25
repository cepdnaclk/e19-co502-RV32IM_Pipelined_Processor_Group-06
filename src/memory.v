`timescale 1ns / 1ps

module Data_Memory(CLK, RESET, WRITEENABLE, ADDR, DATA_IN, DATA_OUT);

    input CLK, RESET, WRITEENABLE;
    input [31:0] ADDR, DATA_IN;
    output [31:0] DATA_OUT;

    reg [31:0] mem [1023:0];

    always @ (posedge CLK) begin
        if (WRITEENABLE)
            mem[ADDR] <= DATA_IN;
    end

    assign DATA_OUT = (~RESET) ? 32'd0 : mem[ADDR];

    initial begin
        mem[0] = 32'h00000000;
        mem[1] = 32'h00000056;
    end

endmodule
