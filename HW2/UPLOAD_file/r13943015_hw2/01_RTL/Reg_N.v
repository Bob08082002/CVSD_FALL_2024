//`include "define.v"
module Reg_N #( 
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) ( 
	input i_clk,
    input i_rst_n,
	
	input Reg_N_en,  
	input  [ADDR_WIDTH-1:0] Reg_N_pc_in,
	output [ADDR_WIDTH-1:0] Reg_N_pc_out
);
// registers
reg [ADDR_WIDTH-1:0] Reg_N_pc_r, Reg_N_pc_w;
// combinational assignment
assign Reg_N_pc_out = Reg_N_pc_r;

// next output-logic
always@(*)begin
	Reg_N_pc_w = (Reg_N_en)? Reg_N_pc_in : Reg_N_pc_r; // 1: allow to write, 0: cant write
end

// sequential block
always@(posedge i_clk or negedge i_rst_n)begin
	if(~i_rst_n)begin
		Reg_N_pc_r <= 32'b0;
	end
	else begin
		Reg_N_pc_r <= Reg_N_pc_w;
	end
end

endmodule