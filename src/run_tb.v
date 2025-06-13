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
        #100;

        $display("Finished simulation.");
        $finish;
    end

    // Optional monitor: Print internal state at each positive edge
    always @(posedge CLK) begin
        $display("[%0t] PC=%h | IF_PC=%h | ID_PC=%h | EX_PC_4=%h | MA_PC=%h | MA_PC_4=%h | WB_PC=%h",
            $time,  uut.PC_I,uut.IF_PC, uut.ID_PC
            , uut.EX_PC, uut.MA_PC, uut.MA_PC_4, uut.WB_PC);
    end
endmodule
