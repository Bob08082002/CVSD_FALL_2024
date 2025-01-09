//`include "define.v"
module Reg_A #( 
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) ( 
	input i_clk,
    input i_rst_n,
	
	input Reg_A_en,  
	input  [DATA_WIDTH-1:0] Reg_A_rfd_in,
	output [DATA_WIDTH-1:0] Reg_A_rfd_out
);
// registers
reg [DATA_WIDTH-1:0] Reg_A_rfd_r, Reg_A_rfd_w;
// combinational assignment
assign Reg_A_rfd_out = Reg_A_rfd_r;

// next output-logic
always@(*)begin
	Reg_A_rfd_w = (Reg_A_en)? Reg_A_rfd_in : Reg_A_rfd_r; // 1: allow to write, 0: cant write
end

// sequential block
always@(posedge i_clk or negedge i_rst_n)begin
	if(~i_rst_n)begin
		Reg_A_rfd_r <= 32'b0;
	end
	else begin
		Reg_A_rfd_r <= Reg_A_rfd_w;
	end
end

endmodule