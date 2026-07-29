`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Vishnupriya Ponnam
// Module Name: synchronizer
// Description: Two-flop synchronizer for async input signals
//////////////////////////////////////////////////////////////////////////////////


module synchronizer(Sync, Async, Clk);

    //NOTE: both tlc_controller_ver1 and tlc_controller_ver2 connect this module
    //positionally - synchronizer syncRst(RstSync, Rst, Clk) - so the port ORDER
    //(Sync, Async, Clk) must not change

    output wire Sync;   //synchronized output, safe to use in the Clk domain
    input wire Async;   //asynchronous input, e.g. a raw button press
    input wire Clk;     //destination domain clock

    //two cascaded d flip flops. the first stage can go metastable when it
    //samples an input that changes near the clock edge; the second stage gives
    //that metastability a full clock period to resolve before the value is used
    reg Meta;    //first stage, may be metastable
    reg Stable;  //second stage, resolved

    //no reset here on purpose - this module is what synchronizes the reset
    //itself, so it cannot depend on a synchronized reset existing yet
    always @(posedge Clk) begin
        Meta   <= Async;
        Stable <= Meta;
    end

    assign Sync = Stable;

endmodule
