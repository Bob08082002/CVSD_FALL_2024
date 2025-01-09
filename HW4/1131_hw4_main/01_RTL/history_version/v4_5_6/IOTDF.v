`timescale 1ns/10ps
module IOTDF( clk, rst, in_en, iot_in, fn_sel, busy, valid, iot_out);
input          clk;
input          rst;
input          in_en;
input  [7:0]   iot_in;
input  [2:0]   fn_sel;
output         busy;
output         valid;
output [127:0] iot_out;

// function
localparam ENCRYPT = 1, DECRYPT = 2, CRC_GEN = 3, TOP2MAX = 4, LAST2MIN = 5;




// ---------------------------------------------------------------------------
// Wires and Registers
// ---------------------------------------------------------------------------
// counters
reg [3:0]cnt_read_r, cnt_read_w; // read input
reg [2:0]cnt_round_r, cnt_round_w; // for F4, F5, for round counting, 8 IOT data a round.
// flag
reg [1:0]start_output_flag_r, start_output_flag_w; // first 16 cycle only read IOT data, do not output // start_output_flag_r == 2: valid to output
reg [1:0]idle_in_rounds_flag_r, idle_in_rounds_flag_w; // used only in F4 & F5, after 1 round is finished, need to stall 2 cycle

// ---------------------------------input & output buffer---------------------------------
// fn_sel input buffer  // fn_sel is unchanged in one simulation
reg [2:0] fn_sel_r;
wire [2:0]fn_sel_w = fn_sel;
// iot_in input buffer
reg [127:0]iot_in_r, iot_in_w;
// busy output buffer
reg busy_r;
// valid output buffer
reg valid_r;
// iot_out output buffer 1 & 2
reg [127:0]iot_out1_r, iot_out1_w;
reg [127:0]iot_out2_r, iot_out2_w;


// --------------------------------- F1 & F2 --------------------------------- 
wire [63:0]IP_out;
wire [31:0]IP_out_L, IP_out_R;
wire [63:0]FP_in, FP_out;
wire [31:0]XOR_out, XOR_in1, XOR_in2;
reg [31:0]MUX_out1_63_32, MUX_out1_31_0;
wire [63:0]MUX_out1_127_64;
// SUB KEY GEN
wire [55:0]MUX_sub_key_gen_in;
wire [55:0]PC1_out;
wire [47:0]KEY;
reg [55:0]KEY_before_PC2_r;
wire [55:0]KEY_before_PC2_w;

// --------------------------------- F3 --------------------------------- 
wire [2:0]CRC_remainder;

// --------------------------------- F4 & F5 --------------------------------- 
reg Is_in_biggerthan_out1_r, Is_in_biggerthan_out1_w; // iot_in_r > iot_out1_r?
reg Is_in_biggerthan_out2_r, Is_in_biggerthan_out2_w; // iot_in_r > iot_out2_r?
wire Is_in_biggerthan_out1_8b, Is_in_biggerthan_out2_8b; // 8 bit cmp output
wire Is_in_equal_out1_8b, Is_in_equal_out2_8b; // 8 bit cmp output
wire [7:0]cmp_in_in, cmp_in_out1, cmp_in_out2; // 8 bit cmp inputs






// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------
assign busy = busy_r;
assign valid = valid_r; 
assign iot_out = ((fn_sel_r==TOP2MAX || fn_sel_r==LAST2MIN) && idle_in_rounds_flag_r==2)? iot_out1_r:iot_out2_r; // ~!!!!!!!!!????????????


// ---------------------------------------------------------------------------
// Control Signals
// ---------------------------------------------------------------------------
// counters
// read input counters
always@(*)begin
	cnt_read_w = (in_en)? cnt_read_r + 1'b1:cnt_read_r;
end
always@(posedge clk or posedge rst)begin
	if(rst) cnt_read_r <= 0;
	else cnt_read_r <= cnt_read_w;
end
// counting round, round = 0 ~ 7
always@(*)begin
	cnt_round_w = (cnt_read_r==15)? cnt_round_r + 1'b1:cnt_round_r;
end
always@(posedge clk or posedge rst)begin
	if(rst) cnt_round_r <= 0;
	else cnt_round_r <= cnt_round_w;
end

// flags
// start_output_flag, can output only when start_output_flag==2
always@(*)begin
	if(start_output_flag_r==0 && cnt_read_r==15)start_output_flag_w = 1;
	else if(start_output_flag_r==1 && cnt_read_r==15)start_output_flag_w = 2;
	else start_output_flag_w = start_output_flag_r;
end
always@(posedge clk or posedge rst)begin
	if(rst) start_output_flag_r <= 0;
	else start_output_flag_r <= start_output_flag_w;
end
// idle_in_rounds_flag
always@(*)begin
	if(cnt_round_r==7 && cnt_read_r==15)idle_in_rounds_flag_w = 1;
	else if(idle_in_rounds_flag_r==1)idle_in_rounds_flag_w = 2;
	else if(idle_in_rounds_flag_r==2)idle_in_rounds_flag_w = 0;
	else idle_in_rounds_flag_w = idle_in_rounds_flag_r;
end
always@(posedge clk or posedge rst)begin
	if(rst) idle_in_rounds_flag_r <= 0;
	else idle_in_rounds_flag_r <= idle_in_rounds_flag_w;
end


// ---------------------------------------------------------------------------
// Input, Output Buffer
// ---------------------------------------------------------------------------
// fn_sel input buffer 
always@(posedge clk or posedge rst)begin // can optimize?
	if(rst) fn_sel_r <= fn_sel_w;
	else fn_sel_r <= fn_sel_w;
end
// valid output buffer
always@(posedge clk or posedge rst)begin
	if(rst) valid_r <= 1'b0;
	else if((fn_sel_r==TOP2MAX || fn_sel_r==LAST2MIN))begin
		valid_r <= (idle_in_rounds_flag_r == 1 || idle_in_rounds_flag_r == 2);
	end
	else begin
		valid_r <= (cnt_read_r==0 && start_output_flag_r == 2);
	end 
end
// busy output buffer
always@(posedge clk or posedge rst)begin
	if(rst) busy_r <= 1'b1;
	// used only in F4 & F5, after 1 round is finished, need to stall 2 cycle
	else if((fn_sel_r==TOP2MAX || fn_sel_r==LAST2MIN) && cnt_round_r==7 && (cnt_read_r==14 || cnt_read_r==15)) busy_r <= 1'b1; 
	else busy_r <= 1'b0;
end
// iot_in input buffer: iot_in_r
wire [6:0] cnt_read_r_mul_8 = {cnt_read_r, 3'b0}; // cnt_read_r x 8
always@(*)begin
	iot_in_w = iot_in_r;
	iot_in_w[cnt_read_r_mul_8+:8] = iot_in;
end
always@(posedge clk or posedge rst)begin
	if(rst)iot_in_r <= iot_in_w;
	else iot_in_r <= iot_in_w;
end
// iot_out output buffer 1: iot_out1_w
// also used as operating register
// also store max/min value in F4 & F5
always@(*)begin
	iot_out1_w = iot_out1_r;
	// MUX of FLIP FLOP iot_out1_w // depends on functions
	if(fn_sel_r==ENCRYPT || fn_sel_r==DECRYPT)begin
		iot_out1_w[63:0] = {MUX_out1_63_32, MUX_out1_31_0};
	end
	else if(fn_sel_r==CRC_GEN)begin
		if(cnt_read_r==0)iot_out1_w = iot_in_r;
		else iot_out1_w = {CRC_remainder, iot_out1_r[116:0], 8'b0};
	end
	else if(fn_sel_r==TOP2MAX)begin // TOP2MAX 
		if(cnt_round_r==0 && idle_in_rounds_flag_r==0 /*&& cnt_read_r==0*/)begin // initialize iot_out1_r to min(TOP2MAX)
			iot_out1_w=0; // min
		end
		else if(idle_in_rounds_flag_r!=2&& cnt_read_r==0)begin // update out1 & out2 in sorted order
			if(Is_in_biggerthan_out1_w&&Is_in_biggerthan_out2_w) iot_out1_w = iot_in_r;
		end
	end
	else begin // LAST2MIN
		if(cnt_round_r==0 && idle_in_rounds_flag_r==0 /*&& cnt_read_r==0*/)begin // initialize iot_out1_r to max(LAST2MIN)
			iot_out1_w={128{1'b1}}; // max
		end
		else if(idle_in_rounds_flag_r!=2&& cnt_read_r==0)begin // update out1 & out2 in sorted order
			if((!Is_in_biggerthan_out1_w)&&(!Is_in_biggerthan_out2_w)) iot_out1_w = iot_in_r;
		end
	end
end
always@(posedge clk or posedge rst)begin
	if(rst)iot_out1_r <= iot_out1_w;
	else iot_out1_r <= iot_out1_w;
end
// iot_out output buffer 2: iot_out2_w
// also store second max/min value in F4 & F5
always@(*)begin
	iot_out2_w = iot_out2_r;
	// MUX of FLIP FLOP iot_out2_w // depends on functions
	if(fn_sel_r==ENCRYPT || fn_sel_r==DECRYPT)begin
		if(cnt_read_r==0)iot_out2_w[63:0] = FP_out; //can optimize?
		if(cnt_read_r==1)iot_out2_w[127:64] = iot_in_r[127:64]; // main key
	end
	else if(fn_sel_r==CRC_GEN)begin
		if(cnt_read_r==0)iot_out2_w = CRC_remainder;//can optimize?
	end
	else if(fn_sel_r==TOP2MAX)begin // TOP2MAX 
		if(cnt_round_r==0 && idle_in_rounds_flag_r==0 /*&& cnt_read_r==0*/)begin // initialize iot_out2_r to min(TOP2MAX)
			iot_out2_w=0; // min
		end
		else if(idle_in_rounds_flag_r!=2&& cnt_read_r==0)begin // update out1 & out2 in sorted order
			if(Is_in_biggerthan_out2_w)begin
				if(Is_in_biggerthan_out1_w) iot_out2_w = iot_out1_r;
				else iot_out2_w = iot_in_r;
			end
		end
	end
	else begin // LAST2MIN
		if(cnt_round_r==0 && idle_in_rounds_flag_r==0 /*&& cnt_read_r==0*/)begin // initialize iot_out2_r to max(LAST2MIN)
			iot_out2_w={128{1'b1}}; // max
		end
		else if(idle_in_rounds_flag_r!=2&& cnt_read_r==0)begin // update out1 & out2 in sorted order
			if(!Is_in_biggerthan_out2_w)begin
				if(!Is_in_biggerthan_out1_w)iot_out2_w = iot_out1_r;
				else iot_out2_w = iot_in_r;
			end
		end
	end
end
always@(posedge clk or posedge rst)begin
	if(rst)iot_out2_r <= iot_out2_w;
	else iot_out2_r <= iot_out2_w;
end

// ---------------------------------------------------------------------------
// Functions 
// ---------------------------------------------------------------------------
// ------------ F1 Encrypt & F2 Decrypt ------------
// IP
assign IP_out = {iot_in_r[ 6],iot_in_r[14],iot_in_r[22],iot_in_r[30]
			    ,iot_in_r[38],iot_in_r[46],iot_in_r[54],iot_in_r[62]
			    ,iot_in_r[ 4],iot_in_r[12],iot_in_r[20],iot_in_r[28]
			    ,iot_in_r[36],iot_in_r[44],iot_in_r[52],iot_in_r[60]
			    ,iot_in_r[ 2],iot_in_r[10],iot_in_r[18],iot_in_r[26]
			    ,iot_in_r[34],iot_in_r[42],iot_in_r[50],iot_in_r[58]
			    ,iot_in_r[ 0],iot_in_r[ 8],iot_in_r[16],iot_in_r[24]
			    ,iot_in_r[32],iot_in_r[40],iot_in_r[48],iot_in_r[56]
			    ,iot_in_r[ 7],iot_in_r[15],iot_in_r[23],iot_in_r[31]
			    ,iot_in_r[39],iot_in_r[47],iot_in_r[55],iot_in_r[63]
			    ,iot_in_r[ 5],iot_in_r[13],iot_in_r[21],iot_in_r[29]
			    ,iot_in_r[37],iot_in_r[45],iot_in_r[53],iot_in_r[61]
			    ,iot_in_r[ 3],iot_in_r[11],iot_in_r[19],iot_in_r[27]
			    ,iot_in_r[35],iot_in_r[43],iot_in_r[51],iot_in_r[59]
			    ,iot_in_r[ 1],iot_in_r[ 9],iot_in_r[17],iot_in_r[25]
			    ,iot_in_r[33],iot_in_r[41],iot_in_r[49],iot_in_r[57]};
assign 	{IP_out_L, IP_out_R} = IP_out;
// FP
assign FP_in = {XOR_out, iot_out1_r[31:0]};
assign FP_out = {FP_in[24],FP_in[56],FP_in[16],FP_in[48]
			    ,FP_in[ 8],FP_in[40],FP_in[ 0],FP_in[32]
			    ,FP_in[25],FP_in[57],FP_in[17],FP_in[49]
			    ,FP_in[ 9],FP_in[41],FP_in[ 1],FP_in[33]
			    ,FP_in[26],FP_in[58],FP_in[18],FP_in[50]
			    ,FP_in[10],FP_in[42],FP_in[ 2],FP_in[34]
			    ,FP_in[27],FP_in[59],FP_in[19],FP_in[51]
			    ,FP_in[11],FP_in[43],FP_in[ 3],FP_in[35]
			    ,FP_in[28],FP_in[60],FP_in[20],FP_in[52]
			    ,FP_in[12],FP_in[44],FP_in[ 4],FP_in[36]
			    ,FP_in[29],FP_in[61],FP_in[21],FP_in[53]
			    ,FP_in[13],FP_in[45],FP_in[ 5],FP_in[37]
			    ,FP_in[30],FP_in[62],FP_in[22],FP_in[54]
			    ,FP_in[14],FP_in[46],FP_in[ 6],FP_in[38]
			    ,FP_in[31],FP_in[63],FP_in[23],FP_in[55]
			    ,FP_in[15],FP_in[47],FP_in[ 7],FP_in[39]};
// SUB KEY GEN
// PC1 // pass main key through PC1
assign PC1_out = {iot_in_r[ 71],iot_in_r[ 79],iot_in_r[ 87],iot_in_r[95]
				 ,iot_in_r[103],iot_in_r[111],iot_in_r[119],iot_in_r[127]
				 ,iot_in_r[ 70],iot_in_r[ 78],iot_in_r[ 86],iot_in_r[94]
				 ,iot_in_r[102],iot_in_r[110],iot_in_r[118],iot_in_r[126]
				 ,iot_in_r[ 69],iot_in_r[ 77],iot_in_r[ 85],iot_in_r[93]
				 ,iot_in_r[101],iot_in_r[109],iot_in_r[117],iot_in_r[125]
				 ,iot_in_r[ 68],iot_in_r[ 76],iot_in_r[ 84],iot_in_r[92]
				 ,iot_in_r[ 65],iot_in_r[ 73],iot_in_r[ 81],iot_in_r[89]
				 ,iot_in_r[ 97],iot_in_r[105],iot_in_r[113],iot_in_r[121]
				 ,iot_in_r[ 66],iot_in_r[ 74],iot_in_r[ 82],iot_in_r[90]
				 ,iot_in_r[ 98],iot_in_r[106],iot_in_r[114],iot_in_r[122]
				 ,iot_in_r[ 67],iot_in_r[ 75],iot_in_r[ 83],iot_in_r[91]
				 ,iot_in_r[ 99],iot_in_r[107],iot_in_r[115],iot_in_r[123]
				 ,iot_in_r[100],iot_in_r[108],iot_in_r[116],iot_in_r[124]};
// PC2 // get the KEY (48 bits)
assign KEY = {KEY_before_PC2_r[42],KEY_before_PC2_r[39],KEY_before_PC2_r[45],KEY_before_PC2_r[32]			     
			 ,KEY_before_PC2_r[55],KEY_before_PC2_r[51],KEY_before_PC2_r[53],KEY_before_PC2_r[28]			     
			 ,KEY_before_PC2_r[41],KEY_before_PC2_r[50],KEY_before_PC2_r[35],KEY_before_PC2_r[46]			     
			 ,KEY_before_PC2_r[33],KEY_before_PC2_r[37],KEY_before_PC2_r[44],KEY_before_PC2_r[52]			     
			 ,KEY_before_PC2_r[30],KEY_before_PC2_r[48],KEY_before_PC2_r[40],KEY_before_PC2_r[49]			     
			 ,KEY_before_PC2_r[29],KEY_before_PC2_r[36],KEY_before_PC2_r[43],KEY_before_PC2_r[54]			     
			 ,KEY_before_PC2_r[15],KEY_before_PC2_r[ 4],KEY_before_PC2_r[25],KEY_before_PC2_r[19]			     
			 ,KEY_before_PC2_r[ 9],KEY_before_PC2_r[ 1],KEY_before_PC2_r[26],KEY_before_PC2_r[16]			     
			 ,KEY_before_PC2_r[ 5],KEY_before_PC2_r[11],KEY_before_PC2_r[23],KEY_before_PC2_r[ 8]			     
			 ,KEY_before_PC2_r[12],KEY_before_PC2_r[ 7],KEY_before_PC2_r[17],KEY_before_PC2_r[ 0]			     
			 ,KEY_before_PC2_r[22],KEY_before_PC2_r[ 3],KEY_before_PC2_r[10],KEY_before_PC2_r[14]			
			 ,KEY_before_PC2_r[ 6],KEY_before_PC2_r[20],KEY_before_PC2_r[27],KEY_before_PC2_r[24]};
// Sub_Key_u: do circular shift depends on fn_sel_r and cnt_read_r
Sub_Key Sub_Key_u(
	.sub_key_in(MUX_sub_key_gen_in),
	.fn_sel_r(fn_sel_r),
	.cnt_read_r(cnt_read_r),
	.sub_key_out(KEY_before_PC2_w));	
// sub key buffer
always@(posedge clk or posedge rst)begin
	if(rst) KEY_before_PC2_r <= KEY_before_PC2_w;
	else  KEY_before_PC2_r <= KEY_before_PC2_w;
end	
// F_Function
F_Function F_Function_u(
.key_in(KEY),
.R_in(iot_out1_r[31:0]),
.F_out(XOR_in2));
// 32bit XOR
assign XOR_in1 = iot_out1_r[63:32];
assign XOR_out = XOR_in1 ^ XOR_in2;
// MUX: if cnt==0, means previous data is loaded ==> start calculating
assign MUX_sub_key_gen_in = (cnt_read_r==0)? PC1_out:KEY_before_PC2_r;
always@(*)begin
	if(cnt_read_r==0)MUX_out1_63_32 = IP_out_L;
	else MUX_out1_63_32 = iot_out1_r[31:0];
end
always@(*)begin
	if(cnt_read_r==0)MUX_out1_31_0 = IP_out_R;
	else MUX_out1_31_0 = XOR_out;
end

// ------------ F3 CRC generator ------------
CRC_Gen CRC_Gen_u(
.crc_dividend_in(iot_out1_r[127:117]), // 11bit msb of dividend
.crc_remainder_out(CRC_remainder));

// ------------ F4 TOP2MAX & F5 LAST2MIN ------------
// Is_in_biggerthan_out1_r, Is_in_biggerthan_out2_r
always@(*)begin
	// if current 8 bit sub-datas are equal, use previous cmp result(less significant). Otherwise, use current cmp result(more significant).
	Is_in_biggerthan_out1_w = (Is_in_equal_out1_8b)? Is_in_biggerthan_out1_r:Is_in_biggerthan_out1_8b;
	Is_in_biggerthan_out2_w = (Is_in_equal_out2_8b)? Is_in_biggerthan_out2_r:Is_in_biggerthan_out2_8b;
end
always@(posedge clk or posedge rst)begin
	if(rst)begin
		Is_in_biggerthan_out1_r <= Is_in_biggerthan_out1_w;
		Is_in_biggerthan_out2_r <= Is_in_biggerthan_out2_w;
	end
	else begin
		Is_in_biggerthan_out1_r <= Is_in_biggerthan_out1_w;
		Is_in_biggerthan_out2_r <= Is_in_biggerthan_out2_w;
	end
end
// 8 bit cmp(unsigned)
wire [3:0]cnt_read_r_minus_1 = cnt_read_r - 1;  // can optimize?
wire [6:0]cnt_read_r_minus_1_mul_8 = {cnt_read_r_minus_1, 3'b0}; // (cnt_read_r - 1)*8
assign cmp_in_in = iot_in_r[cnt_read_r_minus_1_mul_8+:8];    // cnt_read_r=1 -> choose [7:0], cnt_read_r=2 -> choose [16:8], ...cnt_read_r=0 -> choose [127:120] 
assign cmp_in_out1 = iot_out1_r[cnt_read_r_minus_1_mul_8+:8];
assign cmp_in_out2 = iot_out2_r[cnt_read_r_minus_1_mul_8+:8];
assign Is_in_biggerthan_out1_8b = (cmp_in_in > cmp_in_out1);
assign Is_in_biggerthan_out2_8b = (cmp_in_in > cmp_in_out2);
assign Is_in_equal_out1_8b = (cmp_in_in == cmp_in_out1);
assign Is_in_equal_out2_8b = (cmp_in_in == cmp_in_out2);




endmodule
