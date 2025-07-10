`timescale 1ns/1ps

module Data_Memory_TB;

    reg CLK, RESET, WRITEENABLE;
    reg [31:0] ADDR, DATA_IN;
    wire [31:0] DATA_OUT;

    // Instantiate the memory module
    Data_Memory mem_inst(
        .CLK(CLK),
        .RESET(RESET),
        .WRITEENABLE(WRITEENABLE),
        .ADDR(ADDR),
        .DATA_IN(DATA_IN),
        .DATA_OUT(DATA_OUT)
    );

    // Clock generation
    always #5 CLK = ~CLK;

    initial begin
        // Initialize inputs
        CLK = 0;
        RESET = 1;
        WRITEENABLE = 0;
        ADDR = 0;
        DATA_IN = 0;

        $display("Time | WRITE | ADDR | DATA_IN | DATA_OUT");
        $monitor("%4t |   %b   | %d   | %d      | %h", $time, WRITEENABLE, ADDR, DATA_IN, DATA_OUT);

        // Write 100 to address 10
        #10;
        ADDR = 10;
        DATA_IN = 100;
        WRITEENABLE = 1;
        #10;

        // Write 55 to address 20
        ADDR = 20;
        DATA_IN = 55;
        #10;

        // Disable write, enable read
        WRITEENABLE = 0;

        // Read from address 10
        #10;
        ADDR = 10;

        // Read from address 20
        #10;
        ADDR = 20;

        // Read from address 0 (default)
        #10;
        ADDR = 0;

        ADDR = 1;

        $finish;
    end

endmodule
