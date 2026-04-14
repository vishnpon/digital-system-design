# ECEN 248 — Verilog Design Portfolio

A collection of digital hardware designs from ECEN 248 at Texas A&M University, implemented in Verilog and tested on a Digilent ZYBO Z7-10 FPGA board.

---

## Projects

### Up Counter with Selectable Clock Speed

A 3-bit synchronous up counter built from half adder primitives, driven by a clock divider that produces four selectable frequencies from the board's onboard fast clock.

- **Architecture:** half-adder chain forming a 3-bit ripple counter, with a 27-bit clock divider and a behavioral 4-way mux for clock selection
- **Features:** real-time clock speed switching via switches, push button enable and reset, count output displayed on LEDs

---

### Carry Lookahead Adder — High Speed Addition

A 16-bit two-level carry lookahead adder that computes all carry signals in parallel rather than propagating them one bit at a time, significantly reducing critical path delay.

- **Architecture:** modular design using a generate/propagate unit, a carry lookahead unit, block carry-lookahead units, and a summation unit — connected structurally at the top level
- **Performance:** 16ns propagation delay compared to 64ns for a ripple carry equivalent, achieved through parallel carry generation across all 16 bits

---

### Digital Combination Lock — Sequential Security System

A Moore finite state machine implementing a combination lock that verifies a multi-digit password sequence entered through push buttons and a 4-bit switch input.

- **Architecture:** 5-state FSM with a 3-bit state register, separate sequential and combinational always blocks, and synchronous reset
- **Security:** any incorrect input immediately returns the FSM to the locked state; supports 65,536 unique combinations across 4 password digits

---

### Traffic Light Controller — Intersection Management

An FSM-based traffic light controller for a highway and farm road intersection, extended from a 6-state base design to an 8-state sensor-aware version that adapts signal timing dynamically.

- **Architecture:** Moore/Mealy hybrid FSM with a 32-bit hardware counter clocked at 125 MHz; RstCount output handled as a Mealy signal in a dedicated always block
- **Features:** timed state transitions (1s, 3s, 15s, 30s) and a farm road vehicle sensor that extends highway green indefinitely until traffic is detected, then caps additional farm green at 15 seconds

---

## Hardware & Tools

| | |
|---|---|
| **FPGA Board** | Digilent ZYBO Z7-10 |
| **HDL** | Verilog (Xilinx) |
| **Toolchain** | Vivado Design Suite |
| **Simulation** | Vivado XSim |
