`timescale 1ns/1ps

module tb_RISC_V_CPU;
    reg CLK;
    reg RESET;

    // Instantiate the CPU
    RISC_V_CPU uut (
        .CLK(CLK),
        .RESET(RESET)
    );

    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // 10ns clock period
    end

    // Test sequence
    initial begin
        $display("Starting RISC-V CPU Simulation...");
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, tb_RISC_V_CPU);

        RESET = 1;
        #10;
        RESET = 0;

        // Run for 1000 clock cycles (10,000ns)
        #600;

        $display("Finished simulation.");
        $finish;
    end

    // Optional monitor: Print internal state at each positive edge
    always @(posedge CLK) begin
        $display("[%0t] PC=%h | IF_PC=%h | ID_PC=%d | EX_PC_4=%d | MA_PC=%b | MA_PC_4=%h | WB_PC=%h",
            $time,  uut.PC_I,uut.IF_INSTR, uut.EX_D1
            , uut.EX_D2, uut.WB_ADD, uut.MA_SIGN, uut.MA_DATA);
    end
endmodule
