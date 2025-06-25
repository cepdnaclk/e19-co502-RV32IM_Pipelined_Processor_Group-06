`timescale 1ns / 1ps

module CONTROL_UNIT (
    input [31:0] INSTRUCTION,
    output reg [4:0] ALUOP,
    output reg [2:0] IMME_SELECT,
    output reg MUX1_SELECT,     // ALU operand1: 0=reg, 1=PC
    output reg MUX2_SELECT,     // ALU operand2: 0=reg, 1=imm
    output reg [2:0] BR_SEL,    // Branch type
    output reg WRITEENABLE,     // Reg write enable
    output reg [1:0] MEM_WRITE, // Memory write type
    output reg [1:0] MEM_READ,   // Memory read type
    output reg [1:0] WB_SEL
);

// Instruction decoding
wire [6:0] OPCODE    = INSTRUCTION[6:0];
wire [2:0] FUNCT3    = INSTRUCTION[14:12];
wire [6:0] FUNCT7    = INSTRUCTION[31:25];

// Defaults to avoid latches
always @(*) begin
    // Default values
    IMME_SELECT  = 3'b000;
    MUX1_SELECT  = 1'b0;
    MUX2_SELECT  = 1'b0;
    WRITEENABLE  = 1'b0;
    MEM_WRITE    = 2'b00;
    MEM_READ     = 2'b00;
    BR_SEL       = 3'b011;
    ALUOP        = 5'b00000;
    WB_SEL       = 2'b01;

    case (OPCODE)
        // R-Type instructions (register-register)
        7'b0110011: begin
            WRITEENABLE = 1'b1;
            MUX1_SELECT = 1'b0;
            MUX2_SELECT = 1'b0;
            WB_SEL       = 2'b01;
            case ({FUNCT7, FUNCT3})
                10'b0000000000: ALUOP = 5'b00001; // ADD
                10'b0100000000: ALUOP = 5'b00010; // SUB
                10'b0000000001: ALUOP = 5'b00011; // SLL
                10'b0000000010: ALUOP = 5'b00100; // SLT
                10'b0000000011: ALUOP = 5'b00101; // SLTU
                10'b0000000100: ALUOP = 5'b00110; // XOR
                10'b0000000101: ALUOP = 5'b00111; // SRL
                10'b0100000101: ALUOP = 5'b01000; // SRA
                10'b0000000110: ALUOP = 5'b01001; // OR
                10'b0000000111: ALUOP = 5'b01010; // AND
                10'b0000001000: ALUOP = 5'b01011; // MUL
                10'b0000001001: ALUOP = 5'b01100; // MULH
                10'b0000001010: ALUOP = 5'b01101; // MULHSU
                10'b0000001011: ALUOP = 5'b01110; // MULHU
                10'b0000001100: ALUOP = 5'b01111; // DIV
                10'b0000001101: ALUOP = 5'b10000; // DIVU
                10'b0000001110: ALUOP = 5'b10001; // REM
                10'b0000001111: ALUOP = 5'b10010; // REMU
                default:        ALUOP = 5'b00000;
            endcase
        end

        // I-Type ALU (Immediate arithmetic)
        7'b0010011: begin
            IMME_SELECT  = 3'b010;
            MUX1_SELECT  = 1'b0;
            MUX2_SELECT  = 1'b1;
            WRITEENABLE  = 1'b1;
            WB_SEL       = 2'b01;
            case (FUNCT3)
                3'b000: ALUOP = 5'b00001; // ADDI
                3'b010: ALUOP = 5'b00100; // SLTI
                3'b011: ALUOP = 5'b00101; // SLTIU
                3'b100: ALUOP = 5'b00110; // XORI
                3'b110: ALUOP = 5'b01001; // ORI
                3'b111: ALUOP = 5'b01010; // ANDI
                3'b001: ALUOP = 5'b00011; // SLLI
                3'b101: begin
                    if (FUNCT7 == 7'b0000000)
                        ALUOP = 5'b00111; // SRLI
                    else
                        ALUOP = 5'b01000; // SRAI
                end
            endcase
        end

        // Load
        7'b0000011: begin
            IMME_SELECT = 3'b011;
            MUX1_SELECT = 1'b0;
            MUX2_SELECT = 1'b1;
            MEM_READ    = FUNCT3[1:0];
            WRITEENABLE = 1'b1;
            WB_SEL       = 2'b10;
            ALUOP       = 5'b00001; // ADD for address calc
        end

        // Store
        7'b0100011: begin
            IMME_SELECT = 3'b101;
            MUX1_SELECT = 1'b0;
            MUX2_SELECT = 1'b1;
            MEM_WRITE   = FUNCT3[1:0];
            WRITEENABLE = 1'b0;
            WB_SEL       = 2'b10;
            ALUOP       = 5'b00001; // ADD for address calc
        end

        // Branch
        7'b1100011: begin
            IMME_SELECT = 3'b011;
            MUX1_SELECT = 1'b1;
            MUX2_SELECT = 1'b1;
            BR_SEL      = FUNCT3;
            ALUOP       = 5'b00001; // ADD
            WRITEENABLE = 1'b0;
            WB_SEL       = 2'b00;
        end

        // JAL
        7'b1101111: begin
            IMME_SELECT = 3'b001;
            MUX1_SELECT = 1'b1;
            MUX2_SELECT = 1'b1;
            ALUOP       = 5'b00001;
            WRITEENABLE = 1'b1;
            WB_SEL       = 2'b00;
            BR_SEL      =3'b010;
        end

        // JALR
        7'b1100111: begin
            IMME_SELECT = 3'b001;
            MUX1_SELECT = 1'b0;
            MUX2_SELECT = 1'b1;
            ALUOP       = 5'b00001;
            WRITEENABLE = 1'b1;
            WB_SEL       = 2'b00;
            BR_SEL      =3'b010;
        end

        // LUI
        7'b0110111: begin
            IMME_SELECT = 3'b000;
            MUX1_SELECT = 1'b0;
            MUX2_SELECT = 1'b1;
            ALUOP       = 5'b00000;
            WRITEENABLE = 1'b1;
        end

        // AUIPC
        7'b0010111: begin
            IMME_SELECT = 3'b000;
            MUX1_SELECT = 1'b1;
            MUX2_SELECT = 1'b1;
            ALUOP       = 5'b00001;
            WRITEENABLE = 1'b1;
        end
    endcase
end

endmodule
