module Mul(
    input clk,
	input rst,
    input [254:0] X,
    input [254:0] Y,
    output [509:0] product_result
);


	// 255*255 4 stage multiplier
	DW02_mult_4_stage #(255, 255)
    U0 ( .A(X),   .B(Y),   .TC(1'b0), 
         .CLK(clk),   .PRODUCT(product_result) );

endmodule