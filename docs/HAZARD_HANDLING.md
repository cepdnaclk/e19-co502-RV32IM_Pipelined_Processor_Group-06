# Hazard Handling in RISC-V Pipelined Processor

## Table of Contents
1. [Overview](#overview)
2. [Types of Hazards](#types-of-hazards)
3. [Data Hazard Handling](#data-hazard-handling)
4. [Control Hazard Handling](#control-hazard-handling)
5. [Implementation Architecture](#implementation-architecture)
6. [Pipeline Register Modifications](#pipeline-register-modifications)
7. [Testing Strategy](#testing-strategy)

## Overview

This document describes the hazard handling implementation for a 5-stage RISC-V pipelined processor. The implementation addresses both **data hazards** and **control hazards** through a combination of forwarding, stalling, and flushing techniques.

### Pipeline Stages
- **IF (Instruction Fetch)**: Fetch instruction from memory
- **ID (Instruction Decode)**: Decode instruction and read registers
- **EX (Execute)**: Perform ALU operations and branch resolution
- **MEM (Memory Access)**: Access data memory
- **WB (Write Back)**: Write results back to register file

## Types of Hazards

### 1. Data Hazards (Read-After-Write - RAW)
Occur when an instruction depends on the result of a previous instruction that hasn't completed yet.

**Example:**
```assembly
ADD x3, x1, x2    # EX stage: writing to x3
SUB x4, x3, x1    # ID stage: needs x3 (not ready yet)
```

### 2. Control Hazards
Occur when the pipeline doesn't know which instruction to fetch next due to branch instructions.

**Example:**
```assembly
BEQ x1, x2, target    # Branch instruction in EX stage
ADD x3, x4, x5        # Already fetched (might be wrong)
SUB x6, x7, x8        # Already fetched (might be wrong)
target: OR x9, x10, x11  # Correct instruction if branch taken
```

## Data Hazard Handling

### Detection Mechanisms

The hazard unit detects data hazards by comparing register addresses:

```verilog
// EX stage hazard detection
assign ex_rs1_hazard = EXWE && (EXRD != 5'b0) && (EXRD == ADDR1);
assign ex_rs2_hazard = EXWE && (EXRD != 5'b0) && (EXRD == ADDR2);

// MEM stage hazard detection  
assign mem_rs1_hazard = MEMWE && (MEMRD != 5'b0) && (MEMRD == ADDR1);
assign mem_rs2_hazard = MEMWE && (MEMRD != 5'b0) && (MEMRD == ADDR2);
```

### Resolution Strategies

#### 1. Data Forwarding (Bypass)
Forward data from later pipeline stages to earlier stages when possible.

**Forwarding Sources:**
- `2'b01`: Forward from EX/MEM pipeline register
- `2'b10`: Forward from MEM/WB pipeline register
- `2'b00`: No forwarding (use register file data)

**Implementation:**
```verilog
if (ex_rs1_hazard && !EXMEMR) begin
    FDATA1SEL = 2'b01;  // Forward from EX/MEM
end else if (mem_rs1_hazard) begin
    FDATA1SEL = 2'b10;  // Forward from MEM/WB
end
```

#### 2. Pipeline Stalling
Stall the pipeline when forwarding is not possible (load-use hazard).

```verilog
assign load_use_hazard = EXMEMR && (EXRD != 5'b0) && 
                        ((EXRD == ADDR1) || (EXRD == ADDR2));

if (load_use_hazard) begin
    PC_STALL = 1'b1;
    IF_ID_STALL = 1'b1;
    PIPELINE_STALL = 1'b1;
end
```

### Hazard Scenarios

#### Scenario 1: ALU-to-ALU Forwarding
```assembly
ADD x3, x1, x2    # EX stage: x3 = x1 + x2
SUB x4, x3, x1    # ID stage: needs x3
```
**Solution**: Forward ALU result directly to next instruction

#### Scenario 2: Load-Use Hazard
```assembly
LW x3, 0(x1)      # EX stage: loading x3 from memory
ADD x4, x3, x2    # ID stage: needs x3 immediately
```
**Solution**: Insert pipeline bubble (stall) for one cycle

## Control Hazard Handling

### Detection
```verilog
// Branch instruction detected in ID stage
input IS_BRANCH_ID;
// Branch instruction in EX stage with decision
input IS_BRANCH_EX;
input BRANCH_TAKEN;
```

### Resolution Strategies

#### 1. Pipeline Stalling
When a branch is detected in ID stage, stall the pipeline until resolution.

```verilog
if (IS_BRANCH_ID && !RESET) begin
    PC_STALL = 1'b1;       // Don't fetch new instruction
    IF_ID_STALL = 1'b1;    // Hold current IF/ID register
    CONTROL_HAZARD = 1'b1;
end
```

#### 2. Pipeline Flushing
When branch decision is made, flush incorrect instructions.

```verilog
if (IS_BRANCH_EX && BRANCH_TAKEN) begin
    IF_ID_FLUSH = 1'b1;   // Flush wrong instruction
    ID_EX_FLUSH = 1'b1;   // Flush wrong instruction
    PC_MUX_SEL = 1'b1;    // Jump to branch target
end
```

## Implementation Architecture

### Enhanced Hazard Unit

The `ENHANCED_HAZARD_UNIT` handles both data and control hazards with priority:

**Priority Order:**
1. **Control Hazards** (Highest Priority)
2. **Load-Use Data Hazards** (Requires Stall)
3. **Data Forwarding** (Lowest Priority)

### Key Components

#### 1. Hazard Detection Logic
```verilog
// Data hazard detection
wire ex_rs1_hazard, ex_rs2_hazard;
wire mem_rs1_hazard, mem_rs2_hazard;
wire load_use_hazard;

// Control hazard detection
wire control_hazard = IS_BRANCH_ID || IS_BRANCH_EX;
```

#### 2. Control Signal Generation
```verilog
output reg [1:0] FDATA1SEL, FDATA2SEL;  // Data forwarding
output reg PC_STALL, IF_ID_STALL;       // Pipeline stalling
output reg IF_ID_FLUSH, ID_EX_FLUSH;    // Pipeline flushing
output reg PC_MUX_SEL;                  // PC source selection
```

## Pipeline Register Modifications

### IF/ID Pipeline Register
```verilog
module IF_ID_REG(
    input CLK, RESET,
    input STALL,        // Hold current values
    input FLUSH,        // Insert NOP bubble
    input [31:0] PC_IN, INSTRUCTION_IN,
    output reg [31:0] PC_OUT, INSTRUCTION_OUT
);

always @(posedge CLK) begin
    if (RESET || FLUSH) begin
        PC_OUT <= 32'h00000000;
        INSTRUCTION_OUT <= 32'h00000013;  // NOP
    end else if (!STALL) begin
        PC_OUT <= PC_IN;
        INSTRUCTION_OUT <= INSTRUCTION_IN;
    end
    // If STALL, maintain current values
end
```

### ID/EX Pipeline Register
```verilog
module ID_EX_REG(
    input CLK, RESET,
    input FLUSH,        // Insert NOP bubble
    // ... other inputs/outputs
);

always @(posedge CLK) begin
    if (RESET || FLUSH) begin
        // Disable all control signals
        REG_WRITE_OUT <= 1'b0;
        MEM_READ_OUT <= 1'b0;
        MEM_WRITE_OUT <= 1'b0;
        // ... clear all outputs
    end else begin
        // Normal operation
    end
end
```

### Program Counter with Stall
```verilog
module PC_HAZARD(
    input CLK, RESET,
    input PC_STALL,           // Don't update PC
    input PC_MUX_SEL,         // Select PC source
    input [31:0] PC_PLUS_4, BRANCH_TARGET,
    output reg [31:0] PC_OUT
);

always @(posedge CLK) begin
    if (RESET) begin
        PC_OUT <= 32'h00000000;
    end else if (!PC_STALL) begin
        PC_OUT <= PC_MUX_SEL ? BRANCH_TARGET : PC_PLUS_4;
    end
    // If PC_STALL, maintain current PC
end
```

## Performance Impact

### Cycle Penalties
- **Data Forwarding**: 0 cycles (no penalty)
- **Load-Use Stall**: 1 cycle penalty
- **Branch Stall**: 1-2 cycle penalty
- **Branch Misprediction**: 2-3 cycle penalty

### Optimization Techniques
1. **Early Branch Resolution**: Resolve branches in ID stage
2. **Branch Prediction**: Predict branch outcomes
3. **Delayed Branching**: Execute useful instructions in delay slots
4. **Multiple Forwarding Paths**: Reduce stall scenarios

## Integration Requirements

### Connection to CPU
```verilog
// Instantiate hazard unit in main CPU
ENHANCED_HAZARD_UNIT hazard_unit (
    .CLK(CLK), .RESET(RESET),
    // Data hazard inputs
    .ADDR1(rs1_addr), .ADDR2(rs2_addr),
    .EXRD(id_ex_rd), .MEMRD(ex_mem_rd),
    .EXWE(id_ex_reg_write), .MEMWE(ex_mem_reg_write),
    .EXMEMR(id_ex_mem_read),
    // Control hazard inputs
    .IS_BRANCH_ID(is_branch_id),
    .IS_BRANCH_EX(is_branch_ex),
    .BRANCH_TAKEN(branch_taken),
    .BRANCH_TARGET(branch_target),
    // Control outputs
    .FDATA1SEL(fdata1sel), .FDATA2SEL(fdata2sel),
    .PC_STALL(pc_stall), .IF_ID_STALL(if_id_stall),
    .IF_ID_FLUSH(if_id_flush), .ID_EX_FLUSH(id_ex_flush),
    .PC_MUX_SEL(pc_mux_sel)
);
```

### Forwarding Multiplexers
```verilog
// Data forwarding logic
always @(*) begin
    case (fdata1sel)
        2'b00: forwarded_data1 = reg_file_data1;
        2'b01: forwarded_data1 = ex_mem_result;
        2'b10: forwarded_data1 = mem_wb_result;
        default: forwarded_data1 = reg_file_data1;
    endcase
end
```

This hazard handling implementation ensures correct program execution while maintaining pipeline performance through intelligent forwarding and minimal stalling.
