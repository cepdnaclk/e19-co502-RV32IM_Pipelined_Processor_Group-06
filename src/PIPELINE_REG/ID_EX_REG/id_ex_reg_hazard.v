`timescale 1ns/1ps

// Modified ID/EX Pipeline Register with Hazard Control
module ID_EX_REG(
    input CLK,
    input RESET,
    
    // Hazard control signals
    input FLUSH,        // From hazard unit - clear register (insert bubble)
    
    // Control inputs
    input [4:0] ALU_OP_IN,
    input REG_WRITE_IN,
    input MEM_READ_IN,
    input MEM_WRITE_IN,
    input BRANCH_IN,
    input [4:0] RD_IN,
    
    // Data inputs
    input [31:0] PC_IN,
    input [31:0] DATA1_IN,
    input [31:0] DATA2_IN,
    input [31:0] IMM_IN,
    input [4:0] RS1_IN,
    input [4:0] RS2_IN,
    
    // Control outputs
    output reg [4:0] ALU_OP_OUT,
    output reg REG_WRITE_OUT,
    output reg MEM_READ_OUT,
    output reg MEM_WRITE_OUT,
    output reg BRANCH_OUT,
    output reg [4:0] RD_OUT,
    
    // Data outputs
    output reg [31:0] PC_OUT,
    output reg [31:0] DATA1_OUT,
    output reg [31:0] DATA2_OUT,
    output reg [31:0] IMM_OUT,
    output reg [4:0] RS1_OUT,
    output reg [4:0] RS2_OUT
);

    always @(posedge CLK) begin
        if (RESET || FLUSH) begin
            // Reset or flush - insert NOP (all control signals disabled)
            ALU_OP_OUT <= 5'b00000;
            REG_WRITE_OUT <= 1'b0;
            MEM_READ_OUT <= 1'b0;
            MEM_WRITE_OUT <= 1'b0;
            BRANCH_OUT <= 1'b0;
            RD_OUT <= 5'b00000;
            
            PC_OUT <= 32'h00000000;
            DATA1_OUT <= 32'h00000000;
            DATA2_OUT <= 32'h00000000;
            IMM_OUT <= 32'h00000000;
            RS1_OUT <= 5'b00000;
            RS2_OUT <= 5'b00000;
        end else begin
            // Normal operation
            ALU_OP_OUT <= ALU_OP_IN;
            REG_WRITE_OUT <= REG_WRITE_IN;
            MEM_READ_OUT <= MEM_READ_IN;
            MEM_WRITE_OUT <= MEM_WRITE_IN;
            BRANCH_OUT <= BRANCH_IN;
            RD_OUT <= RD_IN;
            
            PC_OUT <= PC_IN;
            DATA1_OUT <= DATA1_IN;
            DATA2_OUT <= DATA2_IN;
            IMM_OUT <= IMM_IN;
            RS1_OUT <= RS1_IN;
            RS2_OUT <= RS2_IN;
        end
    end

endmodule
