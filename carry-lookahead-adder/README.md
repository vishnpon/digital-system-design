# Carry Lookahead Adder — High Speed Addition
a 16-bit two-level carry lookahead adder that computes all carries in parallel, achieving 4x lower propagation delay than an equivalent ripple carry adder

## Overview
this project implements both a 4-bit and a 16-bit carry lookahead adder using a hierarchical, modular design. the CLA eliminates the sequential carry propagation bottleneck found in ripple carry adders by computing all carry signals simultaneously using generate (G) and propagate (P) logic. the 4-bit design was built first from three submodules, then extended to 16 bits using block carry-lookahead units that compute block-level G* and P* signals across four 4-bit sections.

## Architecture
the design is built from the following modules:

- **Generate/Propagate Unit:** computes per-bit generate (G = X & Y) and propagate (P = X ^ Y) signals for all 16 bits simultaneously using dataflow Verilog
- **Carry Lookahead Unit (CLAU):** takes G, P, and carry-in to calculate all four carry outputs at once using the full boolean carry equations
- **Summation Unit:** produces the final sum bits by XOR-ing the propagate signals with their corresponding carry inputs
- **Block Carry Lookahead Unit (BCLAU):** extends the CLAU to produce block-level generate (G*) and propagate (P*) signals, enabling the two-level 16-bit design
- **4-bit CLA Top Level:** structural module connecting the GPU, CLAU, and summation unit into a complete 4-bit adder
- **16-bit CLA Top Level:** instantiates four BCLAUs, one top-level CLAU for inter-block carries, and the shared GPU and summation unit

## Performance
- **4-bit CLA:** 8ns propagation delay — 4 gate levels at 2ns each (1 for G/P, 2 for carries, 1 for sum)
- **16-bit CLA:** 16ns propagation delay — 8 gate levels at 2ns each, 4x faster than a 16-bit ripple carry at 64ns
- **Gate delay:** 2ns per logic level applied to all assign statements for realistic timing simulation

## Modules
- **`generate_propagate_unit.v`** — computes G and P signals for all bit positions
- **`carry_lookahead_unit.v`** — 4-bit carry computation using boolean carry equations
- **`summation_unit.v`** — final sum calculation via XOR of propagate and carry vectors
- **`carry_lookahead_4bit.v`** — top-level structural module for the 4-bit CLA
- **`block_carrylookahead_unit.v`** — block-level G* and P* generation for the 16-bit design
- **`carry_lookahead_16bit.v`** — top-level structural module for the full 16-bit two-level CLA

## Simulation Results
both adders were simulated and verified using Vivado XSim. the 4-bit testbench confirmed all test cases passed at 8ns delay. the 16-bit testbench confirmed all test cases passed at 16ns delay, with waveforms showing correct carry propagation across all four 4-bit blocks

## Implementation
developed and tested using Xilinx Vivado on the Digilent Zybo Z7-10 FPGA board — demonstrates how parallel carry computation significantly reduces critical path delay compared to sequential ripple carry propagation
