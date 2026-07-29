`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Vishnupriya Ponnam
// Module Name: summation_unit
// Description: computes the 16-bit sum vector as S = P ^ C from propagates and carries
//////////////////////////////////////////////////////////////////////////////////


module summation_unit(S, P, C);

    //declare ports as wires
    output wire [15:0] S;
    input wire [15:0] P, C; //propagate and carry vectors

    //sum bits = si = pi XOR ci
    assign #2 S = P ^ C;

endmodule
