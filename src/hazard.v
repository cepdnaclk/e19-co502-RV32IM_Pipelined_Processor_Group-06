`timescale 1ns/1ps

module HAZARD_UNIT( ADDR1, ADDR2, EXRD, MEMRD, EXWE, MEMWE, EXMEMR, FDATA1SEL, FDATA2SEL, BUBBLE, STALL);

    input [4:0] ADDR1, ADDR2, EXRD, MEMRD;
    input EXWE, MEMWE;
    output reg [1:0] FDATA1SEL, FDATA2SEL, EXMEMR;
    output reg BUBBLE, STALL;
    
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
        FDATA1SEL = 2'b00;
        FDATA2SEL = 2'b00;
        BUBBLE = 1'b0;
        STALL = 1'b0;

        // Check for forwarding conditions
        if (EXMEMR && EXRD_EQ_ADDR1) begin
            FDATA1SEL = 2'b01;
        end
        if (EXMEMR && EXRD_EQ_ADDR2) begin
            FDATA2SEL = 2'b01;
        end
        if (MEMWE && MEMRD_EQ_ADDR1) begin
            FDATA1SEL = 2'b10;
        end
        if (MEMWE && MEMRD_EQ_ADDR2) begin
            FDATA2SEL = 2'b10;
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
