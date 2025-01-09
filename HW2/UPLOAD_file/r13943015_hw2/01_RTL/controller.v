//`include "define.v"
module controller #( 
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) ( 
    input i_clk,
    input i_rst_n,
	
	input [6:0] i_opcode,  // opcode from decode stage
	input [6:0] i_func7,   // func7  from decode stage
	input [2:0] i_func3,   // func3  from decode stage
	
	input i_invalid_pc,    // 0: valid, 1: invalid => pc is fetching an invalid memory index(ex: fetching DM: idx > 1023)				   
	input i_invalid_alu,   // 0: valid   => operation of instruction is valid
	                       // 1: invalid => 1.integer arithmetic overflow  2.floating point arithmetic in or out is Nan or INF 3.load, store instruction memory
	input i_branch_cond,   // 0: no branch, 1: branch to $pc + imm
	
	// ---- MEM ----
	output mem_addr_IM_DM_mux_sel, // 0: IM address, 1: DM address
	output mem_wen,        // 0: read, 1: write
	
	// ---- REGFILE ----
	output rd_wen,         // 0: read, 1: write // integer regfile
	output fd_wen,         // 0: read, 1: write // floating point regfile
	output alu_lw_mux_sel, // 0: rd or fd is from alu, 1: rd or fd is loaded from Data Memory
	
	// ---- STAGE REG ----
	output Reg_I_en,     // 0: keep, 1: store new value // INST_FETCH stage
	output Reg_D_en,     // 0: keep, 1: store new value // DECODE stage
	output Reg_A_en,     // 0: keep, 1: store new value // ALU stage
	output Reg_N_en,     // 0: keep, 1: store new value // NEXT_PC_GEN stage
	
	// ---- ALU ----
	output imm_rf2_mux_sel, // choose ALU operand 2 ==> 0: imm, 1: rf2
	output [6:0] o_opcode,  // opcode to alu stage
	output [6:0] o_func7,   // func7  to alu stage
	output [2:0] o_func3,   // func3  to alu stage
	
	// ---- PC ----
	output branch_flag,  // 0: no branch, 1: branch to $pc + imm 
	
	// ---- STATUS -----
	output reg [2:0] status, 
    output       status_valid
);

// states local parameter
localparam IDLE = 4'd0, INST_FETCH = 4'd1, DECODE = 4'd2, ALU = 4'd3, WRITE_BACK = 4'd4, NEXT_PC_GEN = 4'd5, PROCESS_END = 4'd6;

// ---------------------------------------------------------------------------
// Wires and Registers
// ---------------------------------------------------------------------------
reg [3:0]st, nst;

// opcode, func7, func3
reg [6:0]opcode_r, opcode_w;
reg [6:0]func7_r, func7_w;
reg [2:0]func3_r, func3_w;

// counters
reg cnt1_r, cnt1_w;

// flags
reg process_end_invalid_eof_r, process_end_invalid_eof_w; // 0: invalid, 1: eof
reg branch_cond_r, branch_cond_w;                         // 0: no branch, 1: branch to $pc + imm
wire IsEOF = (opcode_r == `OP_EOF);



// ---------------------------------------------------------------------------
// Continuous Assignment
// ---------------------------------------------------------------------------

// ---- MEM ----
assign mem_addr_IM_DM_mux_sel = (st == INST_FETCH)? 1'b0 : 1'b1; // 0: IM address(INST_FETCH), 1: DM address(ALU)
// write mem iff valid(which store value in DM) and instruction is S type(store) and "at ALU state"
assign mem_wen = (st == ALU && !i_invalid_alu && ((opcode_r == `OP_SW && func3_r == `FUNCT3_SW )|| (opcode_r == `OP_FSW && func3_r == `FUNCT3_FSW))); //0: read, 1: write 
				
				
// ---- REGFILE ----								
// write back integer regfile iff "state is WRITE_BACK" and inst is add, sub, slt, sll, srl, addi, lw, fclass, flt 
assign rd_wen = (st == WRITE_BACK && (
					(opcode_r == 7'b0110011) || // add, sub, slt, sll, srl
					(opcode_r == `OP_ADDI) || (opcode_r == `OP_LW) || // addi, lw
					(opcode_r == `OP_FCLASS && func7_r == `FUNCT7_FCLASS && func3_r == `FUNCT3_FCLASS) || // fclass
					(opcode_r == `OP_FLT && func7_r == `FUNCT7_FLT && func3_r == `FUNCT3_FLT) // flt
					)
				);
// write back fp num regfile iff "state is WRITE_BACK" and inst is fadd, fsub, flw
assign fd_wen = (st == WRITE_BACK &&  (
					(opcode_r == `OP_FADD && func7_r == `FUNCT7_FADD && func3_r == `FUNCT3_FADD) || //fadd
					(opcode_r == `OP_FSUB && func7_r == `FUNCT7_FSUB && func3_r == `FUNCT3_FSUB) || //fsub
					(opcode_r == `OP_FLW) //flw
					)
				);
// 0: rd or fd is from alu, 1: rd or fd is loaded from Data Memory
assign alu_lw_mux_sel = (opcode_r == `OP_LW || opcode_r == `OP_FLW);
			
			
// ---- STAGE REG ----
assign Reg_I_en = (st == INST_FETCH && nst == DECODE); // 0: keep, 1: store new value
assign Reg_D_en = (st == DECODE);                      // 0: keep, 1: store new value
assign Reg_A_en = (st == ALU);                         // 0: keep, 1: store new value
assign Reg_N_en = (st == NEXT_PC_GEN);                 // 0: keep, 1: store new value


// ---- ALU ----
// choose ALU operand 2 ==> 0: imm, 1: rf2
// addi, lw, sw, flw, fsw use imm as operand2 in alu
assign imm_rf2_mux_sel = ((opcode_r == `OP_ADDI) || (opcode_r == `OP_LW) || (opcode_r == `OP_SW) || (opcode_r == `OP_FLW) || (opcode_r == `OP_FSW))? 1'b0:1'b1; 
assign o_opcode = opcode_r;
assign o_func7 = func7_r;
assign o_func3 = func3_r;


// ---- PC ----
// branch iff branch_cond_r = true and instruction is B type
assign branch_flag = (st == NEXT_PC_GEN && branch_cond_r && opcode_r == 7'b1100011); // 0: no branch, 1: branch to $pc + imm

// ---- STATUS -----
always@(*)begin
	status = 0; // give default value
	if(st == NEXT_PC_GEN)begin
		case(opcode_r) //opcode
			7'b0110011, 7'b1010011: //R_type
				status = `R_TYPE;
			7'b0010011, 7'b0000011, 7'b0000111: //I_type
				status = `I_TYPE;
			7'b0100011, 7'b0100111: //S_type
				status = `S_TYPE;
			7'b1100011: //B_type
				status = `B_TYPE;
		endcase
	end
	else if(st == PROCESS_END)begin
		if(process_end_invalid_eof_w == 1'b0) // invalid
			status = `INVALID_TYPE;
		else  // eof
			status = `EOF_TYPE;
	end
	else if(st == IDLE)begin // output are 0 when reset is active
		status = 0;
	end
end
// status is valid iff at (NEXT_PC_GEN state and inst is valid: valid status) or (PROCESS_END state: invalid status/ EOF status)
assign status_valid = ((st == NEXT_PC_GEN && !i_invalid_pc) || st == PROCESS_END ); 


// ---------------------------------------------------------------------------
// Combinational Blocks
// ---------------------------------------------------------------------------
// Next-State Logic
always@(*)begin
	case(st)
	IDLE: nst = INST_FETCH;
	
	INST_FETCH: 
		if(cnt1_r == 1'b1) nst = DECODE;
		else nst = INST_FETCH;
		
	DECODE: nst = ALU;
	
	ALU: 
		if(IsEOF || i_invalid_alu) nst = PROCESS_END; //if EOF or invalid occured
		else nst = WRITE_BACK;
		
	WRITE_BACK: nst = NEXT_PC_GEN;
	
	NEXT_PC_GEN:
		if(i_invalid_pc) nst = PROCESS_END; //if invalid occured
		else nst = INST_FETCH;
	
	PROCESS_END: nst = PROCESS_END;
	
	default: nst = IDLE;
	
	endcase
end
// counters
always@(*)begin
	if((st == IDLE && nst == INST_FETCH)||(st == NEXT_PC_GEN && nst == INST_FETCH)) 
		cnt1_w = 1'b0; // initialize to zero
	else if(st == INST_FETCH) 
		cnt1_w = 1'b1; // increase 1
	else 
		cnt1_w = cnt1_r;
end
// flags
always@(*)begin
	process_end_invalid_eof_w = process_end_invalid_eof_r; // give default value
	branch_cond_w = branch_cond_r; // give default value
	if(st == ALU)begin
		process_end_invalid_eof_w = (i_invalid_alu)? 1'b0:1'b1; // 0: invalid,   1: eof
		branch_cond_w = i_branch_cond;                          // 0: no branch, 1: branch to $pc + imm	
	end	
	else if(st == NEXT_PC_GEN)begin
		process_end_invalid_eof_w = (i_invalid_pc)? 1'b0:1'b1;  // 0: invalid,   1: eof
	end
end
// opcode, func7, func3
always@(*)begin
	if(st == DECODE)begin // get new value from decoder at decode stage
		opcode_w = i_opcode;
		func7_w = i_func7;
		func3_w = i_func3;
	end
	else begin
		opcode_w = opcode_r;
		func7_w = func7_r;
		func3_w = func3_r;
	end
end

// ---------------------------------------------------------------------------
// Sequential Block
// ---------------------------------------------------------------------------
// state
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n) 
		st <= IDLE;
	else 
		st <= nst;
end
// counters
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n) 
		cnt1_r <= 1'b0;
	else 
		cnt1_r <= cnt1_w;
end
// flags
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin 
		process_end_invalid_eof_r <= 1'b0;
		branch_cond_r <= 1'b0;
	end
	else begin
		process_end_invalid_eof_r <= process_end_invalid_eof_w;
		branch_cond_r <= branch_cond_w;
	end
end
// opcode, func7, func3
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin
		opcode_r <= 7'b0;
		func7_r <= 7'b0;
		func3_r <= 3'b0;
	end
	else begin
		opcode_r <= opcode_w;
		func7_r <= func7_w;
		func3_r <= func3_w;
	end
end

endmodule