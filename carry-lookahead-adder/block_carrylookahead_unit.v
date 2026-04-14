`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2025 12:11:20 PM
// Design Name: 
// Module Name: block_carrylookahead_unit
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


module block_carrylookahead_unit(G_star, P_star, C, G, P, C0);

    //ports are wires
    input wire [3:0] P, G;
    input wire C0;
    output wire G_star, P_star;
    output wire [3:1] C;
    
    assign #4 C[1] = G[0] | (P[0] & C0);
    
    //c2 = g1 + p1*g0 + p1*p0*c0
    assign #4  C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C0);
    
    //c3 = g2 + p2*g1 + p2*p1*g0 + p2*p1*p0*c0
    assign #4 C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C0);
   
    
    assign #4 G_star = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]);
    assign #2 P_star = P[3] & P[2] & P[1] & P[0];  
    
    
 
endmodule
