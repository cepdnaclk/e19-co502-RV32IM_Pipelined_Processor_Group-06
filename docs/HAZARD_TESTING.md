# Hazard Handling Testing Documentation

## Table of Contents
1. [Testing Overview](#testing-overview)
2. [Data Hazard Testing](#data-hazard-testing)
3. [Control Hazard Testing](#control-hazard-testing)
4. [Integration Testing](#integration-testing)
5. [Test Results Analysis](#test-results-analysis)
6. [Debugging and Verification](#debugging-and-verification)

## Testing Overview

This document describes the comprehensive testing strategy for hazard handling in the RISC-V pipelined processor. The testing approach validates both individual component behavior and integrated system performance.

### Testing Philosophy
- **Unit Testing**: Individual hazard detection components
- **Integration Testing**: Complete hazard handling system
- **Functional Testing**: Real instruction sequences
- **Edge Case Testing**: Corner cases and boundary conditions
- **Performance Testing**: Pipeline efficiency and cycle counts

### Test Environment
- **Simulator**: Icarus Verilog (iverilog)
- **Waveform Viewer**: GTKWave
- **File Format**: VCD (Value Change Dump)
- **Language**: Verilog HDL with SystemVerilog assertions

## Data Hazard Testing

### Test Structure Overview

The data hazard testbench (`hazard_unit_tb.v`) provides comprehensive validation of the hazard detection and forwarding logic.

```verilog
module hazard_unit_tb();
    // Input signals
    reg [4:0] ADDR1, ADDR2, EXRD, MEMRD;  // Register addresses
    reg EXWE, MEMWE, EXMEMR;              // Control signals
    
    // Output signals  
    wire [1:0] FDATA1SEL, FDATA2SEL;      // Forwarding selectors
    wire BUBBLE, STALL;                   // Pipeline control
    
    // Device under test
    HAZARD_UNIT dut (.ADDR1(ADDR1), ...);
```

### Test Cases

#### Test Case 1: No Hazard Scenario
```verilog
test_hazard(5'd1, 5'd2, 5'd3, 5'd4, 1'b1, 1'b1, 1'b0, 
           "No Hazard - Different registers");
```
**Purpose**: Validate normal operation without dependencies
**Expected Output**: `FDATA1SEL=00, FDATA2SEL=00, BUBBLE=0, STALL=0`

#### Test Case 2: EX Stage ALU Forwarding
```verilog
test_hazard(5'd3, 5'd2, 5'd3, 5'd4, 1'b1, 1'b1, 1'b0,
           "EX Stage Forwarding - ADD x3,x1,x2; SUB x4,x3,x1");
```
**Instruction Sequence**:
```assembly
ADD x3, x1, x2    # EX stage: produces x3
SUB x4, x3, x1    # ID stage: needs x3
```
**Expected Output**: `FDATA1SEL=01` (forward from EX/MEM register)

#### Test Case 3: MEM Stage Forwarding
```verilog
test_hazard(5'd3, 5'd2, 5'd1, 5'd3, 1'b1, 1'b1, 1'b0,
           "MEM Stage Forwarding - Previous instruction result");
```
**Expected Output**: `FDATA1SEL=10` (forward from MEM/WB register)

#### Test Case 4: Load-Use Hazard (Critical Test)
```verilog
test_hazard(5'd3, 5'd2, 5'd3, 5'd4, 1'b1, 1'b1, 1'b1,
           "Load-Use Hazard - LW x3,0(x1); ADD x4,x3,x2");
```
**Instruction Sequence**:
```assembly
LW x3, 0(x1)      # EX stage: loading x3 from memory
ADD x4, x3, x2    # ID stage: needs x3 immediately
```
**Expected Output**: `BUBBLE=1, STALL=1` (pipeline stall required)

#### Test Case 5: Multiple Operand Forwarding
```verilog
test_hazard(5'd3, 5'd4, 5'd3, 5'd4, 1'b1, 1'b1, 1'b0,
           "Both Operands Forward - EX:x3, MEM:x4");
```
**Expected Output**: `FDATA1SEL=01, FDATA2SEL=10` (both operands forwarded)

#### Test Case 6: Register x0 Special Case
```verilog
test_hazard(5'd0, 5'd2, 5'd0, 5'd4, 1'b1, 1'b1, 1'b0,
           "Register x0 Test - Should not forward");
```
**Purpose**: Verify that writes to x0 (hardwired to 0) don't trigger forwarding
**Expected Output**: `FDATA1SEL=00` (no forwarding for x0)

### Test Output Analysis

Each test produces detailed output for verification:

```
Test: EX Stage Forwarding - ADD x3,x1,x2; SUB x4,x3,x1
  Inputs: ADDR1=3, ADDR2=2, EXRD=3, MEMRD=4
  Control: EXWE=1, MEMWE=1, EXMEMR=0
  Output: FDATA1SEL=01, FDATA2SEL=00, BUBBLE=0, STALL=0
  Action: FORWARD DATA
```

### Running Data Hazard Tests

```bash
# Compile and run the testbench
iverilog -o hazard_test hazard_unit_tb.v hazard_unit.v
./hazard_test

# Generate waveform for analysis
gtkwave hazard_unit_tb.vcd &
```

## Control Hazard Testing

### Control Hazard Test Structure

The control hazard testbench validates branch prediction and pipeline flushing:

```verilog
module control_hazard_tb();
    // Control inputs
    reg IS_BRANCH_ID, IS_BRANCH_EX, BRANCH_TAKEN;
    reg [31:0] BRANCH_TARGET;
    
    // Control outputs
    wire PC_STALL, IF_ID_STALL, IF_ID_FLUSH, ID_EX_FLUSH;
    wire PC_MUX_SEL;
```

### Control Hazard Test Cases

#### Test Case 1: Branch Detection in ID Stage
```verilog
test_control_hazard(1'b1, 1'b0, 1'b0, 32'h00000100,
                   "Branch detected in ID stage - stall pipeline");
```
**Expected**: Pipeline stalls until branch resolves

#### Test Case 2: Branch Taken - Flush Pipeline
```verilog
test_control_hazard(1'b0, 1'b1, 1'b1, 32'h00000200,
                   "Branch taken - flush wrong instructions");
```
**Expected**: Flush IF/ID and ID/EX registers, jump to target

#### Test Case 3: Branch Not Taken - Continue
```verilog
test_control_hazard(1'b0, 1'b1, 1'b0, 32'h00000200,
                   "Branch not taken - continue sequential");
```
**Expected**: No flush, continue with next instruction

## Integration Testing

### Full CPU Integration Test

The integrated CPU test validates the complete hazard handling system:

```verilog
module cpu_hazard_integration_tb();
    // Full CPU instantiation with hazard handling
    CPU_WITH_HAZARDS cpu (
        .CLK(clk), .RESET(reset),
        .INSTRUCTION_OUT(instruction),
        .PC_OUT(pc_out),
        .ALU_RESULT(alu_result)
    );
    
    // Memory initialization with test program
    initial begin
        // Load test program into instruction memory
        $readmemh("hazard_test_program.mem", cpu.inst_mem.memory);
    end
```

### Test Program Examples

#### Data Hazard Test Program
```assembly
# hazard_test_program.mem
00000000: 00208133  # ADD x2, x1, x2    (no hazard)
00000004: 002081B3  # ADD x3, x1, x2    (no hazard)
00000008: 00318233  # ADD x4, x3, x3    (RAW hazard on x3)
0000000C: 00420293  # ADDI x5, x4, 4    (RAW hazard on x4)
00000010: 0002A303  # LW x6, 0(x5)      (load instruction)
00000014: 00630333  # ADD x6, x6, x6    (load-use hazard)
```

#### Control Hazard Test Program
```assembly
# branch_test_program.mem
00000000: 00100093  # ADDI x1, x0, 1
00000004: 00200113  # ADDI x2, x0, 2
00000008: 00209463  # BNE x1, x2, skip   (branch instruction)
0000000C: 00300193  # ADDI x3, x0, 3     (should be flushed)
00000010: 00400213  # ADDI x4, x0, 4     (should be flushed)
00000014: 00500293  # skip: ADDI x5, x0, 5
```

### Integration Test Verification

```verilog
// Monitor pipeline state
always @(posedge clk) begin
    $display("Cycle %0d: PC=%h, IF/ID=%h, ID/EX=%h", 
             cycle_count, pc_out, if_id_instruction, id_ex_instruction);
    
    if (cpu.hazard_unit.PIPELINE_STALL)
        $display("  -> PIPELINE STALLED (Load-Use Hazard)");
    
    if (cpu.hazard_unit.IF_ID_FLUSH)
        $display("  -> IF/ID FLUSHED (Control Hazard)");
end
```

## Test Results Analysis

### Expected Behavior Verification

#### Data Hazard Resolution
```
Cycle 1: ADD x3, x1, x2 (EX stage)
Cycle 2: SUB x4, x3, x1 (ID stage) - Forward x3 from EX
Result: FDATA1SEL=01, no stall required
```

#### Load-Use Hazard Resolution
```
Cycle 1: LW x3, 0(x1) (EX stage)
Cycle 2: ADD x4, x3, x2 (ID stage) - Cannot forward, must stall
Cycle 3: ADD x4, x3, x2 (ID stage) - Now x3 is available
Result: One cycle bubble inserted
```

#### Branch Hazard Resolution
```
Cycle 1: BEQ x1, x2, target (ID stage) - Stall pipeline
Cycle 2: Pipeline stalled
Cycle 3: Branch decision made, flush if taken
Result: 1-2 cycle penalty depending on branch outcome
```

### Performance Metrics

#### Pipeline Efficiency
- **No Hazards**: 1 instruction per cycle (IPC = 1.0)
- **Data Forwarding**: IPC = 1.0 (no penalty)
- **Load-Use Stall**: IPC = 0.5 for affected instructions
- **Branch Penalty**: IPC = 0.33-0.5 for branch instructions

#### Test Coverage
- **Data Hazard Types**: 100% (all RAW combinations tested)
- **Control Hazard Types**: 100% (branch taken/not taken)
- **Edge Cases**: Register x0, disabled writes, multiple hazards
- **Integration**: Full CPU with realistic instruction sequences

## Debugging and Verification

### GTKWave Analysis

#### Signal Grouping for Analysis
```
Hazard Detection:
  - ADDR1, ADDR2 (source registers)
  - EXRD, MEMRD (destination registers)
  - EXWE, MEMWE (write enables)

Hazard Resolution:
  - FDATA1SEL, FDATA2SEL (forwarding)
  - PC_STALL, IF_ID_STALL (stalling)
  - IF_ID_FLUSH, ID_EX_FLUSH (flushing)

Pipeline State:
  - PC, IF/ID_PC, ID/EX_PC
  - IF/ID_INST, ID/EX_INST
  - CLK, RESET
```

#### Common Debug Scenarios

**Problem**: Unnecessary stalls
**Debug**: Check forwarding logic and write enable signals

**Problem**: Incorrect forwarding
**Debug**: Verify register address comparisons and priority logic

**Problem**: Control hazard not detected
**Debug**: Check branch instruction decoding and timing

### Automated Test Scripts

```bash
#!/bin/bash
# run_hazard_tests.sh

echo "Running Hazard Unit Tests..."

# Data hazard tests
iverilog -o hazard_test hazard_unit_tb.v enhanced_hazard_unit.v
./hazard_test > hazard_test_results.log

# Control hazard tests  
iverilog -o control_test control_hazard_tb.v enhanced_hazard_unit.v
./control_test > control_test_results.log

# Integration tests
iverilog -o cpu_test cpu_hazard_integration_tb.v cpu_with_hazards.v
./cpu_test > cpu_test_results.log

echo "All tests completed. Check log files for results."
```

### Test Success Criteria

#### Functional Requirements
1. **Correctness**: All hazards detected and resolved properly
2. **Performance**: Minimal unnecessary stalls or flushes
3. **Coverage**: All hazard scenarios tested
4. **Integration**: Proper interaction with pipeline registers

#### Verification Checklist
- [ ] Data forwarding works for all combinations
- [ ] Load-use hazards cause appropriate stalls
- [ ] Branch hazards trigger correct flush/stall behavior
- [ ] Register x0 handling is correct
- [ ] Write enable signals properly gate hazard detection
- [ ] Priority logic handles multiple simultaneous hazards
- [ ] Integration with CPU produces correct execution results

This comprehensive testing approach ensures robust hazard handling that maintains both correctness and performance in the pipelined processor implementation.
