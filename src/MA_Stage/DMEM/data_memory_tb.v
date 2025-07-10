`timescale 1ns/1ps

module data_memory_tb();
    // Testbench signals
    reg CLK;
    reg RESET;
    reg [1:0] WRITE, READ;
    reg [31:0] ADDR, DATA_IN;
    wire [31:0] DATA_OUT;
    
    // Instantiate the DATA_MEMORY module
    DATA_MEMORY dut (
        .CLK(CLK),
        .RESET(RESET),
        .WRITE(WRITE),
        .READ(READ),
        .ADDR(ADDR),
        .DATA_IN(DATA_IN),
        .DATA_OUT(DATA_OUT)
    );
    
    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // 10ns period (100MHz)
    end
    
    // Task to perform write operation
    task write_memory;
        input [1:0] write_type;
        input [31:0] address;
        input [31:0] data;
        input [63:0] test_name; // 8 characters
        begin
            @(posedge CLK);
            WRITE = write_type;
            READ = 2'b00;
            ADDR = address;
            DATA_IN = data;
            @(posedge CLK);
            WRITE = 2'b00;
            $display("WRITE %0s: Addr=%h, Data=%h, Type=%b", test_name, address, data, write_type);
        end
    endtask
    
    // Task to perform read operation
    task read_memory;
        input [1:0] read_type;
        input [31:0] address;
        input [31:0] expected;
        input [63:0] test_name; // 8 characters
        begin
            @(posedge CLK);
            READ = read_type;
            WRITE = 2'b00;
            ADDR = address;
            @(posedge CLK);
            #1; // Wait for combinational logic
            $display("READ  %0s: Addr=%h, Data=%h, Expected=%h, Type=%b %s", 
                     test_name, address, DATA_OUT, expected, read_type,
                     (DATA_OUT == expected) ? "PASS" : "FAIL");
            READ = 2'b00;
        end
    endtask
    
    initial begin
        $display("=== Data Memory Testbench Started ===");
        $display("Operation | Address  | Data     | Expected | Type | Result");
        $display("----------|----------|----------|----------|------|-------");
        
        // Initialize signals
        RESET = 1;
        WRITE = 2'b00;
        READ = 2'b00;
        ADDR = 32'h00000000;
        DATA_IN = 32'h00000000;
        
        // Apply reset
        repeat(3) @(posedge CLK);
        RESET = 0;
        repeat(2) @(posedge CLK);
        
        $display("\n=== Testing Word Operations (32-bit) ===");
        
        // Test word write and read
        write_memory(2'b11, 32'h00000000, 32'hDEADBEEF, "WORD_W1");
        read_memory(2'b11, 32'h00000000, 32'hDEADBEEF, "WORD_R1");
        
        write_memory(2'b11, 32'h00000004, 32'hCAFEBABE, "WORD_W2");
        read_memory(2'b11, 32'h00000004, 32'hCAFEBABE, "WORD_R2");
        
        write_memory(2'b11, 32'h00000008, 32'h12345678, "WORD_W3");
        read_memory(2'b11, 32'h00000008, 32'h12345678, "WORD_R3");
        
        // Test unaligned word access (should return 0 or not work)
        read_memory(2'b11, 32'h00000001, 32'h00000000, "WORD_UA");
        read_memory(2'b11, 32'h00000002, 32'h00000000, "WORD_UB");
        read_memory(2'b11, 32'h00000003, 32'h00000000, "WORD_UC");
        
        $display("\n=== Testing Half-word Operations (16-bit) ===");
        
        // Test half-word write and read
        write_memory(2'b10, 32'h00000010, 32'h0000ABCD, "HALF_W1");
        read_memory(2'b10, 32'h00000010, 32'h0000ABCD, "HALF_R1");
        
        write_memory(2'b10, 32'h00000012, 32'h0000EF12, "HALF_W2");
        read_memory(2'b10, 32'h00000012, 32'h0000EF12, "HALF_R2");
        
        // Read the full word to verify both halves
        read_memory(2'b11, 32'h00000010, 32'hEF12ABCD, "HALF_FW");
        
        // Test unaligned half-word access
        read_memory(2'b10, 32'h00000011, 32'h00000000, "HALF_UA");
        read_memory(2'b10, 32'h00000013, 32'h00000000, "HALF_UB");
        
        $display("\n=== Testing Byte Operations (8-bit) ===");
        
        // Test byte write and read at different positions
        write_memory(2'b01, 32'h00000020, 32'h000000AA, "BYTE_W0");  // Byte 0
        read_memory(2'b01, 32'h00000020, 32'h000000AA, "BYTE_R0");
        
        write_memory(2'b01, 32'h00000021, 32'h000000BB, "BYTE_W1");  // Byte 1
        read_memory(2'b01, 32'h00000021, 32'h000000BB, "BYTE_R1");
        
        write_memory(2'b01, 32'h00000022, 32'h000000CC, "BYTE_W2");  // Byte 2
        read_memory(2'b01, 32'h00000022, 32'h000000CC, "BYTE_R2");
        
        write_memory(2'b01, 32'h00000023, 32'h000000DD, "BYTE_W3");  // Byte 3
        read_memory(2'b01, 32'h00000023, 32'h000000DD, "BYTE_R3");
        
        // Read the full word to verify all bytes
        read_memory(2'b11, 32'h00000020, 32'hDDCCBBAA, "BYTE_FW");
        
        $display("\n=== Testing Mixed Operations ===");
        
        // Write a word, then read as bytes
        write_memory(2'b11, 32'h00000030, 32'h12345678, "MIX_WW");
        read_memory(2'b01, 32'h00000030, 32'h00000078, "MIX_RB0"); // LSB
        read_memory(2'b01, 32'h00000031, 32'h00000056, "MIX_RB1");
        read_memory(2'b01, 32'h00000032, 32'h00000034, "MIX_RB2");
        read_memory(2'b01, 32'h00000033, 32'h00000012, "MIX_RB3"); // MSB
        
        // Write a word, then read as half-words
        read_memory(2'b10, 32'h00000030, 32'h00005678, "MIX_RH0"); // Lower half
        read_memory(2'b10, 32'h00000032, 32'h00001234, "MIX_RH1"); // Upper half
        
        $display("\n=== Testing Reset Functionality ===");
        
        // Reset the memory
        RESET = 1;
        repeat(2) @(posedge CLK);
        
        // All reads should return 0 during reset
        read_memory(2'b11, 32'h00000000, 32'h00000000, "RST_R1");
        read_memory(2'b11, 32'h00000004, 32'h00000000, "RST_R2");
        
        // Release reset
        RESET = 0;
        repeat(2) @(posedge CLK);
        
        // Memory should be cleared
        read_memory(2'b11, 32'h00000000, 32'h00000000, "CLR_R1");
        read_memory(2'b11, 32'h00000004, 32'h00000000, "CLR_R2");
        
        $display("\n=== Testing Edge Cases ===");
        
        // Test boundary addresses
        write_memory(2'b11, 32'h00000FFC, 32'hFFFFFFFF, "EDGE_W1"); // Last word
        read_memory(2'b11, 32'h00000FFC, 32'hFFFFFFFF, "EDGE_R1");
        
        // Test no operation cases
        @(posedge CLK);
        WRITE = 2'b00;
        READ = 2'b00;
        ADDR = 32'h00000040;
        @(posedge CLK);
        #1;
        $display("NO_OP: DATA_OUT = %h (should be previous value or 0)", DATA_OUT);
        
        $display("\n=== Data Memory Testbench Completed ===");
        $finish;
    end
    
    // Generate VCD file for waveform viewing
    initial begin
        $dumpfile("data_memory_tb.vcd");
        $dumpvars(0, data_memory_tb);
    end
    
endmodule
