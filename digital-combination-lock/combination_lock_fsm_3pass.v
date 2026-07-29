`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Vishnupriya Ponnam
// Module Name: combination_lock_fsm_3pass
// Description: Moore FSM 3-entry combination lock unlocking on 13, 7, 9
//////////////////////////////////////////////////////////////////////////////////


module combination_lock_fsm_3pass(
    output reg [1:0] state,
    output wire [3:0] Lock, //asserted when unlocked
    input wire Key1, //unlock button 1
    input wire Key2, //unlock button 2
    input wire [3:0] Password, //indicate number
    input wire Reset, //reset
    input wire Clk // clock
    );

    reg [1:0] nextState;

    //use local parameters for state encoding
    localparam S0 = 2'b00;
    localparam S1 = 2'b01;
    localparam S2 = 2'b10;
    localparam S3 = 2'b11;

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
                    if(Key2 && Password == 4'd7)
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
                    nextState = S3; // reset already checked in first always block
                    end
            endcase
        end

    assign Lock = (state == S3) ? 4'b1111 : 4'b0000; // given

endmodule
