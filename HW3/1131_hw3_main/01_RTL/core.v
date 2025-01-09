module core (                       //Don't modify interface
	input         i_clk,
	input         i_rst_n,
	input         i_op_valid,
	input  [ 3:0] i_op_mode,
    output        o_op_ready, // ok
	input         i_in_valid,
	input  [ 7:0] i_in_data,
	output        o_in_ready, // ok
	output        o_out_valid,
	output [13:0] o_out_data
);

// ==============================================================================================================================
// Local Parameters
// ==============================================================================================================================
// can't be modified by param redefinition(defparam or #(.localparam(2)) -> verilog 2001)
localparam RESET = 0, READY_NEXT_OP = 1, WAIT_OP = 2, LOAD_IMAGE = 3, DISPLAY = 4, 
			CONV_32_16 = 5, CONV_32_16_OUT = 6, CONV_8 = 7, CONV_8_OUT = 8,
			MEDIAN = 9, MEDIAN_OUT = 10,
			SOBEL_CAL_Gx_Gy = 11, SOBEL_CAL_BOUND = 12, SOBEL_CMP_BOUND = 13, SOBEL_GET_ABS_G = 14, SOBEL_OUT = 15;

// for Depth_32_16_8
localparam DEPTH32 = 2'd0, DEPTH16 = 2'd1, DEPTH8 = 2'd2;


// ==============================================================================================================================
// Wires and Registers
// ==============================================================================================================================
integer i;
reg [3:0] st, nst;
// display region 
reg [2:0] origin_X, origin_Y; // only be used as iterator in LOAD_IMAGE
reg [1:0] Depth_32_16_8;      //0->32, 1->16, 2->8
// iterators
reg X_iter, Y_iter;
reg [4:0]Depth_iter;  // only be used as iterator in LOAD_IMAGE & DISPLAY
reg [1:0]Depth_iter_delay1, Depth_iter_delay2; // remember which sram_data_r_FF to use // for DISPLAY
// cnt & flag
reg [3:0]cnt;
reg flag; // used in CONV_8
// input flip flops
reg [3:0] i_op_mode_FF;
reg i_op_valid_FF;
reg [7:0] i_in_data_FF;
reg i_in_valid_FF;

// ------------------------------- CONV------------------------------- 
reg [11:0]conv_col_sum_16[63:0]; // columns sum of channel 0 ~ 15
reg [12:0]conv_col_sum_32[63:0]; // columns sum of channel 0 ~ 31

// ------------------------------- MEDIAN ------------------------------- 
// cache
reg [2:0]median_last0_X, median_last0_X_w, median_last0_Y, median_last0_Y_w;
reg [2:0]median_last1_X, median_last1_X_w, median_last1_Y, median_last1_Y_w;
reg [7:0]median_last0_result_c0[0:3];  reg [7:0]median_last0_result_c0_w[0:3];
reg [7:0]median_last0_result_c1[0:3];  reg [7:0]median_last0_result_c1_w[0:3];
reg [7:0]median_last0_result_c2[0:3];  reg [7:0]median_last0_result_c2_w[0:3];
reg [7:0]median_last0_result_c3[0:3];  reg [7:0]median_last0_result_c3_w[0:3];
reg median_last0_valid[0:3];           reg median_last0_valid_w[0:3];

reg [7:0]median_last1_result_c0[0:3];  reg [7:0]median_last1_result_c0_w[0:3];
reg [7:0]median_last1_result_c1[0:3];  reg [7:0]median_last1_result_c1_w[0:3];
reg [7:0]median_last1_result_c2[0:3];  reg [7:0]median_last1_result_c2_w[0:3];
reg [7:0]median_last1_result_c3[0:3];  reg [7:0]median_last1_result_c3_w[0:3];
reg median_last1_valid[0:3];           reg median_last1_valid_w[0:3];

// array to store 5 smallest values
reg [7:0]median_min5_c0[0:4]; reg [7:0]median_min5_c0_w[0:4]; 
reg [7:0]median_min5_c1[0:4]; reg [7:0]median_min5_c1_w[0:4];
reg [7:0]median_min5_c2[0:4]; reg [7:0]median_min5_c2_w[0:4];
reg [7:0]median_min5_c3[0:4]; reg [7:0]median_min5_c3_w[0:4];

// ------------------------------- SOBEL -------------------------------
// cache
reg [2:0]sobel_last_X, sobel_last_X_w, sobel_last_Y, sobel_last_Y_w;
reg [1:0]sobel_last_dir_c0[0:3];  reg [1:0]sobel_last_dir_c0_w[0:3];
reg [1:0]sobel_last_dir_c1[0:3];  reg [1:0]sobel_last_dir_c1_w[0:3];
reg [1:0]sobel_last_dir_c2[0:3];  reg [1:0]sobel_last_dir_c2_w[0:3];
reg [1:0]sobel_last_dir_c3[0:3];  reg [1:0]sobel_last_dir_c3_w[0:3];

reg [10:0]sobel_last_G_c0[0:3];   reg [10:0]sobel_last_G_c0_w[0:3];
reg [10:0]sobel_last_G_c1[0:3];   reg [10:0]sobel_last_G_c1_w[0:3];
reg [10:0]sobel_last_G_c2[0:3];   reg [10:0]sobel_last_G_c2_w[0:3];
reg [10:0]sobel_last_G_c3[0:3];   reg [10:0]sobel_last_G_c3_w[0:3];

reg sobel_last_valid[0:3];    reg sobel_last_valid_w[0:3];

// accumulator and flags and register
reg sobel_dir_channel_valid[0:3];
reg sobel_sign_Gx_Gy[0:3]; // sign of Gx and Gy from each channel: 0:同號, 1:異號 
reg [16:0]accum[0:3];
reg [10:0]sobel_abs_Gy[0:3];

// ------------------------------- 17 bits ADDER x 4 ------------------------------- 
reg [16:0] adder0_operand1, adder0_operand2;
reg [16:0] adder1_operand1, adder1_operand2;
reg [16:0] adder2_operand1, adder2_operand2;
reg [16:0] adder3_operand1, adder3_operand2;
wire [16:0]adder0_result;
wire [16:0]adder1_result;
wire [16:0]adder2_result;
wire [16:0]adder3_result;

// ------------------------------- array cmp x 4 ------------------------------- 
reg [7:0]cmp_c0_operand;
reg [7:0]cmp_c1_operand;
reg [7:0]cmp_c2_operand;
reg [7:0]cmp_c3_operand;

wire cmp_c0_result[0:4];
wire cmp_c1_result[0:4];
wire cmp_c2_result[0:4];
wire cmp_c3_result[0:4];

wire [2:0]cmp_c0_CLO; // calculate leading 1
wire [2:0]cmp_c1_CLO;
wire [2:0]cmp_c2_CLO;
wire [2:0]cmp_c3_CLO;

// ------------------------------- SRAM ------------------------------- 
wire sram_0_wen, sram_1_wen, sram_2_wen, sram_3_wen;                  // 0: write(only write in LOAD_IMAGE)
wire [8:0]sram_addr;                                                  // read, write address of sram
wire [7:0]sram_0_data_r, sram_1_data_r, sram_2_data_r, sram_3_data_r;
reg [7:0] sram_data_r_FF[0:3];   // flip flop of read data

//-------------------------------  intermidiate signals------------------------------- 
// DISPLAY
wire [4:0]origin_Depth = (Depth_32_16_8==DEPTH32)? 5'd31:(Depth_32_16_8==DEPTH16)? 5'd15:(Depth_32_16_8==DEPTH8)? 5'd7:0; // convert back to 0~31

// for iteration: DISPLAY, CONV_8, MEDIAN, SOBEL
wire [2:0] origin_plus_iter_X = origin_X + X_iter;  
wire [2:0] origin_plus_iter_Y = origin_Y + Y_iter; // origin_Y=0~6, origin_X=0~6==> NO OVERFLOW
wire Is_origin_plus_iter_X_left = (origin_plus_iter_X == 0);
wire Is_origin_plus_iter_X_right = (origin_plus_iter_X == 7);
wire Is_origin_plus_iter_Y_top = (origin_plus_iter_Y == 0);
wire Is_origin_plus_iter_Y_down = (origin_plus_iter_Y == 7);
// kernel_iter_X, kernel_iter_Y: conv8, MEDIAN
reg [2:0]kernel_iter_X, kernel_iter_Y;

// CONV_32_16
wire [2:0] conv_r0_X = origin_X;    wire [2:0] conv_r0_Y = origin_Y;
wire [2:0] conv_r1_X = origin_X+1;  wire [2:0] conv_r1_Y = origin_Y;
wire [2:0] conv_r2_X = origin_X;    wire [2:0] conv_r2_Y = origin_Y+1;
wire [2:0] conv_r3_X = origin_X+1;  wire [2:0] conv_r3_Y = origin_Y+1;
wire [2:0]conv_r0_X_plus1 = conv_r0_X + 1; wire [2:0]conv_r0_X_minus1 = conv_r0_X - 1; wire [2:0]conv_r0_Y_plus1 = conv_r0_Y + 1; wire [2:0]conv_r0_Y_minus1 = conv_r0_Y - 1;
wire [2:0]conv_r1_X_plus1 = conv_r1_X + 1; wire [2:0]conv_r1_X_minus1 = conv_r1_X - 1; wire [2:0]conv_r1_Y_plus1 = conv_r1_Y + 1; wire [2:0]conv_r1_Y_minus1 = conv_r1_Y - 1;
wire [2:0]conv_r2_X_plus1 = conv_r2_X + 1; wire [2:0]conv_r2_X_minus1 = conv_r2_X - 1; wire [2:0]conv_r2_Y_plus1 = conv_r2_Y + 1; wire [2:0]conv_r2_Y_minus1 = conv_r2_Y - 1;
wire [2:0]conv_r3_X_plus1 = conv_r3_X + 1; wire [2:0]conv_r3_X_minus1 = conv_r3_X - 1; wire [2:0]conv_r3_Y_plus1 = conv_r3_Y + 1; wire [2:0]conv_r3_Y_minus1 = conv_r3_Y - 1;
wire conv_Is_r0r1_top = (origin_Y==0);
wire conv_Is_r2r3_down = (origin_Y==6);
wire conv_Is_r0r2_left = (origin_X==0);
wire conv_Is_r1r3_right = (origin_X==6);


// MEDIAN
wire median_last0_valid_hit = median_last0_valid[0] && median_last0_valid[1] && median_last0_valid[2] && median_last0_valid[3];
wire median_last1_valid_hit = median_last1_valid[0] && median_last1_valid[1] && median_last1_valid[2] && median_last1_valid[3];

// SOBEL
wire sobel_last_valid_hit = sobel_last_valid[0] && sobel_last_valid[1] && sobel_last_valid[2] && sobel_last_valid[3];
reg [16:0]sram_data_r_FF_mul_neg_1[0:3];
reg [16:0]sram_data_r_FF_mul_neg_2[0:3];
reg [16:0]sram_data_r_FF_mul_pos_1[0:3];
reg [16:0]sram_data_r_FF_mul_pos_2[0:3];
always@(*)begin
	for(i=0;i<4;i=i+1)begin
		sram_data_r_FF_mul_neg_1[i] = ~({9'b0, sram_data_r_FF[i]}) + 1;
		sram_data_r_FF_mul_neg_2[i] = {sram_data_r_FF_mul_neg_1[i], 1'b0};
		sram_data_r_FF_mul_pos_1[i] = {9'b0, sram_data_r_FF[i]};
		sram_data_r_FF_mul_pos_2[i] = {sram_data_r_FF_mul_pos_1[i], 1'b0};
	end
end
reg [10:0]sobel_abs_accum[0:3];//11 bit signed to 11 bit unsigned
always@(*)begin
	for(i = 0; i < 4; i=i+1)begin
		sobel_abs_accum[i] = (accum[i][10:0] ^ {11{accum[i][10]}}) + accum[i][10]; 
	end
end
wire sobel_OR_frac0 = |adder0_result[6:0];
wire sobel_OR_frac1 = |adder1_result[6:0];
wire sobel_OR_frac2 = |adder2_result[6:0];
wire sobel_OR_frac3 = |adder3_result[6:0];



//OUTPUTS
reg [13:0]o_out_data_wire;
reg o_out_valid_wire;
reg [13:0]o_out_data_FF;
reg o_out_valid_FF;



// ==============================================================================================================================
// Combination Circuits
// ==============================================================================================================================
//  ------------------------------- OUTPUTS ------------------------------- 
assign o_op_ready = (st == READY_NEXT_OP);
assign o_in_ready = 1'b1;
assign o_out_valid = o_out_valid_FF;
assign o_out_data = o_out_data_FF;
reg [1:0]out_sobel_last_dir;  //v2
reg [10:0]out_sobel_last_G[0:3]; //v2
always@(*)begin
	o_out_data_wire = 0;
	o_out_valid_wire = 0;
	case(st)
	DISPLAY: begin
		o_out_data_wire = sram_data_r_FF[Depth_iter_delay2];
		o_out_valid_wire = (cnt != 0 && cnt != 1)? 1:0;
	end
	CONV_32_16_OUT:begin
		o_out_data_wire = accum[{Y_iter, X_iter}][16:4] + accum[{Y_iter, X_iter}][3]; // round to nearest
		o_out_valid_wire = 1;
	end
	CONV_8_OUT:begin
		o_out_data_wire = accum[1][16:4] + accum[1][3]; // round to nearest
		o_out_valid_wire = 1;
	end
	MEDIAN_OUT:begin
		case(cnt[3:2])
		0: o_out_data_wire = median_last0_result_c0[cnt[1:0]];
		1: o_out_data_wire = median_last0_result_c1[cnt[1:0]];
		2: o_out_data_wire = median_last0_result_c2[cnt[1:0]];
		3: o_out_data_wire = median_last0_result_c3[cnt[1:0]];
		default: o_out_data_wire = 0;
		endcase
		o_out_valid_wire = 1;
	end
	SOBEL_OUT:begin // NMS
		case(cnt[3:2])
		0: begin
			out_sobel_last_dir = sobel_last_dir_c0[cnt[1:0]];
			for(i=0; i<4; i=i+1)begin
				out_sobel_last_G[i] = sobel_last_G_c0[i];
			end
		end
		1: begin
			out_sobel_last_dir = sobel_last_dir_c1[cnt[1:0]];
			for(i=0; i<4; i=i+1)begin
				out_sobel_last_G[i] = sobel_last_G_c1[i];
			end
		end
		2: begin
			out_sobel_last_dir = sobel_last_dir_c2[cnt[1:0]];
			for(i=0; i<4; i=i+1)begin
				out_sobel_last_G[i] = sobel_last_G_c2[i];
			end
		end
		3: begin
			out_sobel_last_dir = sobel_last_dir_c3[cnt[1:0]];
			for(i=0; i<4; i=i+1)begin
				out_sobel_last_G[i] = sobel_last_G_c3[i];
			end
		end
		endcase
		
		case(out_sobel_last_dir) //direction
			2'b00: o_out_data_wire = (out_sobel_last_G[cnt[1:0]] < out_sobel_last_G[{cnt[1], (~cnt[0])}])? 0:out_sobel_last_G[cnt[1:0]]; // dir0: degree0
			2'b01: begin
				if(cnt[1] == cnt[0]) o_out_data_wire = (out_sobel_last_G[cnt[1:0]] < out_sobel_last_G[{(~cnt[1]), (~cnt[0])}])? 0:out_sobel_last_G[cnt[1:0]]; // dir1: degree45
				else o_out_data_wire = out_sobel_last_G[cnt[1:0]]; // dir1: degree45
			end
			2'b10: o_out_data_wire = (out_sobel_last_G[cnt[1:0]] < out_sobel_last_G[{(~cnt[1]), cnt[0]}])? 0:out_sobel_last_G[cnt[1:0]]; // dir2: degree90
			2'b11: begin
				if(cnt[1] != cnt[0]) o_out_data_wire = (out_sobel_last_G[cnt[1:0]] < out_sobel_last_G[{(~cnt[1]), (~cnt[0])}])? 0:out_sobel_last_G[cnt[1:0]]; // dir3: degree135
				else o_out_data_wire = out_sobel_last_G[cnt[1:0]]; // dir3: degree135
			end
		endcase
		o_out_valid_wire = 1;
	end
	default: begin
		o_out_data_wire = 0;
		o_out_valid_wire = 0;
	end
	endcase
end


// ------------------------------- Next State Logic ------------------------------- 
always@(*)begin
	nst = RESET; // given default value
	case(st)
		RESET: nst = READY_NEXT_OP;
		READY_NEXT_OP: nst = WAIT_OP;
		WAIT_OP:begin
			nst = WAIT_OP;
			if(i_op_valid_FF)begin
				case(i_op_mode_FF)
				4'b0000: nst = LOAD_IMAGE;
				4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110: nst = READY_NEXT_OP;
				4'b0111: nst = DISPLAY;
				4'b1000: nst = (Depth_32_16_8==DEPTH8)? CONV_8:CONV_32_16;
				4'b1001: nst = MEDIAN;
				4'b1010: nst = SOBEL_CAL_Gx_Gy;
				endcase
			end
		end
		LOAD_IMAGE: nst = (i_in_valid_FF && origin_X==7 && origin_Y==7 && Depth_iter==31)? READY_NEXT_OP:LOAD_IMAGE;
		DISPLAY: nst = (cnt==4)? RESET:DISPLAY;
		CONV_32_16: nst = (cnt==8)? CONV_32_16_OUT:CONV_32_16;
		CONV_32_16_OUT: nst = (X_iter==1 && Y_iter==1)?RESET:CONV_32_16_OUT;
		CONV_8: nst = (cnt == 10 && flag == 1)? CONV_8_OUT:CONV_8;
		CONV_8_OUT: nst = (X_iter==1 && Y_iter==1)? RESET:CONV_8;
		MEDIAN: begin
			if((median_last0_valid_hit && median_last0_X==origin_X && median_last0_Y==origin_Y) || 
			(median_last1_valid_hit && median_last1_X==origin_X && median_last1_Y==origin_Y))// last0 hit or last1 hit
				nst = MEDIAN_OUT; 
			else 
				nst = (X_iter==1 && Y_iter==1 && (cnt==10 || median_last0_valid[3]))? MEDIAN_OUT:MEDIAN;
		end
		MEDIAN_OUT: nst = (cnt==15)? RESET:MEDIAN_OUT;
		SOBEL_CAL_Gx_Gy: begin
			if(sobel_last_valid_hit && sobel_last_X==origin_X && sobel_last_Y==origin_Y) // last hit
				nst = SOBEL_OUT;
			else begin
				if(cnt == 15) nst = SOBEL_CAL_BOUND;
				else if(sobel_last_valid[{Y_iter, X_iter}]) nst = (X_iter==1 && Y_iter==1)? SOBEL_OUT:SOBEL_CAL_Gx_Gy;
				else nst = SOBEL_CAL_Gx_Gy;
			end
		end
		SOBEL_CAL_BOUND: nst =(cnt==2 || cnt==3)? SOBEL_CMP_BOUND:SOBEL_CAL_BOUND;
		SOBEL_CMP_BOUND: nst =(cnt==3)? SOBEL_CAL_BOUND:SOBEL_GET_ABS_G;
		SOBEL_GET_ABS_G: nst =(X_iter==1 && Y_iter==1)? SOBEL_OUT:SOBEL_CAL_Gx_Gy;
		SOBEL_OUT: nst = (cnt==15)? RESET:SOBEL_OUT; 
		
		default: nst = RESET;
	
	endcase
end

//  ------------------------------- SRAM ------------------------------- 
//(only write in LOAD_IMAGE)
assign sram_0_wen = (st == LOAD_IMAGE && i_in_valid_FF && Depth_iter[1:0] == 2'd0)? 0:1; //i_in_valid_FF is valid and correct depth
assign sram_1_wen = (st == LOAD_IMAGE && i_in_valid_FF && Depth_iter[1:0] == 2'd1)? 0:1; //i_in_valid_FF is valid and correct depth
assign sram_2_wen = (st == LOAD_IMAGE && i_in_valid_FF && Depth_iter[1:0] == 2'd2)? 0:1; //i_in_valid_FF is valid and correct depth
assign sram_3_wen = (st == LOAD_IMAGE && i_in_valid_FF && Depth_iter[1:0] == 2'd3)? 0:1; //i_in_valid_FF is valid and correct depth

// 8*8*32 fmap由4個sram穿插存//unfinish read part
always@(*)begin
	kernel_iter_X = 0;
	kernel_iter_Y = 0;
	if(st == SOBEL_CAL_Gx_Gy)begin
		case(cnt)
		0, 7:begin kernel_iter_X = origin_plus_iter_X - 1; kernel_iter_Y = origin_plus_iter_Y - 1;end
		1:   begin kernel_iter_X = origin_plus_iter_X    ; kernel_iter_Y = origin_plus_iter_Y - 1;end
		2, 8:begin kernel_iter_X = origin_plus_iter_X + 1; kernel_iter_Y = origin_plus_iter_Y - 1;end
		9:   begin kernel_iter_X = origin_plus_iter_X - 1; kernel_iter_Y = origin_plus_iter_Y    ;end
		10:  begin kernel_iter_X = origin_plus_iter_X + 1; kernel_iter_Y = origin_plus_iter_Y    ;end
		3,11:begin kernel_iter_X = origin_plus_iter_X - 1; kernel_iter_Y = origin_plus_iter_Y + 1;end
		4:   begin kernel_iter_X = origin_plus_iter_X    ; kernel_iter_Y = origin_plus_iter_Y + 1;end
		5,12:begin kernel_iter_X = origin_plus_iter_X + 1; kernel_iter_Y = origin_plus_iter_Y + 1;end
		endcase
	end	
	else begin // CONV_8, MEDIAN
		case(cnt)
		0:begin kernel_iter_X = origin_plus_iter_X - 1; kernel_iter_Y = origin_plus_iter_Y - 1;end
		1:begin kernel_iter_X = origin_plus_iter_X    ; kernel_iter_Y = origin_plus_iter_Y - 1;end
		2:begin kernel_iter_X = origin_plus_iter_X + 1; kernel_iter_Y = origin_plus_iter_Y - 1;end
		3:begin kernel_iter_X = origin_plus_iter_X - 1; kernel_iter_Y = origin_plus_iter_Y    ;end
		4:begin kernel_iter_X = origin_plus_iter_X    ; kernel_iter_Y = origin_plus_iter_Y    ;end
		5:begin kernel_iter_X = origin_plus_iter_X + 1; kernel_iter_Y = origin_plus_iter_Y    ;end
		6:begin kernel_iter_X = origin_plus_iter_X - 1; kernel_iter_Y = origin_plus_iter_Y + 1;end
		7:begin kernel_iter_X = origin_plus_iter_X    ; kernel_iter_Y = origin_plus_iter_Y + 1;end
		8:begin kernel_iter_X = origin_plus_iter_X + 1; kernel_iter_Y = origin_plus_iter_Y + 1;end
		endcase
	end
end
assign sram_addr = (st == LOAD_IMAGE)? {Depth_iter[4:2], origin_Y, origin_X}: 
					 (st == DISPLAY)?{Depth_iter[4:2], origin_plus_iter_Y, origin_plus_iter_X}: 
					 (st == CONV_8)? {flag, kernel_iter_Y, kernel_iter_X}:
					 (st == MEDIAN)? {kernel_iter_Y, kernel_iter_X}:
					 (st == SOBEL_CAL_Gx_Gy)? {kernel_iter_Y, kernel_iter_X}:0;

//  ------------------------------- MEDIAN_UPDATA_LAST ------------------------------- 
always@(*)begin
	// default values: keep
	median_last0_X_w = median_last0_X; median_last1_X_w = median_last1_X; 
	median_last0_Y_w = median_last0_Y; median_last1_Y_w = median_last1_Y;
	for(i = 0; i < 4; i=i+1)begin
		median_last0_result_c0_w[i] = median_last0_result_c0[i];    median_last1_result_c0_w[i] = median_last1_result_c0[i];
		median_last0_result_c1_w[i] = median_last0_result_c1[i];    median_last1_result_c1_w[i] = median_last1_result_c1[i];
		median_last0_result_c2_w[i] = median_last0_result_c2[i];    median_last1_result_c2_w[i] = median_last1_result_c2[i];
		median_last0_result_c3_w[i] = median_last0_result_c3[i];    median_last1_result_c3_w[i] = median_last1_result_c3[i];
		median_last0_valid_w[i]     = median_last0_valid[i];        median_last1_valid_w[i]     = median_last1_valid[i];
	end
	
	if(median_last0_valid_hit && median_last0_X==origin_X && median_last0_Y==origin_Y)begin // last0 hit
		// keep
	end
	else if(median_last1_valid_hit && median_last1_X==origin_X && median_last1_Y==origin_Y)begin // last1 hit
		// swap last0 and last1
		median_last0_X_w = median_last1_X; median_last1_X_w = median_last0_X; 
		median_last0_Y_w = median_last1_Y; median_last1_Y_w = median_last0_Y;
		for(i = 0; i < 4; i=i+1)begin
			median_last0_result_c0_w[i] = median_last1_result_c0[i];    median_last1_result_c0_w[i] = median_last0_result_c0[i];
			median_last0_result_c1_w[i] = median_last1_result_c1[i];    median_last1_result_c1_w[i] = median_last0_result_c1[i];
			median_last0_result_c2_w[i] = median_last1_result_c2[i];    median_last1_result_c2_w[i] = median_last0_result_c2[i];
			median_last0_result_c3_w[i] = median_last1_result_c3[i];    median_last1_result_c3_w[i] = median_last0_result_c3[i];
			median_last0_valid_w[i]     = median_last1_valid[i];        median_last1_valid_w[i]     = median_last0_valid[i];
		end
	end
	else begin // no hit
		// replace last1 values by last0
		median_last1_X_w = median_last0_X; 
		median_last1_Y_w = median_last0_Y;
		for(i = 0; i < 4; i=i+1)begin
			median_last1_result_c0_w[i] = median_last0_result_c0[i];
			median_last1_result_c1_w[i] = median_last0_result_c1[i];
			median_last1_result_c2_w[i] = median_last0_result_c2[i];
			median_last1_result_c3_w[i] = median_last0_result_c3[i];
			median_last1_valid_w[i]     = median_last0_valid[i];
		end
		
		if(!median_last0_valid_hit)begin
			// keep
		end
		else begin
			if(origin_X==median_last0_X && origin_Y-1==median_last0_Y)begin // shift up
				{median_last0_valid_w[0], median_last0_valid_w[1], median_last0_valid_w[2], median_last0_valid_w[3]}=4'b1100;
				median_last0_result_c0_w[0] = median_last0_result_c0[2];
				median_last0_result_c0_w[1] = median_last0_result_c0[3];
				median_last0_result_c1_w[0] = median_last0_result_c1[2];
				median_last0_result_c1_w[1] = median_last0_result_c1[3];
				median_last0_result_c2_w[0] = median_last0_result_c2[2];
				median_last0_result_c2_w[1] = median_last0_result_c2[3];
				median_last0_result_c3_w[0] = median_last0_result_c3[2];
				median_last0_result_c3_w[1] = median_last0_result_c3[3];	
			end
			else if(origin_X==median_last0_X && origin_Y+1==median_last0_Y)begin // shift down
				{median_last0_valid_w[0], median_last0_valid_w[1], median_last0_valid_w[2], median_last0_valid_w[3]}=4'b0011;
				median_last0_result_c0_w[2] = median_last0_result_c0[0];
				median_last0_result_c0_w[3] = median_last0_result_c0[1];
				median_last0_result_c1_w[2] = median_last0_result_c1[0];
				median_last0_result_c1_w[3] = median_last0_result_c1[1];
				median_last0_result_c2_w[2] = median_last0_result_c2[0];
				median_last0_result_c2_w[3] = median_last0_result_c2[1];
				median_last0_result_c3_w[2] = median_last0_result_c3[0];
				median_last0_result_c3_w[3] = median_last0_result_c3[1];	
			end
			else if(origin_X-1==median_last0_X && origin_Y==median_last0_Y)begin // shift left
				{median_last0_valid_w[0], median_last0_valid_w[1], median_last0_valid_w[2], median_last0_valid_w[3]}=4'b1010;
				median_last0_result_c0_w[0] = median_last0_result_c0[1];
				median_last0_result_c0_w[2] = median_last0_result_c0[3];
				median_last0_result_c1_w[0] = median_last0_result_c1[1];
				median_last0_result_c1_w[2] = median_last0_result_c1[3];
				median_last0_result_c2_w[0] = median_last0_result_c2[1];
				median_last0_result_c2_w[2] = median_last0_result_c2[3];
				median_last0_result_c3_w[0] = median_last0_result_c3[1];
				median_last0_result_c3_w[2] = median_last0_result_c3[3];	
			end
			else if(origin_X+1==median_last0_X && origin_Y==median_last0_Y)begin // shift right
				{median_last0_valid_w[0], median_last0_valid_w[1], median_last0_valid_w[2], median_last0_valid_w[3]}=4'b0101;
				median_last0_result_c0_w[1] = median_last0_result_c0[0];
				median_last0_result_c0_w[3] = median_last0_result_c0[2];
				median_last0_result_c1_w[1] = median_last0_result_c1[0];
				median_last0_result_c1_w[3] = median_last0_result_c1[2];
				median_last0_result_c2_w[1] = median_last0_result_c2[0];
				median_last0_result_c2_w[3] = median_last0_result_c2[2];
				median_last0_result_c3_w[1] = median_last0_result_c3[0];
				median_last0_result_c3_w[3] = median_last0_result_c3[2];	
			end
			else begin
				{median_last0_valid_w[0], median_last0_valid_w[1], median_last0_valid_w[2], median_last0_valid_w[3]}=4'b0000;
			end
		end	
	end
end

//  ------------------------------- SOBEL_UPDATA_LAST ------------------------------- 
always@(*)begin
	// default values: keep
	sobel_last_X_w = sobel_last_X;
	sobel_last_Y_w = sobel_last_Y;
	for(i = 0; i < 4; i=i+1)begin
		sobel_last_dir_c0_w[i] = sobel_last_dir_c0[i];  sobel_last_G_c0_w[i] = sobel_last_G_c0[i];
		sobel_last_dir_c1_w[i] = sobel_last_dir_c1[i];  sobel_last_G_c1_w[i] = sobel_last_G_c1[i];
		sobel_last_dir_c2_w[i] = sobel_last_dir_c2[i];  sobel_last_G_c2_w[i] = sobel_last_G_c2[i];
		sobel_last_dir_c3_w[i] = sobel_last_dir_c3[i];  sobel_last_G_c3_w[i] = sobel_last_G_c3[i];
		sobel_last_valid_w[i]  = sobel_last_valid[i];    
	end
	
	if(sobel_last_valid_hit && sobel_last_X==origin_X && sobel_last_Y==origin_Y)begin // last hit
		// keep
	end
	else begin // no hit
		if(!sobel_last_valid_hit)begin
			// keep
		end
		else begin
			if(origin_X==sobel_last_X && origin_Y-1==sobel_last_Y)begin // shift up
				{sobel_last_valid_w[0], sobel_last_valid_w[1], sobel_last_valid_w[2], sobel_last_valid_w[3]}=4'b1100;
				sobel_last_dir_c0_w[0] = sobel_last_dir_c0[2];  sobel_last_G_c0_w[0] = sobel_last_G_c0[2];
				sobel_last_dir_c0_w[1] = sobel_last_dir_c0[3];  sobel_last_G_c0_w[1] = sobel_last_G_c0[3];
				sobel_last_dir_c1_w[0] = sobel_last_dir_c1[2];  sobel_last_G_c1_w[0] = sobel_last_G_c1[2];
				sobel_last_dir_c1_w[1] = sobel_last_dir_c1[3];  sobel_last_G_c1_w[1] = sobel_last_G_c1[3];
				sobel_last_dir_c2_w[0] = sobel_last_dir_c2[2];  sobel_last_G_c2_w[0] = sobel_last_G_c2[2];
				sobel_last_dir_c2_w[1] = sobel_last_dir_c2[3];  sobel_last_G_c2_w[1] = sobel_last_G_c2[3];
				sobel_last_dir_c3_w[0] = sobel_last_dir_c3[2];  sobel_last_G_c3_w[0] = sobel_last_G_c3[2];
				sobel_last_dir_c3_w[1] = sobel_last_dir_c3[3];	sobel_last_G_c3_w[1] = sobel_last_G_c3[3];
			end
			else if(origin_X==sobel_last_X && origin_Y+1==sobel_last_Y)begin // shift down
				{sobel_last_valid_w[0], sobel_last_valid_w[1], sobel_last_valid_w[2], sobel_last_valid_w[3]}=4'b0011;
				sobel_last_dir_c0_w[2] = sobel_last_dir_c0[0];  sobel_last_G_c0_w[2] = sobel_last_G_c0[0];
				sobel_last_dir_c0_w[3] = sobel_last_dir_c0[1];  sobel_last_G_c0_w[3] = sobel_last_G_c0[1];
				sobel_last_dir_c1_w[2] = sobel_last_dir_c1[0];  sobel_last_G_c1_w[2] = sobel_last_G_c1[0];
				sobel_last_dir_c1_w[3] = sobel_last_dir_c1[1];  sobel_last_G_c1_w[3] = sobel_last_G_c1[1];
				sobel_last_dir_c2_w[2] = sobel_last_dir_c2[0];  sobel_last_G_c2_w[2] = sobel_last_G_c2[0];
				sobel_last_dir_c2_w[3] = sobel_last_dir_c2[1];  sobel_last_G_c2_w[3] = sobel_last_G_c2[1];
				sobel_last_dir_c3_w[2] = sobel_last_dir_c3[0];  sobel_last_G_c3_w[2] = sobel_last_G_c3[0];
				sobel_last_dir_c3_w[3] = sobel_last_dir_c3[1];	sobel_last_G_c3_w[3] = sobel_last_G_c3[1];
			end
			else if(origin_X-1==sobel_last_X && origin_Y==sobel_last_Y)begin // shift left
				{sobel_last_valid_w[0], sobel_last_valid_w[1], sobel_last_valid_w[2], sobel_last_valid_w[3]}=4'b1010;
				sobel_last_dir_c0_w[0] = sobel_last_dir_c0[1];  sobel_last_G_c0_w[0] = sobel_last_G_c0[1];
				sobel_last_dir_c0_w[2] = sobel_last_dir_c0[3];  sobel_last_G_c0_w[2] = sobel_last_G_c0[3];
				sobel_last_dir_c1_w[0] = sobel_last_dir_c1[1];  sobel_last_G_c1_w[0] = sobel_last_G_c1[1];
				sobel_last_dir_c1_w[2] = sobel_last_dir_c1[3];  sobel_last_G_c1_w[2] = sobel_last_G_c1[3];
				sobel_last_dir_c2_w[0] = sobel_last_dir_c2[1];  sobel_last_G_c2_w[0] = sobel_last_G_c2[1];
				sobel_last_dir_c2_w[2] = sobel_last_dir_c2[3];  sobel_last_G_c2_w[2] = sobel_last_G_c2[3];
				sobel_last_dir_c3_w[0] = sobel_last_dir_c3[1];  sobel_last_G_c3_w[0] = sobel_last_G_c3[1];
				sobel_last_dir_c3_w[2] = sobel_last_dir_c3[3];	sobel_last_G_c3_w[2] = sobel_last_G_c3[3];
			end
			else if(origin_X+1==sobel_last_X && origin_Y==sobel_last_Y)begin // shift right
				{sobel_last_valid_w[0], sobel_last_valid_w[1], sobel_last_valid_w[2], sobel_last_valid_w[3]}=4'b0101;
				sobel_last_dir_c0_w[1] = sobel_last_dir_c0[0];  sobel_last_G_c0_w[1] = sobel_last_G_c0[0];
				sobel_last_dir_c0_w[3] = sobel_last_dir_c0[2];  sobel_last_G_c0_w[3] = sobel_last_G_c0[2];
				sobel_last_dir_c1_w[1] = sobel_last_dir_c1[0];  sobel_last_G_c1_w[1] = sobel_last_G_c1[0];
				sobel_last_dir_c1_w[3] = sobel_last_dir_c1[2];  sobel_last_G_c1_w[3] = sobel_last_G_c1[2];
				sobel_last_dir_c2_w[1] = sobel_last_dir_c2[0];  sobel_last_G_c2_w[1] = sobel_last_G_c2[0];
				sobel_last_dir_c2_w[3] = sobel_last_dir_c2[2];  sobel_last_G_c2_w[3] = sobel_last_G_c2[2];
				sobel_last_dir_c3_w[1] = sobel_last_dir_c3[0];  sobel_last_G_c3_w[1] = sobel_last_G_c3[0];
				sobel_last_dir_c3_w[3] = sobel_last_dir_c3[2];	sobel_last_G_c3_w[3] = sobel_last_G_c3[2];
			end
			else begin
				{sobel_last_valid_w[0], sobel_last_valid_w[1], sobel_last_valid_w[2], sobel_last_valid_w[3]}=4'b0000;
			end
		end	
	end
end


//  ------------------------------- MEDIAN ------------------------------- 
// insert new operand into array with sorted order
// array to store 5 samllest values
always@(*)begin
	// defult values: keep
	for(i = 0; i < 5; i=i+1)begin
		median_min5_c0_w[i] = median_min5_c0[i];    
		median_min5_c1_w[i] = median_min5_c1[i]; 
		median_min5_c2_w[i] = median_min5_c2[i]; 
		median_min5_c3_w[i] = median_min5_c3[i]; 
	end
	case(cmp_c0_CLO)
	4: begin median_min5_c0_w[4] = cmp_c0_operand;end
	3: begin median_min5_c0_w[3] = cmp_c0_operand; median_min5_c0_w[4] = median_min5_c0[3];end
	2: begin median_min5_c0_w[2] = cmp_c0_operand; median_min5_c0_w[4] = median_min5_c0[3]; median_min5_c0_w[3] = median_min5_c0[2];end
	1: begin median_min5_c0_w[1] = cmp_c0_operand; median_min5_c0_w[4] = median_min5_c0[3]; median_min5_c0_w[3] = median_min5_c0[2]; median_min5_c0_w[2] = median_min5_c0[1];end
	0: begin median_min5_c0_w[0] = cmp_c0_operand; median_min5_c0_w[4] = median_min5_c0[3]; median_min5_c0_w[3] = median_min5_c0[2]; median_min5_c0_w[2] = median_min5_c0[1]; median_min5_c0_w[1] = median_min5_c0[0];end
	endcase
	case(cmp_c1_CLO)
	4: begin median_min5_c1_w[4] = cmp_c1_operand;end
	3: begin median_min5_c1_w[3] = cmp_c1_operand; median_min5_c1_w[4] = median_min5_c1[3];end
	2: begin median_min5_c1_w[2] = cmp_c1_operand; median_min5_c1_w[4] = median_min5_c1[3]; median_min5_c1_w[3] = median_min5_c1[2];end
	1: begin median_min5_c1_w[1] = cmp_c1_operand; median_min5_c1_w[4] = median_min5_c1[3]; median_min5_c1_w[3] = median_min5_c1[2]; median_min5_c1_w[2] = median_min5_c1[1];end
	0: begin median_min5_c1_w[0] = cmp_c1_operand; median_min5_c1_w[4] = median_min5_c1[3]; median_min5_c1_w[3] = median_min5_c1[2]; median_min5_c1_w[2] = median_min5_c1[1]; median_min5_c1_w[1] = median_min5_c1[0];end
	endcase
	case(cmp_c2_CLO)
	4: begin median_min5_c2_w[4] = cmp_c2_operand;end
	3: begin median_min5_c2_w[3] = cmp_c2_operand; median_min5_c2_w[4] = median_min5_c2[3];end
	2: begin median_min5_c2_w[2] = cmp_c2_operand; median_min5_c2_w[4] = median_min5_c2[3]; median_min5_c2_w[3] = median_min5_c2[2];end
	1: begin median_min5_c2_w[1] = cmp_c2_operand; median_min5_c2_w[4] = median_min5_c2[3]; median_min5_c2_w[3] = median_min5_c2[2]; median_min5_c2_w[2] = median_min5_c2[1];end
	0: begin median_min5_c2_w[0] = cmp_c2_operand; median_min5_c2_w[4] = median_min5_c2[3]; median_min5_c2_w[3] = median_min5_c2[2]; median_min5_c2_w[2] = median_min5_c2[1]; median_min5_c2_w[1] = median_min5_c2[0];end
	endcase
	case(cmp_c3_CLO)
	4: begin median_min5_c3_w[4] = cmp_c3_operand;end
	3: begin median_min5_c3_w[3] = cmp_c3_operand; median_min5_c3_w[4] = median_min5_c3[3];end
	2: begin median_min5_c3_w[2] = cmp_c3_operand; median_min5_c3_w[4] = median_min5_c3[3]; median_min5_c3_w[3] = median_min5_c3[2];end
	1: begin median_min5_c3_w[1] = cmp_c3_operand; median_min5_c3_w[4] = median_min5_c3[3]; median_min5_c3_w[3] = median_min5_c3[2]; median_min5_c3_w[2] = median_min5_c3[1];end
	0: begin median_min5_c3_w[0] = cmp_c3_operand; median_min5_c3_w[4] = median_min5_c3[3]; median_min5_c3_w[3] = median_min5_c3[2]; median_min5_c3_w[2] = median_min5_c3[1]; median_min5_c3_w[1] = median_min5_c3[0];end
	endcase
end



//  ------------------------------- 17 bits ADDER x 4 ------------------------------- 
// CONV_32_16
reg [16:0] adder0_operand1_temp;
reg [16:0] adder1_operand1_temp;
reg [16:0] adder2_operand1_temp;
reg [16:0] adder3_operand1_temp;
// Zero pad and divide
always@(*)begin
	adder0_operand1 = 0; adder0_operand2 = 0;
	adder1_operand1 = 0; adder1_operand2 = 0;
	adder2_operand1 = 0; adder2_operand2 = 0;
	adder3_operand1 = 0; adder3_operand2 = 0;
	case(st)
	CONV_32_16:begin
		case(cnt)
		0: begin // top and left of 3*3 kernel
			// choose column sum
			adder0_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r0_Y_minus1, conv_r0_X_minus1}]:conv_col_sum_16[{conv_r0_Y_minus1, conv_r0_X_minus1}];
			adder1_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r1_Y_minus1, conv_r1_X_minus1}]:conv_col_sum_16[{conv_r1_Y_minus1, conv_r1_X_minus1}];
			adder2_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r2_Y_minus1, conv_r2_X_minus1}]:conv_col_sum_16[{conv_r2_Y_minus1, conv_r2_X_minus1}];
			adder3_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r3_Y_minus1, conv_r3_X_minus1}]:conv_col_sum_16[{conv_r3_Y_minus1, conv_r3_X_minus1}];
			// zero pad and divide by 16
			adder0_operand1 = (conv_Is_r0r1_top||conv_Is_r0r2_left)?   0:adder0_operand1_temp;
			adder1_operand1 = (conv_Is_r0r1_top)?  0:adder1_operand1_temp;
			adder2_operand1 = (conv_Is_r0r2_left)?  0:adder2_operand1_temp;
			adder3_operand1 = adder3_operand1_temp;
		end
		1: begin // top of 3*3 kernel
			// choose column sum
			adder0_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r0_Y_minus1, conv_r0_X}]:conv_col_sum_16[{conv_r0_Y_minus1, conv_r0_X}];
			adder1_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r1_Y_minus1, conv_r1_X}]:conv_col_sum_16[{conv_r1_Y_minus1, conv_r1_X}];
			adder2_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r2_Y_minus1, conv_r2_X}]:conv_col_sum_16[{conv_r2_Y_minus1, conv_r2_X}];
			adder3_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r3_Y_minus1, conv_r3_X}]:conv_col_sum_16[{conv_r3_Y_minus1, conv_r3_X}];
			// zero pad and divide by 8
			adder0_operand1 = (conv_Is_r0r1_top)?  0:{adder0_operand1_temp,1'b0};
			adder1_operand1 = (conv_Is_r0r1_top)?  0:{adder1_operand1_temp,1'b0};
			adder2_operand1 = {adder2_operand1_temp,1'b0};
			adder3_operand1 = {adder3_operand1_temp,1'b0};
		end
		2: begin // top and right of 3*3 kernel
			// choose column sum
			adder0_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r0_Y_minus1, conv_r0_X_plus1}]:conv_col_sum_16[{conv_r0_Y_minus1, conv_r0_X_plus1}];
			adder1_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r1_Y_minus1, conv_r1_X_plus1}]:conv_col_sum_16[{conv_r1_Y_minus1, conv_r1_X_plus1}];
			adder2_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r2_Y_minus1, conv_r2_X_plus1}]:conv_col_sum_16[{conv_r2_Y_minus1, conv_r2_X_plus1}];
			adder3_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r3_Y_minus1, conv_r3_X_plus1}]:conv_col_sum_16[{conv_r3_Y_minus1, conv_r3_X_plus1}];
			// zero pad and divide by 16
			adder0_operand1 = (conv_Is_r0r1_top)?   0:adder0_operand1_temp;
			adder1_operand1 = (conv_Is_r0r1_top||conv_Is_r1r3_right)?  0:adder1_operand1_temp;
			adder2_operand1 = adder2_operand1_temp;
			adder3_operand1 = (conv_Is_r1r3_right)? 0:adder3_operand1_temp;
		end
		3: begin // left of 3*3 kernel
			// choose column sum
			adder0_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r0_Y, conv_r0_X_minus1}]:conv_col_sum_16[{conv_r0_Y, conv_r0_X_minus1}];
			adder1_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r1_Y, conv_r1_X_minus1}]:conv_col_sum_16[{conv_r1_Y, conv_r1_X_minus1}];
			adder2_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r2_Y, conv_r2_X_minus1}]:conv_col_sum_16[{conv_r2_Y, conv_r2_X_minus1}];
			adder3_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r3_Y, conv_r3_X_minus1}]:conv_col_sum_16[{conv_r3_Y, conv_r3_X_minus1}];
			// zero pad and divide by 8
			adder0_operand1 = (conv_Is_r0r2_left)?   0:{adder0_operand1_temp,1'b0};
			adder1_operand1 = {adder1_operand1_temp,1'b0};
			adder2_operand1 = (conv_Is_r0r2_left)?  0:{adder2_operand1_temp,1'b0};
			adder3_operand1 = {adder3_operand1_temp,1'b0};
		end
		4: begin // middle of 3*3 kernel
			// choose column sum
			adder0_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r0_Y, conv_r0_X}]:conv_col_sum_16[{conv_r0_Y, conv_r0_X}];
			adder1_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r1_Y, conv_r1_X}]:conv_col_sum_16[{conv_r1_Y, conv_r1_X}];
			adder2_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r2_Y, conv_r2_X}]:conv_col_sum_16[{conv_r2_Y, conv_r2_X}];
			adder3_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r3_Y, conv_r3_X}]:conv_col_sum_16[{conv_r3_Y, conv_r3_X}];
			// zero pad and divide by 4
			adder0_operand1 = {adder0_operand1_temp,2'b0};
			adder1_operand1 = {adder1_operand1_temp,2'b0};
			adder2_operand1 = {adder2_operand1_temp,2'b0};
			adder3_operand1 = {adder3_operand1_temp,2'b0};
		end
		5: begin // right of 3*3 kernel
			// choose column sum
			adder0_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r0_Y, conv_r0_X_plus1}]:conv_col_sum_16[{conv_r0_Y, conv_r0_X_plus1}];
			adder1_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r1_Y, conv_r1_X_plus1}]:conv_col_sum_16[{conv_r1_Y, conv_r1_X_plus1}];
			adder2_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r2_Y, conv_r2_X_plus1}]:conv_col_sum_16[{conv_r2_Y, conv_r2_X_plus1}];
			adder3_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r3_Y, conv_r3_X_plus1}]:conv_col_sum_16[{conv_r3_Y, conv_r3_X_plus1}];
			// zero pad and divide by 8
			adder0_operand1 = {adder0_operand1_temp,1'b0};
			adder1_operand1 = (conv_Is_r1r3_right)?  0:{adder1_operand1_temp,1'b0};
			adder2_operand1 = {adder2_operand1_temp,1'b0};
			adder3_operand1 = (conv_Is_r1r3_right)? 0:{adder3_operand1_temp,1'b0};
		end
		6: begin // down and left of 3*3 kernel
			// choose column sum
			adder0_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r0_Y_plus1, conv_r0_X_minus1}]:conv_col_sum_16[{conv_r0_Y_plus1, conv_r0_X_minus1}];
			adder1_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r1_Y_plus1, conv_r1_X_minus1}]:conv_col_sum_16[{conv_r1_Y_plus1, conv_r1_X_minus1}];
			adder2_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r2_Y_plus1, conv_r2_X_minus1}]:conv_col_sum_16[{conv_r2_Y_plus1, conv_r2_X_minus1}];
			adder3_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r3_Y_plus1, conv_r3_X_minus1}]:conv_col_sum_16[{conv_r3_Y_plus1, conv_r3_X_minus1}];
			// zero pad and divide by 16
			adder0_operand1 = (conv_Is_r0r2_left)?   0:adder0_operand1_temp;
			adder1_operand1 = adder1_operand1_temp;
			adder2_operand1 = (conv_Is_r2r3_down||conv_Is_r0r2_left)?  0:adder2_operand1_temp;
			adder3_operand1 = (conv_Is_r2r3_down)? 0:adder3_operand1_temp;
		end
		7: begin // down of 3*3 kernel
			// choose column sum
			adder0_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r0_Y_plus1, conv_r0_X}]:conv_col_sum_16[{conv_r0_Y_plus1, conv_r0_X}];
			adder1_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r1_Y_plus1, conv_r1_X}]:conv_col_sum_16[{conv_r1_Y_plus1, conv_r1_X}];
			adder2_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r2_Y_plus1, conv_r2_X}]:conv_col_sum_16[{conv_r2_Y_plus1, conv_r2_X}];
			adder3_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r3_Y_plus1, conv_r3_X}]:conv_col_sum_16[{conv_r3_Y_plus1, conv_r3_X}];
			// zero pad and divide by 8
			adder0_operand1 = {adder0_operand1_temp,1'b0};
			adder1_operand1 = {adder1_operand1_temp,1'b0};
			adder2_operand1 = (conv_Is_r2r3_down)? 0:{adder2_operand1_temp,1'b0};
			adder3_operand1 = (conv_Is_r2r3_down)? 0:{adder3_operand1_temp,1'b0};
		end
		8: begin // right and down of 3*3 kernel
			// choose column sum
			adder0_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r0_Y_plus1, conv_r0_X_plus1}]:conv_col_sum_16[{conv_r0_Y_plus1, conv_r0_X_plus1}];
			adder1_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r1_Y_plus1, conv_r1_X_plus1}]:conv_col_sum_16[{conv_r1_Y_plus1, conv_r1_X_plus1}];
			adder2_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r2_Y_plus1, conv_r2_X_plus1}]:conv_col_sum_16[{conv_r2_Y_plus1, conv_r2_X_plus1}];
			adder3_operand1_temp = (Depth_32_16_8==DEPTH32)? conv_col_sum_32[{conv_r3_Y_plus1, conv_r3_X_plus1}]:conv_col_sum_16[{conv_r3_Y_plus1, conv_r3_X_plus1}];
			// zero pad and divide by 16
			adder0_operand1 = adder0_operand1_temp;
			adder1_operand1 = (conv_Is_r1r3_right)?  0:adder1_operand1_temp;
			adder2_operand1 = (conv_Is_r2r3_down)?  0:adder2_operand1_temp;
			adder3_operand1 = (conv_Is_r2r3_down||conv_Is_r1r3_right)? 0:adder3_operand1_temp;
		end
		default: begin
			adder0_operand1 = 0;
		    adder1_operand1 = 0;
		    adder2_operand1 = 0;
		    adder3_operand1 = 0;
		end
		endcase
		
		adder0_operand2 = accum[0];
		adder1_operand2 = accum[1];
		adder2_operand2 = accum[2];
	    adder3_operand2 = accum[3];
	end
	CONV_8:begin
		case(cnt)
		1: begin // top and left of 3*3 kernel
			// zero pad and divide by 16
			adder0_operand1 = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[0];
			adder1_operand1 = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[1];
			adder2_operand1 = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[2];
			adder3_operand1 = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[3];
		end
		2: begin // top of 3*3 kernel
			// zero pad and divide by 8
			adder0_operand1 = (Is_origin_plus_iter_Y_top)? 0:{sram_data_r_FF[0],1'b0};
			adder1_operand1 = (Is_origin_plus_iter_Y_top)? 0:{sram_data_r_FF[1],1'b0};
			adder2_operand1 = (Is_origin_plus_iter_Y_top)? 0:{sram_data_r_FF[2],1'b0};
			adder3_operand1 = (Is_origin_plus_iter_Y_top)? 0:{sram_data_r_FF[3],1'b0};
		end
		3: begin // top and right of 3*3 kernel
			// zero pad and divide by 16
			adder0_operand1 = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[0];
			adder1_operand1 = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[1];
			adder2_operand1 = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[2];
			adder3_operand1 = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[3];
		end
		4: begin // left of 3*3 kernel
			// zero pad and divide by 8
			adder0_operand1 = (Is_origin_plus_iter_X_left)? 0:{sram_data_r_FF[0],1'b0};
			adder1_operand1 = (Is_origin_plus_iter_X_left)? 0:{sram_data_r_FF[1],1'b0};
			adder2_operand1 = (Is_origin_plus_iter_X_left)? 0:{sram_data_r_FF[2],1'b0};
			adder3_operand1 = (Is_origin_plus_iter_X_left)? 0:{sram_data_r_FF[3],1'b0};
		end
		5: begin // middle of 3*3 kernel
			// zero pad and divide by 4
			adder0_operand1 = {sram_data_r_FF[0],2'b0};
			adder1_operand1 = {sram_data_r_FF[1],2'b0};
			adder2_operand1 = {sram_data_r_FF[2],2'b0};
			adder3_operand1 = {sram_data_r_FF[3],2'b0};
		end
		6: begin // right of 3*3 kernel
			// zero pad and divide by 8
			adder0_operand1 = (Is_origin_plus_iter_X_right)? 0:{sram_data_r_FF[0],1'b0};
			adder1_operand1 = (Is_origin_plus_iter_X_right)? 0:{sram_data_r_FF[1],1'b0};
			adder2_operand1 = (Is_origin_plus_iter_X_right)? 0:{sram_data_r_FF[2],1'b0};
			adder3_operand1 = (Is_origin_plus_iter_X_right)? 0:{sram_data_r_FF[3],1'b0};
		end
		7: begin // down and left of 3*3 kernel
			// zero pad and divide by 16
			adder0_operand1 = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[0];
			adder1_operand1 = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[1];
			adder2_operand1 = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[2];
			adder3_operand1 = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[3];
		end
		8: begin // down of 3*3 kernel
			// zero pad and divide by 8
			adder0_operand1 = (Is_origin_plus_iter_Y_down)? 0:{sram_data_r_FF[0],1'b0};
			adder1_operand1 = (Is_origin_plus_iter_Y_down)? 0:{sram_data_r_FF[1],1'b0};
			adder2_operand1 = (Is_origin_plus_iter_Y_down)? 0:{sram_data_r_FF[2],1'b0};
			adder3_operand1 = (Is_origin_plus_iter_Y_down)? 0:{sram_data_r_FF[3],1'b0};
		end
		9: begin // right and down of 3*3 kernel
			// zero pad and divide by 16
			adder0_operand1 = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[0];
			adder1_operand1 = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[1];
			adder2_operand1 = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[2];
			adder3_operand1 = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[3];
		end
		10:begin
			adder0_operand1 = accum[1];
			adder1_operand1 = accum[2];
			adder2_operand1 = accum[3];
		end
		
		endcase
		adder0_operand2 = accum[0];
		adder1_operand2 = (cnt==10)? accum[0]:accum[1];
		adder2_operand2 = accum[2];
	    adder3_operand2 = accum[3];
	end
	SOBEL_CAL_Gx_Gy:begin
		case(cnt)
		2, 9: begin // top and left of 3*3 kernel
			// zero pad and multiplier X=-1, Y=-1
			adder0_operand1 = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_left)? 0: sram_data_r_FF_mul_neg_1[0];
			adder1_operand1 = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_left)? 0: sram_data_r_FF_mul_neg_1[1];
			adder2_operand1 = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_left)? 0: sram_data_r_FF_mul_neg_1[2];
			adder3_operand1 = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_left)? 0: sram_data_r_FF_mul_neg_1[3];
		end
		3: begin // top of 3*3 kernel
			// zero pad and multiplier Y=-2
			adder0_operand1 = (Is_origin_plus_iter_Y_top)? 0:sram_data_r_FF_mul_neg_2[0];
			adder1_operand1 = (Is_origin_plus_iter_Y_top)? 0:sram_data_r_FF_mul_neg_2[1];
			adder2_operand1 = (Is_origin_plus_iter_Y_top)? 0:sram_data_r_FF_mul_neg_2[2];
			adder3_operand1 = (Is_origin_plus_iter_Y_top)? 0:sram_data_r_FF_mul_neg_2[3];
		end
		4, 10: begin // top and right of 3*3 kernel
			// zero pad and multiplier X=1, Y=-1
			adder0_operand1 = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_right)? 0:(cnt==4)? sram_data_r_FF_mul_neg_1[0]:sram_data_r_FF_mul_pos_1[0];
			adder1_operand1 = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_right)? 0:(cnt==4)? sram_data_r_FF_mul_neg_1[1]:sram_data_r_FF_mul_pos_1[1];
			adder2_operand1 = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_right)? 0:(cnt==4)? sram_data_r_FF_mul_neg_1[2]:sram_data_r_FF_mul_pos_1[2];
			adder3_operand1 = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_right)? 0:(cnt==4)? sram_data_r_FF_mul_neg_1[3]:sram_data_r_FF_mul_pos_1[3];
		end
		11: begin // left of 3*3 kernel
			// zero pad and multiplier X=-2
			adder0_operand1 = (Is_origin_plus_iter_X_left)? 0:sram_data_r_FF_mul_neg_2[0];
			adder1_operand1 = (Is_origin_plus_iter_X_left)? 0:sram_data_r_FF_mul_neg_2[1];
			adder2_operand1 = (Is_origin_plus_iter_X_left)? 0:sram_data_r_FF_mul_neg_2[2];
			adder3_operand1 = (Is_origin_plus_iter_X_left)? 0:sram_data_r_FF_mul_neg_2[3];
		end
		12: begin // right of 3*3 kernel
			// zero pad and multiplier X=2
			adder0_operand1 = (Is_origin_plus_iter_X_right)? 0:sram_data_r_FF_mul_pos_2[0];
			adder1_operand1 = (Is_origin_plus_iter_X_right)? 0:sram_data_r_FF_mul_pos_2[1];
			adder2_operand1 = (Is_origin_plus_iter_X_right)? 0:sram_data_r_FF_mul_pos_2[2];
			adder3_operand1 = (Is_origin_plus_iter_X_right)? 0:sram_data_r_FF_mul_pos_2[3];
		end
		5, 13: begin // down and left of 3*3 kernel
			// zero pad and multiplier X=-1, Y=1
			adder0_operand1 = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_left)? 0:(cnt==5)? sram_data_r_FF_mul_pos_1[0]:sram_data_r_FF_mul_neg_1[0];
			adder1_operand1 = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_left)? 0:(cnt==5)? sram_data_r_FF_mul_pos_1[1]:sram_data_r_FF_mul_neg_1[1];
			adder2_operand1 = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_left)? 0:(cnt==5)? sram_data_r_FF_mul_pos_1[2]:sram_data_r_FF_mul_neg_1[2];
			adder3_operand1 = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_left)? 0:(cnt==5)? sram_data_r_FF_mul_pos_1[3]:sram_data_r_FF_mul_neg_1[3];
		end
		6: begin // down of 3*3 kernel
			// zero pad and multiplier Y=2
			adder0_operand1 = (Is_origin_plus_iter_Y_down)? 0:sram_data_r_FF_mul_pos_2[0];
			adder1_operand1 = (Is_origin_plus_iter_Y_down)? 0:sram_data_r_FF_mul_pos_2[1];
			adder2_operand1 = (Is_origin_plus_iter_Y_down)? 0:sram_data_r_FF_mul_pos_2[2];
			adder3_operand1 = (Is_origin_plus_iter_Y_down)? 0:sram_data_r_FF_mul_pos_2[3];
		end
		7, 14: begin // right and down of 3*3 kernel
			// zero pad and multiplier X=1, Y=1
			adder0_operand1 = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF_mul_pos_1[0];
			adder1_operand1 = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF_mul_pos_1[1];
			adder2_operand1 = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF_mul_pos_1[2];
			adder3_operand1 = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF_mul_pos_1[3];
		end
		endcase
		adder0_operand2 = accum[0];
		adder1_operand2 = accum[1];
		adder2_operand2 = accum[2];
	    adder3_operand2 = accum[3];
	end
	SOBEL_CAL_BOUND:begin
		case(cnt)
		0: begin // add |Gx|*2^-3
			adder0_operand1 = {sobel_last_G_c0[{Y_iter, X_iter}], 4'b0};   
			adder1_operand1 = {sobel_last_G_c1[{Y_iter, X_iter}], 4'b0};   
			adder2_operand1 = {sobel_last_G_c2[{Y_iter, X_iter}], 4'b0};   
			adder3_operand1 = {sobel_last_G_c3[{Y_iter, X_iter}], 4'b0};   
		end
		1: begin // add |Gx|*2^-5
			adder0_operand1 = {sobel_last_G_c0[{Y_iter, X_iter}], 2'b0};   
			adder1_operand1 = {sobel_last_G_c1[{Y_iter, X_iter}], 2'b0};   
			adder2_operand1 = {sobel_last_G_c2[{Y_iter, X_iter}], 2'b0};   
			adder3_operand1 = {sobel_last_G_c3[{Y_iter, X_iter}], 2'b0};   
		end
		2: begin // add |Gx|*2^-7
			adder0_operand1 = {sobel_last_G_c0[{Y_iter, X_iter}]};   
			adder1_operand1 = {sobel_last_G_c1[{Y_iter, X_iter}]};   
			adder2_operand1 = {sobel_last_G_c2[{Y_iter, X_iter}]};   
			adder3_operand1 = {sobel_last_G_c3[{Y_iter, X_iter}]};   
		end
		3:begin // add |Gx|*2 (12.1)
			adder0_operand1 = {sobel_last_G_c0[{Y_iter, X_iter}], 2'b0};   
			adder1_operand1 = {sobel_last_G_c1[{Y_iter, X_iter}], 2'b0};   
			adder2_operand1 = {sobel_last_G_c2[{Y_iter, X_iter}], 2'b0};   
			adder3_operand1 = {sobel_last_G_c3[{Y_iter, X_iter}], 2'b0};   
		end

		
		endcase
		adder0_operand2 = accum[0];
		adder1_operand2 = accum[1];
		adder2_operand2 = accum[2];
	    adder3_operand2 = accum[3];
	end
	SOBEL_GET_ABS_G:begin
		adder0_operand1 = sobel_last_G_c0[{Y_iter, X_iter}][10:0];   
		adder1_operand1 = sobel_last_G_c1[{Y_iter, X_iter}][10:0];   
		adder2_operand1 = sobel_last_G_c2[{Y_iter, X_iter}][10:0];   
		adder3_operand1 = sobel_last_G_c3[{Y_iter, X_iter}][10:0]; 
		adder0_operand2 = sobel_abs_Gy[0][10:0];   
		adder1_operand2 = sobel_abs_Gy[1][10:0];   
		adder2_operand2 = sobel_abs_Gy[2][10:0];   
		adder3_operand2 = sobel_abs_Gy[3][10:0]; 
	end
	default:begin
		adder0_operand1 = 0;
		adder1_operand1 = 0;
		adder2_operand1 = 0;
		adder3_operand1 = 0;
		adder0_operand2 = 0;
		adder1_operand2 = 0;
		adder2_operand2 = 0;
		adder3_operand2 = 0;
	end
	endcase
end
assign adder0_result = adder0_operand1 + adder0_operand2;
assign adder1_result = adder1_operand1 + adder1_operand2;
assign adder2_result = adder2_operand1 + adder2_operand2;
assign adder3_result = adder3_operand1 + adder3_operand2;


//  ------------------------------- array CMP x 4 ------------------------------- 
// Zero pad
always@(*)begin
	cmp_c0_operand = 0;
	cmp_c1_operand = 0;
	cmp_c2_operand = 0;
	cmp_c3_operand = 0;
	case(cnt)
	2: begin // top and left of 3*3 kernel
		cmp_c0_operand = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[0];
		cmp_c1_operand = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[1];
		cmp_c2_operand = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[2];
		cmp_c3_operand = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[3];
	end
	3: begin // top of 3*3 kernel
		cmp_c0_operand = (Is_origin_plus_iter_Y_top)? 0:sram_data_r_FF[0];
		cmp_c1_operand = (Is_origin_plus_iter_Y_top)? 0:sram_data_r_FF[1];
		cmp_c2_operand = (Is_origin_plus_iter_Y_top)? 0:sram_data_r_FF[2];
		cmp_c3_operand = (Is_origin_plus_iter_Y_top)? 0:sram_data_r_FF[3];
	end
	4: begin // top and right of 3*3 kernel
		cmp_c0_operand = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[0];
		cmp_c1_operand = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[1];
		cmp_c2_operand = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[2];
		cmp_c3_operand = (Is_origin_plus_iter_Y_top || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[3];
	end
	5: begin // left of 3*3 kernel
		cmp_c0_operand = (Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[0];
		cmp_c1_operand = (Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[1];
		cmp_c2_operand = (Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[2];
		cmp_c3_operand = (Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[3];
	end
	6: begin // middle of 3*3 kernel
		cmp_c0_operand = sram_data_r_FF[0];
		cmp_c1_operand = sram_data_r_FF[1];
		cmp_c2_operand = sram_data_r_FF[2];
		cmp_c3_operand = sram_data_r_FF[3];
	end
	7: begin // right of 3*3 kernel
		cmp_c0_operand = (Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[0];
		cmp_c1_operand = (Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[1];
		cmp_c2_operand = (Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[2];
		cmp_c3_operand = (Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[3];
	end
	8: begin // down and left of 3*3 kernel
		cmp_c0_operand = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[0];
		cmp_c1_operand = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[1];
		cmp_c2_operand = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[2];
		cmp_c3_operand = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_left)? 0:sram_data_r_FF[3];
	end
	9: begin // down of 3*3 kernel
		cmp_c0_operand = (Is_origin_plus_iter_Y_down)? 0:sram_data_r_FF[0];
		cmp_c1_operand = (Is_origin_plus_iter_Y_down)? 0:sram_data_r_FF[1];
		cmp_c2_operand = (Is_origin_plus_iter_Y_down)? 0:sram_data_r_FF[2];
		cmp_c3_operand = (Is_origin_plus_iter_Y_down)? 0:sram_data_r_FF[3];
	end
	10: begin // right and down of 3*3 kernel
		cmp_c0_operand = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[0];
		cmp_c1_operand = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[1];
		cmp_c2_operand = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[2];
		cmp_c3_operand = (Is_origin_plus_iter_Y_down || Is_origin_plus_iter_X_right)? 0:sram_data_r_FF[3];
	end
	endcase
end

assign cmp_c0_result[0] = (median_min5_c0[0] < cmp_c0_operand); assign cmp_c1_result[0] = (median_min5_c1[0] < cmp_c1_operand);
assign cmp_c0_result[1] = (median_min5_c0[1] < cmp_c0_operand); assign cmp_c1_result[1] = (median_min5_c1[1] < cmp_c1_operand);
assign cmp_c0_result[2] = (median_min5_c0[2] < cmp_c0_operand); assign cmp_c1_result[2] = (median_min5_c1[2] < cmp_c1_operand);
assign cmp_c0_result[3] = (median_min5_c0[3] < cmp_c0_operand); assign cmp_c1_result[3] = (median_min5_c1[3] < cmp_c1_operand);
assign cmp_c0_result[4] = (median_min5_c0[4] < cmp_c0_operand); assign cmp_c1_result[4] = (median_min5_c1[4] < cmp_c1_operand);

assign cmp_c2_result[0] = (median_min5_c2[0] < cmp_c2_operand); assign cmp_c3_result[0] = (median_min5_c3[0] < cmp_c3_operand);
assign cmp_c2_result[1] = (median_min5_c2[1] < cmp_c2_operand); assign cmp_c3_result[1] = (median_min5_c3[1] < cmp_c3_operand);
assign cmp_c2_result[2] = (median_min5_c2[2] < cmp_c2_operand); assign cmp_c3_result[2] = (median_min5_c3[2] < cmp_c3_operand);
assign cmp_c2_result[3] = (median_min5_c2[3] < cmp_c2_operand); assign cmp_c3_result[3] = (median_min5_c3[3] < cmp_c3_operand);
assign cmp_c2_result[4] = (median_min5_c2[4] < cmp_c2_operand); assign cmp_c3_result[4] = (median_min5_c3[4] < cmp_c3_operand);


// calculate leading one
assign cmp_c0_CLO = (cmp_c0_result[4])? 5:(cmp_c0_result[3])? 4:(cmp_c0_result[2])? 3:(cmp_c0_result[1])? 2:(cmp_c0_result[0])? 1:0;
assign cmp_c1_CLO = (cmp_c1_result[4])? 5:(cmp_c1_result[3])? 4:(cmp_c1_result[2])? 3:(cmp_c1_result[1])? 2:(cmp_c1_result[0])? 1:0;
assign cmp_c2_CLO = (cmp_c2_result[4])? 5:(cmp_c2_result[3])? 4:(cmp_c2_result[2])? 3:(cmp_c2_result[1])? 2:(cmp_c2_result[0])? 1:0;
assign cmp_c3_CLO = (cmp_c3_result[4])? 5:(cmp_c3_result[3])? 4:(cmp_c3_result[2])? 3:(cmp_c3_result[1])? 2:(cmp_c3_result[0])? 1:0;



// ==============================================================================================================================
// Sequential Block
// ==============================================================================================================================
//state
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n) st <= RESET;
	else st <= nst;
end

// origin_X, origin_Y: only be used as iterator in LOAD_IMAGE
// X_iter, Y_iter
// Depth_32_16_8
// Depth_iter: only be used as iterator in LOAD_IMAGE & DISPLAY
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin
		origin_X <= 0;
		origin_Y <= 0;
		X_iter <= 0;
		Y_iter <= 0;
		Depth_32_16_8 <= DEPTH32;
		Depth_iter <= 0;
	end
	else begin
		case(st)
		WAIT_OP: begin //init iterator & UPDATE_ORIGIN_DEPTH
			if(i_op_valid_FF)begin
				case(i_op_mode_FF)
					// LOAD_IMAGE //init iterator
					4'b0000: begin origin_X <= 0; origin_Y <= 0;  end
					// UPDATE_ORIGIN_DEPTH
					4'b0001: origin_X <= (origin_X==6)? origin_X:origin_X+1;//Origin right shift
					4'b0010: origin_X <= (origin_X==0)? origin_X:origin_X-1;//Origin left shift
					4'b0011: origin_Y <= (origin_Y==0)? origin_Y:origin_Y-1;//Origin up shift
					4'b0100: origin_Y <= (origin_Y==6)? origin_Y:origin_Y+1;//Origin down shift
					4'b0101: Depth_32_16_8 <= (Depth_32_16_8==DEPTH8)? DEPTH8:Depth_32_16_8+1;  //Reduce the channel depth of the display region
					4'b0110: Depth_32_16_8 <= (Depth_32_16_8==DEPTH32)? DEPTH32:Depth_32_16_8-1;//Increase the channel depth of the display region
				endcase
				
				// init iterator
				X_iter <= 0;
				Y_iter <= 0;
				Depth_iter <= 0;
			end
		end
		LOAD_IMAGE: begin // iterators: origin_X, origin_Y, Depth_iter
			if(i_in_valid_FF)begin
				if(origin_X==7 && origin_Y==7 && Depth_iter==31)begin // load last pixel. nst = READY_NEXT_OP, init Origin & Depth_32_16_8
					origin_X <= 0;
					origin_Y <= 0; 
					Depth_32_16_8 <= DEPTH32;
				end
				else if(origin_X==7 && origin_Y==7)begin // change channel
					origin_X <= 0;
					origin_Y <= 0; 
					Depth_iter <= Depth_iter + 1;
				end
				else if(origin_X==7)begin // change column
					origin_X <= 0;
					origin_Y <= origin_Y + 1; 
				end
				else begin // change row
					origin_X <= origin_X + 1;
				end
			end
		end
		DISPLAY:begin // iterators: X_iter, Y_iter, Depth_iter
			if(X_iter==1 && Y_iter==1)begin // change channel
				X_iter <= 0;
				Y_iter <= 0; 
				Depth_iter <= Depth_iter + 1;
			end
			else if(X_iter==1)begin // change column
				X_iter <= 0;
				Y_iter <= Y_iter + 1; 
			end
			else begin // change row
				X_iter <= X_iter + 1;
			end
		end
		CONV_32_16_OUT:begin// iterators: X_iter, Y_iter
			if(X_iter==1)begin // change column
				X_iter <= 0;
				Y_iter <= Y_iter + 1; 
			end
			else begin // change row
				X_iter <= X_iter + 1;
			end
		end
		CONV_8_OUT:begin// iterators: X_iter, Y_iter
			if(X_iter==1)begin // change column
				X_iter <= 0;
				Y_iter <= Y_iter + 1; 
			end
			else begin // change row
				X_iter <= X_iter + 1;
			end
		end
		MEDIAN:begin // iterators: X_iter, Y_iter
			if(median_last0_valid[{Y_iter, X_iter}] || cnt==10)begin
				if(X_iter==1)begin // change column
					X_iter <= 0;
					Y_iter <= Y_iter + 1; 
				end
				else begin // change row
					X_iter <= X_iter + 1;
				end
			end
		end
		SOBEL_GET_ABS_G:begin
			if(X_iter==1)begin // change column
				X_iter <= 0;
				Y_iter <= Y_iter + 1; 
			end
			else begin // change row
				X_iter <= X_iter + 1;
			end
		end
		SOBEL_CAL_Gx_Gy:begin
			if(sobel_last_valid[{Y_iter, X_iter}])begin
				if(X_iter==1)begin // change column
					X_iter <= 0;
					Y_iter <= Y_iter + 1; 
				end
				else begin // change row
					X_iter <= X_iter + 1;
				end
			end
		end
		endcase
	end


end
// cnt
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n) cnt <= 0;
	else if(st == WAIT_OP)cnt <= 0;
	else if(st == DISPLAY)begin
		if(X_iter==1 && Y_iter==1 && Depth_iter==origin_Depth && cnt==2) cnt <= 3; //address last
		else if(cnt==2)cnt <= 2;
		else cnt <= cnt + 1;
	end
	else if(st == CONV_32_16)cnt <= cnt + 1;
	else if(st == CONV_8 && flag == 1)cnt <= cnt + 1;
	else if(st == CONV_8_OUT)cnt <= 0;
	else if(st == MEDIAN)begin
		if(cnt == 10)cnt <= 0;
		else if(median_last0_valid[{Y_iter, X_iter}])cnt <= 0;
		else cnt <= cnt + 1;
	end
	else if(st == MEDIAN_OUT)cnt <= cnt + 1;
	else if(st == SOBEL_CAL_Gx_Gy)begin
		if(cnt == 15)cnt <= 0;
		else if(sobel_last_valid[{Y_iter, X_iter}] || (sobel_last_valid_hit && sobel_last_X==origin_X && sobel_last_Y==origin_Y))cnt <= 0;
		else cnt <= cnt + 1;
	end
	else if(st == SOBEL_CAL_BOUND) cnt <= cnt + 1;
	else if(st == SOBEL_GET_ABS_G) cnt <= 0;
	else if(st == SOBEL_OUT)cnt <= cnt + 1;

end
// flag
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n) flag <= 0;
	else if(st == WAIT_OP)flag <= 0;
	else if(st == CONV_8)flag <= ~flag;
	else if(st == CONV_8_OUT)flag <= 0;
end

// input Flip flop
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin
	end
	else begin
		// i_in_valid and i_in_data FF
		i_in_valid_FF <= i_in_valid;   // only used in load image
		i_in_data_FF <= i_in_data;     // only used in load image
		// i_op_mode and i_op_valid FF
		i_op_mode_FF <= i_op_mode;     // only used in WAIT_OP
		i_op_valid_FF <= i_op_valid;   // only used in WAIT_OP
	end
end
// output FF
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin
		o_out_valid_FF<=0;
		o_out_data_FF<=0;
	end
	else begin
		o_out_valid_FF <= o_out_valid_wire;
		o_out_data_FF <= o_out_data_wire;
	end
end

// [15:0]accum[0:3]
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin
		for(i = 0; i < 4; i=i+1)begin
			accum[i] <= 0;    
		end
	end
	else if(st == WAIT_OP && nst == CONV_32_16)begin 
		for(i=0; i<4; i=i+1)begin
			accum[i] <= 0;
		end
	end
	else if(st == CONV_32_16)begin 
		accum[0] <= adder0_result;
		accum[1] <= adder1_result;
		accum[2] <= adder2_result;
		accum[3] <= adder3_result;
	end
	else if(st == CONV_8)begin
		if(cnt == 0)begin
			for(i=0; i<4; i=i+1)begin
				accum[i] <= 0;
			end
		end
		else begin
			accum[0] <= adder0_result;
			accum[1] <= adder1_result;
			accum[2] <= adder2_result;
			accum[3] <= adder3_result;
		end
	end
	else if(st == SOBEL_CAL_Gx_Gy)begin 
		if((cnt==1 || cnt==8))begin
			for(i = 0; i < 4; i=i+1)begin
				accum[i] <= 0;    
			end
		end
		else if(cnt==15)begin // set |Gx|*2^-2 // in SOBEL_CAL_BOUND with cnt = 0 ~ 2, accum is 10.7
			for(i = 0; i < 4; i=i+1)begin
				accum[i] <= {sobel_abs_accum[i], 5'b0};    
			end
		end
		else begin
			accum[0] <= adder0_result;
			accum[1] <= adder1_result;
			accum[2] <= adder2_result;
			accum[3] <= adder3_result;
		end
	end
	else if(st == SOBEL_CAL_BOUND)begin
		if(cnt == 2)begin // 因為只和整數比，把小數unary OR -> 10.7==>10.1
			accum[0] <= {adder0_result[16:7], sobel_OR_frac0};
			accum[1] <= {adder1_result[16:7], sobel_OR_frac1};
			accum[2] <= {adder2_result[16:7], sobel_OR_frac2};
			accum[3] <= {adder3_result[16:7], sobel_OR_frac3};
		end
		else begin
			accum[0] <= adder0_result;
			accum[1] <= adder1_result;
			accum[2] <= adder2_result;
			accum[3] <= adder3_result;
		end
		
	end
end





// DISPLAY
// Depth_iter_delay1, 2: for DISPLAY
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin
	end
	else begin
		Depth_iter_delay1 <= Depth_iter[1:0];
		Depth_iter_delay2 <= Depth_iter_delay1;
	end
end


// CONV
// conv_col_sum_16 & conv_col_sum_32 
// get the column sum in LOAD_IMAGE(ony update in this state)
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin
		for(i=0; i<64; i=i+1)begin
			conv_col_sum_16[i] <= 0;
			conv_col_sum_32[i] <= 0;
		end
	end
	else if(st == LOAD_IMAGE && i_in_valid_FF)begin 
		conv_col_sum_16[{origin_Y, origin_X}] <= (Depth_iter <= 15)? conv_col_sum_16[{origin_Y, origin_X}] + i_in_data_FF : conv_col_sum_16[{origin_Y, origin_X}];
		conv_col_sum_32[{origin_Y, origin_X}] <= conv_col_sum_32[{origin_Y, origin_X}] + i_in_data_FF;
	end
end



// MEDIAN
// cache: last0, last1
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin
		median_last0_X <= 0; median_last1_X <= 0; 
		median_last0_Y <= 0; median_last1_Y <= 0;
		for(i = 0; i < 4; i=i+1)begin
			median_last0_result_c0[i] <= 0;    median_last1_result_c0[i] <= 0;
			median_last0_result_c1[i] <= 0;    median_last1_result_c1[i] <= 0;
			median_last0_result_c2[i] <= 0;    median_last1_result_c2[i] <= 0;
			median_last0_result_c3[i] <= 0;    median_last1_result_c3[i] <= 0;
			median_last0_valid[i]     <= 0;    median_last1_valid[i]     <= 0;
		end
	end
	else if(st == WAIT_OP && i_op_valid_FF && i_op_mode_FF==4'b1001)begin // MEDIAN update last
		median_last0_X <= median_last0_X_w; median_last1_X <= median_last1_X_w; 
		median_last0_Y <= median_last0_Y_w; median_last1_Y <= median_last1_Y_w;
		for(i = 0; i < 4; i=i+1)begin
			median_last0_result_c0[i] <= median_last0_result_c0_w[i];    median_last1_result_c0[i] <= median_last1_result_c0_w[i];
			median_last0_result_c1[i] <= median_last0_result_c1_w[i];    median_last1_result_c1[i] <= median_last1_result_c1_w[i];
			median_last0_result_c2[i] <= median_last0_result_c2_w[i];    median_last1_result_c2[i] <= median_last1_result_c2_w[i];
			median_last0_result_c3[i] <= median_last0_result_c3_w[i];    median_last1_result_c3[i] <= median_last1_result_c3_w[i];
			median_last0_valid[i]     <= median_last0_valid_w[i];        median_last1_valid[i]     <= median_last1_valid_w[i];
		end		
	end
	else if(st == MEDIAN && cnt==10)begin // MEDIAN
		median_last0_result_c0[{Y_iter, X_iter}] <= median_min5_c0_w[4]; 
		median_last0_result_c1[{Y_iter, X_iter}] <= median_min5_c1_w[4]; 
		median_last0_result_c2[{Y_iter, X_iter}] <= median_min5_c2_w[4]; 
		median_last0_result_c3[{Y_iter, X_iter}] <= median_min5_c3_w[4]; 
		median_last0_valid[{Y_iter, X_iter}]     <= 1;     
	end
	else if(st == MEDIAN_OUT)begin
		median_last0_X <= origin_X;  
		median_last0_Y <= origin_Y; 
	end	
end
// array to store 5 samllest values: median_min5_c0[0:4]
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin
		for(i = 0; i < 5; i=i+1)begin
			median_min5_c0[i] <= 255;    
			median_min5_c1[i] <= 255; 
			median_min5_c2[i] <= 255; 
			median_min5_c3[i] <= 255; 
		end
	end
	else if(st == MEDIAN)begin 
		if(cnt == 1)begin// init array
			for(i = 0; i < 5; i=i+1)begin
				median_min5_c0[i] <= 255;    
				median_min5_c1[i] <= 255; 
				median_min5_c2[i] <= 255; 
				median_min5_c3[i] <= 255; 
			end
		end
		else begin
			for(i = 0; i < 5; i=i+1)begin
				median_min5_c0[i] <= median_min5_c0_w[i];    
				median_min5_c1[i] <= median_min5_c1_w[i]; 
				median_min5_c2[i] <= median_min5_c2_w[i]; 
				median_min5_c3[i] <= median_min5_c3_w[i]; 
			end
		end
	end
	
end



// SOBEL
// cache: last
// sobel_dir_channel_valid
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin
		sobel_last_X <= 0; 
		sobel_last_Y <= 0; 
		for(i = 0; i < 4; i=i+1)begin
			sobel_last_dir_c0[i] <= 0;    sobel_last_G_c0[i] <= 0;
			sobel_last_dir_c1[i] <= 0;    sobel_last_G_c1[i] <= 0;
			sobel_last_dir_c2[i] <= 0;    sobel_last_G_c2[i] <= 0;
			sobel_last_dir_c3[i] <= 0;    sobel_last_G_c3[i] <= 0;
			sobel_last_valid[i]  <= 0;  
			sobel_dir_channel_valid[i] <= 0;
		end
	end
	else if(st == WAIT_OP && i_op_valid_FF && i_op_mode_FF==4'b1010)begin // SOBEL update last
		sobel_last_X <= sobel_last_X_w;  
		sobel_last_Y <= sobel_last_Y_w; 
		for(i = 0; i < 4; i=i+1)begin
			sobel_last_dir_c0[i] <= sobel_last_dir_c0_w[i];    sobel_last_G_c0[i] <= sobel_last_G_c0_w[i];
			sobel_last_dir_c1[i] <= sobel_last_dir_c1_w[i];    sobel_last_G_c1[i] <= sobel_last_G_c1_w[i];
			sobel_last_dir_c2[i] <= sobel_last_dir_c2_w[i];    sobel_last_G_c2[i] <= sobel_last_G_c2_w[i];
			sobel_last_dir_c3[i] <= sobel_last_dir_c3_w[i];    sobel_last_G_c3[i] <= sobel_last_G_c3_w[i];
			sobel_last_valid[i]  <= sobel_last_valid_w[i];  
			sobel_dir_channel_valid[i] <= 0;  			
		end		
	end
	else if(st == SOBEL_CAL_Gx_Gy && cnt == 15)begin // get abs(Gx) and put it in sobel_last_G  ([10:0]sobel_abs_accum)
		sobel_last_G_c0[{Y_iter, X_iter}] <= sobel_abs_accum[0]; 
		sobel_last_G_c1[{Y_iter, X_iter}] <= sobel_abs_accum[1]; 
		sobel_last_G_c2[{Y_iter, X_iter}] <= sobel_abs_accum[2]; 
		sobel_last_G_c3[{Y_iter, X_iter}] <= sobel_abs_accum[3]; 
	end
	else if(st == SOBEL_CMP_BOUND && cnt == 3)begin
		if(sobel_dir_channel_valid[0] == 0)begin 
			if(accum[0][10:0] > {sobel_abs_Gy[0], 1'b0})begin// dir0: degree 0
				sobel_last_dir_c0[{Y_iter, X_iter}] <= 0;
				sobel_dir_channel_valid[0] <= 1;
			end
		end
		if(sobel_dir_channel_valid[1] == 0)begin 
			if(accum[1][10:0] > {sobel_abs_Gy[1], 1'b0})begin// dir0: degree 0
				sobel_last_dir_c1[{Y_iter, X_iter}] <= 0;
				sobel_dir_channel_valid[1] <= 1;
			end
		end
		if(sobel_dir_channel_valid[2] == 0)begin 
			if(accum[2][10:0] > {sobel_abs_Gy[2], 1'b0})begin// dir0: degree 0
				sobel_last_dir_c2[{Y_iter, X_iter}] <= 0;
				sobel_dir_channel_valid[2] <= 1;
			end
		end
		if(sobel_dir_channel_valid[3] == 0)begin 
			if(accum[3][10:0] > {sobel_abs_Gy[3], 1'b0})begin// dir0: degree 0
				sobel_last_dir_c3[{Y_iter, X_iter}] <= 0;
				sobel_dir_channel_valid[3] <= 1;
			end
		end
	end
	else if(st == SOBEL_CMP_BOUND && cnt == 4)begin
		if(sobel_dir_channel_valid[0] == 0)begin 
			if(accum[0][12:0] < {sobel_abs_Gy[0], 1'b0})begin// dir2: degree 90
				sobel_last_dir_c0[{Y_iter, X_iter}] <= 2;
				sobel_dir_channel_valid[0] <= 1;
			end
			else begin  // dir3: degree 135, dir1: degree 45
				sobel_last_dir_c0[{Y_iter, X_iter}] <= (sobel_sign_Gx_Gy[0])? 3:1;  // 0:同號 1:異號
				sobel_dir_channel_valid[0] <= 1;
			end
		end
		if(sobel_dir_channel_valid[1] == 0)begin 
			if(accum[1][12:0] < {sobel_abs_Gy[1], 1'b0})begin// dir2: degree 90
				sobel_last_dir_c1[{Y_iter, X_iter}] <= 2;
				sobel_dir_channel_valid[1] <= 1;
			end
			else begin  // dir3: degree 135, dir1: degree 45
				sobel_last_dir_c1[{Y_iter, X_iter}] <= (sobel_sign_Gx_Gy[1])? 3:1;  // 0:同號 1:異號
				sobel_dir_channel_valid[1] <= 1;
			end
		end
		if(sobel_dir_channel_valid[2] == 0)begin 
			if(accum[2][12:0] < {sobel_abs_Gy[2], 1'b0})begin// dir2: degree 90
				sobel_last_dir_c2[{Y_iter, X_iter}] <= 2;
				sobel_dir_channel_valid[2] <= 1;
			end
			else begin  // dir3: degree 135, dir1: degree 45
				sobel_last_dir_c2[{Y_iter, X_iter}] <= (sobel_sign_Gx_Gy[2])? 3:1;  // 0:同號 1:異號
				sobel_dir_channel_valid[2] <= 1;
			end
		end
		if(sobel_dir_channel_valid[3] == 0)begin 
			if(accum[3][12:0] < {sobel_abs_Gy[3], 1'b0})begin// dir2: degree 90
				sobel_last_dir_c3[{Y_iter, X_iter}] <= 2;
				sobel_dir_channel_valid[3] <= 1;
			end
			else begin  // dir3: degree 135, dir1: degree 45
				sobel_last_dir_c3[{Y_iter, X_iter}] <= (sobel_sign_Gx_Gy[3])? 3:1;  // 0:同號 1:異號
				sobel_dir_channel_valid[3] <= 1;
			end
		end
	end
	else if(st == SOBEL_GET_ABS_G)begin // get abs(G) = |Gx| + |Gy|
		sobel_last_G_c0[{Y_iter, X_iter}] <= adder0_result; 
		sobel_last_G_c1[{Y_iter, X_iter}] <= adder1_result; 
		sobel_last_G_c2[{Y_iter, X_iter}] <= adder2_result; 
		sobel_last_G_c3[{Y_iter, X_iter}] <= adder3_result;
		sobel_last_valid[{Y_iter, X_iter}] <= 1;	
		for(i = 0; i < 4; i=i+1)begin
			sobel_dir_channel_valid[i] <= 0;  			
		end	
	end
	else if(st == SOBEL_OUT && cnt == 15)begin
		sobel_last_X<=origin_X;
		sobel_last_Y<=origin_Y;
	end
end
// [10:0]sobel_abs_Gy, sobel_sign_Gx_Gy(0:同號, 1:異號)
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin
	end
	else if(st == SOBEL_CAL_Gx_Gy)begin 
		if(cnt==8)begin // get the abs(Gy) and sign of Gy
			for(i = 0; i < 4; i=i+1)begin
				sobel_abs_Gy[i] <= sobel_abs_accum[i]; 
				sobel_sign_Gx_Gy[i] <= accum[i][10]; 
			end
		end
		else if(cnt==15)begin // XOR sign of Gx and Gy(0:同號, 1:異號)
			for(i = 0; i < 4; i=i+1)begin
				sobel_sign_Gx_Gy[i] <= sobel_sign_Gx_Gy[i] ^ accum[i][10]; 
			end
		end
	end
end



//SRAM read data flip flop: sram_data_r_FF
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin
	end
	else begin
		sram_data_r_FF[0] <= sram_0_data_r;
		sram_data_r_FF[1] <= sram_1_data_r;
		sram_data_r_FF[2] <= sram_2_data_r;
		sram_data_r_FF[3] <= sram_3_data_r;
	end
	
end

sram_512x8 sram_0(.CLK(i_clk), .CEN(1'b0), .WEN(sram_0_wen), .A(sram_addr), .D(i_in_data_FF), .Q(sram_0_data_r));
sram_512x8 sram_1(.CLK(i_clk), .CEN(1'b0), .WEN(sram_1_wen), .A(sram_addr), .D(i_in_data_FF), .Q(sram_1_data_r));
sram_512x8 sram_2(.CLK(i_clk), .CEN(1'b0), .WEN(sram_2_wen), .A(sram_addr), .D(i_in_data_FF), .Q(sram_2_data_r));
sram_512x8 sram_3(.CLK(i_clk), .CEN(1'b0), .WEN(sram_3_wen), .A(sram_addr), .D(i_in_data_FF), .Q(sram_3_data_r));


endmodule
