`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Vishnupriya Ponnam
// Module Name: up_counter (with Three_bit_counter submodule)
// Description: 3-bit up counter built from chained half adders with enable and reset
//////////////////////////////////////////////////////////////////////////////////


module up_counter(Count, Carry2, En, Clk, Rst);
        //count output needs to be a reg
        output reg [2:0] Count;
        output wire Carry2;
        
        //inputs are wires
        input wire En, Clk, Rst;
        
        //declare intermediate wires
        wire [2:0] Carry, Sum;
        
        //create and instantiate a wrapper for 3-bit counter
        
        Three_bit_counter UC1(Sum, Carry2, Count, En);
        
        //describe pos edge triggered flip flops for count
        
        always@(posedge Clk or posedge Rst)
            if(Rst) //if rst == 1'b1
                Count <=0; // reset count
            else //otherwise latch sum
                Count <= Sum;
endmodule

module Three_bit_counter(Sum, Carry2, Count, En, Clk, Rst);

    //declare variables
    input wire En, Clk, Rst;
    input wire [2:0] Count;
    output wire [2:0] Sum;
    output wire Carry2;
    wire [2:0] Carry;
    
    //intantiate and wire up half adders 
    half_adder HA1(Sum[0], Carry[0], En, Count[0]);
    half_adder HA2( Sum[1], Carry[1], Carry[0], Count[1]);
    half_adder HA3(Sum[2], Carry[2], Carry[1], Count[2]); 

    //wire up carry 2 here
    assign Carry2 = Carry[2];
    
endmodule
    