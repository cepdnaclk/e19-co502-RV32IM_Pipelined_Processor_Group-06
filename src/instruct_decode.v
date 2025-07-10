`timescale 1ns/1ps

module Insutruct_Decode(W_Addr,PC,Data_1,Data_2,sign_ext,op2_sel,op1_sel,Alu_sel,Br_sel,Mem_W,Mem_R,Reg_w_Sel,Reg_w_En,CLK,REST)
    input CLK,RESET
    input[0:4] W_Addr,Alu_sel
    input[0:31] PC,Data_1,Data_2,sign_ext
    input[1:0] Mem_R, Mem_W, Reg_w_Sel
    input op1_sel,op2_sel,Reg_w_En
    input[0:2] Br_sel

    output[0:4] W_Addr_o,Alu_sel_o
    output[0:31] PC_o,Data_1_o,Data_2_o,sign_ext_o
    output[1:0] Mem_R_o, Mem_W_o, Reg_w_Sel_o
    output op1_sel_o,op2_sel_o,Reg_w_En_o
    output[0:2] Br_sel_o

    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            // ID_PC <= 0;
            // ID_INSTR <= 0;
            W_Addr__o <=0;
            Alu_sel_o <=0;
            PC_o <= 0;
            Data_1_o <= 0;
            Data_2_o <= 0;
            sign_ext_o <= 0:
            Mem_R_o <= 0;
            Mem_W_o <= 0;
            Reg_w_En_o <= 0;
            Reg_w_Sel_o <= 0;
            op1_sel_o <= 0;
            op2_sel_o <= 0;
            Br_sel_o <= 0;

        end else begin
            W_Addr__o <= W_Addr;
            Alu_sel_o <= Alu_sel;
            PC_o <= PC;
            Data_1_o <= Data_1;
            Data_2_o <= Data_2;
            sign_ext_o <= sign_ext:
            Mem_R_o <= Mem_R;
            Mem_W_o <= Mem_W;
            Reg_w_En_o <= Reg_w_En;
            Reg_w_Sel_o <= Reg_w_Sel;
            op1_sel_o <= op1_sel;
            op2_sel_o <= op2_sel;
            Br_sel_o <= Br_sel;
        end
    end

endmodule
