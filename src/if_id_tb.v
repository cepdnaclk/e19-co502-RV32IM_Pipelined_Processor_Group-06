`timescale 1ps/1ps

module if_stage_tb();

    reg CLOCK, RESET;

    wire [31:0] PC_IF;
    wire [127:0] INST_BLOCK;
    wire [31:0] ID_INSTR;

    wire [31:0] NEXT_PC;
    wire [27:0] BLOCK_ADDR;
    wire READ;
    wire [31:0] A;
    wire [31:0] RD;
    wire rst;

    wire BUSYWAIT_MEM;
    wire BUSYWAIT;

    assign BLOCK_ADDR = PC_IF[31:4];   // Convert byte address to block address
    assign READ = 1'b1;                // Always reading instructions
    assign NEXT_PC = PC_IF + 4;        // Simple PC increment
    assign BUSYWAIT = BUSYWAIT_MEM;    // Connect PC's BUSYWAIT to instruction memory

    // Clock generation
    initial begin
        CLOCK = 0;
        forever #5 CLOCK = ~CLOCK;
    end

    // Reset logic
    initial begin
        RESET = 1;
        #12 RESET = 0; // Release reset after some delay
    end

    // PC
    PC pc_instance (
        .PC(NEXT_PC),
        .NEXTPC(PC_IF),
        .RESET(RESET),
        .CLOCK(CLOCK),
        .BUSYWAIT(BUSYWAIT)
    );

    // Instruction Memory
    INSTRUCTION_MEMORY instr_mem (
        // .rst(1'b1),
        .A(PC_IF),
        .RD(RD)
    );

    // IF/ID Register
    IF_ID if_id (
        .CLK(CLOCK),
        .RESET(RESET),
        .IF_INSTR(INST_BLOCK[31:0]),
        .ID_INSTR(ID_INSTR)
    );

    // Control Unit
    wire [4:0] ALUOP;
    wire [2:0] IMME_SELECT;
    wire MUX1_SELECT, MUX2_SELECT, WRITEENABLE;
    wire [2:0] BR_SEL;
    wire [1:0] MEM_READ, MEM_WRITE;

    CONTROL_UNIT cu (
        .INSTRUCTION(ID_INSTR),
        .ALUOP(ALUOP),
        .IMME_SELECT(IMME_SELECT),
        .MUX1_SELECT(MUX1_SELECT),
        .MUX2_SELECT(MUX2_SELECT),
        .BR_SEL(BR_SEL),
        .WRITEENABLE(WRITEENABLE),
        .MEM_READ(MEM_READ),
        .MEM_WRITE(MEM_WRITE)
    );

    // Monitor
    initial begin
        $display("Time\tPC\t\tInstruction\t\tALUOP\tWRITEENABLE\tIMM_SEL");
        $monitor("%0t\t%h\t%h\t%b\t%b\t\t%b", 
                 $time, PC_IF, ID_INSTR, ALUOP, WRITEENABLE, IMME_SELECT,rst,RD);
        #200000 $finish;
    end

endmodule
