`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2025 12:32:41 PM
// Design Name: 
// Module Name: carry_lookahead_16bit
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


module carry_lookahead_16bit(Cout, S, X, Y, Cin);

    //ports are wires since we're using structural
    output wire Cout; // cout for 16 bit adder
    output wire [15:0] S; // final 16 bit sum vector
    input wire [15:0] X, Y; // addends
    input wire Cin; // input carry
    
    //intermediate nets
    wire [16:0] C; // 17 bit carry vector
    wire [15:0] P, G; // gen and prop
    wire [3:0] P_star, G_star; //block gens and props
    
    //input and output carry
    assign Cout = C[16];
    assign C[0] = Cin;
    
    //instantiate gen and prop unit
    generate_propagate_unit GPU0(G, P, X, Y);
    
    //instantiate bclaus 
    block_carrylookahead_unit BCLAU0(
        .G_star (G_star[0]),
        .P_star (P_star[0]),
        .C (C[3:1]),
        .G (G[3:0]),
        .P (P[3:0]),
        .C0 (C[0])
    );
    
    block_carrylookahead_unit BCLAU1(
        .G_star (G_star[1]),
        .P_star (P_star[1]),
        .C (C[7:5]),
        .G (G[7:4]),
        .P (P[7:4]),
        .C0 (C[4])
    );
    
    block_carrylookahead_unit BCLAU2(
        .G_star (G_star[2]),
        .P_star (P_star[2]),
        .C (C[11:9]),
        .G (G[11:8]),
        .P (P[11:8]),
        .C0 (C[8])
    );
    
    block_carrylookahead_unit BCLAU3(
        .G_star (G_star[3]),
        .P_star (P_star[3]),
        .C (C[15:13]),
        .G (G[15:12]),
        .P (P[15:12]),
        .C0 (C[12])
    );
    
    //instantiate clau
    carry_lookahead_unit CLAU (
        .C ({C[16], C[12], C[8], C[4]}),
        .G ( G_star),
        .P (P_star),
        .C0 (C[0])
    );
    
    //instantiate summation unit
    summation_unit SUM0(
        .P (P[15:0]),
        .C (C [15:0]),
        .S (S [15:0])
    );
endmodule
