// IEEE 754 Single-Precision Comparater
// input: normal, subnormal, signed zero
// output: if operand_A < operand_B, then less_than_flag = 1, else less_than_flag = 0
// Do not consider cases which input is INF or Nan. These cases will raise INVALID.

module FPU_cmp(less_than_flag, operand_A, operand_B); 

input [31:0]operand_A;
input [31:0]operand_B;
output reg less_than_flag; // if operand_A < operand_B, then less_than_flag = 1, else less_than_flag = 0


// From signed zero to positive zero(only exist one zero, positive zero)
wire [31:0]operand_A_unsign_zero, operand_B_unsign_zero;
assign operand_A_unsign_zero = (operand_A[30:0] == 31'b0)? 32'b0 : operand_A; // convert neg zero or pos zero to pos zero
assign operand_B_unsign_zero = (operand_B[30:0] == 31'b0)? 32'b0 : operand_B;

// Check if operand is subnormal number
wire Is_A_Subnorm = (operand_A[30:23] == 8'b0 && operand_A[22:0] != 23'b0);
wire Is_B_Subnorm = (operand_B[30:23] == 8'b0 && operand_B[22:0] != 23'b0);

// Get the bias 127 exponent of two operands
wire [7:0] exp_A = (Is_A_Subnorm)?  8'd1 :operand_A[30:23]; //if is a subnormal number, assign its e = 1, so 1 - 127 = -126//unsigned exp_A is bias 127
wire [7:0] exp_B = (Is_B_Subnorm)?  8'd1 :operand_B[30:23];

// Recover the original mantissa(add implicit one of normal number)
wire [23:0]unsign_mantissa_A = (Is_A_Subnorm || operand_A_unsign_zero == 32'b0)? {1'b0, operand_A[22:0]} : {1'b1,operand_A[22:0]};//1'b1: 1 is leading one
wire [23:0]unsign_mantissa_B = (Is_B_Subnorm || operand_B_unsign_zero == 32'b0)? {1'b0, operand_B[22:0]} : {1'b1,operand_B[22:0]};//1'b1: 1 is leading one

always@(*)begin
	less_than_flag = 1'b0; // default value
	
	if(operand_A_unsign_zero[31] == 1'b1 && operand_B_unsign_zero[31] == 1'b0)begin // A < 0, B > 0 ==> A < B
		less_than_flag = 1'b1;
	end
	else if(operand_A_unsign_zero[31] == 1'b0 && operand_B_unsign_zero[31] == 1'b1)begin // A > 0, B < 0 ==> A > B
		less_than_flag = 1'b0;
	end
	else begin // same sign bit, ie operand_A_unsign_zero[31] == operand_B_unsign_zero[31]
	
		if(exp_A < exp_B)begin // if A, B positive, then A < B. else A > B
			less_than_flag = !operand_A_unsign_zero[31];
		end
		else if(exp_A > exp_B)begin // if A, B positive, then A > B. else A < B
			less_than_flag = operand_A_unsign_zero[31];
		end
		else begin // A, B has same exp
		
			if(unsign_mantissa_A < unsign_mantissa_B)begin // if A, B positive, then A < B. else A > B
				less_than_flag = !operand_A_unsign_zero[31];
			end
			else if(unsign_mantissa_A > unsign_mantissa_B)begin // if A, B positive, then A > B. else A < B
				less_than_flag = operand_A_unsign_zero[31];
			end
			else begin // A, B has same mantissa //A == B
				less_than_flag = 1'b0;
			end
			
		end
		
	end
end


endmodule

