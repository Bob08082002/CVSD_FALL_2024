// exclude PC1, PC2, just do circular shift
module Sub_Key(
input   [55:0] sub_key_in,
input   [2:0] func_in,
output  reg[55:0] sub_key_out);

localparam FUNC_LEFT_1 = 0, FUNC_LEFT_2 = 1, FUNC_RIGHT_1 = 2, FUNC_RIGHT_2 = 3, FUNC_KEEP = 4;

// split to half
wire [27:0]sub_key_in_msb = sub_key_in[55:28];
wire [27:0]sub_key_in_lsb = sub_key_in[27:0];

// circular shift left 1
wire [27:0]sub_key_in_msb_left_1 = {sub_key_in_msb[26:0], sub_key_in_msb[27]};
wire [27:0]sub_key_in_lsb_left_1 = {sub_key_in_lsb[26:0], sub_key_in_lsb[27]};
// circular shift left 2
wire [27:0]sub_key_in_msb_left_2 = {sub_key_in_msb[25:0], sub_key_in_msb[27:26]};
wire [27:0]sub_key_in_lsb_left_2 = {sub_key_in_lsb[25:0], sub_key_in_lsb[27:26]};
// circular shift right 1
wire [27:0]sub_key_in_msb_right_1 = {sub_key_in_msb[0], sub_key_in_msb[27:1]};
wire [27:0]sub_key_in_lsb_right_1 = {sub_key_in_lsb[0], sub_key_in_lsb[27:1]};
// circular shift right 2
wire [27:0]sub_key_in_msb_right_2 = {sub_key_in_msb[1:0], sub_key_in_msb[27:2]};
wire [27:0]sub_key_in_lsb_right_2 = {sub_key_in_lsb[1:0], sub_key_in_lsb[27:2]};



always@(*)begin
	case(func_in)
		FUNC_LEFT_1: sub_key_out = {sub_key_in_msb_left_1, sub_key_in_lsb_left_1};
		FUNC_LEFT_2: sub_key_out = {sub_key_in_msb_left_2, sub_key_in_lsb_left_2};
		FUNC_RIGHT_1: sub_key_out = {sub_key_in_msb_right_1, sub_key_in_lsb_right_1};
		FUNC_RIGHT_2: sub_key_out = {sub_key_in_msb_right_2, sub_key_in_lsb_right_2};
		FUNC_KEEP: sub_key_out = sub_key_in;
		default: sub_key_out = sub_key_in;
	endcase
end


endmodule