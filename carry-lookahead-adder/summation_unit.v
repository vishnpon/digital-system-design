`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/09/2025 07:50:54 PM
// Design Name:
// Module Name: summation_unit
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


module summation_unit(S, P, C);

    //declare ports as wires
    output wire [15:0] S;
    input wire [15:0] P, C; //propagate and carry vectors

    //sum bits = si = pi XOR ci
    assign #2 S = P ^ C;

endmodule
