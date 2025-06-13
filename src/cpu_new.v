`timescale 1ns/1ps
`include "alu.v"
`include "br_unit.v"
`include "adder.v"
`include "control.v"
`include "memory.v"
`include "mux.v"
`include "pc.v"
`include "registor_file.v"
`include "ma_wb.v"
`include "if_pl.v"
`include "id_ex.v"
`include "EX_MA.v"
`include "tri_mux.v"
`include "ist_mem.v"
`include "sign_extend.v"

module RISC_V_CPU (
    input CLK,
    input RESET
);

    // ===== Wires for ID stage =====
    wire [31:0] ID_PC;
    wire [31:0] IF_INSTR;
    wire BUSYWAIT;
    wire [31:0] IFD_INSTR;
    wire BR_SEL;

    // ===== Wires for IF Stage =====
    wire [31:0] IF_PC;
    wire [4:0] IF_ADD;
    wire [31:0] IF_D1, IF_D2;
    wire [31:0] IF_SIGN;
    wire IF_OP1, IF_OP2;
    wire [1:0]  IF_W_REG;
    wire [1:0]  EX_W_REG;
    wire [4:0]  IF_ALU;
    wire [2:0]  IF_BS;
    wire [1:0]  IF_MW, IF_MR;
    wire        IF_REG_EN;
    wire [31:0] PC_I;
    wire [31:0] PC_I_4;

    // ===== Wires for EX Stage =====
    wire [31:0] EX_PC, EX_D1, EX_D2, EX_DATA, EX_SIGN;
    wire        EX_OP1, EX_OP2;
    wire [4:0]  EX_ALU,EX_ADD;
    wire [2:0]  EX_BS;
    wire [1:0]  EX_MW, EX_MR;
    wire        EX_REG_EN;
    wire [31:0] EX_AL1, EX_AL2;

    // ===== Wires for MA Stage =====
    wire [31:0] MA_DATA, MA_SIGN,MA_PC_4;
    wire [1:0] MA_MW, MA_MR;
    wire [4:0] MA_ADD;
    wire  MA_REG_EN;
    wire [1:0] MA_W_REG;

    // ===== Wires for WB Stage =====
    wire [31:0] MA_PC, WB_PC;
    wire [31:0] MA_MEM_OUT, WB_MEM_OUT;
    wire [31:0] WB_DATA;
    wire [4:0]  WB_ADD;
    wire [1:0] WB_W_REG;
    wire WB_REG_EN;
    wire [31:0] MUX_OUT;
    wire [2:0] IMME_SELECT;

    PC PC (
        .PC(PC_I), 
        .NEXTPC(IF_PC), 
        .RESET(RESET), 
        .CLOCK(CLK), 
        .BUSYWAIT(1'b0)
    );

    INSTRUCTION_MEMORY inst_mem(
        .CLK(CLK),
        .RESET(RESET),
        .ADDR(IF_PC),
        .INSTRUCTION(IF_INSTR)
    );

    MUX m3 (
        .Input1(PC_I_4),
        .Input2(EX_DATA),
        .Select(BR_SEL),
        .Answer(PC_I)
    );

    ADDER adder1 (
        .DATA(IF_PC),
        .OUT(PC_I_4)
    );

    // IF/ID Pipeline Register
    IF_ID if_id (
        .CLK(CLK),
        .RESET(RESET),
        .IF_PC(IF_PC),
        .IF_INSTR(IF_INSTR),
        .ID_PC(ID_PC),
        .ID_INSTR(IFD_INSTR)
    );

    SIGN_EXTEND sign(
        .inst(IFD_INSTR),
        .imm_sel(IMME_SELECT),
        .imm_ext(IF_SIGN)
    );

    // Control Unit
    CONTROL_UNIT cu (
        .INSTRUCTION(IFD_INSTR),
        .ALUOP(IF_ALU),
        .IMME_SELECT(IMME_SELECT),
        .MUX1_SELECT(IF_OP1),
        .MUX2_SELECT(IF_OP2),
        .BR_SEL(IF_BS),
        .WRITEENABLE(IF_REG_EN),
        .MEM_READ(IF_MR),
        .MEM_WRITE(IF_MW)
    );

    REG_FILE reg_file(
        .CLK(CLK),
        .RESET(RESET),
        .IN(MUX_OUT),
        .ADDR1(IFD_INSTR[19:15]),
        .ADDR2(IFD_INSTR[24:20]),
        .ADDRW(WB_ADD),
        .OUT1(IF_D1),
        .OUT2(IF_D2),
        .WRITE(WB_REG_EN)
    );

    // IF to EX pipeline register
    IF_EX if_ex (
        .CLK(CLK), .RESET(RESET),
        .IF_PC(ID_PC), .IF_ADD(IFD_INSTR[11:7]),
        .IF_D1(IF_D1), .IF_D2(IF_D2),
        .IF_SIGN(IF_SIGN), .IF_OP1(IF_OP1), .IF_OP2(IF_OP2),
        .IF_ALU(IF_ALU), .IF_BS(IF_BS),
        .IF_MW(IF_MW), .IF_MR(IF_MR),
        .IF_W_REG(IF_W_REG), .IF_REG_EN(IF_REG_EN),
        .EX_PC(EX_PC), .EX_ADD(EX_ADD),
        .EX_D1(EX_D1), .EX_D2(EX_D2),
        .EX_SIGN(EX_SIGN), .EX_OP1(EX_OP1), .EX_OP2(EX_OP2),
        .EX_ALU(EX_ALU), .EX_BS(EX_BS),
        .EX_MW(EX_MW), .EX_MR(EX_MR),
        .EX_W_REG(EX_W_REG), .EX_REG_EN(EX_REG_EN)
    );

    MUX mx1 (
        .Input1(EX_D1),
        .Input2(EX_PC),
        .Select(EX_OP1),
        .Answer(EX_AL1)
    );

    MUX mx2 (
        .Input1(EX_D2),
        .Input2(EX_SIGN),
        .Select(EX_OP2),
        .Answer(EX_AL2)
    );

    ALU alu (
        .CLK(CLK),
        .RESET(RESET),
        .DATA1(EX_AL1),
        .DATA2(EX_AL2),
        .SELECT(EX_ALU),
        .RESULT(EX_DATA)
    );

    BRANCH branch(
        .data1(EX_D1),
        .data2(EX_SIGN),
        .op(EX_BS),
        .out(BR_SEL)
    );

    EX_MA ex_ma (
        .CLK(CLK), .RESET(RESET),
        .EX_PC(EX_PC),
        .EX_ADD(EX_ADD), .EX_DATA(EX_DATA),
        .EX_SIGN(EX_SIGN), .EX_MR(EX_MR), .EX_MW(EX_MW),
        .EX_W_REG(EX_W_REG), .EX_REG_EN(EX_REG_EN),
        .MA_PC(MA_PC),
        .MA_ADD(MA_ADD), .MA_DATA(MA_DATA), .MA_SIGN(MA_SIGN),
        .MA_MR(MA_MR), .MA_MW(MA_MW),
        .MA_W_REG(MA_W_REG), .MA_REG_EN(MA_REG_EN)
    );

    ADDER adder2(
        .DATA(MA_PC),
        .OUT(MA_PC_4)
    );

    Data_Memory rom (
        .CLK(CLK),
        .RESET(RESET),
        .READ(MA_MR), 
        .WRITE(MA_MW),
        .ADDR(MA_DATA), 
        .DATA_IN(MA_SIGN), 
        .DATA_OUT(MA_MEM_OUT)
    );

    MA_WB ma_wb (
        .CLK(CLK), .RESET(RESET),
        .MA_PC(MA_PC_4), .MA_ADD(MA_ADD),
        .MA_DATA(MA_DATA), .MA_MEM_OUT(MA_MEM_OUT),
        .MA_W_REG(MA_W_REG), .MA_REG_EN(MA_REG_EN),
        .WB_PC(WB_PC), .WB_ADD(WB_ADD),
        .WB_DATA(WB_DATA), .WB_MEM_OUT(WB_MEM_OUT),
        .WB_W_REG(WB_W_REG), .WB_REG_EN(WB_REG_EN)
    );

    TRI_MUX tri_mux (
        .Answer(MUX_OUT),
        .Input1(WB_PC),
        .Input2(WB_DATA),
        .Input3(WB_MEM_OUT),
        .Select(WB_W_REG)
    );

   

endmodule
