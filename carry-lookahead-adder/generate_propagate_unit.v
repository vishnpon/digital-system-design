`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2025 07:50:54 PM
// Design Name: 
// Module Name: generate_propagate_unit
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


module generate_propagate_unit(G, P, X, Y);

    //ports are wires since we're using dataflow
    output wire [15:0]G, P;
    input wire [15:0] X,Y;
    
    //using equations generate signals: gi = xi * yi
    assign #2 G = X & Y;
    
    //propagate signals : pi = xi xor yi
    assign #2 P = X ^ Y;
    
endmodule

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

module summation_unit(S, P, C);
    
    //declare ports as wires
    output wire [15:0] S;
    input wire [15:0] P, C; //propagate and carry vectors
    
    //sum bits = si = pi XOR ci
    assign #2 S = P ^ C;
endmodule

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


