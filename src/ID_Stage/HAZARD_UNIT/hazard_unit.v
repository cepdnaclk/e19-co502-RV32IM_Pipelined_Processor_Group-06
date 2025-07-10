`timescale 1ns/1ps

// Define a module called "HAZARD_UNIT"
module HAZARD_UNIT( ADDR1, ADDR2, EXRD, MEMRD, EXWE, MEMWE, EXMEMR, FDATA1SEL, FDATA2SEL, BUBBLE, STALL);

    //  Inputs
    // ADDR1: Source register 1 address
    // ADDR2: Source register 2 address
    // EXRD: Register address from EX stage
    // MEMRD: Register address from MEM stage
    // EXWE: Write enable signal from EX stage
    // MEMWE: Write enable signal from MEM stage
    // EXMEMR: Memory read signal from EX stage

    // Outputs
    // FDATA1SEL: Forwarding data select signal for source 1
    // FDATA2SEL: Forwarding data select signal for source 2
    // BUBBLE: Bubble signal to stall pipeline
    // STALL: Stall signal to pause pipeline

    input [4:0] ADDR1, ADDR2, EXRD, MEMRD;
    input EXWE, MEMWE, EXMEMR;
    output reg FDATA1SEL, FDATA2SEL, BUBBLE, STALL;
    
    // Internal signals
    wire EXRD_EQ_ADDR1, EXRD_EQ_ADDR2, MEMRD_EQ_ADDR1, MEMRD_EQ_ADDR2;
    wire EXRD_EQ_MEMRD, EXRD_EQ_EXRD, MEMRD_EQ_MEMRD;
    wire EXRD_EQ_EXRD_MEMRD, MEMRD_EQ_EXRD_MEMRD;
    wire EXRD_EQ_ADDR1_MEMRD, EXRD_EQ_ADDR2_MEMRD, MEMRD_EQ_ADDR1_EXRD, MEMRD_EQ_ADDR2_EXRD;
    wire EXRD_EQ_ADDR1_EXRD, EXRD_EQ_ADDR2_EXRD, MEMRD_EQ_ADDR1_MEMRD, MEMRD_EQ_ADDR2_MEMRD;
    wire EXRD_EQ_ADDR1_EXRD_MEMRD, EXRD_EQ_ADDR2_EXRD_MEMRD, MEMRD_EQ_ADDR1_EXRD_MEMRD, MEMRD_EQ_ADDR2_EXRD_MEMRD;

    // Check if EX stage register address matches source register 1 or 2
    assign EXRD_EQ_ADDR1 = (EXRD == ADDR1);
    assign EXRD_EQ_ADDR2 = (EXRD == ADDR2);

    // Check if MEM stage register address matches source register 1 or 2
    assign MEMRD_EQ_ADDR1 = (MEMRD == ADDR1);
    assign MEMRD_EQ_ADDR2 = (MEMRD == ADDR2);

    // Check if EX stage register address matches MEM stage register address
    assign EXRD_EQ_MEMRD = (EXRD == MEMRD);
    assign EXRD_EQ_EXRD = (EXRD == EXRD);
    assign MEMRD_EQ_MEMRD = (MEMRD == MEMRD);

    // Check if EX stage register address matches source register 1 or 2 and MEM stage register address
    assign EXRD_EQ_ADDR1_MEMRD = (EXRD == ADDR1) && (MEMRD == ADDR1);
    assign EXRD_EQ_ADDR2_MEMRD = (EXRD == ADDR2) && (MEMRD == ADDR2);
    assign MEMRD_EQ_ADDR1_EXRD = (MEMRD == ADDR1) && (EXRD == ADDR1);
    assign MEMRD_EQ_ADDR2_EXRD = (MEMRD == ADDR2) && (EXRD == ADDR2);

    // Check if EX stage register address matches source register 1 or 2 and MEM stage register address
    assign EXRD_EQ_ADDR1_EXRD = (EXRD == ADDR1) && (EXRD == ADDR1);
    assign EXRD_EQ_ADDR2_EXRD = (EXRD == ADDR2) && (EXRD == ADDR2);
    assign MEMRD_EQ_ADDR1_MEMRD = (MEMRD == ADDR1) && (MEMRD == ADDR1);
    assign MEMRD_EQ_ADDR2_MEMRD = (MEMRD == ADDR2) && (MEMRD == ADDR2);

    // Check if EX stage register address matches source register 1 or 2 and MEM stage register address
    assign EXRD_EQ_ADDR1_EXRD_MEMRD = (EXRD == ADDR1) && (EXRD == ADDR1) && (MEMRD == ADDR1);
    assign EXRD_EQ_ADDR2_EXRD_MEMRD = (EXRD == ADDR2) && (EXRD == ADDR2) && (MEMRD == ADDR2);
    assign MEMRD_EQ_ADDR1_EXRD_MEMRD = (MEMRD == ADDR1) && (EXRD == ADDR1) && (MEMRD == ADDR1);
    assign MEMRD_EQ_ADDR2_EXRD_MEMRD = (MEMRD == ADDR2) && (EXRD == ADDR2) && (MEMRD == ADDR2);
    
    // Forwarding data select signals
    always @(*) begin
        FDATA1SEL = 1'b0;
        FDATA2SEL = 1'b0;
        BUBBLE = 1'b0;
        STALL = 1'b0;

        // Check for forwarding conditions
        if (EXMEMR && EXRD_EQ_ADDR1) begin
            FDATA1SEL = 1'b1;
        end
        if (EXMEMR && EXRD_EQ_ADDR2) begin
            FDATA2SEL = 1'b1;
        end
        if (MEMWE && MEMRD_EQ_ADDR1) begin
            FDATA1SEL = 1'b1;
        end
        if (MEMWE && MEMRD_EQ_ADDR2) begin
            FDATA2SEL = 1'b1;
        end
        // Check for bubble conditions
        if (EXMEMR && (EXRD_EQ_ADDR1_MEMRD || EXRD_EQ_ADDR2_MEMRD)) begin
            BUBBLE = 1'b1;
        end
        if (MEMWE && (MEMRD_EQ_ADDR1_EXRD_MEMRD || MEMRD_EQ_ADDR2_EXRD_MEMRD)) begin
            BUBBLE = 1'b1;
        end
        // Check for stall conditions
        if (BUBBLE) begin
            STALL = 1'b1;
        end
    end
endmodule
