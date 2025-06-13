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
        #500;

        $display("Finished simulation.");
        $finish;
    end

    // ALU monitor
    always @(posedge CLK) begin
        $display("[%0t] PC=%d | ISR=%h| ALU_OP=%b | imme=%b | DATA1=%h | DATA2=%h | SELECT=%h | ANSWER=%h | bR_SEL=%h | wb_data=%b", 
            $time,
            uut.IF_PC,
            uut.IFD_INSTR, 
            uut.EX_ALU,
            uut.IMME_SELECT,
            uut.alu.DATA1, 
            uut.alu.DATA2,
            uut.alu.SELECT, 
            uut.alu.RESULT,
            uut.MUX_OUT,
            uut.WB_ADD);
    end

endmodule
