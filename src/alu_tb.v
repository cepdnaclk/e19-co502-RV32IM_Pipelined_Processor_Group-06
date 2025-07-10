`timescale 1ns/1ps

module tb_RISC_V_CPU;

    reg CLK;
    reg RESET;

    // Instantiate the CPU
    RISC_V_CPU uut (
        .CLK(CLK),
        .RESET(RESET)
    );

    // Generate clock signal
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;  // 10 ns clock
    end

    // Main test process
    initial begin
        $display("Starting RISC-V CPU Simulation...");
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, tb_RISC_V_CPU);

        RESET = 1;
        #10;
        RESET = 0;

        // Run for 2000 ns (100+ clock cycles)
        #100;

        $display("Finished simulation.");
        $finish;
    end

    // ALU monitor
    always @(posedge CLK) begin
        $display("[%0t] PC=%d | FSEL1=%b| FSD1=%d | FD2=%d | DATA1=%d | DATA2=%d| SELECT=%d | ANSWER=%d | bR_SEL=%d| wb_data=%d", 
            $time,
            uut.IF_PC,
            uut.FDATA1SEL, 
            uut.EX_AL1,
            uut.EX_AL2,
            uut.IF_D1, 
            uut.IF_D2,
            uut.alu.SELECT, 
            uut.alu.RESULT,
            uut.mx1.Input1,
            uut.mx2.Input2);
    end

endmodule
