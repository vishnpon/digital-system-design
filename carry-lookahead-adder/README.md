# Carry Lookahead Adder - High Speed Addition
a 16-bit two-level carry lookahead adder that computes all carries in parallel, reducing critical path depth compared to its ripple carry counterpart

## Overview
this project implements both a 4-bit and 16-bit CLA using a modular, hierarchical design. the CLA solves the sequential carry propagation bottleneck in ripple-carry adders by computing all carry signals simultaneously using generate (G) and propagate (P) logic. the 4-bit design was built first from three submodules using dataflow Verilog, then extended to 16 bits by adding block carry-lookahead units that handle inter-group carry propagation across four 4-bit sections

## Architecture
the design is made up of the following key modules:

* **Generate/Propagate Unit:** computes per-bit generate (G = X & Y) and propagate (P = X ^ Y) signals for all bits in parallel using dataflow Verilog
* **Carry Lookahead Unit (CLAU):** uses the full boolean carry equations to calculate all four carry outputs simultaneously given G, P, and carry-in
* **Summation Unit:** produces the final sum by XOR-ing each propagate signal with its corresponding carry input
* **Block Carry Lookahead Unit (BCLAU):** generates block-level G* and P* signals across each 4-bit group, enabling the two-level 16-bit design
* **4-bit CLA Top Level:** structurally connects the GPU, CLAU, and summation unit into a complete 4-bit adder
* **16-bit CLA Top Level:** instantiates four BCLAUs, one top-level CLAU for block carry inputs, and the shared GPU and summation unit

## Performance
The two-level CLA structure reduces carry-chain depth from N gate levels (ripple carry) to log(N) levels. Four BCLAUs compute within-block carries in parallel; one CLAU resolves the four block carries (C4, C8, C12, C16) simultaneously. Post-synthesis timing pending.

## Modules of this Project

* __generate_propagate_unit.v__ - computes G and P signals for all bit positions
* __carry_lookahead_unit.v__ - 4-bit carry computation using boolean carry equations
* __summation_unit.v__ - final sum calculation via XOR of propagate and carry vectors
* __carry_lookahead_4bit.v__ - top-level structural module for the complete 4-bit CLA
* __block_carrylookahead_unit.v__ - block-level G* and P* generation for the 16-bit design
* __carry_lookahead_16bit.v__ - top-level structural module for the full 16-bit two-level CLA
* __tb_cla16.sv__ - self-checking testbench for the 16-bit CLA (directed edge cases, carry-propagation sweeps across block boundaries, and randomized comparison against a behavioral reference)

## Verification
Self-checking testbench (tb_cla16.sv): 20,160 vectors across three phases — 32 directed edge cases (including carry-chain boundary cases and alternating patterns, each with both Cin values), 128 carry-propagation sweeps targeting the block boundaries at bits 3/4, 7/8, and 11/12, and 20,000 randomized vectors compared against a behavioral A + B + Cin reference.

Result: PASS — 0 failures out of 20,160 vectors.

Simulated with Cadence Xcelium 25.03.

Note: Post-synthesis timing numbers pending Vivado implementation run.

## Simulation Results
**4-bit CLA Waveform**
<img width="1295" height="306" alt="4_bit_cla1" src="https://github.com/user-attachments/assets/4524477c-5701-41fc-9a99-59ba338fcd81" />
<img width="1291" height="294" alt="4_bit_cla2" src="https://github.com/user-attachments/assets/bc139194-8e42-4f2e-ac9e-9c57b16297c6" />

**16-bit CLA Waveform**
<img width="1233" height="233" alt="16_bit_cla1" src="https://github.com/user-attachments/assets/29656855-420a-4fe8-99d2-901ada7bed5a" />
<img width="1101" height="206" alt="16_bit_cla2" src="https://github.com/user-attachments/assets/7919aa7f-5d1a-4712-a73e-ffac3e85335d" />

## Implementation
synthesized and deployed on the Digilent Zybo Z7-10 FPGA board using Xilinx Vivado, with functional verification of the testbench run in Cadence Xcelium — demonstrates how parallel carry computation reduces critical path depth compared to the sequential carry chain of ripple carry designs
