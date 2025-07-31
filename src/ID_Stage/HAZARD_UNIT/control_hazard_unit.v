`timescale 1ns/1ps

// Control Hazard Unit for handling branch instructions
module CONTROL_HAZARD_UNIT(
    input CLK,
    input RESET,
    
    // Branch detection inputs
    input IS_BRANCH_ID,          // Branch instruction detected in ID stage
    input IS_BRANCH_EX,          // Branch instruction in EX stage
    input BRANCH_TAKEN,          // Branch decision from EX stage
    input [31:0] BRANCH_TARGET,  // Branch target address
    input [31:0] PC_PLUS_4,      // PC + 4 (next sequential instruction)
    
    // Pipeline control outputs
    output reg PC_STALL,         // Stall PC (don't fetch new instruction)
    output reg IF_ID_STALL,      // Stall IF/ID pipeline register
    output reg IF_ID_FLUSH,      // Flush IF/ID pipeline register
    output reg ID_EX_FLUSH,      // Flush ID/EX pipeline register
    output reg PC_MUX_SEL,       // Select PC source (0: PC+4, 1: branch target)
    
    // Control hazard detection
    output reg CONTROL_HAZARD
);

    // Control hazard detection logic
    always @(*) begin
        // Default values
        PC_STALL = 1'b0;
        IF_ID_STALL = 1'b0;
        IF_ID_FLUSH = 1'b0;
        ID_EX_FLUSH = 1'b0;
        PC_MUX_SEL = 1'b0;
        CONTROL_HAZARD = 1'b0;
        
        // Control hazard handling
        if (IS_BRANCH_ID && !RESET) begin
            // Branch instruction detected in ID stage
            // Strategy: Stall pipeline until branch is resolved
            CONTROL_HAZARD = 1'b1;
            PC_STALL = 1'b1;       // Don't fetch new instruction
            IF_ID_STALL = 1'b1;    // Hold current IF/ID register
            
        end else if (IS_BRANCH_EX && !RESET) begin
            // Branch instruction in EX stage - decision made
            if (BRANCH_TAKEN) begin
                // Branch is taken - flush incorrect instructions
                IF_ID_FLUSH = 1'b1;   // Flush IF/ID (wrong instruction)
                ID_EX_FLUSH = 1'b1;   // Flush ID/EX (wrong instruction)
                PC_MUX_SEL = 1'b1;    // Select branch target for PC
            end else begin
                // Branch not taken - continue with PC+4
                PC_MUX_SEL = 1'b0;    // Select PC+4
            end
        end
    end

endmodule
