`define Q 'b111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101101
`define D 'h52036cee2b6ffe738cc740797779e89800700a4d4141d8ab75eb4dca135978a3



module ed25519(
    input i_clk,
    input i_rst,
    input i_in_valid,
    output o_in_ready,
    input [63:0]i_in_data,
    output o_out_valid,
    input i_out_ready,
    output reg [63:0]o_out_data
); 


// local parameters
localparam RESET = 0, READ_INPUT = 1, PRE_CAL = 2, DOUBLE_AND_ADDITION = 3, RESET_R = 4, DIVINV = 5, DIVMUL = 6, OUTPUT_STAGE = 7;
// state
reg [2:0] ed25519_st, ed25519_nst;
// counter 
reg [7:0] ed25519_counter_r, ed25519_counter_w; // count 0 ~ 254
reg [1:0] which_input_output_r, which_input_output_w; // for input => 0: M, 1: xp, 2: yp. for output => 0: xg, 1: yg.
reg [1:0] input_output_idx_r, input_output_idx_w; // 0: MSB, 3:LSB
// ALU
reg alu_in_valid;
reg [1:0]alu_in_state; // 0: PRE-CAL, 1: DOUBLE, 2: DIV-INV, 3: DIV-MUL
reg alu_in_keep_flag;
reg alu_in_consecutive_flag;
wire alu_out_ready;


// interconnect of ALU & RegFile & LUTFile
wire [254:0] X_reg_wire_File2ALU, Y_reg_wire_File2ALU, Z_reg_wire_File2ALU, T_reg_wire_File2ALU;  // RegFile & LUTFile to ALU // directly connect
wire [254:0] X_lut_wire_File2ALU, Y_lut_wire_File2ALU, T_lut_wire_File2ALU;  // RegFile & LUTFile to ALU // directly connect
wire alu_out_X_reg_we, alu_out_Y_reg_we, alu_out_Z_reg_we, alu_out_T_reg_we;  // ALU to RegFile & LUTFile & mux  
wire alu_out_X_lut_we, alu_out_Y_lut_we, alu_out_T_lut_we;  // ALU to RegFile & LUTFile & mux 
wire [254:0] alu_out_X, alu_out_Y, alu_out_Z, alu_out_T;                      // ALU to RegFile & LUTFile & mux 
// mux between ALU & LUTFile
reg [254:0] mux_out_LUTFile_X_in, mux_out_LUTFile_Y_in;
reg mux_out_LUTFile_X_we, mux_out_LUTFile_Y_we;
reg [1:0]mux_sel_LUTFile_X_in; // READ_INPUT -> set lut, RESET_R -> reset r, OTHERS 
reg mux_sel_LUTFile_Y_in;      // READ_INPUT -> set lut, OTHERS 
reg mux_sel_LUTFile_X_we, mux_sel_LUTFile_Y_we;

// input 
reg [254:0]M_r, M_w;
reg [254:0]XP_w, YP_w;




// handshake flag
wire input_handshake = i_in_valid & o_in_ready;
wire output_handshake = o_out_valid & i_out_ready;


// -------------------------- state --------------------------
always@(*)begin
	case(ed25519_st)
		RESET:begin
			ed25519_nst = READ_INPUT;
		end
		READ_INPUT:begin
			if(input_handshake && which_input_output_r == 2 && input_output_idx_r == 3)ed25519_nst = PRE_CAL;
			else ed25519_nst = READ_INPUT;
		end
		PRE_CAL:begin
			if(alu_out_ready) ed25519_nst = DOUBLE_AND_ADDITION;
			else ed25519_nst = PRE_CAL;
		end
		DOUBLE_AND_ADDITION:begin
			if(ed25519_counter_r==254 && alu_out_ready)ed25519_nst = RESET_R;
			else ed25519_nst = DOUBLE_AND_ADDITION;
		end
		RESET_R:begin  // 	reset r = 1(A2_lut)
			ed25519_nst = DIVINV;
		end
		DIVINV:begin  // calculate the modular inversion
			if(ed25519_counter_r==254 && alu_out_ready)ed25519_nst = DIVMUL;
			else ed25519_nst = DIVINV;
		end
		DIVMUL:begin  // x = r*X -> keep x even, y = r*Y -> keep y even
			if(alu_out_ready)ed25519_nst = OUTPUT_STAGE;
			else ed25519_nst = DIVMUL;
		end
		OUTPUT_STAGE:begin
			ed25519_nst = OUTPUT_STAGE;
		end
	endcase
end
always@(posedge i_clk)begin
    if(i_rst)begin
        ed25519_st <= RESET;
    end
    else begin
		ed25519_st <= ed25519_nst;
    end
end

// -------------------------- counters --------------------------
// ed25519_counter_r: 0 ~ 254
always@(*)begin
	ed25519_counter_w = ed25519_counter_r;
	if((ed25519_st==PRE_CAL) || ed25519_st==RESET_R) // initial counter when entering DOUBLE_AND_ADDITION & DIVINV state
		ed25519_counter_w = 0;
	else if((ed25519_st==DOUBLE_AND_ADDITION || ed25519_st==DIVINV) && alu_out_ready)
		ed25519_counter_w = ed25519_counter_r + 1;
end
always@(posedge i_clk)begin
    if(i_rst)begin
        ed25519_counter_r <= 0;
    end
    else begin
		ed25519_counter_r <= ed25519_counter_w;
    end
end
// which_input_output_r: for input 0: M, 1: xp, 2: yp; for output 0: xg, 1: yg;
// input_output_idx_r: 0: MSB, 3:LSB
always@(*)begin
	which_input_output_w = which_input_output_r;
	input_output_idx_w = input_output_idx_r;
	if(ed25519_st==DIVMUL)begin // initial counter when next state = OUTPUT_STAGE & READ_INPUT
		which_input_output_w = 0;
		input_output_idx_w = 0;
	end
	else if(input_handshake || output_handshake)begin 
		if(input_output_idx_r == 3)begin
			which_input_output_w = which_input_output_r + 1;
			input_output_idx_w = 0;
		end
		else begin
			which_input_output_w = which_input_output_r;
			input_output_idx_w = input_output_idx_r + 1;
		end
	end
end
always@(posedge i_clk)begin
    if(i_rst)begin
        which_input_output_r <= 0;
		input_output_idx_r <= 0;
    end
    else begin
		which_input_output_r <= which_input_output_w;
		input_output_idx_r <= input_output_idx_w;
    end
end
// -------------------------- outputs --------------------------	
assign o_in_ready = (ed25519_st == READ_INPUT);
assign o_out_valid = (ed25519_st == OUTPUT_STAGE);
// which_input_output_r: for output 0: xg, 1: yg;
// input_output_idx_r: 0: MSB, 3:LSB
always@(*)begin
	o_out_data = 0; // optimize?
	if(which_input_output_r == 0)begin // xg
		case(input_output_idx_r)
			0: o_out_data = X_lut_wire_File2ALU[254:192];  // MSB
			1: o_out_data = X_lut_wire_File2ALU[191:128];
			2: o_out_data = X_lut_wire_File2ALU[127:64];
			3: o_out_data = X_lut_wire_File2ALU[63:0];     // LSB
		endcase
	end
	else if(which_input_output_r == 1)begin // yg
		case(input_output_idx_r)
			0: o_out_data = Y_lut_wire_File2ALU[254:192];  // MSB
			1: o_out_data = Y_lut_wire_File2ALU[191:128];
			2: o_out_data = Y_lut_wire_File2ALU[127:64];
			3: o_out_data = Y_lut_wire_File2ALU[63:0];     // LSB
		endcase
	end 
end


// -------------------------- inputs --------------------------
//which_input_output_r // for input => 0: M, 1: xp, 2: yp. for output => 0: xg, 1: yg.
//input_output_idx_r   // 0: MSB, 3:LSB
always@(*)begin
	XP_w = X_lut_wire_File2ALU;
	if(which_input_output_r == 1)begin // xp
		case(input_output_idx_r)
			0: XP_w[254:192] = i_in_data[62:0];  // MSB
			1: XP_w[191:128] = i_in_data;
			2: XP_w[127:64] = i_in_data;
			3: XP_w[63:0] = i_in_data;           // LSB
		endcase
	end
end

always@(*)begin
	YP_w = Y_lut_wire_File2ALU;
	if(which_input_output_r == 2)begin // yp
		case(input_output_idx_r)
			0: YP_w[254:192] = i_in_data[62:0];  // MSB
			1: YP_w[191:128] = i_in_data;
			2: YP_w[127:64] = i_in_data;
			3: YP_w[63:0] = i_in_data;           // LSB
		endcase
	end
end

always@(*)begin
	M_w = M_r;
	if(which_input_output_r==0 && ed25519_st==READ_INPUT && input_handshake)begin // M
		case(input_output_idx_r)
			0: M_w[254:192] = i_in_data[62:0];  // MSB
			1: M_w[191:128] = i_in_data;
			2: M_w[127:64] = i_in_data;
			3: M_w[63:0] = i_in_data;           // LSB
		endcase
	end
	else if(ed25519_st == DOUBLE_AND_ADDITION && alu_out_ready)begin
		M_w = M_r << 1;
	end
end
always@(posedge i_clk)begin
	M_r <= M_w;
end


//-------------------------- ALU, LUTFile, RegFile --------------------------
ALU ALU_u0(
	// inputs
    .clk(i_clk),
    .rst(i_rst),
	.in_valid(alu_in_valid),
	.in_state(alu_in_state), // 0: PRE-CAL, 1: DOUBLE, 2: DIV-INV, 3: DIV-MUL
	.in_keep_flag(alu_in_keep_flag),
	.in_consecutive_flag(alu_in_consecutive_flag), // if DOUBLE and ADD, DIV-MUL consecutive
	.in_X_reg(X_reg_wire_File2ALU),
	.in_Y_reg(Y_reg_wire_File2ALU),
	.in_Z_reg(Z_reg_wire_File2ALU),
	.in_T_reg(T_reg_wire_File2ALU),
	.in_X_lut(X_lut_wire_File2ALU), // A2_lut
	.in_Y_lut(Y_lut_wire_File2ALU), // B2_lut
	.in_T_lut(T_lut_wire_File2ALU), // Td_lut
	// outputs
	.out_ready(alu_out_ready), // finish calculation
	.out_X(alu_out_X),
	.out_Y(alu_out_Y),
	.out_Z(alu_out_Z),
	.out_T(alu_out_T),
	.out_X_reg_we(alu_out_X_reg_we),
	.out_Y_reg_we(alu_out_Y_reg_we),
	.out_Z_reg_we(alu_out_Z_reg_we),
	.out_T_reg_we(alu_out_T_reg_we),
	.out_X_lut_we(alu_out_X_lut_we),
	.out_Y_lut_we(alu_out_Y_lut_we),
	.out_T_lut_we(alu_out_T_lut_we)
);

RegFile RegFile_u0(
	// inputs
    .clk(i_clk),
    .rst(i_rst),
    .X_in_data(alu_out_X),   // directly connect from alu
    .Y_in_data(alu_out_Y),   // directly connect from alu
    .Z_in_data(alu_out_Z),   // directly connect from alu
    .T_in_data(alu_out_T),   // directly connect from alu
    .X_we(alu_out_X_reg_we), // directly connect from alu
    .Y_we(alu_out_Y_reg_we), // directly connect from alu
    .Z_we(alu_out_Z_reg_we), // directly connect from alu
    .T_we(alu_out_T_reg_we), // directly connect from alu
	// outputs
    .X_out_data(X_reg_wire_File2ALU),
    .Y_out_data(Y_reg_wire_File2ALU),
    .Z_out_data(Z_reg_wire_File2ALU),
    .T_out_data(T_reg_wire_File2ALU)
);

LUTFile LUTFile_u0(
	// inputs
    .clk(i_clk),
    .rst(i_rst),
    .X_in_data(mux_out_LUTFile_X_in),
    .Y_in_data(mux_out_LUTFile_Y_in),
    .T_in_data(alu_out_T),   // directly connect from alu
    .X_we(mux_out_LUTFile_X_we),
    .Y_we(mux_out_LUTFile_Y_we),
    .T_we(alu_out_T_lut_we), // directly connect from alu
	// outputs
    .X_out_data(X_lut_wire_File2ALU),
    .Y_out_data(Y_lut_wire_File2ALU),
    .T_out_data(T_lut_wire_File2ALU)
);
// -------------------------- Mux between ALU and LUTFile -------------------------- 
// mux of LUTFile.X_in_data
always@(*)begin
	case(mux_sel_LUTFile_X_in)
	0: mux_out_LUTFile_X_in = alu_out_X; // OTHERS: directly connect from alu
	1: mux_out_LUTFile_X_in = XP_w;      // READ_INPUT: set X_lut to XP
	2: mux_out_LUTFile_X_in = 255'b1;    // RESET_R: reset r(X_lut) to 1
	default: mux_out_LUTFile_X_in = 0;   // optimize?
	endcase
end
always@(*)begin
	if(ed25519_st == RESET_R) mux_sel_LUTFile_X_in = 2; // RESET_R: reset r(X_lut) to 1
	else if(ed25519_st == READ_INPUT) mux_sel_LUTFile_X_in = 1; // READ_INPUT: set X_lut to XP
	else mux_sel_LUTFile_X_in = 0;
end

// mux of LUTFile.Y_in_data
always@(*)begin
	case(mux_sel_LUTFile_Y_in)
	0: mux_out_LUTFile_Y_in = alu_out_Y; // OTHERS: directly connect from alu
	1: mux_out_LUTFile_Y_in = YP_w;      // READ_INPUT: set Y_lut to YP
	endcase
end
always@(*)begin
	if(ed25519_st == READ_INPUT) mux_sel_LUTFile_Y_in = 1; // READ_INPUT: set Y_lut to YP
	else mux_sel_LUTFile_Y_in = 0;
end

// mux of LUTFile.X_we
always@(*)begin
	case(mux_sel_LUTFile_X_we)
	0: mux_out_LUTFile_X_we = alu_out_X_lut_we; // OTHERS: directly connect from alu
	1: mux_out_LUTFile_X_we = 1'b1;             // FORCE WRITE ==> READ_INPUT: set X_lut to XP / RESET_R: reset r(X_lut) to 1 
	endcase
end
always@(*)begin
	if(ed25519_st == RESET_R || (ed25519_st == READ_INPUT && input_handshake)) mux_sel_LUTFile_X_we = 1; // FORCE WRITE
	else mux_sel_LUTFile_X_we = 0;
end

// mux of LUTFile.Y_we
always@(*)begin
	case(mux_sel_LUTFile_Y_we)
	0: mux_out_LUTFile_Y_we = alu_out_Y_lut_we; // OTHERS: directly connect from alu
	1: mux_out_LUTFile_Y_we = 1'b1;             // FORCE WRITE ==> READ_INPUT: set Y_lut to YP
	endcase
end
always@(*)begin
	if((ed25519_st == READ_INPUT && input_handshake)) mux_sel_LUTFile_Y_we = 1; // FORCE WRITE
	else mux_sel_LUTFile_Y_we = 0;
end

// -------------------------- ALU's in_valid & in_state & in_consecutive_flag & alu_in_keep_flag --------------------------
always@(*)begin // optimize?
	alu_in_valid = 0;
	alu_in_state = 0;  
	alu_in_consecutive_flag = 0;
	alu_in_keep_flag = 0;
	case(ed25519_st)
		PRE_CAL: begin
			alu_in_valid = 1;
			alu_in_state = 0; // PRE_CAL
		end
		DOUBLE_AND_ADDITION:begin
			alu_in_valid = 1;
			alu_in_state = 1; // DOUBLE
			alu_in_consecutive_flag = M_r[254]; // MSB OF M
			alu_in_keep_flag = (ed25519_counter_r != 254);
		end
		DIVINV:begin
			alu_in_valid = 1;
			alu_in_state = 2; // DIVINV
			alu_in_consecutive_flag = (ed25519_counter_r==250||ed25519_counter_r==252)? 0:1; // when q_minus_2[i] == 0
			alu_in_keep_flag = (ed25519_counter_r != 254);
		end
		DIVMUL:begin
			alu_in_valid = 1;
			alu_in_state = 3; // DIVMUL
		end
	endcase
end


				
endmodule