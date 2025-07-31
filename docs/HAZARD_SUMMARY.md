# Hazard Handling Implementation Summary

## Quick Reference Guide

This document provides a concise overview of the hazard handling implementation for quick reference and implementation guidance.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    RISC-V Pipeline with Hazard Handling         │
├─────────────┬─────────────┬─────────────┬─────────────┬─────────┤
│     IF      │     ID      │     EX      │    MEM      │   WB    │
│             │             │             │             │         │
│ PC ────────▶│ REG_FILE   │ ALU        │ DATA_MEM   │ REG     │
│ INST_MEM   │ HAZARD_UNIT │ BRANCH     │             │ WRITE   │
│             │             │             │             │         │
└─────────────┴─────────────┴─────────────┴─────────────┴─────────┘
                      │
                      ▼
           ┌─────────────────────────┐
           │   ENHANCED_HAZARD_UNIT  │
           │  ┌─────────────────────┐│
           │  │  Data Hazard        ││
           │  │  Detection &        ││
           │  │  Forwarding         ││
           │  └─────────────────────┘│
           │  ┌─────────────────────┐│
           │  │  Control Hazard     ││
           │  │  Detection &        ││
           │  │  Resolution         ││
           │  └─────────────────────┘│
           └─────────────────────────┘
```

## Key Components

### 1. Enhanced Hazard Unit
**File**: `src/ID_Stage/HAZARD_UNIT/enhanced_hazard_unit.v`

**Inputs**:
- Register addresses: `ADDR1[4:0]`, `ADDR2[4:0]`, `EXRD[4:0]`, `MEMRD[4:0]`
- Control signals: `EXWE`, `MEMWE`, `EXMEMR`
- Branch signals: `IS_BRANCH_ID`, `IS_BRANCH_EX`, `BRANCH_TAKEN`

**Outputs**:
- Data forwarding: `FDATA1SEL[1:0]`, `FDATA2SEL[1:0]`
- Pipeline control: `PC_STALL`, `IF_ID_STALL`, `IF_ID_FLUSH`, `ID_EX_FLUSH`

### 2. Modified Pipeline Registers

#### IF/ID Register with Hazard Control
**File**: `src/PIPELINE_REG/IF_ID_REG/if_id_reg_hazard.v`
- **STALL**: Hold current values
- **FLUSH**: Insert NOP instruction

#### ID/EX Register with Hazard Control  
**File**: `src/PIPELINE_REG/ID_EX_REG/id_ex_reg_hazard.v`
- **FLUSH**: Clear all control signals

#### PC with Stall Capability
**File**: `src/IF_Stage/PC/pc_hazard.v`
- **PC_STALL**: Don't update PC
- **PC_MUX_SEL**: Select branch target vs. PC+4

### 3. Integrated CPU
**File**: `src/cpu_with_hazards.v`
- Complete CPU with hazard handling integration
- All control signals properly connected

## Hazard Resolution Summary

### Data Hazards

| Hazard Type | Detection | Resolution | Penalty |
|-------------|-----------|------------|---------|
| ALU-to-ALU | Address match | Forward from EX/MEM | 0 cycles |
| MEM-to-ALU | Address match | Forward from MEM/WB | 0 cycles |
| Load-Use | Load + immediate use | Pipeline stall | 1 cycle |

### Control Hazards

| Scenario | Detection | Resolution | Penalty |
|----------|-----------|------------|---------|
| Branch in ID | IS_BRANCH_ID | Stall pipeline | 1 cycle |
| Branch taken | BRANCH_TAKEN | Flush IF/ID, ID/EX | 2 cycles |
| Branch not taken | !BRANCH_TAKEN | Continue normally | 0 cycles |

## Critical Code Sections

### Data Forwarding Logic
```verilog
// Priority: EX stage over MEM stage forwarding
if (ex_rs1_hazard && !EXMEMR) begin
    FDATA1SEL = 2'b01;  // Forward from EX/MEM
end else if (mem_rs1_hazard) begin
    FDATA1SEL = 2'b10;  // Forward from MEM/WB  
end else begin
    FDATA1SEL = 2'b00;  // Use register file
end
```

### Load-Use Hazard Detection
```verilog
wire load_use_hazard = EXMEMR && (EXRD != 5'b0) && 
                      ((EXRD == ADDR1) || (EXRD == ADDR2));

if (load_use_hazard) begin
    PC_STALL = 1'b1;
    IF_ID_STALL = 1'b1;
    PIPELINE_STALL = 1'b1;
end
```

### Control Hazard Handling
```verilog
// Branch stall
if (IS_BRANCH_ID && !RESET) begin
    PC_STALL = 1'b1;
    IF_ID_STALL = 1'b1;
    CONTROL_HAZARD = 1'b1;
end

// Branch flush
if (IS_BRANCH_EX && BRANCH_TAKEN) begin
    IF_ID_FLUSH = 1'b1;
    ID_EX_FLUSH = 1'b1;
    PC_MUX_SEL = 1'b1;
end
```

## Testing Files

### Primary Test Files
1. **Data Hazard Testing**: `src/ID_Stage/HAZARD_UNIT/hazard_unit_tb.v`
2. **Control Hazard Testing**: `src/ID_Stage/HAZARD_UNIT/control_hazard_tb.v`
3. **Enhanced Unit Testing**: `src/ID_Stage/HAZARD_UNIT/enhanced_hazard_unit.v`

### Test Execution Commands
```bash
# Compile and run data hazard tests
iverilog -o hazard_test hazard_unit_tb.v enhanced_hazard_unit.v
./hazard_test

# Generate and view waveforms
gtkwave hazard_unit_tb.vcd &
```

## Integration Checklist

### CPU Integration Requirements
- [ ] Connect hazard unit to pipeline registers
- [ ] Implement forwarding multiplexers in ALU inputs
- [ ] Add branch target calculation in EX stage
- [ ] Connect stall/flush signals to pipeline registers
- [ ] Ensure proper reset behavior

### Validation Requirements
- [ ] All data hazard scenarios tested
- [ ] Load-use hazards properly stalled
- [ ] Branch hazards correctly handled
- [ ] No unnecessary stalls or flushes
- [ ] Register x0 special case handled
- [ ] Performance benchmarks met

## Performance Characteristics

### Typical CPI (Cycles Per Instruction)
- **No hazards**: 1.0 CPI
- **With data forwarding**: 1.0 CPI  
- **With load-use hazards**: 1.2-1.5 CPI
- **With branch penalties**: 1.3-1.8 CPI

### Optimization Opportunities
1. **Branch Prediction**: Reduce control hazard penalties
2. **Load Forwarding**: Forward from memory directly to ALU
3. **Delayed Branching**: Fill delay slots with useful instructions
4. **Out-of-Order Execution**: Advanced hazard handling

## Common Issues and Solutions

### Issue: Excessive Stalls
**Solution**: Verify forwarding paths are correctly implemented

### Issue: Incorrect Branch Behavior  
**Solution**: Check branch condition evaluation and target calculation

### Issue: Register x0 Forwarding
**Solution**: Ensure x0 writes don't trigger hazard detection

### Issue: Multiple Hazard Conflicts
**Solution**: Implement proper priority logic (control > load-use > forwarding)

This implementation provides robust hazard handling while maintaining pipeline performance through intelligent forwarding and minimal stalling strategies.
