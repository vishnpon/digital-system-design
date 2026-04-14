`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025 11:16:01 AM
// Design Name: 
// Module Name: tlcfsm
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


module tlcfsm(
    output reg [2:0] state, //current state, output for debugging
    output reg RstCount, //counter reset signal for mealy
    output reg [1:0] highwaySignal, farmSignal, //traffic light outputs
    input wire [31:0] Count, //32 bit counter input 
    input wire Clk, Rst //clock and reset signals
    );
    
    //3 bit state encoding for 6 states s0-s5
    parameter S0 = 3'b000; //both red
    parameter S1 = 3'b001; //highway green, farm red
    parameter S2 = 3'b010; //highway yellow, farm red
    parameter S3 = 3'b011; //both lights red
    parameter S4 = 3'b100; //highway red, farm green
    parameter S5 = 3'b101; //highway red, farm yellow

    
    //encoding for traffic light color
    parameter red = 2'b01; 
    parameter yellow = 2'b10;
    parameter green = 2'b11;
    
    //count vals based on 125 mhz
    parameter sec1 = 125000000;
    parameter sec3 = 3 *sec1;
    parameter sec15 = 15 *sec1;
    parameter sec30 = 30 *sec1;
    
    //internal nets
    reg [2:0] nextState;
    
    //next state combinational logic
    always @(*) begin
        case(state)
            //state s0--both lights red
            S0: begin
                if(Count == sec1)
                    nextState = S1; //move to highway green
                else 
                    nextState = S0;
            end 
                    
            //state s1 = highway green, farm red
            S1: begin
                if(Count == sec30)
                    nextState = S2; //move to highway yellow
                else 
                    nextState = S1;
            end
      
            //state s2 - highway yellow, farm red
            S2: begin 
                if(Count == sec3)
                    nextState = S3; //move to transition
                else 
                    nextState = S2; 
            end
            //state s3 = both red
            S3: begin
                if(Count == sec1)
                    nextState = S4; //move to farm green
                else
                    nextState = S3;
            end
            //state s4 = highway red, farm green
            S4:begin
                if(Count == sec3)
                    nextState = S5; //move to farm yellow
                else 
                    nextState = S4;
            end
            
            S5: begin 
                if(Count ==sec3)
                    nextState = S0; //return to s0 and restart cycle
                else
                    nextState = S5; //stay in s5
            end 
       endcase
    end 
    
    //output logic for rstcount 
    always @(*) begin
        case(state)
            S0: RstCount = (Count ==sec1) ? 1'b1 : 1'b0;
            S1: RstCount = (Count ==sec30) ? 1'b1 : 1'b0;
            S2: RstCount = (Count ==sec3) ? 1'b1 : 1'b0;
            S3: RstCount = (Count ==sec1) ? 1'b1 : 1'b0;
            S4: RstCount = (Count ==sec15) ? 1'b1 : 1'b0;
            S5: RstCount = (Count ==sec3) ? 1'b1 : 1'b0;
            
           
        endcase
    end
    

    
    //traffic signals output logic
    always @(*) begin
        case(state)
            S0: begin
                highwaySignal = red;
                farmSignal = red;
            end
            S1: begin
                highwaySignal = green;
                farmSignal = red;
                
            end
            
            S2: begin
                highwaySignal = yellow;
                farmSignal = red;
            end 
            S3: begin
                highwaySignal = red;
                farmSignal = red;
            end  
            S4: begin
                highwaySignal = red;
                farmSignal = green;
            end
            
            S5: begin
                highwaySignal = red;
                farmSignal = yellow;
            end  
        endcase
    end
    
    //state reg 
    always @(posedge Clk) begin
        if(Rst)
            state <=S0; //reset to initial state
        else
            state <= nextState;//update
    end 
               
    
endmodule
