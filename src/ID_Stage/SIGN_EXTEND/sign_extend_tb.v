`timescale 1ns/1ps

module sign_extend_tb;

    reg  [31:0] INST;
    reg  [3:0]  IMM_SEL;
    wire [31:0] IMM_EXT;

    // Connect DUT (Design Under Test)
    SIGN_EXTEND uut (
        .INST(INST),
        .IMM_SEL(IMM_SEL),
        .IMM_EXT(IMM_EXT)
    );

    // Type constants
    localparam U_TYPE = 4'b000;
    localparam J_TYPE = 4'b001;
    localparam I_TYPE = 4'b010;
    localparam B_TYPE = 4'b011;
    localparam S_TYPE = 4'b100;
    localparam SHAMT  = 4'b101;

    // Test result checker
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
        // U-type: LUI
        INST = 32'h12345000;
        IMM_SEL = U_TYPE;
        check(32'h12345000);

        // J-type signed offset
        INST = 32'b10000000010000000000000011011111;
        IMM_SEL = J_TYPE;
        check(32'hfff80400);  

        // I-type signed (-1)
        INST = 32'b11111111111100000000000000010011;
        IMM_SEL = I_TYPE;
        check(32'hffffffff);

        // I-type unsigned
        INST = 32'b00000000000100000000000000010011;
        IMM_SEL = I_TYPE | 4'b1000;  // IMM_SEL[3] = 1
        check(32'h00000001);

        // B-type signed offset
        INST = 32'b11111110000000000000000001100011;
        IMM_SEL = B_TYPE;
        check(32'hfffffe00);

        // S-type signed
        INST = 32'b11111110000000000010000000100011;
        IMM_SEL = S_TYPE;
        check(32'hffffffe0);

        // SHAMT
        INST = 32'b00000000000100000001000000010011;
        IMM_SEL = SHAMT;
        check(32'h00000001);

        // Default case
        INST = 32'h0;
        IMM_SEL = 4'b1111;
        check(32'h00000000);

        $display("All tests completed.");
        $finish;
    end

    // Dump waveform
    initial begin
        $dumpfile("sign_extend_tb.vcd");
        $dumpvars(0, sign_extend_tb);
    end

endmodule
