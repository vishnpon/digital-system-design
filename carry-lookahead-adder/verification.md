# Verification — 16-bit Carry-Lookahead Adder

## What this verification achieves

A passing testbench proves only one thing: that the testbench does not report false failures. It says nothing about whether the testbench would *notice* a real defect. A suite that checks nothing passes every design, including a broken one.

Closing that gap requires inverting the question. Instead of asking "does the design pass?", inject a known defect and ask "does the suite fail?" That is fault injection, and it converts an untested assumption into evidence.

The goal here was to answer three specific questions about `tb_cla16.sv`:

1. **Is the suite sensitive to faults in each functional block?** The design decomposes into generate/propagate, block-level carry lookahead, second-level block-carry resolution, and summation. A fault was injected into each distinct region so that no part of the hierarchy was assumed correct.
2. **Which phase does the work?** The suite has three phases — directed edge cases, structural carry-propagation sweeps, and randomized comparison. If one phase caught everything, the others would be redundant. If some fault escaped all three, the suite would have a blind spot worth knowing about.
3. **Are the failures functional rather than structural?** A fault that breaks compilation proves nothing about the testbench. Every injection was confirmed to elaborate cleanly before simulation, so all reported failures are genuine output mismatches.

Faults were injected one at a time, simulated, then reverted. After the final revert, every fault site was confirmed byte-identical to the committed original (`git diff` clean), so this study left no residue in the RTL.

## Method

`tb_cla16.sv` drives 20,160 vectors in three phases and compares every result against a behavioral `X + Y + Cin` reference. `$error` reports the exact failing stimulus; a PASS/FAIL summary prints at the end.

| Phase | Vectors | Content |
|---|---|---|
| 1 — `EDGE` | 32 | 16 directed operand pairs × both `Cin` values — zero, `0xFFFF+1`, `0xFFFF+0xFFFF`, alternating `0xAAAA`/`0x5555`, MSB carry, nibble complements |
| 2 — `PROP` | 128 | 16 bit positions × 4 carry-propagation patterns × both `Cin` values, aimed at the 4-bit block boundaries at bits 3/4, 7/8 and 11/12 |
| 3 — `RAND` | 20,000 | Uniform random `X`, `Y`, `Cin` |

**Simulator:** Cadence Xcelium 25.03 (via EDA Playground).

**Fault-free baseline:** 20,160 of 20,160 vectors pass, 0 failures.

## Results

| Fault | Description | Phase that caught it | Failures |
|---|---|---|---|
| F1 | Dropped last `G_star` term | Phase 3 only [¹](#note-on-f1) | 1,254+ |
| F2 | Dropped `P[0]` from `P_star` | Phase 3 only | 1,254 of 20,160 |
| F3 | `C12` block carry corruption | Phase 1 + Phase 2 + Phase 3 | 71 of 20,160 |
| F4 | XOR → XNOR on sum | Phase 1 + Phase 2 + Phase 3 | ~20,160 (all) |

All four faults were detected. No fault escaped the suite.

## The injected faults

**F1 — `block_carrylookahead_unit.v`, `G_star`.** Removed the `(P[3] & P[2] & P[1] & G[0])` term, eliminating the path by which a generate at bit 0 of a block propagates through bits 1–3 to leave that block. The module is instantiated four times, so the fault applied to all four blocks.

**F2 — `block_carrylookahead_unit.v`, `P_star`.** Removed the `& P[0]` factor, so the block claims to propagate a carry when bit 0 actually kills it.

**F3 — `carry_lookahead_unit.v`, `C[3]`.** Removed the `(P[2] & P[1] & G[0])` term from the carry into bit 12 — the case where block 0 generates a carry and blocks 1 and 2 both propagate it. A three-block-deep interaction.

**F4 — `summation_unit.v`.** Changed `S = P ^ C` to `S = ~(P ^ C)`, inverting all 16 sum bits.

## What the results show

**Phase 3 is not padding.** F2 is invisible to both directed and sweep vectors and is caught only by randomization. The reason is a four-way coincidence that no hand-written pattern in Phase 1 constructs: the fault is observable only when `P[0]=0`, `G[0]=0`, `P[3:1]=111`, and a carry arrives at that block boundary. `0xAAAA + 0x5555` — the obvious candidate — propagates on every bit, so `P[0]=1` and the fault hides. Minimal exposing vector: `X=0x000E, Y=0x0000, Cin=1` gives `0x001F` instead of `0x000F`. The same vector with `Cin=0` passes. **A directed-only suite would ship this bug.**

**Directed vectors are not padding either.** F3 is caught by 20 of the 160 directed and sweep vectors but only 51 of 20,000 random ones — roughly 125× more efficient per vector. Structural tests aimed at known-weak points find sparse faults that random stimulus reaches only by luck.

**Checking the sum matters, not just the carry.** F3's vector `X=0xFFF1, Y=0x000F, Cin=0` produces a *correct* `Cout` alongside a sum wrong by `0xF000`. A testbench comparing only carry-out would pass it.

**F4 is the control.** A fault that corrupts every sum bit must fail immediately or the suite is not comparing sums at all. It failed from the first vector. Simulator output was truncated at the host line limit because nearly every vector emits an error; the process was killed at that limit rather than crashing.

## Limitations

Four faults are a sensitivity demonstration, not a fault-coverage metric.

Exhaustive verification of a 16-bit adder with carry-in requires 2³³ ≈ 8.6 billion input combinations, so no vector set of this size is complete. This study shows the suite detects a chosen set of structurally plausible defects; it does not bound the probability that an unknown defect escapes.

Two regions were not faulted: the internal carry chain within a single block (`C[1]`–`C[3]` of `block_carrylookahead_unit`) and the generate/propagate unit itself. Extending the study there would strengthen the claim.

---

### Note on F1

<a name="note-on-f1"></a>The "Phase 3 only" attribution for F1 is recorded as observed, but it conflicts with deterministic analysis and is worth re-running before being relied on.

Phase 1 and Phase 2 vectors are fixed and seed-independent, so their outcome can be computed without a simulator. Both an independent behavioral model and a hand calculation agree that `X=0xFFFF, Y=0x0001, Cin=0` — the second directed vector in Phase 1 — must fail under F1:

```
        DUT: Sum = 0xFFF0   Cout = 0
  REFERENCE: Sum = 0x0000   Cout = 1
```

Bit 0 generates a carry, bits 1–3 propagate it, and it must exit block 0 — exactly the removed term. `G_star[0]` therefore reads 0 instead of 1, `C[4]` never asserts, and the carry is lost across the remaining 12 bits. On this analysis 4 Phase 1 vectors and 32 Phase 2 vectors fail, giving 2,377 total rather than 1,254.

The recorded F1 failure count is also identical to F2's, which is consistent with the F1 row having been transcribed from the F2 run.
