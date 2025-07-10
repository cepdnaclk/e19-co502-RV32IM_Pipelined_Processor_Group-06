`timescale 1ns/1ps

// Define a module called "SIGN_EXTEND"
module SIGN_EXTEND ( INST, IMM_SEL, IMM_EXT );

    input  wire [31:0] INST;
    input  wire [3:0]  IMM_SEL;
    output reg  [31:0] IMM_EXT;

    // Local type encoding 
    localparam U_TYPE = 3'b000;
    localparam J_TYPE = 3'b001;
    localparam I_TYPE = 3'b010;
    localparam B_TYPE = 3'b011;
    localparam S_TYPE = 3'b100;
    localparam SHAMT  = 3'b101;

    // Pre-decoded fields
    wire [19:0] u_field   = INST[31:12];
    wire [11:0] i_field   = INST[31:20];
    wire [11:0] s_field   = {INST[31:25], INST[11:7]};
    wire [4:0]  shamt_val = INST[24:20];

    always @(*) begin
        case (IMM_SEL[2:0])
            U_TYPE: begin
                // U-type (LUI/AUIPC): shift upper 20 bits left
                IMM_EXT = {u_field, 12'b0};
            end
            J_TYPE: begin
                if (IMM_SEL[3]) begin
                    // J-type (raw 20-bit as positive immediate)
                    IMM_EXT = {11'b0, u_field, 1'b0};
                end else begin
                    // J-type (real format): signed offset
                    IMM_EXT = {{12{INST[31]}}, INST[19:12], INST[20], INST[30:21], 1'b0};
                end
            end
            I_TYPE: begin
                if (IMM_SEL[3]) begin
                    // I-type unsigned (e.g., logical shift)
                    IMM_EXT = {20'b0, i_field};
                end else begin
                    // I-type signed (e.g., addi, lw)
                    IMM_EXT = {{20{i_field[11]}}, i_field};
                end
            end
            B_TYPE: begin
                // B-type branch: offset with sign-extension
                IMM_EXT = {{20{INST[31]}}, INST[7], INST[30:25], INST[11:8], 1'b0};
            end
            S_TYPE: begin
                if (IMM_SEL[3]) begin
                    // S-type unsigned (rare)
                    IMM_EXT = {20'b0, s_field};
                end else begin
                    // S-type signed (sw)
                    IMM_EXT = {{20{INST[31]}}, s_field};
                end
            end
            SHAMT: begin
                // Shift amount: zero-extended
                IMM_EXT = {27'b0, shamt_val};
            end
            default: begin
                // Fallback for safety
                IMM_EXT = 32'b0;
            end
        endcase
    end
endmodule
