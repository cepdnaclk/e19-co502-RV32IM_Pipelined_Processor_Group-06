`timescale 1ns/1ps

module CONTROL_UNIT_TB;

    // Input
    reg [31:0] INSTRUCTION;
    wire [31:0] DATA1, DATA2;
    // Outputs
    wire [4:0] ALUOP;
    wire [2:0] IMME_SELECT;
    wire MUX1_SELECT, MUX2_SELECT, WRITEENABLE;
    wire [2:0] BR_SEL;
    wire [1:0] MEM_WRITE, MEM_READ;
    wire [31:0] ALU_RESULT;
    wire [31:0] OUT1, OUT2;
    reg CLK, RESET;
    reg [31:0] IN;
    reg [4:0] ADDR1, ADDR2, ADDRW;
    reg WRITE;

    // Instantiate the Unit Under Test (UUT)
    CONTROL_UNIT uut (
        .INSTRUCTION(INSTRUCTION),
        .ALUOP(ALUOP),
        .IMME_SELECT(IMME_SELECT),
        .MUX1_SELECT(MUX1_SELECT),
        .MUX2_SELECT(MUX2_SELECT),
        .WRITEENABLE(WRITEENABLE),
        .BR_SEL(BR_SEL),
        .MEM_WRITE(MEM_WRITE),
        .MEM_READ(MEM_READ)
    );

    ALU alu_inst (
        .DATA1(DATA1),
        .DATA2(DATA2),
        .SELECT(ALUOP),
        .RESULT(ALU_RESULT)
    );

    reg_file reg_inst(
        .IN(INSTRUCTION),
        .OUT1(DATA1),
        .OUT2(DATA2),
        .ADDR1(INSTRUCTION[19:15]), // rs1
        .ADDR2(INSTRUCTION[24:20]), // rs2
        .ADDRW(INSTRUCTION[11:7]),  // rd
        .WRITE(WRITEENABLE),
        .CLK(CLK), // Not used in this testbench
        .RESET(RESET) // Not used in this testbench
    );

    initial begin
        $display("Time | Instruction | ALUOP | IMME_SELECT | MUX1 | MUX2 | WRITE | MEM_RD | MEM_WR | BR_SEL");
        $monitor("%0t | %h | %b | %b | %b | %b | %b | %b | %b | %b", 
            $time, INSTRUCTION, ALUOP, IMME_SELECT, MUX1_SELECT, MUX2_SELECT, 
            WRITEENABLE, MEM_READ, MEM_WRITE, BR_SEL,DATA1,DATA2,OUT1,OUT2,ALU_RESULT);

        CLK = 0;
        RESET = 0;
        WRITE = 0;

        // Write 10 into x2 (reg 2)
        IN = 32'd10;
        ADDRW = 5'd2;
        WRITE = 1;
        #5 CLK = 1; #5 CLK = 0;

        // Write 15 into x3 (reg 3)
        IN = 32'd15;
        ADDRW = 5'd3;
        WRITE = 1;
        #5 CLK = 1; #5 CLK = 0;

        WRITE = 0; // Disable write after initializing

        // Apply instruction ADD x1, x2, x3
        INSTRUCTION = 32'h003100b3;  // ADD x1, x2, x3
        ADDR1 = 5'd2; // rs1
        ADDR2 = 5'd3; // rs2
        #100;

        // Apply test vectors
        INSTRUCTION = 32'h003100b3;  // R-type ADD
        //DATA1 = 32'd10;   // x2
        //DATA2 = 32'd15;   // x3
        #100;

        INSTRUCTION = 32'h403100b3;  // R-type SUB
        //DATA1 = 32'd45;   // x2
        //DATA2 = 32'd15; 
        #100;

        INSTRUCTION = 32'h00000003;  // Load (e.g., LB)
        #100;

        INSTRUCTION = 32'h00000023;  // Store (e.g., SB)
        #100;

        INSTRUCTION = 32'h00000063;  // Branch (e.g., BEQ)
        #100;

        $finish;
    end

endmodule
