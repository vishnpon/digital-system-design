`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Vishnupriya Ponnam
// Module Name: ripple_carry_16bit
// Description: structural 16-bit ripple carry adder, baseline for timing comparison
//////////////////////////////////////////////////////////////////////////////////


//single bit full adder built from gate-level expressions. written this way on
//purpose - a gate-level ripple structure maps onto LUTs rather than the
//dedicated CARRY4 primitives, which is what makes it a fair stand-in for the
//"no fast carry chain" case
module full_adder(S, Cout, A, B, Cin);

    output wire S;
    output wire Cout;
    input wire A, B, Cin;

    assign S    = A ^ B ^ Cin;
    assign Cout = (A & B) | (Cin & (A ^ B));

endmodule


module ripple_carry_16bit(Cout, S, X, Y, Cin);

    //port order and names deliberately match carry_lookahead_16bit so the two
    //can be swapped inside a wrapper without touching anything else
    output wire Cout;        //carry out of the top bit
    output wire [15:0] S;    //sum vector
    input wire [15:0] X, Y;  //addends
    input wire Cin;          //carry in

    //17 bit carry vector - C[0] is Cin, C[16] is Cout. every stage waits on the
    //stage below it, which is the whole point of the comparison
    wire [16:0] C;

    assign C[0] = Cin;
    assign Cout = C[16];

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : rca_stage
            full_adder FA (
                .S    (S[i]),
                .Cout (C[i+1]),
                .A    (X[i]),
                .B    (Y[i]),
                .Cin  (C[i])
            );
        end
    endgenerate

endmodule
