`timescale 1ns/1ps

module inst_mem_tb();
    reg CLK, RESET;
    reg [31:0] ADDR;
    wire [31:0] INSTRUCTION;

    // Instantiate the INSTRUCTION_MEMORY module
    INSTRUCTION_MEMORY instr_mem (
        .CLK(CLK),
        .RESET(RESET),
        .ADDR(ADDR),
        .INSTRUCTION(INSTRUCTION)
    );

    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // 10ns period (100MHz)
    end

    // Test sequence
    initial begin
        $display("Time | RESET | ADDR     | INSTRUCTION");
        $display("-----|-------|----------|------------");
        $monitor("%4t |   %b   | %8h | %8h", 
            $time, RESET, ADDR, INSTRUCTION);

        // Initialize signals
        RESET = 1;
        ADDR = 32'h00000000;
        
        // Apply reset
        #20;
        RESET = 0;
        
        // Test reading different addresses
        #10;
        ADDR = 32'h00000000; // First instruction
        #10;
        ADDR = 32'h00000004; // Second instruction (word-aligned)
        #10;
        ADDR = 32'h00000008; // Third instruction
        #10;
        ADDR = 32'h0000000C; // Fourth instruction
        #10;
        ADDR = 32'h00000010; // Fifth instruction
        #10;
        ADDR = 32'h00000014; // Sixth instruction
        #10;
        ADDR = 32'h00000018; // Seventh instruction
        #10;
        ADDR = 32'h0000001C; // Eighth instruction
        #10;
        ADDR = 32'h00000020; // Ninth instruction
        #10;
        
        // Test some higher addresses
        ADDR = 32'h00000040; // Address 64 (16th instruction)
        #10;
        ADDR = 32'h00000044; // Address 68 (17th instruction)
        #10;
        ADDR = 32'h00000048; // Address 72 (18th instruction)
        #10;

        // Test reset functionality
        $display("\n--- Testing RESET functionality ---");
        RESET = 1;
        #10;
        ADDR = 32'h00000000;
        #10;
        RESET = 0;
        #10;

        $display("\n--- Test completed ---");
        $finish;
    end

    // Generate VCD file for waveform viewing
    initial begin
        $dumpfile("inst_mem_tb.vcd");
        $dumpvars(0, inst_mem_tb);
    end

endmodule
