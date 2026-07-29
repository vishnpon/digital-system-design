`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Vishnupriya Ponnam
// Module Name: tlc_controller_ver1
// Description: top-level controller wiring reset synchronizer, 32-bit timing counter and tlcfsm to the LEDs
//////////////////////////////////////////////////////////////////////////////////


module tlc_controller_ver1(
    output wire [1:0] highwaySignal, farmSignal, //connected to leds
    output wire [3:0] JB,
    input wire Clk,
    //buttons provide input to top level circuit
    input wire Rst //use as reset
   
    );
    
    //intermediate nets 
    wire RstSync;
    wire farmSensorSync;
    wire RstCount;
    reg [31:0] Count;
    
    assign JB[3] = RstCount;
    
    //synchronize button inputs
    synchronizer syncRst(RstSync, Rst, Clk); 
    
    //instantiate fsm 
    tlcfsm FSM(
        .state(JB [2:0]), //wire state up to jb to debug
        .RstCount(RstCount),
        .highwaySignal(highwaySignal),
        .farmSignal(farmSignal),
        .Count(Count),
        .Clk(Clk),
        .Rst(RstSync)
        
    );
    
    always @(posedge Clk)
    
        if(RstSync | RstCount)
            Count <= 0;
        else 
            Count <= Count +1;
    
endmodule
