//`include "define.v"
module Reg_I #( 
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) ( 
	input i_clk,
    input i_rst_n,
	
	input Reg_I_en,  
	input  [DATA_WIDTH-1:0] Reg_I_inst_in,
	output [DATA_WIDTH-1:0] Reg_I_inst_out
);
// registers
reg [DATA_WIDTH-1:0] Reg_I_inst_r, Reg_I_inst_w;
// combinational assignment
assign Reg_I_inst_out = Reg_I_inst_r;

// next output-logic
always@(*)begin
	Reg_I_inst_w = (Reg_I_en)? Reg_I_inst_in : Reg_I_inst_r; // 1: allow to write, 0: cant write
end

// sequential block
always@(posedge i_clk or negedge i_rst_n)begin
	if(~i_rst_n)begin
		Reg_I_inst_r <= 32'b0;
	end
	else begin
		Reg_I_inst_r <= Reg_I_inst_w;
	end
end

endmodule