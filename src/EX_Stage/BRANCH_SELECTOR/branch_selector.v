`timescale 1ns/1ps

// Define a module called "BRANCH_SELECTOR"
module BRANCH_SELECTOR(DATA1, DATA2, BRANCH_TYPE, BRANCH_TAKEN);

    // Inputs and Outputs
    input [31:0] DATA1;        // First operand (rs1)
    input [31:0] DATA2;         // Second operand (rs2)
    input [2:0] BRANCH_TYPE;    // Branch type selector
    output BRANCH_TAKEN;        // Branch decision output

    // Branch type encoding (RISC-V standard)
    localparam BEQ  = 3'b000;   // Branch if equal
    localparam BNE  = 3'b001;   // Branch if not equal
    localparam BLT  = 3'b100;   // Branch if less than (signed)
    localparam BGE  = 3'b101;   // Branch if greater or equal (signed)
    localparam BLTU = 3'b110;   // Branch if less than (unsigned)
    localparam BGEU = 3'b111;   // Branch if greater or equal (unsigned)

    // Internal comparison signals
    wire EQUAL;
    wire SIGNED_LT;
    wire UNSIGNED_LT;

    // Comparison operations
    assign EQUAL = (DATA1 == DATA2);
    assign SIGNED_LT = ($signed(DATA1) < $signed(DATA2));
    assign UNSIGNED_LT = (DATA1 < DATA2);

    // Branch decision logic
    reg branch_decision;
    
    always @(*) begin
        case (BRANCH_TYPE)
            BEQ:  branch_decision = EQUAL;              // Branch if equal
            BNE:  branch_decision = ~EQUAL;             // Branch if not equal
            BLT:  branch_decision = SIGNED_LT;          // Branch if less than (signed)
            BGE:  branch_decision = ~SIGNED_LT;         // Branch if greater or equal (signed)
            BLTU: branch_decision = UNSIGNED_LT;        // Branch if less than (unsigned)
            BGEU: branch_decision = ~UNSIGNED_LT;       // Branch if greater or equal (unsigned)
            default: branch_decision = 1'b0;            // No branch for undefined types
        endcase
    end

    assign BRANCH_TAKEN = branch_decision;

endmodule
