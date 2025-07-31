`timescale 1ns/1ps

module hazard_unit_tb();
    // Testbench signals
    reg [4:0] ADDR1, ADDR2, EXRD, MEMRD;
    reg EXWE, MEMWE, EXMEMR;
    wire [1:0] FDATA1SEL, FDATA2SEL;
    wire BUBBLE, STALL;
    
    // Instantiate the hazard unit
    HAZARD_UNIT dut (
        .ADDR1(ADDR1), .ADDR2(ADDR2),
        .EXRD(EXRD), .MEMRD(MEMRD),
        .EXWE(EXWE), .MEMWE(MEMWE), .EXMEMR(EXMEMR),
        .FDATA1SEL(FDATA1SEL), .FDATA2SEL(FDATA2SEL),
        .BUBBLE(BUBBLE), .STALL(STALL)
    );
    
    // Task to test hazard scenarios
    task test_hazard;
        input [4:0] addr1, addr2, exrd, memrd;
        input exwe, memwe, exmemr;
        input [127:0] test_name;
        begin
            ADDR1 = addr1; ADDR2 = addr2;
            EXRD = exrd; MEMRD = memrd;
            EXWE = exwe; MEMWE = memwe; EXMEMR = exmemr;
            #10;
            $display("Test: %0s", test_name);
            $display("  Inputs: ADDR1=%d, ADDR2=%d, EXRD=%d, MEMRD=%d", addr1, addr2, exrd, memrd);
            $display("  Control: EXWE=%b, MEMWE=%b, EXMEMR=%b", exwe, memwe, exmemr);
            $display("  Output: FDATA1SEL=%b, FDATA2SEL=%b, BUBBLE=%b, STALL=%b", 
                     FDATA1SEL, FDATA2SEL, BUBBLE, STALL);
            $display("  Action: %s", 
                     BUBBLE ? "STALL PIPELINE" : 
                     (FDATA1SEL != 2'b00 || FDATA2SEL != 2'b00) ? "FORWARD DATA" : "NO HAZARD");
            $display("");
        end
    endtask
    
    initial begin
        $display("=== Hazard Unit Testbench ===");
        $display("Testing different hazard scenarios in RISC-V pipeline\n");
        
        // Test 1: No hazard
        test_hazard(5'd1, 5'd2, 5'd3, 5'd4, 1'b1, 1'b1, 1'b0, 
                   "No Hazard - Different registers");
        
        // Test 2: EX stage ALU forwarding (EX->ID)
        test_hazard(5'd3, 5'd2, 5'd3, 5'd4, 1'b1, 1'b1, 1'b0,
                   "EX Stage Forwarding - ADD x3,x1,x2; SUB x4,x3,x1");
        
        // Test 3: MEM stage forwarding (MEM->ID)
        test_hazard(5'd3, 5'd2, 5'd1, 5'd3, 1'b1, 1'b1, 1'b0,
                   "MEM Stage Forwarding - Previous instruction result");
        
        // Test 4: Load-use hazard (requires stall)
        test_hazard(5'd3, 5'd2, 5'd3, 5'd4, 1'b1, 1'b1, 1'b1,
                   "Load-Use Hazard - LW x3,0(x1); ADD x4,x3,x2");
        
        // Test 5: Both operands need forwarding
        test_hazard(5'd3, 5'd4, 5'd3, 5'd4, 1'b1, 1'b1, 1'b0,
                   "Both Operands Forward - EX:x3, MEM:x4");
        
        // Test 6: Register x0 (should not forward)
        test_hazard(5'd0, 5'd2, 5'd0, 5'd4, 1'b1, 1'b1, 1'b0,
                   "Register x0 Test - Should not forward");
        
        // Test 7: Multiple hazards with priority
        test_hazard(5'd3, 5'd3, 5'd3, 5'd3, 1'b1, 1'b1, 1'b1,
                   "Load-Use with Multiple Conflicts");
        
        // Test 8: Write enable disabled
        test_hazard(5'd3, 5'd2, 5'd3, 5'd4, 1'b0, 1'b0, 1'b0,
                   "Write Disabled - No hazard even with matching registers");
        
        $display("=== Hazard Unit Test Complete ===");
        $finish;
    end
    
    // Generate VCD file
    initial begin
        $dumpfile("hazard_unit_tb.vcd");
        $dumpvars(0, hazard_unit_tb);
    end
    
endmodule
