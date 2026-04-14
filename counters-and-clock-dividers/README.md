# Up Counter with Selectable Clock Speed
a 3-bit synchronous up counter driven by a configurable clock divider, with hardware-selectable frequency and LED output

## Overview
this project implements a 3-bit up counter built entirely from half adder primitives, paired with a clock divider that generates four distinct clock frequencies from the FPGA's onboard fast clock. a 4-way behavioral mux allows the user to select between clock speeds in real time using the onboard switches, with the count value displayed across the LEDs. push buttons control enable and synchronous reset behavior.

## Architecture
the design is broken into the following modules, connected structurally at the top level:

- **Half Adder:** the fundamental building block — computes a 1-bit sum and carry output
- **Three-Bit Counter:** chains three half adders to form a full 3-bit ripple counter, computing the next count value combinationally
- **Up Counter:** wraps the three-bit counter in a sequential always block, latching the sum on the rising clock edge and supporting synchronous reset
- **Clock Divider:** uses a 27-bit internal counter to divide the fast clock down into four progressively slower frequencies, output as a 4-bit bus
- **Top Level:** connects all submodules; implements a behavioral 4-way mux to select the active clock speed based on switch input

## Features
- 4 selectable clock speeds via onboard switches (SW[1:0])
- push button enable (BTN0) and synchronous reset (BTN1)
- count output displayed across 3 LEDs, with carry out on the fourth
- fully structural design from half adder primitives up to the top level

## Modules
- **`half_adder.v`** — 1-bit half adder, the base primitive for the counter
- **`up_counter.v`** — 3-bit synchronous up counter with enable and reset, includes the three-bit counter submodule
- **`clock_divider.v`** — generates 4 divided clock frequencies from the fast input clock
- **`top_level.v`** — top-level structural module connecting all components with a 4-way clock mux

## Simulation Results
waveforms verified correct counting behavior across all four clock speeds, with enable and reset functioning as expected at each clock frequency

## Implementation
developed and tested using Xilinx Vivado on the Digilent Zybo Z7-10 FPGA board — demonstrates how complex sequential behavior can be built up entirely from simple combinational primitives
