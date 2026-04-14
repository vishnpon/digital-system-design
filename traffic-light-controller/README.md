# Traffic Light Controller - Intersection Management System
an FSM controlling a highway and farm road intersection, extended with a vehicle sensor for adaptive signal timing

## Overview
this project implements a traffic light controller as a Moore/Mealy hybrid FSM using behavioral Verilog. the base design uses 6 states to cycle through highway and farm road signal phases with fixed timing, driven by a 32-bit hardware counter running at 125 MHz. a second extended version adds two more states and a farm road sensor input that keeps the highway green past its minimum 30 seconds until farm traffic is detected, then extends the farm green phase dynamically while vehicles are present — up to 15 extra seconds before forcing a transition

## Architecture
each version is split into an FSM module and a top-level controller:

* **FSM Module:** three combinational always blocks handle next state logic, the Mealy RstCount output, and Moore traffic signal outputs separately — a fourth sequential block manages the state register and synchronous reset
* **Top-Level Controller:** instantiates the FSM, a synchronizer for async button input, and a 32-bit counter that increments each clock cycle and resets the moment RstCount is asserted
* **Synchronizer:** prevents metastability from asynchronous button presses before signals enter the FSM
* **Extended FSM:** adds S6 (highway stays green until farmSensor goes high) and S7 (farm stays green while farmSensor is high, capped at 15 additional seconds)

## Features
the base 6-state cycle runs as follows:

* both red (1s) → highway green (30s) → highway yellow (3s) → both red (1s) → farm green (15s) → farm yellow (3s) → repeat
* the 8-state extended version holds highway green past 30s until farm traffic is detected, and extends farm green dynamically based on sensor input
* RstCount is a Mealy output that resets the counter immediately when a timing condition is met, avoiding a one-cycle delay before the counter clears
* all timing based on sec1 = 125,000,000 clock cycles at 125 MHz, scaled to 1s, 3s, 15s, and 30s using parameters

## Modules of this Project

* __tlcfsm.v__ - original 6-state traffic light FSM (S0–S5)
* __tlc_controller.v__ - top-level controller for the 6-state design with reset synchronizer and 32-bit counter
* __tlcfsm_modified.v__ - extended 8-state FSM (S0–S7) with farmSensor input
* __tlc_controller_ver2.v__ - top-level controller for the 8-state design, adds a second synchronizer for farmSensor

## Implementation
developed and tested using Xilinx Vivado on the Digilent Zybo Z7-10 FPGA board — LED[3:2] display the highway signal and LED[1:0] display the farm signal, BTN0 is the reset, and BTN1 serves as the farm road sensor input in the extended version
