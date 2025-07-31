`timescale 1ns/1ps

module control_hazard_tb();
    reg CLK, RESET;
    reg [4:0] ADDR1, ADDR2, EXRD, MEMRD;
    reg EXWE, MEMWE, EXMEMR;
    reg IS_BRANCH_ID, IS_BRANCH_EX, BRANCH_TAKEN;
    reg [31:0] BRANCH_TARGET;
    
    wire [1:0] FDATA1SEL, FDATA2SEL;
    wire PC_STALL, IF_ID_STALL, IF_ID_FLUSH, ID_EX_FLUSH, PC_MUX_SEL;
    wire DATA_HAZARD, CONTROL_HAZARD, PIPELINE_STALL;
    
    // Instantiate enhanced hazard unit
    ENHANCED_HAZARD_UNIT dut (
        .CLK(CLK), .RESET(RESET),
        .ADDR1(ADDR1), .ADDR2(ADDR2), .EXRD(EXRD), .MEMRD(MEMRD),
        .EXWE(EXWE), .MEMWE(MEMWE), .EXMEMR(EXMEMR),
        .IS_BRANCH_ID(IS_BRANCH_ID), .IS_BRANCH_EX(IS_BRANCH_EX),
        .BRANCH_TAKEN(BRANCH_TAKEN), .BRANCH_TARGET(BRANCH_TARGET),
        .FDATA1SEL(FDATA1SEL), .FDATA2SEL(FDATA2SEL),
        .PC_STALL(PC_STALL), .IF_ID_STALL(IF_ID_STALL),
        .IF_ID_FLUSH(IF_ID_FLUSH), .ID_EX_FLUSH(ID_EX_FLUSH),
        .PC_MUX_SEL(PC_MUX_SEL),
        .DATA_HAZARD(DATA_HAZARD), .CONTROL_HAZARD(CONTROL_HAZARD),
        .PIPELINE_STALL(PIPELINE_STALL)
    );
    
    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end
    
    // Test scenarios
    initial begin
        $display("=== Control Hazard Unit Test ===");
        $display("Time | Scenario | PC_STALL | IF_ID_STALL | IF_ID_FLUSH | ID_EX_FLUSH | PC_MUX | Hazard");
        $display("-----|----------|----------|-------------|-------------|-------------|--------|-------");
        
        // Initialize
        RESET = 1;
        ADDR1 = 0; ADDR2 = 0; EXRD = 0; MEMRD = 0;
        EXWE = 0; MEMWE = 0; EXMEMR = 0;
        IS_BRANCH_ID = 0; IS_BRANCH_EX = 0; BRANCH_TAKEN = 0;
        BRANCH_TARGET = 32'h1000;
        
        @(posedge CLK);
        RESET = 0;
        @(posedge CLK);
        
        // Test 1: No hazard
        $display("%4t | No Hazard | %8b | %11b | %11b | %11b | %6b | %s", 
                 $time, PC_STALL, IF_ID_STALL, IF_ID_FLUSH, ID_EX_FLUSH, PC_MUX_SEL,
                 CONTROL_HAZARD ? "CONTROL" : DATA_HAZARD ? "DATA" : "NONE");
        
        // Test 2: Branch in ID stage (should stall)
        @(posedge CLK);
        IS_BRANCH_ID = 1;
        @(posedge CLK);
        $display("%4t | Branch ID | %8b | %11b | %11b | %11b | %6b | %s", 
                 $time, PC_STALL, IF_ID_STALL, IF_ID_FLUSH, ID_EX_FLUSH, PC_MUX_SEL,
                 CONTROL_HAZARD ? "CONTROL" : DATA_HAZARD ? "DATA" : "NONE");
        
        // Test 3: Branch moves to EX stage, taken
        @(posedge CLK);
        IS_BRANCH_ID = 0;
        IS_BRANCH_EX = 1;
        BRANCH_TAKEN = 1;
        @(posedge CLK);
        $display("%4t | Br Taken | %8b | %11b | %11b | %11b | %6b | %s", 
                 $time, PC_STALL, IF_ID_STALL, IF_ID_FLUSH, ID_EX_FLUSH, PC_MUX_SEL,
                 CONTROL_HAZARD ? "CONTROL" : DATA_HAZARD ? "DATA" : "NONE");
        
        // Test 4: Branch moves to EX stage, not taken
        @(posedge CLK);
        BRANCH_TAKEN = 0;
        @(posedge CLK);
        $display("%4t | Br N-Take| %8b | %11b | %11b | %11b | %6b | %s", 
                 $time, PC_STALL, IF_ID_STALL, IF_ID_FLUSH, ID_EX_FLUSH, PC_MUX_SEL,
                 CONTROL_HAZARD ? "CONTROL" : DATA_HAZARD ? "DATA" : "NONE");
        
        // Test 5: Data hazard with branch resolved
        @(posedge CLK);
        IS_BRANCH_EX = 0;
        ADDR1 = 5'd3; EXRD = 5'd3; EXWE = 1; EXMEMR = 1; // Load-use hazard
        @(posedge CLK);
        $display("%4t | Load-Use | %8b | %11b | %11b | %11b | %6b | %s", 
                 $time, PC_STALL, IF_ID_STALL, IF_ID_FLUSH, ID_EX_FLUSH, PC_MUX_SEL,
                 CONTROL_HAZARD ? "CONTROL" : DATA_HAZARD ? "DATA" : "NONE");
        
        // Test 6: Data forwarding
        @(posedge CLK);
        EXMEMR = 0; // No memory read, can forward
        @(posedge CLK);
        $display("%4t | Forward  | %8b | %11b | %11b | %11b | %6b | %s | FDATA1SEL=%b", 
                 $time, PC_STALL, IF_ID_STALL, IF_ID_FLUSH, ID_EX_FLUSH, PC_MUX_SEL,
                 CONTROL_HAZARD ? "CONTROL" : DATA_HAZARD ? "DATA" : "NONE", FDATA1SEL);
        
        $display("\n=== Control Hazard Test Complete ===");
        $finish;
    end
    
    // Monitor for VCD
    initial begin
        $dumpfile("control_hazard_tb.vcd");
        $dumpvars(0, control_hazard_tb);
    end
    
endmodule
