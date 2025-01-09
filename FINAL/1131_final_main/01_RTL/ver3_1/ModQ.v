module ModQ(
	input clk,
	input rst,
    input [509:0] product_result,
    output [254:0] Result_FF,
    output [254:0] Result_wo_FF
);
	
	reg [254:0]Result_r;
	wire [254:0]Result_w;
	//output assignment
    assign Result_FF = Result_r;
	assign Result_wo_FF = Result_w;
	
	wire [254:0]T1_h;
	wire [254:0]T1_l;
	assign {T1_h, T1_l} = product_result;
	wire [259:0]T2 = ({T1_h, 1'b0} + T1_h) + ({T1_h, 4'b0} + T1_l); // T2 = T1_h * 19 + T1_l
	
	wire [4:0]T2_h;
	wire [254:0]T2_l;
	assign {T2_h, T2_l} = T2;
	wire [255:0]T3 = ({T2_h, 1'b0} + T2_h) + ({T2_h, 4'b0} + T2_l); // T3 = T2_h * 19 + T2_l
	
	wire [256:0]T3_sub_Q = T3 - `Q; // T3 - q
	// Mux: if(T3 - q > 0) Result = T3 - q; else Result = T3;
	assign Result_w = (T3_sub_Q[256])? T3[254:0]:T3_sub_Q[254:0];
	
	
	//sequential part
    always @(posedge clk) begin
		Result_r <= Result_w;
    end


endmodule