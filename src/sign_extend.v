`timescale 1ns/1ps

module SIGN_EXTEND (
    input  wire [31:0] inst,
    input  wire [2:0]  imm_sel,
    output reg  [31:0] imm_ext
);

    // Local type encoding 
    localparam U_TYPE = 3'b000;
    localparam J_TYPE = 3'b001;
    localparam I_TYPE = 3'b010;
    localparam B_TYPE = 3'b011;
    localparam S_TYPE = 3'b100;
    localparam SHAMT  = 3'b101;

    // Pre-decoded fields
    wire [19:0] u_field   = inst[31:12];
    wire [11:0] i_field   = inst[31:20];
    wire [11:0] s_field   = {inst[31:25], inst[11:7]};
    wire [4:0]  shamt_val = inst[24:20];

    always @(*) begin
        case (imm_sel[2:0])
            U_TYPE: begin
                // U-type (LUI/AUIPC): shift upper 20 bits left
                imm_ext = {u_field, 12'b0};
            end
            J_TYPE: begin
                if (imm_sel[3]) begin
                    // J-type (raw 20-bit as positive immediate)
                    imm_ext = {11'b0, u_field, 1'b0};
                end else begin
                    // J-type (real format): signed offset
                    imm_ext = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
                end
            end
            I_TYPE: begin
                if (imm_sel[3]) begin
                    // I-type unsigned (e.g., logical shift)
                    imm_ext = {20'b0, i_field};
                end else begin
                    // I-type signed (e.g., addi, lw)
                    imm_ext = {{20{i_field[11]}}, i_field};
                end
            end
            B_TYPE: begin
                // B-type branch: offset with sign-extension
                imm_ext = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            end
            S_TYPE: begin
                if (imm_sel[3]) begin
                    // S-type unsigned (rare)
                    imm_ext = {20'b0, s_field};
                end else begin
                    // S-type signed (sw)
                    imm_ext = {{20{inst[31]}}, s_field};
                end
            end
            SHAMT: begin
                // Shift amount: zero-extended
                imm_ext = {27'b0, shamt_val};
            end
            default: begin
                // Fallback for safety
                imm_ext = 32'b0;
            end
        endcase
    end
endmodule
