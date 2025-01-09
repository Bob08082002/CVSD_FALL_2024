module ALU(
    input clk,
    input rst,
	input in_valid,
	input [1:0]in_state, // 0: PRE-CAL, 1: DOUBLE, 2: DIV-INV, 3: DIV-MUL
	input in_keep_flag,        // if DOUBLEandADD & DOUBLEandADD, DIV-INV & DIV-INV consecutive
	input in_consecutive_flag, // if DOUBLE & ADD , DIV-INV(r*r & r*other) consecutive
	input [254:0]in_X_reg,
	input [254:0]in_Y_reg,
	input [254:0]in_Z_reg,
	input [254:0]in_T_reg,
	input [254:0]in_X_lut, // A2_lut
	input [254:0]in_Y_lut, // B2_lut
	input [254:0]in_T_lut, // Td_lut
	
	output out_ready, // finish calculation
	output reg [254:0]out_X,
	output reg [254:0]out_Y,
	output reg [254:0]out_Z,
	output reg [254:0]out_T,
	output out_X_reg_we,
	output out_Y_reg_we,
	output out_Z_reg_we,
	output out_T_reg_we,
	output out_X_lut_we,
	output out_Y_lut_we,
	output out_T_lut_we
);

// local parameters
localparam IDLE = 0, PRE_CAL = 1, DOUBLE = 2, ADDITION = 3, DIVINV = 4, DIVMUL = 5;
// state
reg [2:0] alu_st, alu_nst;
// counter
reg [3:0] alu_counter_r, alu_counter_w;
// Mux of Mul's operands // inputs of Mul
reg [254:0]mux_out_Mul_X;
reg [254:0]mux_out_Mul_Y;
reg [2:0]mux_sel_Mul_X;
reg [2:0]mux_sel_Mul_Y;
// Mux of ModularAdd's operands // inputs of ModularAdd
reg [254:0]mux_out_ModularAdd_X;
reg [254:0]mux_out_ModularAdd_Y;
reg [2:0]mux_sel_ModularAdd_X;
reg [1:0]mux_sel_ModularAdd_Y;
// Mux of ModularSub's operands // inputs of ModularSub
reg [254:0]mux_out_ModularSub_X;
reg [254:0]mux_out_ModularSub_Y;
reg [2:0]mux_sel_ModularSub_X;
reg [1:0]mux_sel_ModularSub_Y;
// interconnect of Mul & ModQ
wire [509:0] product_result_wire;
// outputs of ModQ, ModularAdd, ModularSub
wire [254:0] ModQ_out_FF;
wire [254:0] ModQ_out_wo_FF; 
wire [254:0] ModularAdd_out;
wire [254:0] ModularSub_out;
// Mux of ALU's output
reg [1:0]mux_sel_out_X;
reg [1:0]mux_sel_out_Y;
reg [1:0]mux_sel_out_Z;
reg [1:0]mux_sel_out_T;




// -------------------------- state --------------------------
always@(*)begin
	alu_nst = IDLE; // optimize?
	case(alu_st)
		IDLE:begin
			if(in_valid)begin
				case(in_state)
					0: alu_nst = PRE_CAL;
					1: alu_nst = DOUBLE;
					2: alu_nst = DIVINV;
					3: alu_nst = DIVMUL;
				endcase
			end
			else begin
				alu_nst = IDLE;
			end
		end
		PRE_CAL:begin
			if(alu_counter_r == 3)alu_nst = IDLE;
			else alu_nst = PRE_CAL;
		end
		DOUBLE:begin
			if(alu_counter_r == 9)begin
				if(in_consecutive_flag)alu_nst = ADDITION;
				else begin
					if(in_keep_flag)alu_nst = DOUBLE;
					else alu_nst = IDLE;
				end
			end
			else alu_nst = DOUBLE;
		end
		ADDITION:begin
			if(alu_counter_r == 8)begin
				if(in_keep_flag)alu_nst = DOUBLE;
				else alu_nst = IDLE;
			end
			else alu_nst = ADDITION;
		end
		DIVINV:begin  // calculate the modular inversion: r = r*r -> r = r*(other or 1, depends on in_consecutive_flag)
			if(alu_counter_r == 3)begin
				if(in_keep_flag)alu_nst = DIVINV;
				else alu_nst = IDLE;
			end
			else alu_nst = DIVINV;
		end
		DIVMUL:begin  // x = r*X -> keep x even, y = r*Y -> keep y even
			if(alu_counter_r == 3)begin
				alu_nst = IDLE;
			end
			else alu_nst = DIVMUL;
		end
	endcase
end
always@(posedge clk)begin
    if(rst)begin
        alu_st <= IDLE;
    end
    else begin
		alu_st <= alu_nst;
    end
end

// -------------------------- counter --------------------------
always@(*)begin
	if((alu_st == IDLE && in_valid) 
	|| (alu_st == DOUBLE && alu_nst == ADDITION) 
	|| (alu_st == DOUBLE && alu_counter_r == 9 && alu_nst == DOUBLE) 
	|| (alu_st == ADDITION && alu_nst == DOUBLE)
	|| (alu_st == DIVINV && alu_counter_r == 3 && alu_nst == DIVINV)) // initial counter when enter a new state
		alu_counter_w = 0;
	else 
		alu_counter_w = alu_counter_r + 1;
end
always@(posedge clk)begin
    if(rst)begin
        alu_counter_r <= 0;
    end
    else begin
		alu_counter_r <= alu_counter_w;
    end
end

// -------------------------- outputs --------------------------
// write enables
// optimize?
assign out_X_reg_we = (alu_st==DOUBLE && (alu_counter_r==2||alu_counter_r==5||alu_counter_r==9))||
					  (alu_st==ADDITION && (alu_counter_r==0||alu_counter_r==2||alu_counter_r==4||alu_counter_r==7));		  
assign out_Y_reg_we = (alu_st==DOUBLE && (alu_counter_r==4||alu_counter_r==6))||
					  (alu_st==ADDITION && (alu_counter_r==0||alu_counter_r==3||alu_counter_r==6));
assign out_Z_reg_we = (alu_st==DOUBLE && (alu_counter_r==1||alu_counter_r==4||alu_counter_r==7))||
					  (alu_st==ADDITION && (alu_counter_r==1||alu_counter_r==3||alu_counter_r==5));
assign out_T_reg_we = (alu_st==DOUBLE && (alu_counter_r==2||alu_counter_r==5||alu_counter_r==8))||
					  (alu_st==ADDITION && (alu_counter_r==2||alu_counter_r==4||alu_counter_r==8));
assign out_X_lut_we = (alu_st==PRE_CAL && (alu_counter_r==0))||
					  (alu_st==DIVINV && (alu_counter_r==1 || alu_counter_r==3))||
					  (alu_st==DIVMUL && alu_counter_r==2);
assign out_Y_lut_we = (alu_st==PRE_CAL && (alu_counter_r==0))||
					  (alu_st==DIVMUL && alu_counter_r==3);
assign out_T_lut_we = (alu_st==PRE_CAL && (alu_counter_r==1||alu_counter_r==3));

// out_ready
// output ready when it is the last cycle of one operation
assign out_ready = (alu_st==DOUBLE && (in_consecutive_flag==0&&alu_counter_r==9)) || 
				   (alu_st==ADDITION && alu_counter_r==8) ||
				   (alu_st==PRE_CAL && alu_counter_r==3) || 
				   (alu_st==DIVINV && alu_counter_r==3) ||
				   (alu_st==DIVMUL && alu_counter_r==3);

//-------------------------- Modular Multiplier, Modular Adder, Modular Substractor --------------------------
Mul Mul_u0(
    .clk(clk),
	.rst(rst),
    .X(mux_out_Mul_X),
    .Y(mux_out_Mul_Y),
    .product_result(product_result_wire)
);
ModQ ModQ_u0(
	.clk(clk),
	.rst(rst),
    .product_result(product_result_wire),
	.Result_FF(ModQ_out_FF),
    .Result_wo_FF(ModQ_out_wo_FF)
);
ModularAdd ModularAdd_u0(
    .X(mux_out_ModularAdd_X),
    .Y(mux_out_ModularAdd_Y),
    .Result(ModularAdd_out)
);
ModularSub ModularSub_u0(
    .X(mux_out_ModularSub_X),
    .Y(mux_out_ModularSub_Y),
    .Result(ModularSub_out)
);


// -------------------------- Mux of Modular Multiplier input operands -------------------------- 
// specify Modular Multiplier input for different states
always@(*)begin
	case(mux_sel_Mul_X)
	0: mux_out_Mul_X = in_X_reg;
	1: mux_out_Mul_X = in_Y_reg;
	2: mux_out_Mul_X = in_Z_reg;
	3: mux_out_Mul_X = in_X_lut;
	4: mux_out_Mul_X = in_Y_lut;
	5: mux_out_Mul_X = in_T_lut;
	6: mux_out_Mul_X = 1;
	default: mux_out_Mul_X = 0; // optimize?
	endcase
end
always@(*)begin
	case(mux_sel_Mul_Y)
	0: mux_out_Mul_Y = in_X_reg;
	1: mux_out_Mul_Y = in_Y_reg;
	2: mux_out_Mul_Y = in_Z_reg;
	3: mux_out_Mul_Y = in_X_lut;
	4: mux_out_Mul_Y = in_T_reg;
	5: mux_out_Mul_Y = `D;
	default: mux_out_Mul_Y = 0; // optimize?
	endcase
end
always@(*)begin
	mux_sel_Mul_X = 0; // optimize?
	case(alu_st)
		DOUBLE:begin
			case(alu_counter_r)
				1, 7, 8: mux_sel_Mul_X = 0; // X_reg
				2, 5, 6: mux_sel_Mul_X = 1; // Y_reg
				0, 3:    mux_sel_Mul_X = 2; // Z_reg
			endcase
		end
		ADDITION:begin
			case(alu_counter_r)
				1, 7: mux_sel_Mul_X = 0; // X_reg
				4, 6: mux_sel_Mul_X = 1; // Y_reg
				5:    mux_sel_Mul_X = 2; // Z_reg
				2:    mux_sel_Mul_X = 4; // Y_lut(B2_lut)
				0:    mux_sel_Mul_X = 5; // T_lut(Td_lut)
			endcase
		end
		PRE_CAL:begin
			case(alu_counter_r)
				0: mux_sel_Mul_X = 4; // Y_lut(B2_lut)
				2: mux_sel_Mul_X = 5; // T_lut(Td_lut)
			endcase
		end
		DIVINV:begin
			case(alu_counter_r)
				2: mux_sel_Mul_X = (in_consecutive_flag)? 2:6; // Z_reg or 1
				0: mux_sel_Mul_X = 3; // X_lut(A2_lut)
			endcase
		end
		DIVMUL:begin
			mux_sel_Mul_X = 3; // X_lut(A2_lut)
		end
	endcase
end
always@(*)begin
	mux_sel_Mul_Y = 0; // optimize?
	case(alu_st)
		DOUBLE:begin
			case(alu_counter_r)
				1:          mux_sel_Mul_Y = 0; // X_reg
				2:          mux_sel_Mul_Y = 1; // Y_reg
				0, 3, 5, 7: mux_sel_Mul_Y = 2; // Z_reg
				6, 8:       mux_sel_Mul_Y = 4; // T_reg
			endcase
		end
		ADDITION:begin
			case(alu_counter_r)
				5:       mux_sel_Mul_Y = 0; // X_reg
				2:       mux_sel_Mul_Y = 1; // Y_reg
				4:       mux_sel_Mul_Y = 2; // Z_reg
				1:       mux_sel_Mul_Y = 3; // X_lut(A2_lut)
				0, 6, 7: mux_sel_Mul_Y = 4; // T_reg
			endcase
		end
		PRE_CAL:begin
			case(alu_counter_r)
				0: mux_sel_Mul_Y = 3; // X_lut(A2_lut)
				2: mux_sel_Mul_Y = 5; // d
			endcase
		end
		DIVINV:begin
			mux_sel_Mul_Y = 3; // X_lut(A2_lut)
		end
		DIVMUL:begin
			case(alu_counter_r)
				0: mux_sel_Mul_Y = 0; // X_reg
				1: mux_sel_Mul_Y = 1; // Y_reg
			endcase
		end
	endcase
end

// -------------------------- Mux of Modular Adder input operands -------------------------- 
always@(*)begin
	case(mux_sel_ModularAdd_X)
	0: mux_out_ModularAdd_X = ModQ_out_FF;
	1: mux_out_ModularAdd_X = in_Z_reg;
	2: mux_out_ModularAdd_X = in_X_reg;
	3: mux_out_ModularAdd_X = in_T_reg;
	4: mux_out_ModularAdd_X = in_X_lut;
	default: mux_out_ModularAdd_X = 0; // optimize?
	endcase
end
always@(*)begin
	case(mux_sel_ModularAdd_Y)
	0: mux_out_ModularAdd_Y = ModQ_out_FF;
	1: mux_out_ModularAdd_Y = in_Z_reg;
	2: mux_out_ModularAdd_Y = in_Y_reg;
	3: mux_out_ModularAdd_Y = in_Y_lut;
	endcase
end
always@(*)begin
	mux_sel_ModularAdd_X = 0; // optimize?
	case(alu_st)
		DOUBLE:begin
			case(alu_counter_r)
				2:    mux_sel_ModularAdd_X = 0; // ModQ_out_FF
				1, 4: mux_sel_ModularAdd_X = 2; // X_reg
				5:    mux_sel_ModularAdd_X = 3; // T_reg
			endcase
		end
		ADDITION:begin
			case(alu_counter_r)
				2:    mux_sel_ModularAdd_X = 0; // ModQ_out_FF
				1:    mux_sel_ModularAdd_X = 1; // Z_reg
				0, 4: mux_sel_ModularAdd_X = 2; // X_reg
				3:    mux_sel_ModularAdd_X = 3; // T_reg
			endcase
		end
		PRE_CAL:begin
			mux_sel_ModularAdd_X = 4; // X_lut(A2_lut)
		end
	endcase
end
always@(*)begin
	mux_sel_ModularAdd_Y = 0; // optimize?
	case(alu_st)
		DOUBLE:begin
			case(alu_counter_r)
				2, 4: mux_sel_ModularAdd_Y = 0; // ModQ_out_FF
				1, 5: mux_sel_ModularAdd_Y = 2; // Y_reg
			endcase
		end
		ADDITION:begin
			case(alu_counter_r)
				2, 4: mux_sel_ModularAdd_Y = 0; // ModQ_out_FF
				1, 3: mux_sel_ModularAdd_Y = 1; // Z_reg
				0:    mux_sel_ModularAdd_Y = 2; // Y_reg
			endcase
		end
		PRE_CAL:begin
			mux_sel_ModularAdd_Y = 3; // Y_lut(B2_lut)
		end
	endcase
end

// -------------------------- Mux of Modular Substractor input operands -------------------------- 
always@(*)begin
	case(mux_sel_ModularSub_X)
	0: mux_out_ModularSub_X = ModQ_out_FF;
	1: mux_out_ModularSub_X = in_X_reg;
	2: mux_out_ModularSub_X = in_Y_reg;
	3: mux_out_ModularSub_X = in_Z_reg;
	4: mux_out_ModularSub_X = in_Y_lut;
	5: mux_out_ModularSub_X = `Q;
	default: mux_out_ModularSub_X = 0; // optimize?
	endcase
end
always@(*)begin
	case(mux_sel_ModularSub_Y)
	0: mux_out_ModularSub_Y = ModQ_out_FF;
	1: mux_out_ModularSub_Y = in_X_reg;
	2: mux_out_ModularSub_Y = in_T_reg;
	3: mux_out_ModularSub_Y = in_X_lut;
	endcase
end
always@(*)begin
	mux_sel_ModularSub_X = 0; // optimize?
	case(alu_st)
		DOUBLE:begin
			case(alu_counter_r)
				4: mux_sel_ModularSub_X = 1; // X_reg
				5: mux_sel_ModularSub_X = 3; // Z_reg
			endcase
		end
		ADDITION:begin
			case(alu_counter_r)
				4: mux_sel_ModularSub_X = 0; // ModQ_out_FF
				0: mux_sel_ModularSub_X = 2; // Y_reg
				3: mux_sel_ModularSub_X = 3; // Z_reg
			endcase
		end
		PRE_CAL:begin
			mux_sel_ModularSub_X = 4; // Y_lut(B2_lut)
		end
		DIVMUL: begin
			mux_sel_ModularSub_X = 5; // q
		end
	endcase
end
always@(*)begin
	mux_sel_ModularSub_Y = 0; // optimize?
	case(alu_st)
		DOUBLE:begin
			case(alu_counter_r)
				4, 5: mux_sel_ModularSub_Y = 0; // ModQ_out_FF
			endcase
		end
		ADDITION:begin
			case(alu_counter_r)
				0, 4: mux_sel_ModularSub_Y = 1; // X_reg
				3:    mux_sel_ModularSub_Y = 2; // T_reg
			endcase
		end
		PRE_CAL:begin
			mux_sel_ModularSub_Y = 3; // X_lut(A2_lut)
		end
		DIVMUL: begin
			mux_sel_ModularSub_Y = 0; // ModQ_out_FF
		end
	endcase
end



// -------------------------- Mux of ALU outputs -------------------------- 
always@(*)begin // X_reg or X_lut
	case(mux_sel_out_X)
		0: out_X = ModQ_out_wo_FF;
		1: out_X = ModularAdd_out;
		2: out_X = ModularSub_out;
		3: out_X = ModQ_out_FF;
		default: out_X = 0; // optimize?
	endcase
end
always@(*)begin // Y_reg or Y_lut
	case(mux_sel_out_Y)
		0: out_Y = ModQ_out_wo_FF;
		1: out_Y = ModularAdd_out;
		2: out_Y = ModularSub_out;
		3: out_Y = ModQ_out_FF;
		default: out_Y = 0; // optimize?
	endcase
end
always@(*)begin // Z_reg or Z_lut
	case(mux_sel_out_Z)
		0: out_Z = ModQ_out_wo_FF;
		1: out_Z = ModularAdd_out;
		default: out_Z = 0; // optimize?
	endcase
end
always@(*)begin // T_reg or T_lut
	case(mux_sel_out_T)
		0: out_T = ModQ_out_wo_FF;
		1: out_T = ModularAdd_out;
		2: out_T = ModularSub_out;
		default: out_T = 0; // optimize?
	endcase
end
always@(*)begin
	mux_sel_out_X = 0; // optimize?
	case(alu_st)
		DOUBLE:begin
			case(alu_counter_r)
				2, 9: mux_sel_out_X = 0; // ModQ_out_wo_FF
				5:	  mux_sel_out_X = 2; // ModularSub_out
			endcase
		end
		ADDITION:begin
			case(alu_counter_r)
				2, 7: mux_sel_out_X = 0; // ModQ_out_wo_FF
				4:    mux_sel_out_X = 1; // ModularAdd_out
				0:    mux_sel_out_X = 2; // ModularSub_out
			endcase
		end
		PRE_CAL:begin
			mux_sel_out_X = 2; // ModularSub_out
		end
		DIVINV:begin
			mux_sel_out_X = 0; // ModQ_out_wo_FF
		end
		DIVMUL:begin
			mux_sel_out_X = (ModQ_out_FF[0])? 2:3; // q - ModQ_out_FF or ModQ_out_FF
		end
	endcase
end
always@(*)begin
	mux_sel_out_Y = 0; // optimize?
	case(alu_st)
		DOUBLE:begin
			case(alu_counter_r)
				6: mux_sel_out_Y = 0; // ModQ_out_wo_FF
				4: mux_sel_out_Y = 2; // ModularSub_out
			endcase
		end
		ADDITION:begin
			case(alu_counter_r)
				6: mux_sel_out_Y = 0; // ModQ_out_wo_FF
				0: mux_sel_out_Y = 1; // ModularAdd_out
				3: mux_sel_out_Y = 2; // ModularSub_out
			endcase
		end
		PRE_CAL:begin
			mux_sel_out_Y = 1; // ModularAdd_out
		end
		DIVMUL:begin
			mux_sel_out_Y = (ModQ_out_FF[0])? 2:3; // q - ModQ_out_FF or ModQ_out_FF
		end
	endcase
end
always@(*)begin
	mux_sel_out_Z = 0; // optimize?
	case(alu_st)
		DOUBLE:begin
			case(alu_counter_r)
				7:    mux_sel_out_Z = 0; // ModQ_out_wo_FF
				1, 4: mux_sel_out_Z = 1; // ModularAdd_out
			endcase
		end
		ADDITION:begin
			case(alu_counter_r)
				5:    mux_sel_out_Z = 0; // ModQ_out_wo_FF
				1, 3: mux_sel_out_Z = 1; // ModularAdd_out
			endcase
		end
	endcase
end
always@(*)begin
	mux_sel_out_T = 0; // optimize?
	case(alu_st)
		DOUBLE:begin
			case(alu_counter_r)
				8:    mux_sel_out_T = 0; // ModQ_out_wo_FF
				2, 5: mux_sel_out_T = 1; // ModularAdd_out
			endcase
		end
		ADDITION:begin
			case(alu_counter_r)
				8: mux_sel_out_T = 0; // ModQ_out_wo_FF
				2: mux_sel_out_T = 1; // ModularAdd_out
				4: mux_sel_out_T = 2; // ModularSub_out
			endcase
		end
		PRE_CAL:begin
			mux_sel_out_T = 0; // ModQ_out_wo_FF
		end
	endcase
end


endmodule