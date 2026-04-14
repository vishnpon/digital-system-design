`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2025 11:26:57 AM
// Design Name: 
// Module Name: clock_divider
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


module clock_divider(ClkOut, ClkIn);
    
    output wire [3:0] ClkOut;
    input wire ClkIn; // wires can drive regs
    
    parameter n = 26; 
    
    reg[n:0] Count; // count bit width is based on n
    
    always@(posedge ClkIn)
        Count <= Count +1;
    
    assign ClkOut[3:0] = Count[n:n-3];
    
endmodule
