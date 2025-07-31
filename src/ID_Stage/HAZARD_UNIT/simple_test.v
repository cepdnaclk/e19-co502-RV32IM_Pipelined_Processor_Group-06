`timescale 1ns/1ps

module simple_hazard_test();
    reg [4:0] ADDR1, ADDR2, EXRD, MEMRD;
    reg EXWE, MEMWE, EXMEMR;
    wire FDATA1SEL, FDATA2SEL, BUBBLE, STALL;
    
    // Test the original hazard unit
    HAZARD_UNIT dut (
        .ADDR1(ADDR1), .ADDR2(ADDR2),
        .EXRD(EXRD), .MEMRD(MEMRD),
        .EXWE(EXWE), .MEMWE(MEMWE), .EXMEMR(EXMEMR),
        .FDATA1SEL(FDATA1SEL), .FDATA2SEL(FDATA2SEL),
        .BUBBLE(BUBBLE), .STALL(STALL)
    );
    
    initial begin
        $display("=== Simple Hazard Unit Test ===");
        
        // Test 1: No hazard
        ADDR1 = 5'd1; ADDR2 = 5'd2; EXRD = 5'd3; MEMRD = 5'd4;
        EXWE = 1'b1; MEMWE = 1'b1; EXMEMR = 1'b0;
        #10;
        $display("Test 1 - No Hazard: FDATA1SEL=%b, FDATA2SEL=%b, BUBBLE=%b, STALL=%b", 
                 FDATA1SEL, FDATA2SEL, BUBBLE, STALL);
        
        // Test 2: EX stage hazard
        ADDR1 = 5'd3; ADDR2 = 5'd2; EXRD = 5'd3; MEMRD = 5'd4;
        EXWE = 1'b1; MEMWE = 1'b1; EXMEMR = 1'b0;
        #10;
        $display("Test 2 - EX Hazard: FDATA1SEL=%b, FDATA2SEL=%b, BUBBLE=%b, STALL=%b", 
                 FDATA1SEL, FDATA2SEL, BUBBLE, STALL);
        
        // Test 3: Load-use hazard
        ADDR1 = 5'd3; ADDR2 = 5'd2; EXRD = 5'd3; MEMRD = 5'd4;
        EXWE = 1'b1; MEMWE = 1'b1; EXMEMR = 1'b1;
        #10;
        $display("Test 3 - Load-Use: FDATA1SEL=%b, FDATA2SEL=%b, BUBBLE=%b, STALL=%b", 
                 FDATA1SEL, FDATA2SEL, BUBBLE, STALL);
        
        $display("\n=== Test Complete ===");
        $finish;
    end
    
endmodule
