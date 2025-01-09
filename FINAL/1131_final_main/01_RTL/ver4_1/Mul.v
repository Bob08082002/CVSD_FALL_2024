module Mul(
    input clk,
	input rst,
    input [254:0] X,
    input [254:0] Y,
    output [253:0] H0,
    output [255:0] L0,
    output [257:0] M0
);
    reg [253:0] H0_r, H0_w;
    reg [255:0] L0_r, L0_w;
    reg [257:0] M0_r, M0_w;

    wire [127:0] A1_w; reg [127:0] A1_r; 
	wire [126:0] A2_w; reg [126:0] A2_r;
    wire [127:0] B1_w; reg [127:0] B1_r;
	wire [126:0] B2_w; reg [126:0] B2_r;
    wire [128:0] A1_A2_sum_w, B1_B2_sum_w;
    reg [128:0] A1_A2_sum_r, B1_B2_sum_r;

    //output assignment
    assign H0 = H0_r;
    assign L0 = L0_r;
    assign M0 = M0_r;
 
    //combinational part
    assign {A2_w, A1_w} = X;
    assign {B2_w, B1_w} = Y;

    assign A1_A2_sum_w = A1_w + A2_w;
    assign B1_B2_sum_w = B1_w + B2_w;

	// 127x127 multiplier
    always@(*)begin
        H0_w = A2_r * B2_r;
    end
	// 128x128 multiplier
    always@(*)begin
        L0_w = A1_r * B1_r;
    end
	// 129x129 multiplier
    always@(*)begin
        M0_w = A1_A2_sum_r * B1_B2_sum_r;
    end

    //sequential part
    always @(posedge clk) begin
			H0_r <= H0_w;
			L0_r <= L0_w;
			M0_r <= M0_w;
			
			A1_r <= A1_w;
			A2_r <= A2_w;
			B1_r <= B1_w;
			B2_r <= B2_w;
			A1_A2_sum_r <= A1_A2_sum_w;
			B1_B2_sum_r <= B1_B2_sum_w;			
    end

endmodule