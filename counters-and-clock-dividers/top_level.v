`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Vishnupriya Ponnam
// Module Name: top_level
// Description: ties clock divider, switch-selected clock mux and 3-bit up counter to the LEDs
//////////////////////////////////////////////////////////////////////////////////


module top_level(LEDs, SWs, BTNs, FastClk);
     //all ports will be wire
     
     //4 leds, 2 switches, and 2 buttons
     input wire FastClk;
     input wire [1:0] SWs;
     output wire [3:0] LEDs;
     input wire [1:0] BTNs;
     //fastclk is one bit wide input
     
     //intermediate wires
     wire[3:0] Clocks;
     reg SlowClk; //will use an always block for mux
     
     //behavioral description of four way mux
     always@(*) //combinatorial logic
        case(SWs) // SWs is a 2-bit bus
            2'b00: SlowClk = Clocks[0];
            2'b01: SlowClk = Clocks[1];
            2'b10: SlowClk = Clocks[2];
            2'b11: SlowClk = Clocks[3];
        endcase
        
        //instantiate clock divider
    clock_divider clk_div_0(
        .ClkOut(Clocks),
        .ClkIn(FastClk)
    );
    //instantiate upcounter 
    up_counter counter0(LEDs[2:0], LEDs[3], BTNs[0],SlowClk, BTNs[1]);
    
    
            
endmodule
