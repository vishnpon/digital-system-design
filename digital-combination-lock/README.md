# Digital Combination Lock - Sequential Security System
a Moore FSM implementing a multi-digit combination lock that verifies a password sequence entered through push buttons and a 4-bit switch input

## Overview
this project implements a digital combination lock as a finite state machine using behavioral Verilog. the FSM steps through states only when the correct digit and corresponding button press are provided in order. two versions were built — a 3-digit lock using a 2-bit state register, and an extended 4-digit version with a 3-bit state register to accommodate the extra state. any wrong input at any point sends the FSM straight back to S0, and the lock output drives all four LEDs high only when the correct final state is reached

## Architecture
the FSM follows standard Moore machine structure using two separate always blocks:

* **State Register:** synchronous always block on the rising clock edge — handles state updates and forces a return to S0 when Reset is pressed
* **Next State Logic:** combinational always block with a case statement that evaluates the current state, the 4-bit password input, and which key is pressed to decide the next state
* **Output Logic:** continuous assign statement that sets the Lock output to 4'b1111 only in the final unlocked state, 4'b0000 otherwise

## Security
* **3-digit lock:** 4,096 possible combinations (16 × 16 × 16) using three sequential 4-bit password inputs
* **4-digit lock:** 65,536 possible combinations (16 × 16 × 16 × 16) using four sequential 4-bit password inputs
* any incorrect digit or wrong key press at any state immediately resets to S0 — no partial credit for getting part of the sequence right
* the lock stays unlocked until Reset is explicitly pressed, requiring a deliberate action to re-lock

## Modules of this Project

* __combination_lock_fsm_3pass.v__ - 3-digit Moore FSM with 2-bit state register (S0–S3), password sequence: 13 → 7 → 9
* __combination_lock_fsm.v__ - 4-digit Moore FSM with 3-bit state register (S0–S4), password sequence: 13 → 7 → 9 → 1

## Simulation Results
**3-Password Lock Waveform**
<img width="832" height="363" alt="3_pass_combination" src="https://github.com/user-attachments/assets/7bf03906-a78c-41ec-83a0-d47bb55e79b3" />

## Implementation
developed and tested using Xilinx Vivado on the Digilent Zybo Z7-10 FPGA board — the 4-bit switches set the password value in binary, BTN0 acts as Key1, BTN1 as Key2, and all four LEDs light up when the correct sequence is entered
