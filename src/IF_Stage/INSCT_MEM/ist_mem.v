`timescale 1ns/1ps

// Define a module called "INSTRUCTION_MEMORY"
module INSTRUCTION_MEMORY (CLK, RESET, ADDR, INSTRUCTION);

    // Declare inputs and outputs of the module
    input CLK,RESET;
    input  wire [31:0] ADDR;
    output reg  [31:0] INSTRUCTION;

    reg [31:0] memory [0:1023]; // 1024 instructions
    wire [30:0] addr_index;

    assign addr_index = ADDR[31:2];  // Word aligned addressing

    // Load instruction memory from external file at start of simulation
    initial begin
        $readmemh("instruction.mem", memory);
    end

    always @(posedge CLK) begin
        if (RESET) begin
            INSTRUCTION <= 32'b0;
        end else begin
            INSTRUCTION <= memory[addr_index];
        end
    end

endmodule
