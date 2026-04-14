# Carry Lookahead Adder - High Speed Addition
a 16-bit two-level carry lookahead adder that computes all carries in parallel, achieving significantly faster performance than its ripple carry counterpart

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
the 16-bit adder uses a two-level structure with four 4-bit blocks, each handled by its own BCLAU

* **4-bit CLA:** 8ns propagation delay (4 gate levels × 2ns — 1 for G/P, 2 for carries, 1 for sum)
* **16-bit CLA:** 16ns propagation delay (8 gate levels × 2ns), 4x faster than a 16-bit ripple carry at 64ns
* **Gate Delay:** 2ns per logic level added to all assign statements for realistic timing simulation

## Modules of this Project

* __generate_propagate_unit.v__ - computes G and P signals for all bit positions
* __carry_lookahead_unit.v__ - 4-bit carry computation using boolean carry equations
* __summation_unit.v__ - final sum calculation via XOR of propagate and carry vectors
* __carry_lookahead_4bit.v__ - top-level structural module for the complete 4-bit CLA
* __block_carrylookahead_unit.v__ - block-level G* and P* generation for the 16-bit design
* __carry_lookahead_16bit.v__ - top-level structural module for the full 16-bit two-level CLA

## Simulation Results
**4-bit CLA Waveform**
<img width="1295" height="306" alt="4_bit_cla1" src="https://github.com/user-attachments/assets/4524477c-5701-41fc-9a99-59ba338fcd81" />
<img width="1291" height="294" alt="4_bit_cla2" src="https://github.com/user-attachments/assets/bc139194-8e42-4f2e-ac9e-9c57b16297c6" />

**16-bit CLA Waveform**
<img width="1233" height="233" alt="16_bit_cla1" src="https://github.com/user-attachments/assets/29656855-420a-4fe8-99d2-901ada7bed5a" />
<img width="1101" height="206" alt="16_bit_cla2" src="https://github.com/user-attachments/assets/7919aa7f-5d1a-4712-a73e-ffac3e85335d" />

## Implementation
developed and tested using Xilinx Vivado on the Digilent Zybo Z7-10 FPGA board — demonstrates how parallel carry computation drastically cuts critical path delay compared to the sequential bottlenecking of ripple carry designs
