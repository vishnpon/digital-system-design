`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/01/2025 11:42:47 AM
// Design Name:
// Module Name: tlc_controller_ver2
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Modified top-level Traffic Light Controller.
//              Extends ver1 by adding a farmSensor input and synchronizer
//              to support the 8-state tlcfsm_modified FSM.
//
// Dependencies: tlcfsm_modified, synchronizer
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module tlc_controller_ver2(
    output wire [1:0] highwaySignal, farmSignal, //connected to leds
    output wire [3:0] JB,
    input wire Clk,
    input wire Rst,          //use as reset (BTN0)
    input wire farmSensor    //farm road sensor input (BTN1)
    );

    //intermediate nets
    wire RstSync;
    wire farmSensorSync;
    wire RstCount;
    reg [31:0] Count;

    assign JB[3] = RstCount;

    //synchronize button inputs
    synchronizer syncRst(RstSync, Rst, Clk);

    //synchronize farm sensor input
    synchronizer syncFarmSensor(farmSensorSync, farmSensor, Clk);

    //instantiate modified fsm
    tlcfsm_modified FSM(
        .state(JB[2:0]),           //wire state up to jb to debug
        .RstCount(RstCount),
        .highwaySignal(highwaySignal),
        .farmSignal(farmSignal),
        .Count(Count),
        .Clk(Clk),
        .Rst(RstSync),
        .farmSensor(farmSensorSync)
    );

    //counter - resets on RstSync or RstCount
    always @(posedge Clk)
        if(RstSync | RstCount)
            Count <= 0;
        else
            Count <= Count + 1;

endmodule
