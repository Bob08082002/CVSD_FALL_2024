//`include "define.v"
module decoder #( 
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) ( 
	input [DATA_WIDTH-1:0] inst, 
	
	output [6:0] opcode,  
	output reg [6:0] func7,   
	output reg [2:0] func3, 
		   
	output reg [4:0]r_f_1_idx,  // integer regfile r1 index or floating point regfile f1 index
	output reg [4:0]r_f_2_idx,  // integer regfile r2 index or floating point regfile f2 index
	output reg [4:0]r_f_d_idx,  // integer regfile rd index or floating point regfile fd index
		   
	output  r_f_flag_1, // 0: integer regfile(r1), 1: floating point regfile(f1) // write back rd or fd is controlled by rd_wen & fd_en
	output  r_f_flag_2  // 0: integer regfile(r2), 1: floating point regfile(f2) // write back rd or fd is controlled by rd_wen & fd_en
	
);

assign opcode = inst[6:0];

// instructions which use $f1
// fclass rd $f1
assign r_f_flag_1 =((opcode==`OP_FADD && func7==`FUNCT7_FADD && func3==`FUNCT3_FADD) || //fadd
					(opcode==`OP_FSUB && func7==`FUNCT7_FSUB && func3==`FUNCT3_FSUB) || //fsub
					(opcode==`OP_FLT  && func7==`FUNCT7_FLT  && func3==`FUNCT3_FLT)  || //flt
					(opcode==`OP_FCLASS&&func7==`FUNCT7_FCLASS&&func3==`FUNCT3_FCLASS));//fclass 
// instructions which use $f2
// fsw $f2 $r1 imm  ==>  MEM[$r1+imm] = $f2		
assign r_f_flag_2 =((opcode==`OP_FADD && func7==`FUNCT7_FADD && func3==`FUNCT3_FADD) || //fadd
					(opcode==`OP_FSUB && func7==`FUNCT7_FSUB && func3==`FUNCT3_FSUB) || //fsub
					(opcode==`OP_FLT  && func7==`FUNCT7_FLT  && func3==`FUNCT3_FLT)  || //flt
					(opcode==`OP_FSW  && func3==`FUNCT3_FSW));   //fsw
					

always@(*)begin
	case(opcode) //opcode
	7'b0110011, 7'b1010011: begin //R_type
		func7 = inst[31:25];
		func3 = inst[14:12];
		r_f_1_idx = inst[19:15];
		r_f_2_idx = inst[24:20];
		r_f_d_idx = inst[11:7];
	end
	7'b0010011, 7'b0000011, 7'b0000111:begin //I_type
		func7 = 0; //dontcare
		func3 = inst[14:12];
		r_f_1_idx = inst[19:15];
		r_f_2_idx = 0; //dontcare
		r_f_d_idx = inst[11:7];
	end
	7'b0100011, 7'b0100111:begin //S_type
		func7 = 0; //dontcare
		func3 = inst[14:12];
		r_f_1_idx = inst[19:15];
		r_f_2_idx = inst[24:20];
		r_f_d_idx = 0; //dontcare
	end
	7'b1100011:begin //B_type
		func7 = 0; //dontcare
		func3 = inst[14:12];
		r_f_1_idx = inst[19:15];
		r_f_2_idx = inst[24:20];
		r_f_d_idx = 0; //dontcare
	end
	default:begin
		func7 = 0; //dontcare
		func3 = 0; //dontcare
		r_f_1_idx = 0; //dontcare
		r_f_2_idx = 0; //dontcare
		r_f_d_idx = 0; //dontcare
	end
	endcase
end

endmodule