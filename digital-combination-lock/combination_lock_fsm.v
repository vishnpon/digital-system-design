`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Vishnupriya Ponnam
// Module Name: combination_lock_fsm
// Description: Moore FSM 4-entry combination lock unlocking on 13, 7, 9, 1 via Key1/Key2
//////////////////////////////////////////////////////////////////////////////////


module combination_lock_fsm(
    output reg [2:0] state,
    output wire [3:0] Lock, //asserted when locked
    input wire Key1, //unlock button 1
    input wire Key2, //unlock button 2
    input wire [3:0] Password, //indicate number 
    input wire Reset, //reset
    input wire Clk // clock
    );
    
    reg [2:0] nextState;
    
    //use local parameters for state encoding 
    //change to 3 bit nums for 4 num lock
    localparam S0 = 3'b000;
    localparam S1 = 3'b001;
    localparam S2 = 3'b010;
    localparam S3 = 3'b011;
    localparam S4 = 3'b100;
    
    //check for reset at rising edge
    
    always @(posedge Clk) 
        begin
            if(Reset)
                state <= S0;
            else
                state <= nextState;
        end
        
    //check through all cases 
    always @(*) 
        begin
            case(state) 
                S0: begin 
                    if(Key1 && Password == 4'd13)
                        nextState = S1;
                    else
                        nextState = S0;
                    end
                S1: begin
                    if(Key2 && Password == 4'd7)//move forward if digit is correct
                        nextState = S2;
                    else if (Key2 && Password != 4'd7) //return to s0
                        nextState = S0;
                    else 
                        nextState = S1;
                    end
                S2: begin
                    if(Key1 && Password == 4'd9)
                        nextState = S3;
                    else if (Key1 && Password != 4'd9)
                        nextState = S0;
                    else
                        nextState = S2;
                    end
                S3: begin
                    if(Key2 && Password == 4'd1)
                        nextState = S4;
                    else if(Key2 && Password !=4'd1)
                        nextState = S0;
                    else 
                        nextState = S3;
                    end
                S4: begin
                    nextState = S4;//stay at current if not resetting
                    end
            endcase
       end         
       
       assign Lock = (state == S4) ? 4'b1111 : 4'b0000; // given                  
                        
endmodule
