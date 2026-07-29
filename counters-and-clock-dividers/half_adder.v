`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Vishnupriya Ponnam
// Module Name: half_adder
// Description: single-bit half adder giving sum A ^ B and carry out A & B
//////////////////////////////////////////////////////////////////////////////////


module half_adder(S, Cout, A, B);
    input wire A; 
    input wire B;
    output wire Cout;
    output wire S; 
    
    assign Cout = A & B; 
    assign S = A ^ B;
endmodule
