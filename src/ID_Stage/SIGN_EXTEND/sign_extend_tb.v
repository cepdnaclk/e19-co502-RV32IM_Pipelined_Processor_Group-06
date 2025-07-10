`timescale 1ns/1ps

module sign_extend_tb;

    reg  [31:0] INST;
    reg  [3:0]  IMM_SEL;
    wire [31:0] IMM_EXT;

    SIGN_EXTEND uut (
        .INST(INST),
        .IMM_SEL(IMM_SEL),
        .IMM_EXT(IMM_EXT)
    );

    // Helper task to display results
    task check;
        input [31:0] expected;
        begin
            #1;
            if (IMM_EXT !== expected) begin
                $display("FAIL: INST=%h IMM_SEL=%b -> IMM_EXT=%h (expected %h)", INST, IMM_SEL, IMM_EXT, expected);
            end else begin
                $display("PASS: INST=%h IMM_SEL=%b -> IMM_EXT=%h", INST, IMM_SEL, IMM_EXT);
            end
        end
    endtask

    initial begin
        // U-type: LUI (e.g., 0x12345000)
        INST = 32'h12345000;
        IMM_SEL = 3'b000;
        #1;
        check(32'h12345000);

        // J-type: JAL (signed offset)
        INST = 32'b10000000010000000000000011011111; // 32 bits, sign bit set
        IMM_SEL = 3'b001;
        #1;
        check(32'hfff80000); 

        // I-type: ADDI (signed)
        INST = 32'b1111111111110000000000000010011; // 32 bits, -1 immediate
        IMM_SEL = 3'b010;
        #1;
        check(32'hffffffff);

        // I-type: SLLI (unsigned, logical shift)
        INST = 32'b00000000000100000001000000010011; // 32 bits, shamt=1
        IMM_SEL = 3'b010; // signed
        #1;
        check(32'h00000001);
        IMM_SEL = 3'b110; // unsigned (IMM_SEL[3] = 1)
        #1;
        check(32'h00000001);

        // B-type: BEQ (signed offset)
        INST = 32'b1000000000000000000000001100011; // 32 bits, sign bit set
        IMM_SEL = 3'b011;
        #1;
        check(32'hfff00000); 

        // S-type: SW (signed)
        INST = 32'b11111110000000000010000000100011; // 32 bits, -1 immediate
        IMM_SEL = 3'b100;
        #1;
        check(32'hffffffe0);

        // SHAMT: SLLI (shift amount)
        INST = 32'b00000000000100000001000000010011; // 32 bits, shamt=1
        IMM_SEL = 3'b101;
        #1;
        check(32'h00000001);

        // Default case
        INST = 32'h0;
        IMM_SEL = 3'b111;
        #1;
        check(32'h00000000);

        $display("All tests completed.");
        $finish;
    end

    // Generate VCD file for waveform viewing
    initial begin
        $dumpfile("sign_extend_tb.vcd");
        $dumpvars(0, sign_extend_tb);
    end

endmodule