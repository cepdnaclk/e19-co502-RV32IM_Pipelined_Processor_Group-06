`timescale 1ns/1ps

// Top-level CPU with integrated hazard handling
module CPU_WITH_HAZARDS(
    input CLK,
    input RESET
);

    // Pipeline register signals
    wire [31:0] if_id_pc, if_id_instruction;
    wire [31:0] id_ex_pc, id_ex_data1, id_ex_data2, id_ex_imm;
    wire [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
    wire [4:0] id_ex_alu_op;
    wire id_ex_reg_write, id_ex_mem_read, id_ex_mem_write, id_ex_branch;
    
    // PC signals
    wire [31:0] pc_current, pc_plus_4, branch_target;
    
    // Hazard detection signals
    wire [4:0] rs1_addr, rs2_addr;  // Source register addresses from decoder
    wire is_branch_id, is_branch_ex, branch_taken;
    
    // Hazard unit outputs
    wire [1:0] fdata1sel, fdata2sel;
    wire pc_stall, if_id_stall, if_id_flush, id_ex_flush, pc_mux_sel;
    wire data_hazard, control_hazard, pipeline_stall;
    
    // Forwarding mux inputs (from EX/MEM and MEM/WB stages)
    wire [31:0] ex_mem_result, mem_wb_result;
    wire [4:0] ex_mem_rd, mem_wb_rd;
    wire ex_mem_reg_write, mem_wb_reg_write, ex_mem_mem_read;
    
    // Program Counter with hazard support
    PC_HAZARD pc_unit (
        .CLK(CLK),
        .RESET(RESET),
        .PC_STALL(pc_stall),
        .PC_MUX_SEL(pc_mux_sel),
        .PC_PLUS_4(pc_plus_4),
        .BRANCH_TARGET(branch_target),
        .PC_OUT(pc_current)
    );
    
    // PC + 4 adder
    assign pc_plus_4 = pc_current + 32'd4;
    
    // IF/ID Pipeline Register with hazard support
    IF_ID_REG if_id_reg (
        .CLK(CLK),
        .RESET(RESET),
        .STALL(if_id_stall),
        .FLUSH(if_id_flush),
        .PC_IN(pc_current),
        .INSTRUCTION_IN(/* instruction from memory */),
        .PC_OUT(if_id_pc),
        .INSTRUCTION_OUT(if_id_instruction)
    );
    
    // Instruction Decoder (extracts rs1, rs2, rd, immediate, etc.)
    // This would decode if_id_instruction and produce rs1_addr, rs2_addr, etc.
    
    // ID/EX Pipeline Register with hazard support
    ID_EX_REG id_ex_reg (
        .CLK(CLK),
        .RESET(RESET),
        .FLUSH(id_ex_flush),
        .ALU_OP_IN(/* from decoder */),
        .REG_WRITE_IN(/* from decoder */),
        .MEM_READ_IN(/* from decoder */),
        .MEM_WRITE_IN(/* from decoder */),
        .BRANCH_IN(is_branch_id),
        .RD_IN(/* from decoder */),
        .PC_IN(if_id_pc),
        .DATA1_IN(/* from register file with forwarding */),
        .DATA2_IN(/* from register file with forwarding */),
        .IMM_IN(/* from sign extender */),
        .RS1_IN(rs1_addr),
        .RS2_IN(rs2_addr),
        // Outputs
        .ALU_OP_OUT(id_ex_alu_op),
        .REG_WRITE_OUT(id_ex_reg_write),
        .MEM_READ_OUT(id_ex_mem_read),
        .MEM_WRITE_OUT(id_ex_mem_write),
        .BRANCH_OUT(id_ex_branch),
        .RD_OUT(id_ex_rd),
        .PC_OUT(id_ex_pc),
        .DATA1_OUT(id_ex_data1),
        .DATA2_OUT(id_ex_data2),
        .IMM_OUT(id_ex_imm),
        .RS1_OUT(id_ex_rs1),
        .RS2_OUT(id_ex_rs2)
    );
    
    // Enhanced Hazard Unit
    ENHANCED_HAZARD_UNIT hazard_unit (
        .CLK(CLK),
        .RESET(RESET),
        // Data hazard inputs
        .ADDR1(rs1_addr),
        .ADDR2(rs2_addr),
        .EXRD(id_ex_rd),
        .MEMRD(ex_mem_rd),
        .EXWE(id_ex_reg_write),
        .MEMWE(ex_mem_reg_write),
        .EXMEMR(id_ex_mem_read),
        // Control hazard inputs
        .IS_BRANCH_ID(is_branch_id),
        .IS_BRANCH_EX(is_branch_ex),
        .BRANCH_TAKEN(branch_taken),
        .BRANCH_TARGET(branch_target),
        // Outputs
        .FDATA1SEL(fdata1sel),
        .FDATA2SEL(fdata2sel),
        .PC_STALL(pc_stall),
        .IF_ID_STALL(if_id_stall),
        .IF_ID_FLUSH(if_id_flush),
        .ID_EX_FLUSH(id_ex_flush),
        .PC_MUX_SEL(pc_mux_sel),
        .DATA_HAZARD(data_hazard),
        .CONTROL_HAZARD(control_hazard),
        .PIPELINE_STALL(pipeline_stall)
    );
    
    // Data Forwarding Multiplexers
    reg [31:0] forwarded_data1, forwarded_data2;
    
    always @(*) begin
        // Forward data1
        case (fdata1sel)
            2'b00: forwarded_data1 = /* data from register file */;
            2'b01: forwarded_data1 = ex_mem_result;  // Forward from EX/MEM
            2'b10: forwarded_data1 = mem_wb_result;  // Forward from MEM/WB
            default: forwarded_data1 = /* data from register file */;
        endcase
        
        // Forward data2
        case (fdata2sel)
            2'b00: forwarded_data2 = /* data from register file */;
            2'b01: forwarded_data2 = ex_mem_result;  // Forward from EX/MEM
            2'b10: forwarded_data2 = mem_wb_result;  // Forward from MEM/WB
            default: forwarded_data2 = /* data from register file */;
        endcase
    end
    
    // Rest of the pipeline stages (EX, MEM, WB) would be connected here
    // with appropriate pipeline registers and forwarding paths

endmodule
