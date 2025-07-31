`timescale 1ns/1ps

module simple_control_test();
    reg CLK, RESET;
    reg IS_BRANCH_ID, IS_BRANCH_EX, BRANCH_TAKEN;
    reg [31:0] BRANCH_TARGET, PC_PLUS_4;
    
    wire PC_STALL, IF_ID_STALL, IF_ID_FLUSH, ID_EX_FLUSH, PC_MUX_SEL;
    wire CONTROL_HAZARD;
    
    // Instantiate control hazard unit
    CONTROL_HAZARD_UNIT dut (
        .CLK(CLK), .RESET(RESET),
        .IS_BRANCH_ID(IS_BRANCH_ID), .IS_BRANCH_EX(IS_BRANCH_EX),
        .BRANCH_TAKEN(BRANCH_TAKEN), .BRANCH_TARGET(BRANCH_TARGET),
        .PC_PLUS_4(PC_PLUS_4),
        .PC_STALL(PC_STALL), .IF_ID_STALL(IF_ID_STALL),
        .IF_ID_FLUSH(IF_ID_FLUSH), .ID_EX_FLUSH(ID_EX_FLUSH),
        .PC_MUX_SEL(PC_MUX_SEL), .CONTROL_HAZARD(CONTROL_HAZARD)
    );
    
    // Clock
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end
    
    initial begin
        $display("=== Simple Control Hazard Test ===");
        $display("Cycle | Scenario | PC_STALL | IF_ID_STALL | IF_ID_FLUSH | ID_EX_FLUSH | PC_MUX_SEL");
        $display("------|----------|----------|-------------|-------------|-------------|------------");
        
        // Initialize
        RESET = 1; IS_BRANCH_ID = 0; IS_BRANCH_EX = 0; BRANCH_TAKEN = 0;
        BRANCH_TARGET = 32'h2000; PC_PLUS_4 = 32'h1004;
        
        @(posedge CLK);
        RESET = 0;
        @(posedge CLK);
        
        // Test 1: Normal operation
        $display("  1   | Normal   |    %b     |      %b      |      %b      |      %b      |     %b", 
                 PC_STALL, IF_ID_STALL, IF_ID_FLUSH, ID_EX_FLUSH, PC_MUX_SEL);
        
        // Test 2: Branch detected in ID stage
        @(posedge CLK);
        IS_BRANCH_ID = 1;
        @(posedge CLK);
        $display("  2   | Branch ID|    %b     |      %b      |      %b      |      %b      |     %b", 
                 PC_STALL, IF_ID_STALL, IF_ID_FLUSH, ID_EX_FLUSH, PC_MUX_SEL);
        
        // Test 3: Branch in EX stage, taken
        @(posedge CLK);
        IS_BRANCH_ID = 0; IS_BRANCH_EX = 1; BRANCH_TAKEN = 1;
        @(posedge CLK);
        $display("  3   | Br Taken |    %b     |      %b      |      %b      |      %b      |     %b", 
                 PC_STALL, IF_ID_STALL, IF_ID_FLUSH, ID_EX_FLUSH, PC_MUX_SEL);
        
        // Test 4: Branch in EX stage, not taken
        @(posedge CLK);
        BRANCH_TAKEN = 0;
        @(posedge CLK);
        $display("  4   | Br N-Take|    %b     |      %b      |      %b      |      %b      |     %b", 
                 PC_STALL, IF_ID_STALL, IF_ID_FLUSH, ID_EX_FLUSH, PC_MUX_SEL);
        
        $display("\n=== Simple Control Test Complete ===");
        $finish;
    end
    
endmodule
