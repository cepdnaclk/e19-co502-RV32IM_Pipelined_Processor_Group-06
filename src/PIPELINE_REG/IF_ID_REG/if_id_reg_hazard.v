`timescale 1ns/1ps

// Modified IF/ID Pipeline Register with Hazard Control
module IF_ID_REG(
    input CLK,
    input RESET,
    
    // Hazard control signals
    input STALL,        // From hazard unit - hold current values
    input FLUSH,        // From hazard unit - clear register (insert bubble)
    
    // Data inputs
    input [31:0] PC_IN,
    input [31:0] INSTRUCTION_IN,
    
    // Data outputs
    output reg [31:0] PC_OUT,
    output reg [31:0] INSTRUCTION_OUT
);

    always @(posedge CLK) begin
        if (RESET || FLUSH) begin
            // Reset or flush - insert NOP (bubble)
            PC_OUT <= 32'h00000000;
            INSTRUCTION_OUT <= 32'h00000013;  // NOP instruction (ADDI x0, x0, 0)
        end else if (!STALL) begin
            // Normal operation - update with new values
            PC_OUT <= PC_IN;
            INSTRUCTION_OUT <= INSTRUCTION_IN;
        end
        // If STALL is high, maintain current values (no update)
    end

endmodule
