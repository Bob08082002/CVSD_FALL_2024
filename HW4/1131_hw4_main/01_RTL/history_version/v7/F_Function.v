module F_Function(
input   [47:0] key_in,
input   [31:0] R_in,
output  [31:0] F_out);


// Expansion
wire [47:0]expansion_out = {R_in[ 0],R_in[31],R_in[30],R_in[29]
						   ,R_in[28],R_in[27],R_in[28],R_in[27]
						   ,R_in[26],R_in[25],R_in[24],R_in[23]
						   ,R_in[24],R_in[23],R_in[22],R_in[21]
						   ,R_in[20],R_in[19],R_in[20],R_in[19]
						   ,R_in[18],R_in[17],R_in[16],R_in[15]
						   ,R_in[16],R_in[15],R_in[14],R_in[13]
						   ,R_in[12],R_in[11],R_in[12],R_in[11]
						   ,R_in[10],R_in[ 9],R_in[ 8],R_in[ 7]
						   ,R_in[ 8],R_in[ 7],R_in[ 6],R_in[ 5]
						   ,R_in[ 4],R_in[ 3],R_in[ 4],R_in[ 3]
						   ,R_in[ 2],R_in[ 1],R_in[ 0],R_in[31]};
// 48 bit XOR							   
wire [47:0]xor_out = key_in ^ expansion_out;

// xor_out divided to S1 ~ S8
wire [5:0]S1_in = xor_out[47:42];
wire [5:0]S2_in = xor_out[41:36];
wire [5:0]S3_in = xor_out[35:30];
wire [5:0]S4_in = xor_out[29:24];
wire [5:0]S5_in = xor_out[23:18];
wire [5:0]S6_in = xor_out[17:12];
wire [5:0]S7_in = xor_out[11: 6];
wire [5:0]S8_in = xor_out[ 5: 0];


// S Boxes
reg [3:0]S1_out;
reg [3:0]S2_out;
reg [3:0]S3_out;
reg [3:0]S4_out;
reg [3:0]S5_out;
reg [3:0]S6_out;
reg [3:0]S7_out;
reg [3:0]S8_out;
// S1
always@(*)begin
	case({S1_in[5], S1_in[0]})
		2'b00:begin
			case(S1_in[4:1])
				4'b0000: S1_out = 14;
				4'b0001: S1_out = 4;
				4'b0010: S1_out = 13;
				4'b0011: S1_out = 1;
				4'b0100: S1_out = 2;
				4'b0101: S1_out = 15;
				4'b0110: S1_out = 11;
				4'b0111: S1_out = 8;
				4'b1000: S1_out = 3;
				4'b1001: S1_out = 10;
				4'b1010: S1_out = 6;
				4'b1011: S1_out = 12;
				4'b1100: S1_out = 5;
				4'b1101: S1_out = 9;
				4'b1110: S1_out = 0;
				4'b1111: S1_out = 7;
			endcase
		end
		2'b01:begin
			case(S1_in[4:1])
				4'b0000: S1_out = 0;
				4'b0001: S1_out = 15;
				4'b0010: S1_out = 7;
				4'b0011: S1_out = 4;
				4'b0100: S1_out = 14;
				4'b0101: S1_out = 2;
				4'b0110: S1_out = 13;
				4'b0111: S1_out = 1;
				4'b1000: S1_out = 10;
				4'b1001: S1_out = 6;
				4'b1010: S1_out = 12;
				4'b1011: S1_out = 11;
				4'b1100: S1_out = 9;
				4'b1101: S1_out = 5;
				4'b1110: S1_out = 3;
				4'b1111: S1_out = 8;
			endcase
		end
		2'b10:begin
			case(S1_in[4:1])
				4'b0000: S1_out = 4;
				4'b0001: S1_out = 1;
				4'b0010: S1_out = 14;
				4'b0011: S1_out = 8;
				4'b0100: S1_out = 13;
				4'b0101: S1_out = 6;
				4'b0110: S1_out = 2;
				4'b0111: S1_out = 11;
				4'b1000: S1_out = 15;
				4'b1001: S1_out = 12;
				4'b1010: S1_out = 9;
				4'b1011: S1_out = 7;
				4'b1100: S1_out = 3;
				4'b1101: S1_out = 10;
				4'b1110: S1_out = 5;
				4'b1111: S1_out = 0;
			endcase
		end
		2'b11:begin
			case(S1_in[4:1])
				4'b0000: S1_out = 15;
				4'b0001: S1_out = 12;
				4'b0010: S1_out = 8;
				4'b0011: S1_out = 2;
				4'b0100: S1_out = 4;
				4'b0101: S1_out = 9;
				4'b0110: S1_out = 1;
				4'b0111: S1_out = 7;
				4'b1000: S1_out = 5;
				4'b1001: S1_out = 11;
				4'b1010: S1_out = 3;
				4'b1011: S1_out = 14;
				4'b1100: S1_out = 10;
				4'b1101: S1_out = 0;
				4'b1110: S1_out = 6;
				4'b1111: S1_out = 13;
			endcase
		end
	endcase
end
// S2
always@(*)begin
	case({S2_in[5], S2_in[0]})
		2'b00:begin
			case(S2_in[4:1])
				4'b0000: S2_out = 15;
				4'b0001: S2_out = 1;
				4'b0010: S2_out = 8;
				4'b0011: S2_out = 14;
				4'b0100: S2_out = 6;
				4'b0101: S2_out = 11;
				4'b0110: S2_out = 3;
				4'b0111: S2_out = 4;
				4'b1000: S2_out = 9;
				4'b1001: S2_out = 7;
				4'b1010: S2_out = 2;
				4'b1011: S2_out = 13;
				4'b1100: S2_out = 12;
				4'b1101: S2_out = 0;
				4'b1110: S2_out = 5;
				4'b1111: S2_out = 10;
			endcase
		end
		2'b01:begin
			case(S2_in[4:1])
				4'b0000: S2_out = 3;
				4'b0001: S2_out = 13;
				4'b0010: S2_out = 4;
				4'b0011: S2_out = 7;
				4'b0100: S2_out = 15;
				4'b0101: S2_out = 2;
				4'b0110: S2_out = 8;
				4'b0111: S2_out = 14;
				4'b1000: S2_out = 12;
				4'b1001: S2_out = 0;
				4'b1010: S2_out = 1;
				4'b1011: S2_out = 10;
				4'b1100: S2_out = 6;
				4'b1101: S2_out = 9;
				4'b1110: S2_out = 11;
				4'b1111: S2_out = 5;
			endcase
		end
		2'b10:begin
			case(S2_in[4:1])
				4'b0000: S2_out = 0;
				4'b0001: S2_out = 14;
				4'b0010: S2_out = 7;
				4'b0011: S2_out = 11;
				4'b0100: S2_out = 10;
				4'b0101: S2_out = 4;
				4'b0110: S2_out = 13;
				4'b0111: S2_out = 1;
				4'b1000: S2_out = 5;
				4'b1001: S2_out = 8;
				4'b1010: S2_out = 12;
				4'b1011: S2_out = 6;
				4'b1100: S2_out = 9;
				4'b1101: S2_out = 3;
				4'b1110: S2_out = 2;
				4'b1111: S2_out = 15;
			endcase
		end
		2'b11:begin
			case(S2_in[4:1])
				4'b0000: S2_out = 13;
				4'b0001: S2_out = 8;
				4'b0010: S2_out = 10;
				4'b0011: S2_out = 1;
				4'b0100: S2_out = 3;
				4'b0101: S2_out = 15;
				4'b0110: S2_out = 4;
				4'b0111: S2_out = 2;
				4'b1000: S2_out = 11;
				4'b1001: S2_out = 6;
				4'b1010: S2_out = 7;
				4'b1011: S2_out = 12;
				4'b1100: S2_out = 0;
				4'b1101: S2_out = 5;
				4'b1110: S2_out = 14;
				4'b1111: S2_out = 9;
			endcase
		end
	endcase
end
// S3
always@(*)begin
	case({S3_in[5], S3_in[0]})
		2'b00:begin
			case(S3_in[4:1])
				4'b0000: S3_out = 10;
				4'b0001: S3_out = 0;
				4'b0010: S3_out = 9;
				4'b0011: S3_out = 14;
				4'b0100: S3_out = 6;
				4'b0101: S3_out = 3;
				4'b0110: S3_out = 15;
				4'b0111: S3_out = 5;
				4'b1000: S3_out = 1;
				4'b1001: S3_out = 13;
				4'b1010: S3_out = 12;
				4'b1011: S3_out = 7;
				4'b1100: S3_out = 11;
				4'b1101: S3_out = 4;
				4'b1110: S3_out = 2;
				4'b1111: S3_out = 8;
			endcase
		end
		2'b01:begin
			case(S3_in[4:1])
				4'b0000: S3_out = 13;
				4'b0001: S3_out = 7;
				4'b0010: S3_out = 0;
				4'b0011: S3_out = 9;
				4'b0100: S3_out = 3;
				4'b0101: S3_out = 4;
				4'b0110: S3_out = 6;
				4'b0111: S3_out = 10;
				4'b1000: S3_out = 2;
				4'b1001: S3_out = 8;
				4'b1010: S3_out = 5;
				4'b1011: S3_out = 14;
				4'b1100: S3_out = 12;
				4'b1101: S3_out = 11;
				4'b1110: S3_out = 15;
				4'b1111: S3_out = 1;
			endcase
		end
		2'b10:begin
			case(S3_in[4:1])
				4'b0000: S3_out = 13;
				4'b0001: S3_out = 6;
				4'b0010: S3_out = 4;
				4'b0011: S3_out = 9;
				4'b0100: S3_out = 8;
				4'b0101: S3_out = 15;
				4'b0110: S3_out = 3;
				4'b0111: S3_out = 0;
				4'b1000: S3_out = 11;
				4'b1001: S3_out = 1;
				4'b1010: S3_out = 2;
				4'b1011: S3_out = 12;
				4'b1100: S3_out = 5;
				4'b1101: S3_out = 10;
				4'b1110: S3_out = 14;
				4'b1111: S3_out = 7;
			endcase
		end
		2'b11:begin
			case(S3_in[4:1])
				4'b0000: S3_out = 1;
				4'b0001: S3_out = 10;
				4'b0010: S3_out = 13;
				4'b0011: S3_out = 0;
				4'b0100: S3_out = 6;
				4'b0101: S3_out = 9;
				4'b0110: S3_out = 8;
				4'b0111: S3_out = 7;
				4'b1000: S3_out = 4;
				4'b1001: S3_out = 15;
				4'b1010: S3_out = 14;
				4'b1011: S3_out = 3;
				4'b1100: S3_out = 11;
				4'b1101: S3_out = 5;
				4'b1110: S3_out = 2;
				4'b1111: S3_out = 12;
			endcase
		end
	endcase
end
// S4
always@(*)begin
	case({S4_in[5], S4_in[0]})
		2'b00:begin
			case(S4_in[4:1])
				4'b0000: S4_out = 7;
				4'b0001: S4_out = 13;
				4'b0010: S4_out = 14;
				4'b0011: S4_out = 3;
				4'b0100: S4_out = 0;
				4'b0101: S4_out = 6;
				4'b0110: S4_out = 9;
				4'b0111: S4_out = 10;
				4'b1000: S4_out = 1;
				4'b1001: S4_out = 2;
				4'b1010: S4_out = 8;
				4'b1011: S4_out = 5;
				4'b1100: S4_out = 11;
				4'b1101: S4_out = 12;
				4'b1110: S4_out = 4;
				4'b1111: S4_out = 15;
			endcase
		end
		2'b01:begin
			case(S4_in[4:1])
				4'b0000: S4_out = 13;
				4'b0001: S4_out = 8;
				4'b0010: S4_out = 11;
				4'b0011: S4_out = 5;
				4'b0100: S4_out = 6;
				4'b0101: S4_out = 15;
				4'b0110: S4_out = 0;
				4'b0111: S4_out = 3;
				4'b1000: S4_out = 4;
				4'b1001: S4_out = 7;
				4'b1010: S4_out = 2;
				4'b1011: S4_out = 12;
				4'b1100: S4_out = 1;
				4'b1101: S4_out = 10;
				4'b1110: S4_out = 14;
				4'b1111: S4_out = 9;
			endcase
		end
		2'b10:begin
			case(S4_in[4:1])
				4'b0000: S4_out = 10;
				4'b0001: S4_out = 6;
				4'b0010: S4_out = 9;
				4'b0011: S4_out = 0;
				4'b0100: S4_out = 12;
				4'b0101: S4_out = 11;
				4'b0110: S4_out = 7;
				4'b0111: S4_out = 13;
				4'b1000: S4_out = 15;
				4'b1001: S4_out = 1;
				4'b1010: S4_out = 3;
				4'b1011: S4_out = 14;
				4'b1100: S4_out = 5;
				4'b1101: S4_out = 2;
				4'b1110: S4_out = 8;
				4'b1111: S4_out = 4;
			endcase
		end
		2'b11:begin
			case(S4_in[4:1])
				4'b0000: S4_out = 3;
				4'b0001: S4_out = 15;
				4'b0010: S4_out = 0;
				4'b0011: S4_out = 6;
				4'b0100: S4_out = 10;
				4'b0101: S4_out = 1;
				4'b0110: S4_out = 13;
				4'b0111: S4_out = 8;
				4'b1000: S4_out = 9;
				4'b1001: S4_out = 4;
				4'b1010: S4_out = 5;
				4'b1011: S4_out = 11;
				4'b1100: S4_out = 12;
				4'b1101: S4_out = 7;
				4'b1110: S4_out = 2;
				4'b1111: S4_out = 14;
			endcase
		end
	endcase
end
// S5
always@(*)begin
	case({S5_in[5], S5_in[0]})
		2'b00:begin
			case(S5_in[4:1])
				4'b0000: S5_out = 2;
				4'b0001: S5_out = 12;
				4'b0010: S5_out = 4;
				4'b0011: S5_out = 1;
				4'b0100: S5_out = 7;
				4'b0101: S5_out = 10;
				4'b0110: S5_out = 11;
				4'b0111: S5_out = 6;
				4'b1000: S5_out = 8;
				4'b1001: S5_out = 5;
				4'b1010: S5_out = 3;
				4'b1011: S5_out = 15;
				4'b1100: S5_out = 13;
				4'b1101: S5_out = 0;
				4'b1110: S5_out = 14;
				4'b1111: S5_out = 9;
			endcase
		end
		2'b01:begin
			case(S5_in[4:1])
				4'b0000: S5_out = 14;
				4'b0001: S5_out = 11;
				4'b0010: S5_out = 2;
				4'b0011: S5_out = 12;
				4'b0100: S5_out = 4;
				4'b0101: S5_out = 7;
				4'b0110: S5_out = 13;
				4'b0111: S5_out = 1;
				4'b1000: S5_out = 5;
				4'b1001: S5_out = 0;
				4'b1010: S5_out = 15;
				4'b1011: S5_out = 10;
				4'b1100: S5_out = 3;
				4'b1101: S5_out = 9;
				4'b1110: S5_out = 8;
				4'b1111: S5_out = 6;
			endcase
		end
		2'b10:begin
			case(S5_in[4:1])
				4'b0000: S5_out = 4;
				4'b0001: S5_out = 2;
				4'b0010: S5_out = 1;
				4'b0011: S5_out = 11;
				4'b0100: S5_out = 10;
				4'b0101: S5_out = 13;
				4'b0110: S5_out = 7;
				4'b0111: S5_out = 8;
				4'b1000: S5_out = 15;
				4'b1001: S5_out = 9;
				4'b1010: S5_out = 12;
				4'b1011: S5_out = 5;
				4'b1100: S5_out = 6;
				4'b1101: S5_out = 3;
				4'b1110: S5_out = 0;
				4'b1111: S5_out = 14;
			endcase
		end
		2'b11:begin
			case(S5_in[4:1])
				4'b0000: S5_out = 11;
				4'b0001: S5_out = 8;
				4'b0010: S5_out = 12;
				4'b0011: S5_out = 7;
				4'b0100: S5_out = 1;
				4'b0101: S5_out = 14;
				4'b0110: S5_out = 2;
				4'b0111: S5_out = 13;
				4'b1000: S5_out = 6;
				4'b1001: S5_out = 15;
				4'b1010: S5_out = 0;
				4'b1011: S5_out = 9;
				4'b1100: S5_out = 10;
				4'b1101: S5_out = 4;
				4'b1110: S5_out = 5;
				4'b1111: S5_out = 3;
			endcase
		end
	endcase
end
// S6
always@(*)begin
	case({S6_in[5], S6_in[0]})
		2'b00:begin
			case(S6_in[4:1])
				4'b0000: S6_out = 12;
				4'b0001: S6_out = 1;
				4'b0010: S6_out = 10;
				4'b0011: S6_out = 15;
				4'b0100: S6_out = 9;
				4'b0101: S6_out = 2;
				4'b0110: S6_out = 6;
				4'b0111: S6_out = 8;
				4'b1000: S6_out = 0;
				4'b1001: S6_out = 13;
				4'b1010: S6_out = 3;
				4'b1011: S6_out = 4;
				4'b1100: S6_out = 14;
				4'b1101: S6_out = 7;
				4'b1110: S6_out = 5;
				4'b1111: S6_out = 11;
			endcase
		end
		2'b01:begin
			case(S6_in[4:1])
				4'b0000: S6_out = 10;
				4'b0001: S6_out = 15;
				4'b0010: S6_out = 4;
				4'b0011: S6_out = 2;
				4'b0100: S6_out = 7;
				4'b0101: S6_out = 12;
				4'b0110: S6_out = 9;
				4'b0111: S6_out = 5;
				4'b1000: S6_out = 6;
				4'b1001: S6_out = 1;
				4'b1010: S6_out = 13;
				4'b1011: S6_out = 14;
				4'b1100: S6_out = 0;
				4'b1101: S6_out = 11;
				4'b1110: S6_out = 3;
				4'b1111: S6_out = 8;
			endcase
		end
		2'b10:begin
			case(S6_in[4:1])
				4'b0000: S6_out = 9;
				4'b0001: S6_out = 14;
				4'b0010: S6_out = 15;
				4'b0011: S6_out = 5;
				4'b0100: S6_out = 2;
				4'b0101: S6_out = 8;
				4'b0110: S6_out = 12;
				4'b0111: S6_out = 3;
				4'b1000: S6_out = 7;
				4'b1001: S6_out = 0;
				4'b1010: S6_out = 4;
				4'b1011: S6_out = 10;
				4'b1100: S6_out = 1;
				4'b1101: S6_out = 13;
				4'b1110: S6_out = 11;
				4'b1111: S6_out = 6;
			endcase
		end
		2'b11:begin
			case(S6_in[4:1])
				4'b0000: S6_out = 4;
				4'b0001: S6_out = 3;
				4'b0010: S6_out = 2;
				4'b0011: S6_out = 12;
				4'b0100: S6_out = 9;
				4'b0101: S6_out = 5;
				4'b0110: S6_out = 15;
				4'b0111: S6_out = 10;
				4'b1000: S6_out = 11;
				4'b1001: S6_out = 14;
				4'b1010: S6_out = 1;
				4'b1011: S6_out = 7;
				4'b1100: S6_out = 6;
				4'b1101: S6_out = 0;
				4'b1110: S6_out = 8;
				4'b1111: S6_out = 13;
			endcase
		end
	endcase
end
// S7
always@(*)begin
	case({S7_in[5], S7_in[0]})
		2'b00:begin
			case(S7_in[4:1])
				4'b0000: S7_out = 4;
				4'b0001: S7_out = 11;
				4'b0010: S7_out = 2;
				4'b0011: S7_out = 14;
				4'b0100: S7_out = 15;
				4'b0101: S7_out = 0;
				4'b0110: S7_out = 8;
				4'b0111: S7_out = 13;
				4'b1000: S7_out = 3;
				4'b1001: S7_out = 12;
				4'b1010: S7_out = 9;
				4'b1011: S7_out = 7;
				4'b1100: S7_out = 5;
				4'b1101: S7_out = 10;
				4'b1110: S7_out = 6;
				4'b1111: S7_out = 1;
			endcase
		end
		2'b01:begin
			case(S7_in[4:1])
				4'b0000: S7_out = 13;
				4'b0001: S7_out = 0;
				4'b0010: S7_out = 11;
				4'b0011: S7_out = 7;
				4'b0100: S7_out = 4;
				4'b0101: S7_out = 9;
				4'b0110: S7_out = 1;
				4'b0111: S7_out = 10;
				4'b1000: S7_out = 14;
				4'b1001: S7_out = 3;
				4'b1010: S7_out = 5;
				4'b1011: S7_out = 12;
				4'b1100: S7_out = 2;
				4'b1101: S7_out = 15;
				4'b1110: S7_out = 8;
				4'b1111: S7_out = 6;
			endcase
		end
		2'b10:begin
			case(S7_in[4:1])
				4'b0000: S7_out = 1;
				4'b0001: S7_out = 4;
				4'b0010: S7_out = 11;
				4'b0011: S7_out = 13;
				4'b0100: S7_out = 12;
				4'b0101: S7_out = 3;
				4'b0110: S7_out = 7;
				4'b0111: S7_out = 14;
				4'b1000: S7_out = 10;
				4'b1001: S7_out = 15;
				4'b1010: S7_out = 6;
				4'b1011: S7_out = 8;
				4'b1100: S7_out = 0;
				4'b1101: S7_out = 5;
				4'b1110: S7_out = 9;
				4'b1111: S7_out = 2;
			endcase
		end
		2'b11:begin
			case(S7_in[4:1])
				4'b0000: S7_out = 6;
				4'b0001: S7_out = 11;
				4'b0010: S7_out = 13;
				4'b0011: S7_out = 8;
				4'b0100: S7_out = 1;
				4'b0101: S7_out = 4;
				4'b0110: S7_out = 10;
				4'b0111: S7_out = 7;
				4'b1000: S7_out = 9;
				4'b1001: S7_out = 5;
				4'b1010: S7_out = 0;
				4'b1011: S7_out = 15;
				4'b1100: S7_out = 14;
				4'b1101: S7_out = 2;
				4'b1110: S7_out = 3;
				4'b1111: S7_out = 12;
			endcase
		end
	endcase
end
// S8
always@(*)begin
	case({S8_in[5], S8_in[0]})
		2'b00:begin
			case(S8_in[4:1])
				4'b0000: S8_out = 13;
				4'b0001: S8_out = 2;
				4'b0010: S8_out = 8;
				4'b0011: S8_out = 4;
				4'b0100: S8_out = 6;
				4'b0101: S8_out = 15;
				4'b0110: S8_out = 11;
				4'b0111: S8_out = 1;
				4'b1000: S8_out = 10;
				4'b1001: S8_out = 9;
				4'b1010: S8_out = 3;
				4'b1011: S8_out = 14;
				4'b1100: S8_out = 5;
				4'b1101: S8_out = 0;
				4'b1110: S8_out = 12;
				4'b1111: S8_out = 7;
			endcase
		end
		2'b01:begin
			case(S8_in[4:1])
				4'b0000: S8_out = 1;
				4'b0001: S8_out = 15;
				4'b0010: S8_out = 13;
				4'b0011: S8_out = 8;
				4'b0100: S8_out = 10;
				4'b0101: S8_out = 3;
				4'b0110: S8_out = 7;
				4'b0111: S8_out = 4;
				4'b1000: S8_out = 12;
				4'b1001: S8_out = 5;
				4'b1010: S8_out = 6;
				4'b1011: S8_out = 11;
				4'b1100: S8_out = 0;
				4'b1101: S8_out = 14;
				4'b1110: S8_out = 9;
				4'b1111: S8_out = 2;
			endcase
		end
		2'b10:begin
			case(S8_in[4:1])
				4'b0000: S8_out = 7;
				4'b0001: S8_out = 11;
				4'b0010: S8_out = 4;
				4'b0011: S8_out = 1;
				4'b0100: S8_out = 9;
				4'b0101: S8_out = 12;
				4'b0110: S8_out = 14;
				4'b0111: S8_out = 2;
				4'b1000: S8_out = 0;
				4'b1001: S8_out = 6;
				4'b1010: S8_out = 10;
				4'b1011: S8_out = 13;
				4'b1100: S8_out = 15;
				4'b1101: S8_out = 3;
				4'b1110: S8_out = 5;
				4'b1111: S8_out = 8;
			endcase
		end
		2'b11:begin
			case(S8_in[4:1])
				4'b0000: S8_out = 2;
				4'b0001: S8_out = 1;
				4'b0010: S8_out = 14;
				4'b0011: S8_out = 7;
				4'b0100: S8_out = 4;
				4'b0101: S8_out = 10;
				4'b0110: S8_out = 8;
				4'b0111: S8_out = 13;
				4'b1000: S8_out = 15;
				4'b1001: S8_out = 12;
				4'b1010: S8_out = 9;
				4'b1011: S8_out = 0;
				4'b1100: S8_out = 3;
				4'b1101: S8_out = 5;
				4'b1110: S8_out = 6;
				4'b1111: S8_out = 11;
			endcase
		end
	endcase
end


// P
wire [31:0]P_in = {S1_out,S2_out,S3_out,S4_out,S5_out,S6_out,S7_out,S8_out};
assign F_out = {P_in[16],P_in[25],P_in[12],P_in[11]
			   ,P_in[ 3],P_in[20],P_in[ 4],P_in[15]
			   ,P_in[31],P_in[17],P_in[ 9],P_in[ 6]
			   ,P_in[27],P_in[14],P_in[ 1],P_in[22]
			   ,P_in[30],P_in[24],P_in[ 8],P_in[18]
			   ,P_in[ 0],P_in[ 5],P_in[29],P_in[23]
			   ,P_in[13],P_in[19],P_in[ 2],P_in[26]
			   ,P_in[10],P_in[21],P_in[28],P_in[ 7]};




endmodule