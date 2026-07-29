`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Vishnupriya Ponnam
// Module Name: generate_propagate_unit
// Description: computes bitwise generate G = X & Y and propagate P = X ^ Y for all 16 bits
//////////////////////////////////////////////////////////////////////////////////


module generate_propagate_unit(G, P, X, Y);

    //ports are wires since we're using dataflow
    output wire [15:0]G, P;
    input wire [15:0] X,Y;

    //using equations generate signals: gi = xi * yi
    assign #2 G = X & Y;

    //propagate signals : pi = xi xor yi
    assign #2 P = X ^ Y;

endmodule
