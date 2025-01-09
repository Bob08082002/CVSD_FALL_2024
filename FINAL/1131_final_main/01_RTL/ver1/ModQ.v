//`define Q 'b111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101101
//`define D 'h52036cee2b6ffe738cc740797779e89800700a4d4141d8ab75eb4dca135978a3
module ModQ(
	input clk,
	input rst,
    input [253:0] H0,
    input [255:0] L0,
    input [257:0] M0,
    output [254:0] Result_FF,
    output [254:0] Result_wo_FF
);
	
	reg [254:0]Result_r;
	wire [254:0]Result_w;
	//output assignment
    assign Result_FF = Result_r;
	assign Result_wo_FF = Result_w;
	
	
	wire [257:0]M0_sub_L0_sub_H0 = (M0 - L0) - H0; // M0 - L0 - H0
	wire [385:0]M0_sub_L0_sub_H0_shift128 = {M0_sub_L0_sub_H0, 128'b0}; // (M0 - L0 - H0) * 2^128
	wire [259:0]H0_mul_38_add_L0 = ({H0, 5'b0} + {H0, 2'b0}) + ({H0, 1'b0} + L0); // H0 * 38 + L0
	
	wire [386:0]T = M0_sub_L0_sub_H0_shift128 + H0_mul_38_add_L0;
	
	wire [131:0]Th;
	wire [254:0]Tl;
	assign {Th, Tl} = T;
	wire [255:0]Th_mul_19_add_Tl = ({Th, 1'b0} + Th) + ({Th, 4'b0} + Tl); // T' = Th * 19 + Tl
	
	wire [256:0]Th_mul_19_add_Tl_sub_Q = Th_mul_19_add_Tl - `Q; // T' - q
	// Mux: if(T' - q > 0) Result = T' - q; else Result = T';
	assign Result_w = (Th_mul_19_add_Tl_sub_Q[256])? Th_mul_19_add_Tl[254:0]:Th_mul_19_add_Tl_sub_Q[254:0];
	
	
	//sequential part
    always @(posedge clk) begin
		if(rst)begin 
			Result_r <= 0;
		end
		else begin
			Result_r <= Result_w;
		end
    end


endmodule