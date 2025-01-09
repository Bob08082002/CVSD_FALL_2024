//`include "define.v"
module program_counter #( 
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) ( 
	input signed [ADDR_WIDTH-1:0] pc_cur, // current pc  // unsigned to signed:  -2^31 ~ 2^31 - 1
	input signed [ADDR_WIDTH-1:0] simm,    //signed-ext immediate //signed number
	input branch_flag, // 0: no branch, 1: branch to $pc + imm 
	
	output [ADDR_WIDTH-1:0] pc_next, // next pc
	output invalid_pc //invalif if pc is fetching an invalid memory index(ex: fetching DM: idx[12:2] > 1023)
);


wire signed[ADDR_WIDTH-1:0] pc_add = (branch_flag)? pc_cur + simm: pc_cur + 4; // 0: no branch, 1: branch to $pc + imm 

assign pc_next = pc_add;

assign invalid_pc = (pc_add > 4095 || pc_add < 0); // invalid if pc_next exceeds Instruction Memory // 0 ~ 4095 is Inst Memory

endmodule