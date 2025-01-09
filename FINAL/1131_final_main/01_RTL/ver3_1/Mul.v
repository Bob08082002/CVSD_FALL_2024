module Mul(
    input clk,
	input rst,
    input [254:0] X,
    input [254:0] Y,
    output [509:0] product_result
);
    reg [509:0] product_result_r, product_result_w;
	assign product_result = product_result_r;
    
	// 255x255 multiplier
    always@(*)begin
        product_result_w = X * Y;
    end

    //sequential part
    always @(posedge clk) begin
			product_result_r <= product_result_w;
    end

endmodule