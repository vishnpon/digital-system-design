# Digital Combination Lock — Sequential Security System
a finite state machine implementing a multi-digit combination lock that verifies a password sequence entered through push buttons and a 4-bit switch input

## Overview
this project implements a digital combination lock as a Moore FSM using behavioral Verilog. the lock accepts a sequence of 4-bit numeric inputs confirmed by push button presses, advancing through states only when the correct digit and button combination is provided. two versions were built: a 3-digit lock with 4 states, and an extended 4-digit lock with 5 states. any incorrect input at any point immediately resets the FSM back to the initial locked state, and the lock output drives all four LEDs high only when the final unlocked state is reached.

## Architecture
the FSM is implemented using two separate always blocks following standard Moore machine design practice:

- **State Register:** a synchronous always block triggered on the rising clock edge handles state updates and reset. when the Reset button is pressed, the state is forced back to S0 regardless of the current state
- **Next State Logic:** a combinational always block with a case statement evaluates the current state, the password input, and the key press to determine the next state transition
- **Output Logic:** the Lock output is driven by a continuous assign statement, asserting 4'b1111 only when the FSM reaches the final unlocked state

## Security
- **3-digit lock:** 4,096 possible combinations using three sequential 4-bit password inputs
- **4-digit lock:** 65,536 possible combinations using four sequential 4-bit password inputs
- any wrong digit or wrong key press at any state immediately resets to S0, preventing brute-force stepping through states
- the unlocked state persists until the Reset button is pressed, requiring a deliberate reset to re-lock

## Modules
- **`combination_lock_fsm_3pass.v`** — 3-digit Moore FSM with a 2-bit state register (S0–S3), password sequence: 13 → 7 → 9
- **`combination_lock_fsm.v`** — 4-digit Moore FSM with a 3-bit state register (S0–S4), password sequence: 13 → 7 → 9 → 1

## Simulation Results
both FSMs were simulated and verified using Vivado XSim. the testbench checked the correct password sequence, incorrect passwords at each state, wrong key presses, and synchronous reset from every state — all test cases passed

## Implementation
developed and tested using Xilinx Vivado on the Digilent Zybo Z7-10 FPGA board — the 4-bit switches set the password value, BTN0 acts as Key1, BTN1 as Key2, and the LEDs illuminate fully when the correct sequence is entered
