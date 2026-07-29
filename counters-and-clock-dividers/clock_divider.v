`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Vishnupriya Ponnam
// Module Name: clock_divider
// Description: divides ClkIn with a 27-bit counter and taps four of its bits as slower clocks
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
