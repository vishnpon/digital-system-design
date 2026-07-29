`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Vishnupriya Ponnam
// Module Name: behavioral_adder_16bit
// Description: behavioral 16-bit adder, lets Vivado infer the CARRY4 fast carry chain
//////////////////////////////////////////////////////////////////////////////////


module behavioral_adder_16bit(Cout, S, X, Y, Cin);

    //same port order and names as carry_lookahead_16bit and ripple_carry_16bit
    output wire Cout;
    output wire [15:0] S;
    input wire [15:0] X, Y;
    input wire Cin;

    //widened to 17 bits so the carry out lands in bit 16 instead of being
    //truncated away. Vivado maps this onto the dedicated CARRY4 primitives
    //hardwired into each 7-series slice - four CARRY4 blocks for 16 bits
    assign {Cout, S} = {1'b0, X} + {1'b0, Y} + {16'b0, Cin};

endmodule
