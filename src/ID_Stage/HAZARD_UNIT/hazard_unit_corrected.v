`timescale 1ns/1ps

// Define a module called "HAZARD_UNIT"
module HAZARD_UNIT(
    ADDR1, ADDR2, EXRD, MEMRD, 
    EXWE, MEMWE, EXMEMR, 
    FDATA1SEL, FDATA2SEL, BUBBLE, STALL
);

    // Inputs
    input [4:0] ADDR1, ADDR2;    // Source register addresses (rs1, rs2)
    input [4:0] EXRD, MEMRD;     // Destination register addresses
    input EXWE, MEMWE;           // Write enable signals
    input EXMEMR;                // Memory read signal from EX stage
    
    // Outputs
    output reg [1:0] FDATA1SEL, FDATA2SEL;  // 2-bit forwarding select
    output reg BUBBLE, STALL;
    
    // Internal hazard detection signals
    wire ex_rs1_hazard, ex_rs2_hazard;      // EX stage hazards
    wire mem_rs1_hazard, mem_rs2_hazard;    // MEM stage hazards
    wire load_use_hazard;                   // Load-use hazard
    
    // EX stage hazard detection (ALU result forwarding)
    assign ex_rs1_hazard = EXWE && (EXRD != 5'b0) && (EXRD == ADDR1);
    assign ex_rs2_hazard = EXWE && (EXRD != 5'b0) && (EXRD == ADDR2);
    
    // MEM stage hazard detection (Memory/WB result forwarding)
    assign mem_rs1_hazard = MEMWE && (MEMRD != 5'b0) && (MEMRD == ADDR1);
    assign mem_rs2_hazard = MEMWE && (MEMRD != 5'b0) && (MEMRD == ADDR2);
    
    // Load-use hazard detection (requires stall)
    assign load_use_hazard = EXMEMR && (EXRD != 5'b0) && 
                            ((EXRD == ADDR1) || (EXRD == ADDR2));
    
    // Forwarding and stall logic
    always @(*) begin
        // Default values
        FDATA1SEL = 2'b00;  // No forwarding
        FDATA2SEL = 2'b00;  // No forwarding
        BUBBLE = 1'b0;
        STALL = 1'b0;
        
        // Check for load-use hazard first (highest priority)
        if (load_use_hazard) begin
            BUBBLE = 1'b1;
            STALL = 1'b1;
        end else begin
            // Forwarding logic (when no stall needed)
            
            // Source 1 forwarding
            if (ex_rs1_hazard && !EXMEMR) begin
                FDATA1SEL = 2'b01;  // Forward from EX/MEM pipeline register
            end else if (mem_rs1_hazard) begin
                FDATA1SEL = 2'b10;  // Forward from MEM/WB pipeline register
            end
            
            // Source 2 forwarding
            if (ex_rs2_hazard && !EXMEMR) begin
                FDATA2SEL = 2'b01;  // Forward from EX/MEM pipeline register
            end else if (mem_rs2_hazard) begin
                FDATA2SEL = 2'b10;  // Forward from MEM/WB pipeline register
            end
        end
    end

endmodule
