`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/03/2025
// Design Name:
// Module Name: withDebounce
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


module withDebounce(LEDs, BTN, Clk);

    output reg [3:0] LEDs;
    input wire BTN, Clk;

    /*-this is a keyword we have not seen yet!*
     *-as the name implies, it is a parameter *
     * that can be changed at compile time... */
    parameter n = 5;

    wire notMsb, Rst, En, Debounced;
    reg Synchronizer0, Synchronized;
    reg [n-1:0] Count;

    reg edge_detect0;
    wire rising_edge;

    /*This is just for simulation*/
    initial
        LEDs = 0;

    /********************************************/
    /* Debounce circuitry!!!                    */
    /********************************************/

    always@(posedge Clk)
        begin
            Synchronizer0 <= BTN;
            Synchronized <= Synchronizer0;
        end

    //counter increments while button is pressed and hasn't reached the max count
    //gives debounce timing, so how many clock cycles button must be stable for
    always@(posedge Clk)
        if(Rst)
            Count <= 0;
        else if(En) //counts up while button is pressed and most sig bit is 0
            Count <= Count + 1;

    assign notMsb    = ~Count[n-1];          //checks to see if counter hasn't reached where msb is 1
    assign En        = notMsb & Synchronized; //enables counting when button pressed and the counter is not at max
    assign Rst       = ~Synchronized;         //resets counter when button is released
    assign Debounced = Count[n-1];            //debounce signal high when the msb in counter is set

    /********************************************/
    /* End of Debounce circuitry!!!             */
    /********************************************/

    //prev state of debounced signal is detected
    always@(posedge Clk)
        edge_detect0 <= Debounced;

    assign rising_edge = ~edge_detect0 & Debounced; //rising edge is set when current state is high and prev state is low

    always@(posedge Clk)
        if(rising_edge)
            LEDs <= LEDs + 1;

endmodule
