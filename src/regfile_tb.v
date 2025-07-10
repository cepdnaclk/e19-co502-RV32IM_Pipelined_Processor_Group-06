`timescale 1ns/1ps

module reg_file_tb;

    // Inputs
    reg [31:0] IN;
    reg [4:0] ADDR1, ADDR2, ADDRW;
    reg WRITE, CLK, RESET;

    // Outputs
    wire [31:0] OUT1, OUT2;

    // Instantiate the reg_file module
    reg_file uut (
        .IN(IN),
        .OUT1(OUT1),
        .OUT2(OUT2),
        .ADDR1(ADDR1),
        .ADDR2(ADDR2),
        .ADDRW(ADDRW),
        .WRITE(WRITE),
        .CLK(CLK),
        .RESET(RESET)
    );

    // Clock generator: Toggle every 5ns
    always #5 CLK = ~CLK;

    initial begin
        // Initial values
        CLK = 0;
        RESET = 0;
        WRITE = 0;
        IN = 0;
        ADDR1 = 0;
        ADDR2 = 0;
        ADDRW = 0;

        // Start of simulation
        $display("Time\tWRITE\tADDRW\tIN\tADDR1\tADDR2\tOUT1\tOUT2");

        // Reset the register file
        RESET = 1;
        #10;
        RESET = 0;

        // Write 42 to register x5
        IN = 32'd42;
        ADDRW = 5'd5;
        WRITE = 1;
        #10;

        // Write 99 to register x10
        IN = 32'd99;
        ADDRW = 5'd10;
        #10;

        // Disable write
        WRITE = 0;

        // Read from registers x5 and x10
        ADDR1 = 5'd5;
        ADDR2 = 5'd10;
        #10;

        $display("%0t\t%b\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d",
                 $time, WRITE, ADDRW, IN, ADDR1, ADDR2, OUT1, OUT2);

        // Another read example (registers with no writes, should be 0)
        ADDR1 = 5'd0;
        ADDR2 = 5'd1;
        #10;

        $display("%0t\t%b\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d",
                 $time, WRITE, ADDRW, IN, ADDR1, ADDR2, OUT1, OUT2);

        $finish;
    end

endmodule
