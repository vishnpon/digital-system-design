//======================================================================
// Vishnupriya Ponnam
// Self-checking testbench for the 16-bit two-level carry-lookahead adder.
// Runs directed edge cases and carry-propagation sweeps, then a randomized
// comparison against a behavioral A + B + Cin reference. Reports every
// mismatch with the failing stimulus and prints a PASS/FAIL summary.
//
// Simulator: Cadence Xcelium 25.03 (via EDA Playground). Compile as
// SystemVerilog ($error, $urandom).
//======================================================================

`timescale 1ns / 1ps

module tb_cla16;

  //--------------------------------------------------------------------
  // Configuration
  //--------------------------------------------------------------------
  localparam int N            = 16;    // adder width
  localparam int RANDOM_ITERS = 20000; // randomized vectors

  // Settle time before sampling the DUT.
  //
  // The design carries explicit gate delays (#2 on G/P and sum, #4 on the
  // carry equations), so the outputs are NOT valid immediately. Worst-case
  // path through the 16-bit adder:
  //
  //   X,Y --#2--> G,P --#4--> G_star --#4--> C[12] --#4--> C[15] --#2--> S[15]
  //         = 16 ns
  //
  // Sampling any earlier than that reports failures that are artifacts of the
  // delay model rather than real design bugs. 50 ns gives comfortable margin.
  localparam int SETTLE_NS    = 50;

  //--------------------------------------------------------------------
  // DUT connections
  //--------------------------------------------------------------------
  logic [N-1:0] A;
  logic [N-1:0] B;
  logic         Cin;
  logic [N-1:0] Sum;
  logic         Cout;

  //====================================================================
  // DUT instantiation.
  // Testbench signal names on the left of each parenthesis are local to
  // this file; the port names (.X .Y .S) are the DUT's.
  //====================================================================
  carry_lookahead_16bit dut (
    .Cout (Cout),
    .S    (Sum),
    .X    (A),
    .Y    (B),
    .Cin  (Cin)
  );

  //--------------------------------------------------------------------
  // Scoreboard
  //--------------------------------------------------------------------
  int test_count = 0;
  int pass_count = 0;
  int fail_count = 0;

  //--------------------------------------------------------------------
  // Drive one vector, compare against behavioral reference.
  // The reference is deliberately trivial: a 17-bit add whose MSB is the
  // carry out. Any disagreement is a DUT bug.
  //--------------------------------------------------------------------
  task automatic check(input logic [N-1:0] ta,
                       input logic [N-1:0] tbv,
                       input logic         tc,
                       input string        phase);
    logic [N:0] expected;
    logic [N:0] actual;
    begin
      A   = ta;
      B   = tbv;
      Cin = tc;
      #(SETTLE_NS * 1ns);

      // Behavioral reference: widen to N+1 bits so the carry out lands in
      // bit N and nothing is truncated.
      expected = {1'b0, ta} + {1'b0, tbv} + {{N{1'b0}}, tc};
      actual   = {Cout, Sum};

      test_count++;

      // !== also catches X/Z on the DUT outputs, which a plain != would miss.
      if (actual !== expected) begin
        fail_count++;
        $error("[%0s] MISMATCH  A=0x%04h  B=0x%04h  Cin=%0b  |  DUT: Cout=%0b Sum=0x%04h  |  REF: Cout=%0b Sum=0x%04h",
               phase, ta, tbv, tc,
               Cout, Sum,
               expected[N], expected[N-1:0]);
      end
      else begin
        pass_count++;
      end
    end
  endtask

  // Run the same operand pair with Cin = 0 and Cin = 1.
  task automatic check_both_cin(input logic [N-1:0] ta,
                                input logic [N-1:0] tbv,
                                input string        phase);
    begin
      check(ta, tbv, 1'b0, phase);
      check(ta, tbv, 1'b1, phase);
    end
  endtask

  //--------------------------------------------------------------------
  // Stimulus
  //--------------------------------------------------------------------
  initial begin
    $display("========================================================");
    $display(" 16-bit carry-lookahead adder - self-checking testbench");
    $display("========================================================");

    A = '0; B = '0; Cin = 1'b0;
    #(SETTLE_NS * 1ns);

    //----------------------------------------------------------------
    // Phase 1 - directed edge cases
    //----------------------------------------------------------------
    $display("\n[Phase 1] Directed edge cases");

    check_both_cin(16'h0000, 16'h0000, "EDGE");  // identity / zero
    check_both_cin(16'hFFFF, 16'h0001, "EDGE");  // full-length carry, wraps to 0
    check_both_cin(16'hFFFF, 16'hFFFF, "EDGE");  // max + max
    check_both_cin(16'hFFFF, 16'h0000, "EDGE");  // max + zero (Cin=1 wraps)
    check_both_cin(16'h0000, 16'hFFFF, "EDGE");  // operand order swapped
    check_both_cin(16'hAAAA, 16'h5555, "EDGE");  // alternating, sums to 0xFFFF
    check_both_cin(16'h5555, 16'hAAAA, "EDGE");  // alternating, swapped
    check_both_cin(16'hAAAA, 16'hAAAA, "EDGE");  // alternating + itself
    check_both_cin(16'h5555, 16'h5555, "EDGE");  // alternating + itself
    check_both_cin(16'h8000, 16'h8000, "EDGE");  // MSB carry out, sum zero
    check_both_cin(16'h7FFF, 16'h0001, "EDGE");  // carry into MSB only
    check_both_cin(16'hFFFE, 16'h0001, "EDGE");  // one below wrap
    check_both_cin(16'hF0F0, 16'h0F0F, "EDGE");  // nibble complement
    check_both_cin(16'hCCCC, 16'h3333, "EDGE");  // 2-bit pattern complement
    check_both_cin(16'h1234, 16'hEDCB, "EDGE");  // arbitrary, sums to 0xFFFF
    check_both_cin(16'h0001, 16'h0000, "EDGE");  // minimal nonzero

    //----------------------------------------------------------------
    // Phase 2 - carry-propagation sweeps
    //
    // These target the structural weak points of a two-level CLA: the
    // boundaries between 4-bit blocks (bits 3/4, 7/8, 11/12) and the
    // block-carry logic above them. A design that computes carries
    // correctly inside a block but drops a block-level carry passes
    // most random vectors and fails here.
    //----------------------------------------------------------------
    $display("[Phase 2] Carry-propagation sweeps");

    for (int i = 0; i < N; i++) begin
      // Ripple of length i terminated by a single increment:
      // 0x000F + 1, 0x00FF + 1, 0x0FFF + 1, ...
      check_both_cin((16'h0001 << i) - 16'h0001, 16'h0001, "PROP");

      // Single bit added to itself - carry generated at position i only.
      check_both_cin(16'h0001 << i, 16'h0001 << i, "PROP");

      // All-ones plus a single bit - forces a carry through every
      // higher block from position i upward.
      check_both_cin(16'hFFFF, 16'h0001 << i, "PROP");

      // Walking one against walking complement.
      check_both_cin(16'h0001 << i, ~(16'h0001 << i), "PROP");
    end

    //----------------------------------------------------------------
    // Phase 3 - randomized comparison against behavioral reference
    //----------------------------------------------------------------
    $display("[Phase 3] Randomized vectors (%0d iterations)", RANDOM_ITERS);

    for (int i = 0; i < RANDOM_ITERS; i++) begin
      check(N'($urandom_range(0, 16'hFFFF)),
            N'($urandom_range(0, 16'hFFFF)),
            1'($urandom_range(0, 1)),
            "RAND");
    end

    //----------------------------------------------------------------
    // Summary
    //----------------------------------------------------------------
    $display("\n========================================================");
    $display(" Vectors run : %0d", test_count);
    $display(" Passed      : %0d", pass_count);
    $display(" Failed      : %0d", fail_count);
    if (fail_count == 0)
      $display(" RESULT      : PASS - all vectors matched the reference");
    else
      $display(" RESULT      : FAIL - %0d of %0d vectors mismatched",
               fail_count, test_count);
    $display("========================================================");

    $finish;
  end

  //--------------------------------------------------------------------
  // Watchdog - a purely combinational DUT can never legitimately hang,
  // so this only trips on an elaboration or connectivity problem.
  //--------------------------------------------------------------------
  initial begin
    #(10ms);
    $display("========================================================");
    $display(" RESULT      : FAIL - testbench timed out");
    $display("========================================================");
    $finish;
  end

endmodule
