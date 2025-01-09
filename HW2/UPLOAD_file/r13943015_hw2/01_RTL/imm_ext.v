//`include "define.v"
module imm_ext #( 
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) ( 
	input [DATA_WIDTH-1:0] inst, 
	output reg [DATA_WIDTH-1:0] imm
);

always@(*)begin
	case(inst[6:0]) //opcode
	7'b0110011, 7'b1010011: //R_type
		imm = 0;
	7'b0010011, 7'b0000011, 7'b0000111: //I_type
		imm = {{20{inst[31]}}, inst[31:20]}; // signed-ext
	7'b0100011, 7'b0100111: //S_type
		imm = {{20{inst[31]}}, inst[31:25], inst[11:7]}; // signed-ext
	7'b1100011: //B_type
		imm = {{19{inst[31]}},inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}; // signed-ext
	default:
		imm = 0;
	endcase
end

endmodule