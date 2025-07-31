`timescale 1ns/1ps

// Enhanced Hazard Unit handling both Data and Control Hazards
module ENHANCED_HAZARD_UNIT(
    input CLK,
    input RESET,
    
    // Data hazard inputs
    input [4:0] ADDR1, ADDR2,    // Source register addresses
    input [4:0] EXRD, MEMRD,     // Destination register addresses
    input EXWE, MEMWE, EXMEMR,   // Write enables and memory read
    
    // Control hazard inputs
    input IS_BRANCH_ID,          // Branch instruction in ID stage
    input IS_BRANCH_EX,          // Branch instruction in EX stage
    input BRANCH_TAKEN,          // Branch decision
    input [31:0] BRANCH_TARGET,  // Branch target address
    
    // Data hazard outputs
    output reg [1:0] FDATA1SEL, FDATA2SEL,  // Data forwarding selects
    
    // Control outputs
    output reg PC_STALL,         // Stall PC
    output reg IF_ID_STALL,      // Stall IF/ID register
    output reg IF_ID_FLUSH,      // Flush IF/ID register
    output reg ID_EX_FLUSH,      // Flush ID/EX register
    output reg PC_MUX_SEL,       // PC source select
    
    // General hazard indicators
    output reg DATA_HAZARD,      // Data hazard detected
    output reg CONTROL_HAZARD,   // Control hazard detected
    output reg PIPELINE_STALL    // Overall pipeline stall
);

    // Internal signals for data hazard detection
    wire ex_rs1_hazard, ex_rs2_hazard;
    wire mem_rs1_hazard, mem_rs2_hazard;
    wire load_use_hazard;
    
    // Data hazard detection (same as before)
    assign ex_rs1_hazard = EXWE && (EXRD != 5'b0) && (EXRD == ADDR1);
    assign ex_rs2_hazard = EXWE && (EXRD != 5'b0) && (EXRD == ADDR2);
    assign mem_rs1_hazard = MEMWE && (MEMRD != 5'b0) && (MEMRD == ADDR1);
    assign mem_rs2_hazard = MEMWE && (MEMRD != 5'b0) && (MEMRD == ADDR2);
    assign load_use_hazard = EXMEMR && (EXRD != 5'b0) && 
                            ((EXRD == ADDR1) || (EXRD == ADDR2));
    
    // Hazard priority: Control hazards have higher priority than data hazards
    always @(*) begin
        // Default values
        FDATA1SEL = 2'b00;
        FDATA2SEL = 2'b00;
        PC_STALL = 1'b0;
        IF_ID_STALL = 1'b0;
        IF_ID_FLUSH = 1'b0;
        ID_EX_FLUSH = 1'b0;
        PC_MUX_SEL = 1'b0;
        DATA_HAZARD = 1'b0;
        CONTROL_HAZARD = 1'b0;
        PIPELINE_STALL = 1'b0;
        
        // 1. Handle Control Hazards First (Higher Priority)
        if (IS_BRANCH_ID && !RESET) begin
            // Branch in ID stage - stall pipeline
            CONTROL_HAZARD = 1'b1;
            PC_STALL = 1'b1;
            IF_ID_STALL = 1'b1;
            PIPELINE_STALL = 1'b1;
            
        end else if (IS_BRANCH_EX && !RESET) begin
            // Branch in EX stage - handle branch decision
            if (BRANCH_TAKEN) begin
                // Flush incorrect instructions
                IF_ID_FLUSH = 1'b1;
                ID_EX_FLUSH = 1'b1;
                PC_MUX_SEL = 1'b1;  // Jump to branch target
            end
            
        // 2. Handle Data Hazards (Lower Priority)
        end else if (load_use_hazard) begin
            // Load-use hazard requires stall
            DATA_HAZARD = 1'b1;
            PC_STALL = 1'b1;
            IF_ID_STALL = 1'b1;
            PIPELINE_STALL = 1'b1;
            
        end else begin
            // Handle data forwarding
            if (ex_rs1_hazard && !EXMEMR) begin
                FDATA1SEL = 2'b01;  // Forward from EX/MEM
                DATA_HAZARD = 1'b1;
            end else if (mem_rs1_hazard) begin
                FDATA1SEL = 2'b10;  // Forward from MEM/WB
                DATA_HAZARD = 1'b1;
            end
            
            if (ex_rs2_hazard && !EXMEMR) begin
                FDATA2SEL = 2'b01;  // Forward from EX/MEM
                DATA_HAZARD = 1'b1;
            end else if (mem_rs2_hazard) begin
                FDATA2SEL = 2'b10;  // Forward from MEM/WB
                DATA_HAZARD = 1'b1;
            end
        end
    end

endmodule
