`timescale 1ns/1ps

module alu_tb();
    // Testbench signals
    reg [31:0] DATA1, DATA2;
    reg [4:0] SELECT;
    wire [31:0] RESULT;
    wire EQUAL, SIGNEDLT, UNSIGNEDLT;
    
    // Test variables
    integer i;
    reg [31:0] expected_result;
    
    // Instantiate the ALU module
    ALU dut (
        .DATA1(DATA1),
        .DATA2(DATA2),
        .RESULT(RESULT),
        .SELECT(SELECT),
        .EQUAL(EQUAL),
        .SIGNEDLT(SIGNEDLT),
        .UNSIGNEDLT(UNSIGNEDLT)
    );
    
    // Task to display test results
    task display_result;
        input [4:0] op_code;
        input [31:0] data1, data2;
        input [31:0] expected;
        input [79:0] operation_name; // 10 characters max
        begin
            #10; // Wait for ALU to compute
            $display("Time: %0t | Op: %s | DATA1: %h | DATA2: %h | RESULT: %h | Expected: %h | EQUAL: %b | SIGNEDLT: %b | UNSIGNEDLT: %b", 
                     $time, operation_name, data1, data2, RESULT, expected, EQUAL, SIGNEDLT, UNSIGNEDLT);
            
            if (RESULT !== expected) begin
                $display("ERROR: Expected %h, got %h", expected, RESULT);
            end
        end
    endtask
    
    // Task to test an operation
    task test_operation;
        input [4:0] op_code;
        input [31:0] data1, data2;
        input [31:0] expected;
        input [79:0] operation_name;
        begin
            DATA1 = data1;
            DATA2 = data2;
            SELECT = op_code;
            display_result(op_code, data1, data2, expected, operation_name);
        end
    endtask
    
    initial begin
        $display("=== ALU Testbench Started ===");
        $display("Time | Operation | DATA1    | DATA2    | RESULT   | Expected | EQ | SLT | ULT");
        $display("-----|-----------|----------|----------|----------|----------|----|----|----");
        
        // Initialize inputs
        DATA1 = 0;
        DATA2 = 0;
        SELECT = 0;
        #5;
        
        // Test 1: Forward operation (FWD_RES)
        test_operation(5'b00000, 32'h12345678, 32'hABCDEF00, 32'hABCDEF00, "FWD");
        
        // Test 2: Addition (ADD_RES)
        test_operation(5'b00001, 32'h00000010, 32'h00000020, 32'h00000030, "ADD");
        test_operation(5'b00001, 32'hFFFFFFFF, 32'h00000001, 32'h00000000, "ADD_OVF");
        
        // Test 3: Subtraction (SUB_RES)
        test_operation(5'b00010, 32'h00000020, 32'h00000010, 32'h00000010, "SUB");
        test_operation(5'b00010, 32'h00000010, 32'h00000020, 32'hFFFFFFF0, "SUB_NEG");
        
        // Test 4: Shift Left Logical (SLL_RES)
        test_operation(5'b00011, 32'h00000001, 32'h00000004, 32'h00000010, "SLL");
        test_operation(5'b00011, 32'hF0F0F0F0, 32'h00000002, 32'hC3C3C3C0, "SLL2");
        
        // Test 5: Set Less Than (SLT_RES)
        test_operation(5'b00100, 32'h00000010, 32'h00000020, 32'h00000001, "SLT_T");
        test_operation(5'b00100, 32'h00000020, 32'h00000010, 32'h00000000, "SLT_F");
        test_operation(5'b00100, 32'hFFFFFFF0, 32'h00000010, 32'h00000001, "SLT_NEG");
        
        // Test 6: Set Less Than Unsigned (SLTU_RES)
        test_operation(5'b00101, 32'h00000010, 32'h00000020, 32'h00000001, "SLTU_T");
        test_operation(5'b00101, 32'hFFFFFFF0, 32'h00000010, 32'h00000000, "SLTU_F");
        
        // Test 7: XOR (XOR_RES)
        test_operation(5'b00110, 32'hF0F0F0F0, 32'h0F0F0F0F, 32'hFFFFFFFF, "XOR");
        test_operation(5'b00110, 32'hAAAAAAAA, 32'hAAAAAAAA, 32'h00000000, "XOR_SAME");
        
        // Test 8: Shift Right Logical (SRL_RES)
        test_operation(5'b00111, 32'h80000000, 32'h00000004, 32'h08000000, "SRL");
        test_operation(5'b00111, 32'hF0F0F0F0, 32'h00000002, 32'h3C3C3C3C, "SRL2");
        
        // Test 9: Shift Right Arithmetic (SRA_RES)
        test_operation(5'b01000, 32'h80000000, 32'h00000004, 32'hF8000000, "SRA");
        test_operation(5'b01000, 32'h7FFFFFFF, 32'h00000004, 32'h07FFFFFF, "SRA_POS");
        
        // Test 10: OR (OR_RES)
        test_operation(5'b01001, 32'hF0F0F0F0, 32'h0F0F0F0F, 32'hFFFFFFFF, "OR");
        test_operation(5'b01001, 32'h00000000, 32'hFFFFFFFF, 32'hFFFFFFFF, "OR_ALL");
        
        // Test 11: AND (AND_RES)
        test_operation(5'b01010, 32'hF0F0F0F0, 32'h0F0F0F0F, 32'h00000000, "AND");
        test_operation(5'b01010, 32'hFFFFFFFF, 32'hAAAAAAAA, 32'hAAAAAAAA, "AND_MASK");
        
        // Test 12: Multiplication (MUL_RES)
        test_operation(5'b01011, 32'h00000010, 32'h00000020, 32'h00000200, "MUL");
        test_operation(5'b01011, 32'hFFFFFFFF, 32'h00000002, 32'hFFFFFFFE, "MUL_NEG");
        
        // Test 13: Multiplication High Signed (MULH_RES)
        test_operation(5'b01100, 32'h80000000, 32'h80000000, 32'h40000000, "MULH");
        
        // Test 14: Multiplication High Signed*Unsigned (MULHSU_RES)
        test_operation(5'b01101, 32'hFFFFFFFF, 32'h80000000, 32'h7FFFFFFF, "MULHSU");
        
        // Test 15: Multiplication High Unsigned (MULHU_RES)
        test_operation(5'b01110, 32'hFFFFFFFF, 32'hFFFFFFFF, 32'hFFFFFFFE, "MULHU");
        
        // Test 16: Division (DIV_RES)
        test_operation(5'b01111, 32'h00000100, 32'h00000010, 32'h00000010, "DIV");
        test_operation(5'b01111, 32'hFFFFFFF0, 32'h00000002, 32'hFFFFFFF8, "DIV_NEG");
        
        // Test 17: Division Unsigned (DIVU_RES)
        test_operation(5'b10000, 32'hFFFFFFF0, 32'h00000002, 32'h7FFFFFF8, "DIVU");
        
        // Test 18: Remainder (REM_RES)
        test_operation(5'b10001, 32'h00000017, 32'h00000005, 32'h00000003, "REM");
        test_operation(5'b10001, 32'hFFFFFFF9, 32'h00000005, 32'hFFFFFFFE, "REM_NEG");
        
        // Test 19: Remainder Unsigned (REMU_RES)
        test_operation(5'b10010, 32'h00000017, 32'h00000005, 32'h00000003, "REMU");
        
        // Test 20: Default case
        test_operation(5'b11111, 32'h12345678, 32'hABCDEF00, 32'h00000000, "DEFAULT");
        
        // Special tests for flag outputs
        $display("\n=== Testing Flag Outputs ===");
        
        // Test EQUAL flag
        DATA1 = 32'h12345678;
        DATA2 = 32'h12345678;
        SELECT = 5'b00010; // SUB operation should give 0
        #10;
        $display("EQUAL test (same values): DATA1=%h, DATA2=%h, RESULT=%h, EQUAL=%b (should be 1)", 
                 DATA1, DATA2, RESULT, EQUAL);
        
        // Test SIGNEDLT flag
        DATA1 = 32'hFFFFFFF0; // -16 in signed
        DATA2 = 32'h00000010; // +16
        SELECT = 5'b00010; // SUB operation
        #10;
        $display("SIGNEDLT test (negative result): DATA1=%h, DATA2=%h, RESULT=%h, SIGNEDLT=%b (should be 1)", 
                 DATA1, DATA2, RESULT, SIGNEDLT);
        
        // Test UNSIGNEDLT flag
        DATA1 = 32'h00000010;
        DATA2 = 32'h00000020;
        SELECT = 5'b00101; // SLTU operation
        #10;
        $display("UNSIGNEDLT test: DATA1=%h, DATA2=%h, RESULT=%h, UNSIGNEDLT=%b (should be 1)", 
                 DATA1, DATA2, RESULT, UNSIGNEDLT);
        
        $display("\n=== ALU Testbench Completed ===");
        $finish;
    end
    
    // Generate VCD file for waveform viewing
    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
    end
    
endmodule
