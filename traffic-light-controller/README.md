# Traffic Light Controller — Intersection Management System
an FSM-based traffic light controller managing a highway and farm road intersection, extended with a vehicle sensor for adaptive signal timing

## Overview
this project implements a traffic light controller as a Moore/Mealy hybrid FSM using behavioral Verilog. the base design cycles through 6 states controlling highway and farm road signals using a 32-bit hardware counter clocked at 125 MHz for accurate real-world timing. a second extended version adds two additional states and a farm road vehicle sensor (farmSensor) that dynamically adjusts signal timing — keeping the highway green until farm traffic is detected, and extending farm green while vehicles are present up to a maximum of 15 extra seconds.

## Architecture
the design is split across two modules per version — an FSM module and a top-level controller — following standard separation of concerns for FPGA design:

- **FSM Module (tlcfsm):** contains three separate always blocks — a combinational block for next state logic, a combinational block for the Mealy RstCount output, and a combinational block for Moore traffic signal outputs. a fourth sequential block handles the state register and synchronous reset
- **Top-Level Controller:** instantiates the FSM, a synchronizer for the reset button, and maintains a 32-bit counter that increments each clock cycle and resets when RstCount is asserted
- **Synchronizer:** handles metastability for asynchronous push button inputs before passing them into the FSM
- **Extended FSM (tlcfsm_modified):** adds S6 (extended highway green — waits indefinitely for farmSensor to go high) and S7 (extended farm green — holds while farmSensor is high, up to 15 additional seconds)

## Features
- **6-state base design:** both red (1s) → highway green (30s) → highway yellow (3s) → both red (1s) → farm green (15s) → farm yellow (3s) → repeat
- **8-state extended design:** same base cycle, but highway green holds past 30s until farm traffic is detected, and farm green extends dynamically while sensor is active
- **RstCount:** Mealy output that resets the counter as soon as a timing condition is met, avoiding an extra clock cycle of delay before the counter resets
- **125 MHz timing:** all state durations calculated using sec1 = 125,000,000 as the base parameter, scaled for 1s, 3s, 15s, and 30s

## Modules
- **`tlcfsm.v`** — original 6-state traffic light FSM (S0–S5)
- **`tlc_controller.v`** — top-level controller for the 6-state design, with reset synchronizer and 32-bit counter
- **`tlcfsm_modified.v`** — extended 8-state FSM (S0–S7) with farmSensor input
- **`tlc_controller_ver2.v`** — top-level controller for the 8-state design, adds a second synchronizer for the farmSensor input

## Simulation Results
both FSMs were simulated and verified using Vivado XSim. the 6-state testbench confirmed correct state transitions and light output values across the full cycle. the 8-state testbench verified sensor-dependent transitions, including early sensor release and maximum hold time for the extended green states

## Implementation
developed and tested using Xilinx Vivado on the Digilent Zybo Z7-10 FPGA board — LED[3:2] display the highway signal and LED[1:0] display the farm signal, BTN0 serves as synchronous reset, and BTN1 serves as the farm road vehicle sensor input in the extended version
