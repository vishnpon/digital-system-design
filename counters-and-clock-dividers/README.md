# Up Counter with Selectable Clock Speed
a 3-bit synchronous up counter built from half adder primitives, with a clock divider and selectable frequency output

## Overview
this project builds a 3-bit up counter from the ground up using half adders as the base primitive. rather than using a built-in counter, the design chains half adders together to compute the next count value combinationally, then latches it on the rising clock edge. a clock divider generates four different frequencies from the board's fast clock, and a behavioral 4-way mux lets you pick between them in real time using the switches — the count shows up across the LEDs

## Architecture
the design is made up of the following modules connected structurally at the top level:

* **Half Adder:** computes a 1-bit sum and carry — the base building block for everything else
* **Three-Bit Counter:** chains three half adders to ripple carry across 3 bits and compute the next count value
* **Up Counter:** wraps the three-bit counter in a sequential always block, latching on the rising edge with synchronous reset support
* **Clock Divider:** uses a 27-bit internal counter to divide the fast clock into four progressively slower output frequencies
* **Top Level:** connects everything and implements a behavioral case-statement mux to route the selected clock to the counter

## Features
* 4 selectable clock speeds controlled by SW[1:0]
* push button enable (BTN0) and synchronous reset (BTN1)
* 3-bit count output on LEDs[2:0], carry out on LED[3]
* fully structural design built entirely from half adder primitives

## Modules of this Project

* __half_adder.v__ - 1-bit half adder, base primitive used to build the counter
* __up_counter.v__ - 3-bit synchronous up counter with enable and reset, includes three-bit counter submodule
* __clock_divider.v__ - divides fast clock input into 4 selectable output frequencies
* __top_level.v__ - top-level module wiring everything together with the 4-way clock mux

## Simulation Results
waveforms confirmed correct counting behavior at each clock speed, with enable and reset verified across all frequencies

  ## Up Counter
  <img width="1217" height="223" alt="up_counter" src="https://github.com/user-attachments/assets/978ec899-4bde-4e9b-be13-7ff2d2481ccf" />

  ## No Debounce
  <img width="1215" height="232" alt="no_debounce" src="https://github.com/user-attachments/assets/00d1386d-b3c4-46fa-8679-4327aab309ac" />

  ## With Debounce
  <img width="1217" height="190" alt="with_debounce" src="https://github.com/user-attachments/assets/7d4d2c88-39d7-484f-a7cc-d55d08d4ff6c" />


## Implementation
developed and tested using Xilinx Vivado on the Digilent Zybo Z7-10 FPGA board — shows how sequential counting behavior can be built entirely from basic combinational primitives like half adders
