`timescale 1ns/1ps

module branch_selector_tb();
    // Testbench signals
    reg [31:0] DATA1, DATA2;
    reg [2:0] BRANCH_TYPE;
    wire BRANCH_TAKEN;
    
    // Instantiate the branch selector
    BRANCH_SELECTOR dut (
        .DATA1(DATA1),
        .DATA2(DATA2),
        .BRANCH_TYPE(BRANCH_TYPE),
        .BRANCH_TAKEN(BRANCH_TAKEN)
    );
    
    // Task to test branch operations
    task test_branch;
        input [2:0] branch_type;
        input [31:0] data1, data2;
        input expected;
        input [31:0] test_name; // 4 characters
        begin
            DATA1 = data1;
            DATA2 = data2;
            BRANCH_TYPE = branch_type;
            #10;
            $display("Time: %0t | Test: %0s | DATA1: %h | DATA2: %h | Type: %b | BRANCH_TAKEN: %b | Expected: %b | %s", 
                     $time, test_name, data1, data2, branch_type, BRANCH_TAKEN, expected, 
                     (BRANCH_TAKEN == expected) ? "PASS" : "FAIL");
        end
    endtask
    
    initial begin
        $display("=== Branch Selector Testbench Started ===");
        $display("Time | Test | DATA1    | DATA2    | Type | BRANCH | Expected | Result");
        $display("-----|------|----------|----------|------|--------|----------|-------");
        
        // Initialize
        DATA1 = 0;
        DATA2 = 0;
        BRANCH_TYPE = 0;
        #5;
        
        // Test BEQ (Branch if Equal) - Type 000
        test_branch(3'b000, 32'h12345678, 32'h12345678, 1'b1, "BEQ1"); // Equal values
        test_branch(3'b000, 32'h12345678, 32'h87654321, 1'b0, "BEQ2"); // Different values
        test_branch(3'b000, 32'h00000000, 32'h00000000, 1'b1, "BEQ3"); // Zero values
        
        // Test BNE (Branch if Not Equal) - Type 001
        test_branch(3'b001, 32'h12345678, 32'h87654321, 1'b1, "BNE1"); // Different values
        test_branch(3'b001, 32'h12345678, 32'h12345678, 1'b0, "BNE2"); // Equal values
        test_branch(3'b001, 32'hFFFFFFFF, 32'h00000000, 1'b1, "BNE3"); // Max vs Min
        
        // Test BLT (Branch if Less Than - Signed) - Type 100
        test_branch(3'b100, 32'h00000010, 32'h00000020, 1'b1, "BLT1"); // 16 < 20 (both positive)
        test_branch(3'b100, 32'h00000020, 32'h00000010, 1'b0, "BLT2"); // 20 > 16 (both positive)
        test_branch(3'b100, 32'hFFFFFFF0, 32'h00000010, 1'b1, "BLT3"); // -16 < 16 (negative vs positive)
        test_branch(3'b100, 32'h00000010, 32'hFFFFFFF0, 1'b0, "BLT4"); // 16 > -16 (positive vs negative)
        test_branch(3'b100, 32'hFFFFFFE0, 32'hFFFFFFF0, 1'b1, "BLT5"); // -32 < -16 (both negative)
        test_branch(3'b100, 32'h12345678, 32'h12345678, 1'b0, "BLT6"); // Equal values
        
        // Test BGE (Branch if Greater or Equal - Signed) - Type 101
        test_branch(3'b101, 32'h00000020, 32'h00000010, 1'b1, "BGE1"); // 20 >= 16
        test_branch(3'b101, 32'h00000010, 32'h00000010, 1'b1, "BGE2"); // 16 >= 16 (equal)
        test_branch(3'b101, 32'h00000010, 32'h00000020, 1'b0, "BGE3"); // 16 < 20
        test_branch(3'b101, 32'h00000010, 32'hFFFFFFF0, 1'b1, "BGE4"); // 16 >= -16
        test_branch(3'b101, 32'hFFFFFFF0, 32'hFFFFFFE0, 1'b1, "BGE5"); // -16 >= -32
        
        // Test BLTU (Branch if Less Than - Unsigned) - Type 110
        test_branch(3'b110, 32'h00000010, 32'h00000020, 1'b1, "BLTU1"); // 16 < 20 (unsigned)
        test_branch(3'b110, 32'h00000020, 32'h00000010, 1'b0, "BLTU2"); // 20 > 16 (unsigned)
        test_branch(3'b110, 32'h00000010, 32'hFFFFFFF0, 1'b1, "BLTU3"); // 16 < 4294967280 (unsigned)
        test_branch(3'b110, 32'hFFFFFFF0, 32'h00000010, 1'b0, "BLTU4"); // 4294967280 > 16 (unsigned)
        test_branch(3'b110, 32'h12345678, 32'h12345678, 1'b0, "BLTU5"); // Equal values
        
        // Test BGEU (Branch if Greater or Equal - Unsigned) - Type 111
        test_branch(3'b111, 32'h00000020, 32'h00000010, 1'b1, "BGEU1"); // 20 >= 16 (unsigned)
        test_branch(3'b111, 32'h00000010, 32'h00000010, 1'b1, "BGEU2"); // 16 >= 16 (equal)
        test_branch(3'b111, 32'h00000010, 32'h00000020, 1'b0, "BGEU3"); // 16 < 20 (unsigned)
        test_branch(3'b111, 32'hFFFFFFF0, 32'h00000010, 1'b1, "BGEU4"); // 4294967280 >= 16 (unsigned)
        test_branch(3'b111, 32'h00000010, 32'hFFFFFFF0, 1'b0, "BGEU5"); // 16 < 4294967280 (unsigned)
        
        // Test undefined branch type (should not branch)
        test_branch(3'b010, 32'h12345678, 32'h87654321, 1'b0, "UND1"); // Undefined type
        test_branch(3'b011, 32'h00000010, 32'h00000020, 1'b0, "UND2"); // Undefined type
        
        // Edge case tests
        $display("\n=== Edge Case Tests ===");
        test_branch(3'b000, 32'hFFFFFFFF, 32'hFFFFFFFF, 1'b1, "EDG1"); // BEQ with all 1s
        test_branch(3'b100, 32'h80000000, 32'h7FFFFFFF, 1'b1, "EDG2"); // BLT: most negative < most positive
        test_branch(3'b110, 32'h80000000, 32'h7FFFFFFF, 1'b0, "EDG3"); // BLTU: most negative > most positive (unsigned)
        
        $display("\n=== Branch Selector Testbench Completed ===");
        $finish;
    end
    
    // Generate VCD file for waveform viewing
    initial begin
        $dumpfile("branch_selector_tb.vcd");
        $dumpvars(0, branch_selector_tb);
    end
    
endmodule
