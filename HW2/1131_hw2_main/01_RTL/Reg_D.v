//`include "define.v"
module Reg_D #( 
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) ( 
	input i_clk,
    input i_rst_n,
	
	input Reg_D_en,  
	
	input  [DATA_WIDTH-1:0] Reg_D_imm_in,
	output [DATA_WIDTH-1:0] Reg_D_imm_out,
	
	input  [DATA_WIDTH-1:0] Reg_D_rf1_in,
	output [DATA_WIDTH-1:0] Reg_D_rf1_out,
	
	input  [DATA_WIDTH-1:0] Reg_D_rf2_in,
	output [DATA_WIDTH-1:0] Reg_D_rf2_out,
	
	input  [4:0] Reg_D_rfd_idx_in,
	output [4:0] Reg_D_rfd_idx_out
);
// registers
reg [DATA_WIDTH-1:0] Reg_D_imm_r, Reg_D_imm_w;
reg [DATA_WIDTH-1:0] Reg_D_rf1_r, Reg_D_rf1_w;
reg [DATA_WIDTH-1:0] Reg_D_rf2_r, Reg_D_rf2_w;
reg [4:0] Reg_D_rfd_idx_r, Reg_D_rfd_idx_w;
// combinational assignment
assign Reg_D_imm_out = Reg_D_imm_r;
assign Reg_D_rf1_out = Reg_D_rf1_r;
assign Reg_D_rf2_out = Reg_D_rf2_r;
assign Reg_D_rfd_idx_out = Reg_D_rfd_idx_r;

// next output-logic
always@(*)begin
	Reg_D_imm_w = (Reg_D_en)? Reg_D_imm_in : Reg_D_imm_r; // 1: allow to write, 0: cant write
	Reg_D_rf1_w = (Reg_D_en)? Reg_D_rf1_in : Reg_D_rf1_r; // 1: allow to write, 0: cant write
	Reg_D_rf2_w = (Reg_D_en)? Reg_D_rf2_in : Reg_D_rf2_r; // 1: allow to write, 0: cant write
	Reg_D_rfd_idx_w = (Reg_D_en)? Reg_D_rfd_idx_in : Reg_D_rfd_idx_r; // 1: allow to write, 0: cant write
end

// sequential block
always@(posedge i_clk or negedge i_rst_n)begin
	if(~i_rst_n)begin
		Reg_D_imm_r <= 32'b0;
		Reg_D_rf1_r <= 32'b0;
		Reg_D_rf2_r <= 32'b0;
		Reg_D_rfd_idx_r <= 5'b0;
	end
	else begin
		Reg_D_imm_r <= Reg_D_imm_w;
		Reg_D_rf1_r <= Reg_D_rf1_w;
		Reg_D_rf2_r <= Reg_D_rf2_w;
		Reg_D_rfd_idx_r <= Reg_D_rfd_idx_w;
	end
end

endmodule