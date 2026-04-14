`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/09/2025 07:50:54 PM
// Design Name:
// Module Name: carry_lookahead_4bit
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


//top level module for 4-bit cla
module carry_lookahead_4bit(Cout, S, X, Y, Cin);

    //ports are still wires since we are using strucutral
    output wire Cout; // c4 for 4 bit adder
    output wire [3:0] S; //final 4 bit sum vector
    input wire [3:0] X, Y; // 4 bit addends
    input wire Cin; // input carry

    //declare internal nets
    wire [3:0] G, P; // generate propagate vectors
    wire [4:1] C; // carries from cla
    assign Cout = C[4];
    wire [3:0] Carry_sum; // carry for summation unit
    assign Carry_sum = {C[3:1], Cin};

    //instantiate generate propagate unit
    generate_propagate_unit GPU(G, P, X, Y);

    //instantiate cla unit
    carry_lookahead_unit CLA(C, G, P, Cin);

    //instantiate summation unit
    summation_unit SU(S, P, Carry_sum);

endmodule
