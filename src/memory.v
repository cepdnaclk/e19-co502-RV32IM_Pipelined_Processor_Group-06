`timescale 1ns / 1ps

module Data_Memory (
    input CLK, 
    input RESET,
    input [1:0] WRITE, READ,
    input [31:0] ADDR, DATA_IN,
    output reg [31:0] DATA_OUT
);

    reg [31:0] mem [0:1023];  // 4KB word-addressable memory

    // Write Operation
    always @(posedge CLK) begin
        if (WRITE == 2'b11) begin  // Word write
            mem[ADDR[31:2]] <= DATA_IN;
        end
        // Additional cases for byte/half-word can be added here if needed
    end

    // Read Operation
    always @(*) begin
        if (!RESET) begin
            DATA_OUT = 32'd0;
        end else begin
            case (READ)
                2'b11: DATA_OUT = mem[ADDR[31:2]];  // Word read
                // You can extend this to 2'b01 or 2'b10 if byte/half-word support is needed
                default: DATA_OUT = 32'd0;
            endcase
        end
    end

    // Initialize memory for testing
    initial begin
        mem[0] = 32'h00000000;
        mem[1] = 32'h00000056;
        // Add more initialization here if required
    end

endmodule

