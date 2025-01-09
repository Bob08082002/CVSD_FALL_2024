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

    wire [127:0] A1;
	wire [126:0] A2;
    wire [127:0] B1;
	wire [126:0] B2;
    wire [128:0] A1_A2_sum, B1_B2_sum;

    //output assignment
    assign H0 = H0_r;
    assign L0 = L0_r;
    assign M0 = M0_r;
 
    //combinational part
    assign {A2, A1} = X;
    assign {B2, B1} = Y;

    assign A1_A2_sum = A1 + A2;
    assign B1_B2_sum = B1 + B2;

	// 127x127 multiplier
    always@(*)begin
        H0_w = A2 * B2;
    end
	// 128x128 multiplier
    always@(*)begin
        L0_w = A1 * B1;
    end
	// 129x129 multiplier
    always@(*)begin
        M0_w = A1_A2_sum * B1_B2_sum;
    end

    //sequential part
    always @(posedge clk) begin
		if(rst)begin
		
		end
		else begin
			H0_r <= H0_w;
			L0_r <= L0_w;
			M0_r <= M0_w;
		end
    end

endmodule