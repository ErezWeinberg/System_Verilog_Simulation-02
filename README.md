# 32-bit Multiplier Implementations in SystemVerilog

This repository contains assignment number 2 in curse Digital Systems And Comp Structure in the Technion,
multiple implementations of 32-bit multipliers in SystemVerilog, demonstrating different design approaches and optimization techniques.


## Project Overview

This project implements hardware multipliers that can multiply two 32-bit unsigned integers to produce a 64-bit result. The repository includes both standard and optimized implementations, along with comprehensive testbenches.

## Modules

### 1. Standard 32x32 Multiplier (`mult32x32.sv`)

The main top-level module that implements a standard iterative 32x32 bit multiplier.

**Inputs:**
- `clk` - Clock signal
- `reset` - Asynchronous reset
- `start` - Signal to begin multiplication
- `a[31:0]` - First 32-bit operand
- `b[31:0]` - Second 32-bit operand

**Outputs:**
- `busy` - Indicates multiplier is processing
- `product[63:0]` - 64-bit multiplication result

**Architecture:**
The multiplier breaks down the 32x32 multiplication into smaller 8x16 bit multiplications, combining results with appropriate shifts and additions.

### 2. Arithmetic Unit (`mult32x32_arith.sv`)

Implements the datapath for the multiplier, handling byte/word selection, multiplication, shifting, and accumulation.

**Key Features:**
- Byte selector for operand A (selects one of four 8-bit bytes)
- Word selector for operand B (selects lower or upper 16-bit word)
- Configurable barrel shifter for partial product alignment
- Product accumulator with clear and update controls
- Zero detection for optimization (in fast variant)

### 3. Finite State Machine (`mult32x32_fsm.sv`)

Controls the multiplication sequence through 9 states:
- `IDLE` - Waiting for start signal
- `A0_B0` through `A3_B1` - Eight computation states processing different byte/word combinations

The FSM coordinates the arithmetic unit by generating control signals for byte/word selection, shifting, and product accumulation.

### 4. Fast/Optimized Multiplier (`mult32x32_fast.sv`)

An optimized version of the multiplier that includes early termination logic.

**Optimization:**
- Detects when the upper byte of operand A is zero
- Detects when the upper word of operand B is zero
- Skips unnecessary computation states when zeros are detected
- Reduces average multiplication time for numbers with leading zeros

### 5. Fast Arithmetic Unit (`mult32x32_fast_arith.sv`)

Extended arithmetic unit that provides zero detection outputs:
- `a_msb_is_0` - Indicates if the most significant byte of A is zero
- `b_msw_is_0` - Indicates if the most significant word of B is zero

### 6. Fast FSM (`mult32x32_fast_fsm.sv`)

Enhanced FSM that uses zero detection signals to skip states:
- If B's upper word is zero, transitions directly from `a3_b0` to `idle`
- Reduces computation time by up to 50% for suitable operands

### 7. Testbenches

**`mult32x32_test.sv`**
- Comprehensive testbench for standard multiplier
- Tests with large operands (322979956 × 300086550)
- Includes state probing for debugging
- Provides timing analysis and monitoring

**`mult32x32_fast_test.sv`**
- Testbench for optimized multiplier
- Tests early termination scenarios
- Verifies optimization correctness

### 8. RISC-V Assembly Implementation (`mult16x16.s`)

A 16x16 bit multiplier implementation in RISC-V assembly language demonstrating:
- Manual register management
- Use of 16x8 multiplication instructions
- Shift and add algorithm
- Memory operations for operand loading

## Design Methodology

### Multiplication Algorithm

The multipliers use a byte-wise multiplication approach:

1. **Decomposition**: Break 32-bit operands into smaller chunks
   - Operand A: Four 8-bit bytes (A0, A1, A2, A3)
   - Operand B: Two 16-bit words (B0, B1)

2. **Partial Products**: Compute 8x16=24 bit products
   - A0×B0, A1×B0, A2×B0, A3×B0
   - A0×B1, A1×B1, A2×B1, A3×B1

3. **Alignment**: Shift each partial product by appropriate amount
   - Products involving higher bytes/words are shifted left

4. **Accumulation**: Sum all shifted partial products to get final 64-bit result

### State Machine Flow

```
IDLE → (start) → A0_B0 → A1_B0 → A2_B0 → A3_B0 → A0_B1 → A1_B1 → A2_B1 → A3_B1 → IDLE
```

For the fast variant with optimization:
```
IDLE → (start) → A0_B0 → A1_B0 → A2_B0 → A3_B0 → (if b_msw_is_0) → IDLE
                                                 → (else) → A0_B1 → A1_B1 → A2_B1 → A3_B1 → IDLE
```

## Simulation Instructions

### Prerequisites
- ModelSim or QuestaSim (or compatible SystemVerilog simulator)
- SystemVerilog compiler supporting IEEE 1800-2012

### Running Simulations

#### For Standard Multiplier:
```bash
# Compile the design files
vlog mult32x32_arith.sv
vlog mult32x32_fsm.sv
vlog mult32x32.sv
vlog mult32x32_test.sv

# Run simulation
vsim mult32x32_test
run -all
```

#### For Fast Multiplier:
```bash
# Compile the design files
vlog mult32x32_fast_arith.sv
vlog mult32x32_fast_fsm.sv
vlog mult32x32_fast.sv
vlog mult32x32_fast_test.sv

# Run simulation
vsim mult32x32_fast_test
run -all
```

### Expected Output

The testbench monitors and displays:
- Time of each event
- Control signals (reset, start, busy)
- Input operands (a, b)
- Product output
- Internal state transitions (via probe module)

Example output:
```
Time= 0.00 ns reset=1 start=0 busy=0 a=0 b=0 product=0
Time=10.00 ns reset=0 start=0 busy=0 a=322979956 b=300086550 product=0
Time=20.00 ns reset=0 start=1 busy=1 a=322979956 b=300086550 product=0
...
Time=100.00 ns reset=0 start=0 busy=0 a=322979956 b=300086550 product=96919598452880
```

## File Structure

```
.
├── README.md                    # This file
├── mult16x16.s                  # RISC-V assembly 16x16 multiplier
├── mult32x32.sv                 # Standard multiplier top module
├── mult32x32_arith.sv           # Arithmetic unit (standard)
├── mult32x32_fsm.sv             # FSM controller (standard)
├── mult32x32_test.sv            # Testbench for standard multiplier
├── mult32x32_test.sv.bak        # Backup of testbench
├── mult32x32_fast.sv            # Optimized multiplier top module
├── mult32x32_fast_arith.sv      # Arithmetic unit (optimized)
├── mult32x32_fast_fsm.sv        # FSM controller (optimized)
├── mult32x32_fast_test.sv       # Testbench for optimized multiplier
├── vsim.wlf                     # ModelSim waveform file
└── work/                        # Compiled simulation files
```

## Performance Characteristics

### Standard Multiplier
- **Latency**: 9 clock cycles (fixed)
- **Throughput**: 1 multiplication per 9 cycles
- **Area**: Moderate (1 multiplier, 1 adder, registers)

### Fast/Optimized Multiplier
- **Latency**: 5-9 clock cycles (variable)
- **Best Case**: 5 cycles (when B[31:16] = 0)
- **Worst Case**: 9 cycles (same as standard)
- **Average**: ~7 cycles (depending on data distribution)
- **Area**: Slightly larger (additional zero detection logic)

## Design Trade-offs

### Standard Implementation
✅ Predictable timing (always 9 cycles)
✅ Simpler control logic
✅ Smaller area
❌ No optimization for sparse operands

### Fast Implementation
✅ Reduced latency for many operands
✅ Power savings (fewer state transitions)
❌ Variable latency (complicates timing analysis)
❌ Slightly larger area

## Learning Objectives

This project demonstrates:
1. **Hierarchical Design**: Separation of datapath and control
2. **FSM Design**: State machine implementation in SystemVerilog
3. **Arithmetic Optimization**: Trade-offs between speed and area
4. **Testbench Development**: Comprehensive verification methodology
5. **Hardware/Software Co-design**: Assembly language alternative

## Contributing

This is an educational project for Digital Systems and Computer Architecture courses.

## License

Educational use - part of Digital Systems and Computer Structure coursework.

## Course Information

**Course**: Digital Systems and Computer Structure  
**Project**: Simulation 02 - 32-bit Multiplier Implementations
