//`include "define.v"
`define UPPERBOUND_32BIT 2147483647 
`define LOWERBOUND_32BIT -2147483648 

module alu #( 
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) ( 
	input [6:0] opcode,  // opcode to alu stage
	input [6:0] func7,   // func7  to alu stage
	input [2:0] func3,   // func3  to alu stage
	
	input signed[DATA_WIDTH-1:0] operand_1,
	input signed[DATA_WIDTH-1:0] operand_2,
	output reg [DATA_WIDTH-1:0] alu_result,
	output reg invalid_alu // Is operation valid? invalid if 1.integer arithmetic overflow  2.floating point arithmetic in or out is Nan or INF 3.load, store instruction memory
);



reg signed [DATA_WIDTH:0]extend_result; // one more bit ensure no overflow occured
reg [DATA_WIDTH-1:0] operand_1_unsign, operand_2_unsign;


// ------------------- IEEE 754 Single-Precision ADD,SUB ------------------- 
// ADDER(inst = 0) and SUBTRACTOR(inst = 1)
wire [DATA_WIDTH-1:0] FPU_result;
reg FPU_inst;
reg IsNanINF_1, IsNanINF_2, IsNanINF_result;
FPU_add_sub FPU_add_sub_u(.result(FPU_result), .operand_A(operand_1), .operand_B(operand_2), .inst(FPU_inst));
 
// ------------------- IEEE 754 Single-Precision Comparater ------------------- 
// if operand_A < operand_B, then less_than_flag = 1, else less_than_flag = 0
wire less_than_flag_result;
FPU_cmp FPU_cmp_u(.less_than_flag(less_than_flag_result), .operand_A(operand_1), .operand_B(operand_2)); 



//  ------------------- Functions ------------------- 
/* // c.f. test.v // this is weird
function automatic IsOverflow;
	//check if extend_result exceed 32bit signed number range
	input signed[DATA_WIDTH:0]extend_result;
	begin
		// if input exceed 32 bits range
		if(extend_result > `UPPERBOUND_32BIT) IsOverflow = 1'b1;
		else if(extend_result < `LOWERBOUND_32BIT) IsOverflow = 1'b1;
		else IsOverflow = 1'b0;
	end
endfunction*/

function automatic IsOverflow;
	//check if extend_result exceed 32bit signed number range
	input signed[DATA_WIDTH:0]extend_result;
	reg signed[32:0] upperbound_32bit, lowerbound_32bit;
	begin
		upperbound_32bit = 33'b0_0111_1111_1111_1111_1111_1111_1111_1111;
		//lowerbound_32bit = `LOWERBOUND_32BIT;
		lowerbound_32bit = 33'b1_1000_0000_0000_0000_0000_0000_0000_0000;
		// if input exceed 32 bits range
		if(extend_result > upperbound_32bit) IsOverflow = 1'b1;
		else if(extend_result < lowerbound_32bit) IsOverflow = 1'b1;
		else IsOverflow = 1'b0;
	end
endfunction

function automatic IsExceedDM;
	/*check if extend_result exceed Data Memory range*/
	input signed[DATA_WIDTH:0]extend_result;
	begin
		// if input exceed exceed Data Memory range(4096 ~ 8191)
		if(extend_result > 8191) IsExceedDM = 1'b1;
		else if(extend_result < 4096) IsExceedDM = 1'b1;
		else IsExceedDM = 1'b0;
	end
endfunction

function automatic IsNanINF;
	/*check if floating point number is Nan or INF*/
	input [DATA_WIDTH-1:0]fp_number_in;
	begin
		// if input exceed exceed Data Memory range(4096 ~ 8191)
		if(fp_number_in[30:23] == 8'd255 && fp_number_in[22:0] == 23'd0) IsNanINF = 1'b1; // +INF, -INF
		else if(fp_number_in[30:23] == 8'd255 && fp_number_in[22:0] != 23'd0) IsNanINF = 1'b1; //Nan
		else IsNanINF = 1'b0;
	end
endfunction

function automatic [3:0]ClassifyFPFormat;
	/*Classify floating-point format*/
	input [DATA_WIDTH-1:0]fp_number_in;
	reg [7:0]e;
	reg [22:0]m;
	begin
		e = fp_number_in[30:23];
		m = fp_number_in[22:0];
		if(e == 8'd255 && m == 23'd0) ClassifyFPFormat = (fp_number_in[31])? `FLOAT_NEG_INF:`FLOAT_POS_INF; // -INF, +INF
		else if( e == 8'd255 && m != 23'd0) ClassifyFPFormat = `FLOAT_NAN; //Nan
		else if({e, m} == 31'b0) ClassifyFPFormat = (fp_number_in[31])? `FLOAT_NEG_ZERO:`FLOAT_POS_ZERO; // -Zero, +Zero
		else if( e == 8'b0 && m != 23'b0) ClassifyFPFormat = (fp_number_in[31])? `FLOAT_NEG_SUBNORM:`FLOAT_POS_SUBNORM; // -subnorm, +subnorm
		else ClassifyFPFormat = (fp_number_in[31])? `FLOAT_NEG_NORM:`FLOAT_POS_NORM; // -norm, +norm
	end
endfunction

always@(*)begin
	// default value
	extend_result = 0;
	invalid_alu = 0;
	alu_result = 0;
	operand_1_unsign = operand_1; // signed to unsigned
	operand_2_unsign = operand_2;
	IsNanINF_1 = IsNanINF(operand_1); // check if FPU inputs, outputs are INF or Nan
	IsNanINF_2 = IsNanINF(operand_2);
	IsNanINF_result = IsNanINF(FPU_result);
	FPU_inst = 0; 
	
	
	// ================================== add (signed) ==================================
	if(opcode==`OP_ADD && func7==`FUNCT7_ADD && func3==`FUNCT3_ADD)begin // $rd = $r1 + $r2
		extend_result = operand_1 + operand_2; //$r1 + $r2
		invalid_alu = IsOverflow(extend_result);
		alu_result = extend_result[DATA_WIDTH-1:0];		
	end	
	// ================================== sub(signed) ==================================
	else if(opcode==`OP_SUB && func7==`FUNCT7_SUB && func3==`FUNCT3_SUB)begin // $rd = $r1 - $r2
		extend_result = operand_1 - operand_2; //$r1 - $r2
		invalid_alu = IsOverflow(extend_result);
		alu_result = extend_result[DATA_WIDTH-1:0];	
	end
	// ================================== addi(signed) ==================================
	else if(opcode==`OP_ADDI && func3==`FUNCT3_ADDI)begin  // $rd = $r1 + im
		extend_result = operand_1 + operand_2; //$r1 + im
		invalid_alu = IsOverflow(extend_result);
		alu_result = extend_result[DATA_WIDTH-1:0];
	end
	// ==================================  lw(signed) ==================================  
	else if(opcode==`OP_LW && func3==`FUNCT3_LW)begin  // $rd = Mem[$r1 + im]
		extend_result = operand_1 + operand_2; //$r1 + im
		invalid_alu = IsExceedDM(extend_result);
		alu_result = extend_result[DATA_WIDTH-1:0];
	end	
	// ==================================  sw(signed) ================================== 
	else if(opcode==`OP_SW && func3==`FUNCT3_SW)begin // Mem[$r1 + im] = $r2
		extend_result = operand_1 + operand_2; //$r1 + im
		invalid_alu = IsExceedDM(extend_result);
		alu_result = extend_result[DATA_WIDTH-1:0];
	end
	// ==================================  beq(signed) ==================================  
	else if(opcode==`OP_BEQ && func3==`FUNCT3_BEQ)begin // if($r1==$r2), $pc = $pc + im; else, $pc = $pc + 4
		if(operand_1 == operand_2) alu_result = 32'b1; // if($r1==$r2)
		else alu_result = 32'b0;
		invalid_alu = 1'b0;
	end	
	// ==================================  blt(signed) ==================================  
	else if(opcode==`OP_BLT && func3==`FUNCT3_BLT)begin // if($r1<$r2), $pc = $pc + im; else, $pc = $pc + 4
		if(operand_1 < operand_2) alu_result = 32'b1; // if($r1<$r2)
		else alu_result = 32'b0;
		invalid_alu = 1'b0;
	end	
	// ==================================  slt(signed) ==================================  
	else if(opcode==`OP_SLT && func7==`FUNCT7_SLT && func3==`FUNCT3_SLT)begin //if($r1<$r2), $rd = 1; else, $rd = 0   
		if(operand_1 < operand_2) alu_result = 32'b1; // if($r1<$r2)
		else alu_result = 32'b0;
		invalid_alu = 1'b0;
	end
	// ==================================  sll(unsigned) ================================== 
	else if(opcode==`OP_SLL && func7==`FUNCT7_SLL && func3==`FUNCT3_SLL)begin //$rd = $r1 << $r2 
		alu_result = operand_1_unsign << operand_2_unsign;
		invalid_alu = 1'b0;
	end	
	// ==================================  srl(unsigned) ================================== 
	else if(opcode==`OP_SRL && func7==`FUNCT7_SRL && func3==`FUNCT3_SRL)begin   //$rd = $r1 >> $r2
		alu_result = operand_1_unsign >> operand_2_unsign;
		invalid_alu = 1'b0;
	end
	// ==================================  fadd ==================================  
	else if(opcode==`OP_FADD && func7==`FUNCT7_FADD && func3==`FUNCT3_FADD)begin // $fd = $f1 + $f2 
		FPU_inst = 0; //ADD(inst = 0)
		alu_result = FPU_result;
		// if one of them is Nan or INF ==> invalid
		if(IsNanINF_1 || IsNanINF_2 || IsNanINF_result)begin 
			invalid_alu = 1'b1;
		end
		else begin
			invalid_alu = 1'b0;
		end
	end
	// ==================================  fsub ==================================  
	else if(opcode==`OP_FSUB && func7==`FUNCT7_FSUB && func3==`FUNCT3_FSUB)begin  // $fd = $f1 + $f2 
		FPU_inst = 1; //SUB(inst = 1)
		alu_result = FPU_result;
		// if one of them is Nan or INF ==> invalid 
		if(IsNanINF_1 || IsNanINF_2 || IsNanINF_result) invalid_alu = 1'b1;
		else invalid_alu = 1'b0;
	end
	// ==================================  flw(signed) ==================================  
	else if(opcode==`OP_FLW && func3==`FUNCT3_FLW)begin //$fd = Mem[$r1 + im]
		extend_result = operand_1 + operand_2; //$r1 + im
		invalid_alu = IsExceedDM(extend_result);
		alu_result = extend_result[DATA_WIDTH-1:0];
	end	
	// ==================================  fsw(signed) ==================================  
	else if(opcode==`OP_FSW && func3==`FUNCT3_FSW)begin  //Mem[$r1 + im] = $f2  
		extend_result = operand_1 + operand_2; //$r1 + im
		invalid_alu = IsExceedDM(extend_result);
		alu_result = extend_result[DATA_WIDTH-1:0];
	end
	// ==================================  fclass ==================================  
	else if(opcode==`OP_FCLASS && func7==`FUNCT7_FCLASS && func3==`FUNCT3_FCLASS)begin //Classify floating-point format
		alu_result = {28'b0, ClassifyFPFormat(operand_1)};
		invalid_alu = 1'b0;
	end	
	// ==================================  flt ==================================  
	else if(opcode==`OP_FLT && func7==`FUNCT7_FLT && func3==`FUNCT3_FLT)begin  // if($f1<$f2), $rd = 1; else, $rd = 0 
		alu_result = (less_than_flag_result)? 32'b1: 32'b0;
		// if one of inputs is Nan or INF ==> invalid 
		if(IsNanINF_1 || IsNanINF_2) invalid_alu = 1'b1;
		else invalid_alu = 1'b0;
	end
	
end

endmodule