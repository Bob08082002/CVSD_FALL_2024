module Mul(
    input clk,
	input rst,
    input [254:0] X,
    input [254:0] Y,
    output [253:0] H0,
    output [255:0] L0,
    output [257:0] M0
);


    wire [127:0] A1;
	wire [126:0] A2;
    wire [127:0] B1;
	wire [126:0] B2;
    wire [128:0] A1_A2_sum, B1_B2_sum;

 
    //combinational part
    assign {A2, A1} = X;
    assign {B2, B1} = Y;

    assign A1_A2_sum = A1 + A2;
    assign B1_B2_sum = B1 + B2;

	// 127x127 multiplier
	DW02_mult_4_stage #(127, 127)
    U0 ( .A(A2),   .B(B2),   .TC(1'b0), 
         .CLK(clk),   .PRODUCT(H0) );

	// 128x128 multiplier
	DW02_mult_4_stage #(128, 128)
    U1 ( .A(A1),   .B(B1),   .TC(1'b0), 
         .CLK(clk),   .PRODUCT(L0) );

	// 129x129 multiplier
	DW02_mult_4_stage #(129, 129)
    U2 ( .A(A1_A2_sum),   .B(B1_B2_sum),   .TC(1'b0), 
         .CLK(clk),   .PRODUCT(M0) );




endmodule