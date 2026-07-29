`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Vishnupriya Ponnam
// Module Name: timing_wrappers
// Description: register-in/register-out wrappers isolating each adder from the I/O ring
//////////////////////////////////////////////////////////////////////////////////
//
// WHY THESE EXIST
//
// Synthesizing a bare combinational adder with top-level ports produces a
// pad-to-pad timing path: IBUF -> routing -> logic -> routing -> OBUF. On a
// 7-series part the I/O buffers alone are several nanoseconds, so that number
// tells you about the I/O ring, not the adder. It is the timing-report version
// of trying to measure the adder with a benchtop scope.
//
// Each wrapper below registers all inputs and all outputs, so the worst
// register-to-register path runs purely through the adder logic. Combined with
// the set_false_path constraints in timing_compare.xdc (which exclude every
// pad-to-register and register-to-pad path), the reported WNS reflects the
// adder and nothing else.
//
// All three wrappers are structurally identical and expose identical port
// names, so one .xdc constrains all three and the only variable is the adder.
//
//////////////////////////////////////////////////////////////////////////////////


//======================================================================
// Wrapper 1 - hand-built two-level carry lookahead adder
//======================================================================
module wrap_cla16(
    output reg  [15:0] S_q,
    output reg         Cout_q,
    input  wire [15:0] X_d,
    input  wire [15:0] Y_d,
    input  wire        Cin_d,
    input  wire        Clk
    );

    reg  [15:0] X_q, Y_q;
    reg         Cin_q;
    wire [15:0] S_comb;
    wire        Cout_comb;

    //input register stage
    always @(posedge Clk) begin
        X_q   <= X_d;
        Y_q   <= Y_d;
        Cin_q <= Cin_d;
    end

    carry_lookahead_16bit DUT (
        .Cout (Cout_comb),
        .S    (S_comb),
        .X    (X_q),
        .Y    (Y_q),
        .Cin  (Cin_q)
    );

    //output register stage
    always @(posedge Clk) begin
        S_q    <= S_comb;
        Cout_q <= Cout_comb;
    end

endmodule


//======================================================================
// Wrapper 2 - structural ripple carry adder
//======================================================================
module wrap_rca16(
    output reg  [15:0] S_q,
    output reg         Cout_q,
    input  wire [15:0] X_d,
    input  wire [15:0] Y_d,
    input  wire        Cin_d,
    input  wire        Clk
    );

    reg  [15:0] X_q, Y_q;
    reg         Cin_q;
    wire [15:0] S_comb;
    wire        Cout_comb;

    always @(posedge Clk) begin
        X_q   <= X_d;
        Y_q   <= Y_d;
        Cin_q <= Cin_d;
    end

    ripple_carry_16bit DUT (
        .Cout (Cout_comb),
        .S    (S_comb),
        .X    (X_q),
        .Y    (Y_q),
        .Cin  (Cin_q)
    );

    always @(posedge Clk) begin
        S_q    <= S_comb;
        Cout_q <= Cout_comb;
    end

endmodule


//======================================================================
// Wrapper 3 - behavioral adder (Vivado infers CARRY4)
//======================================================================
module wrap_beh16(
    output reg  [15:0] S_q,
    output reg         Cout_q,
    input  wire [15:0] X_d,
    input  wire [15:0] Y_d,
    input  wire        Cin_d,
    input  wire        Clk
    );

    reg  [15:0] X_q, Y_q;
    reg         Cin_q;
    wire [15:0] S_comb;
    wire        Cout_comb;

    always @(posedge Clk) begin
        X_q   <= X_d;
        Y_q   <= Y_d;
        Cin_q <= Cin_d;
    end

    behavioral_adder_16bit DUT (
        .Cout (Cout_comb),
        .S    (S_comb),
        .X    (X_q),
        .Y    (Y_q),
        .Cin  (Cin_q)
    );

    always @(posedge Clk) begin
        S_q    <= S_comb;
        Cout_q <= Cout_comb;
    end

endmodule
