`timescale 1ns/1ps

// Modified Program Counter with Hazard Control
module PC_HAZARD(
    input CLK,
    input RESET,
    
    // Hazard control signals
    input PC_STALL,           // From hazard unit - don't update PC
    input PC_MUX_SEL,         // From hazard unit - select PC source
    
    // PC inputs
    input [31:0] PC_PLUS_4,   // Normal next PC (PC + 4)
    input [31:0] BRANCH_TARGET, // Branch target address
    
    // PC output
    output reg [31:0] PC_OUT
);

    always @(posedge CLK) begin
        if (RESET) begin
            PC_OUT <= 32'h00000000;  // Reset PC to 0
        end else if (!PC_STALL) begin
            // Update PC only when not stalled
            if (PC_MUX_SEL) begin
                PC_OUT <= BRANCH_TARGET;  // Branch taken
            end else begin
                PC_OUT <= PC_PLUS_4;      // Normal increment
            end
        end
        // If PC_STALL is high, maintain current PC value
    end

endmodule
