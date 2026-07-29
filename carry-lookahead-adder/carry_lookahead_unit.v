`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Vishnupriya Ponnam
// Module Name: carry_lookahead_unit
// Description: 4-bit carry lookahead logic computing C1-C4 from generates, propagates and C0
//////////////////////////////////////////////////////////////////////////////////


module carry_lookahead_unit(C, G, P, C0);

    //ports are wire for data flow
    output wire [4:1] C;
    input wire [3:0] G,P; //generates and propagates
    input wire C0; // input carry

    //c1 = g0 + p0*c0
    assign #4 C[1] = G[0] | (P[0] & C0);

    //c2 = g1 + p1*g0 + p1*p0*c0
    assign #4 C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C0);

    //c3 = g2 + p2*g1 + p2*p1*g0 + p2*p1*p0*c0
    assign #4 C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C0);

    //c4 =  g3 + p3*g2 + p3*p2*g1 + p3*p2*p1*g0 + p3*p2*p1*p0*c0
    assign #4 C[4] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & C0);

endmodule
