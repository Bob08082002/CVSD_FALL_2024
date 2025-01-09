`define ONE_OVER_NINE 477218588 //(0.32), 1/9*2^32 ~= 477218588 //Decimal constant max length = 32
`define ONE_OVER_THREE 1431655765 //(0.32), 1/3*2^32 ~= 1431655765

module alu #(
    parameter INST_W = 4,
    parameter INT_W  = 6,
    parameter FRAC_W = 10,
    parameter DATA_W = INT_W + FRAC_W
)(
    input                      i_clk,
    input                      i_rst_n,

    input                      i_in_valid,
    output                     o_busy,
    input         [INST_W-1:0] i_inst,
    input  signed [DATA_W-1:0] i_data_a,
    input  signed [DATA_W-1:0] i_data_b,

    output                     o_out_valid,
    output        [DATA_W-1:0] o_data
);


// ------------------------------------------------------------------
// Local Parameters
// ------------------------------------------------------------------
// can't be modified by param redefinition(defparam or #(.localparam(2)) -> verilog 2001)
localparam RESET = 4'd0, WAIT_INPUT = 4'd1, CAL = 4'd2, SENT_OUTPUT = 4'd3;



// ------------------------------------------------------------------
// Wires and Regs
// ------------------------------------------------------------------
reg signed[19:0] data_acc_r[15:0]; //must not exceed 20 bits
reg signed[19:0] data_acc_w[15:0]; //must not exceed 20 bits
reg [3:0]st, nst;
integer i;

//input registers & wire
reg         [INST_W-1:0] i_inst_r, i_inst_w;
reg  signed [DATA_W-1:0] i_data_a_r, i_data_a_w;
reg  signed [DATA_W-1:0] i_data_b_r, i_data_b_w;


//output flipflop & wire(next-output)
reg o_busy_r, o_busy_w;
reg o_out_valid_r, o_out_valid_w;
reg [DATA_W-1:0] o_data_r, o_data_w;

//wires //temperal wire in combinational block
reg signed[2*DATA_W-1 : 0] mul_before_round;//(12.20)
reg signed[2*DATA_W-FRAC_W : 0] result_before_sat;//(13.10)
reg signed[DATA_W+1 : 0]Numerator; //(8.10)//for (2x+2), (x+2), (2x+5), (x+3)
reg signed [DATA_W+1+32 : 0]result_before_round; //(8.10) * (0.32) = (8.42)
reg signed[2*DATA_W-1 : 0]i_data_a_concate_twice; 

//Regs
reg [3:0]cnt15_r, cnt15_w;

// ------------------------------------------------------------------
// Combinational Circuit
// ------------------------------------------------------------------
//Continuous Assignment(outputs connect to output FF)
assign o_busy = o_busy_r;
assign o_out_valid = o_out_valid_r;
assign o_data = o_data_r;


//Next State Logic
always@(*)begin
	case(st)
	RESET: nst = WAIT_INPUT;
	
	WAIT_INPUT: 
		if(i_in_valid) nst = CAL;
		else nst = WAIT_INPUT;
	
	CAL: 
		if(i_inst_r!=4'b1000 || cnt15_r == 4'd0 || i_data_a_r[cnt15_r]!=1'b0) nst = SENT_OUTPUT;
		else nst = CAL;
	
	SENT_OUTPUT: nst = WAIT_INPUT;

	default: nst = RESET;
	
	endcase
end

//Next Output Logic(generate XXX_w)
always@(*)begin //input registers
	//given default value
	i_inst_w = i_inst_r;
	i_data_a_w = i_data_a_r;
	i_data_b_w = i_data_b_r;
	
	if(st == WAIT_INPUT) begin
		i_inst_w = i_inst;
		i_data_a_w = i_data_a;
		i_data_b_w = i_data_b;
	end
end

always@(*)begin //o_busy_w //if state is WAIT_INPUT, then o_busy_r is low
	if(st == RESET || st == SENT_OUTPUT || (st == WAIT_INPUT && !i_in_valid)) //!i_in_valid --> mealy machine
		o_busy_w = 1'b0;
	else 
		o_busy_w = 1'b1;
end

always@(*)begin //o_out_valid_w //if state is SENT_OUTPUT, then o_out_valid_r is high
	if(st == CAL && nst == SENT_OUTPUT)
		o_out_valid_w = 1'b1;
	else 
		o_out_valid_w = 1'b0;
end

always@(*)begin // cnt15_w // count down
	if(st == WAIT_INPUT)cnt15_w = 4'd15;
	else if(st == CAL)cnt15_w = cnt15_r - 4'b1;
	else cnt15_w = cnt15_r;
end


// saturation function
function automatic [DATA_W-1:0]Saturation; //(6.10)
	input signed[2*DATA_W-FRAC_W:0]result_before_sat; //(13.10)
	begin
		// clamp to 16 bits range
		if(result_before_sat > 32767) Saturation = 32767;
		else if(result_before_sat < -32768) Saturation = -32768;
		else Saturation = result_before_sat[DATA_W-1:0];
	end
endfunction



always@(*)begin //o_data_w//data_acc_w
	// give default value
	o_data_w = 0;
	for(i = 0; i < 16; i = i + 1)begin
		data_acc_w[i] = data_acc_r[i];
	end
	
	if(st == CAL)begin
		case(i_inst_r)
		4'b0000, 4'b0001:begin //Signed Addition and Substraction
			if(i_inst_r == 4'b0000) //add
				result_before_sat = i_data_a_r + i_data_b_r; //result_before_sat is 17 bit signed number.
			else //sub
				result_before_sat = i_data_a_r - i_data_b_r; //result_before_sat is 17 bit signed number.(7.10)
				
			// saturation
			o_data_w = Saturation(result_before_sat);
		end
		
		4'b0010: begin //Signed Multiplication
			mul_before_round = i_data_a_r * i_data_b_r; //mul_before_round is 32 bit signed number(12.20). // (6.10) * (6.10) = (12.20)
			
			//round to nearest //result_before_sat is 23 bit signed number(13.10). prevent overflow // part-select --> unsigned number --> need manual signed extention
			result_before_sat = {mul_before_round[2*DATA_W-1], mul_before_round[2*DATA_W-1 : FRAC_W]} + mul_before_round[FRAC_W-1]; 
			// saturation
			o_data_w = Saturation(result_before_sat);
		end
		4'b0011: begin //Signed Accumulation
			data_acc_w[i_data_a_r[3:0]] = data_acc_r[i_data_a_r[3:0]] + i_data_b_r; //(10.10) = (10.10) + (6.10)//all operands are signed
			result_before_sat = data_acc_w[i_data_a_r[3:0]];
			
			// saturation
			o_data_w = Saturation(result_before_sat);
		end
		4'b0100: begin //Softplus
		
			if(i_data_a_r >= 2048)begin //2048 = 2 * 2^10
				result_before_round = {{2{i_data_a_r[DATA_W-1]}}, i_data_a_r, {32{1'b0}}}; //(6.10) to (8.42)//concate --> unsigned number --> need manual signed extention
			end
			else if(i_data_a_r >= 0)begin //0 = 0 * 2^10
				Numerator = i_data_a_r*2 + 2048;
				result_before_round = Numerator * `ONE_OVER_THREE; //(8.10) * (0.32) = (8.42)
			end
			else if(i_data_a_r >= -1024)begin //-1024 = -1 * 2^10
				Numerator = i_data_a_r + 2048;
				result_before_round = Numerator * `ONE_OVER_THREE; //(8.10) * (0.32) = (8.42)
			end
			else if(i_data_a_r >= -2048)begin //-2048 = -2 * 2^10
				Numerator = i_data_a_r*2 + 5120;
				result_before_round = Numerator * `ONE_OVER_NINE; //(8.10) * (0.32) = (8.42)
			end
			else if(i_data_a_r >= -3072)begin //-3072 = -3 * 2^10
				Numerator = i_data_a_r + 3072;
				result_before_round = Numerator * `ONE_OVER_NINE; //(8.10) * (0.32) = (8.42)
			end
			else begin
				result_before_round = 0;//(8.42)
			end
			
			//round to nearest //result_before_sat is (13.10)// part-select --> unsigned number --> need manual signed extention
			result_before_sat = {{5{result_before_round[DATA_W+1+32]}}, result_before_round[DATA_W+1+32 : 32]} + result_before_round[31]; 
			// saturation
			o_data_w = Saturation(result_before_sat);
		end
		
		4'b0101: begin //XOR
			o_data_w = i_data_a_r ^ i_data_b_r;
		end
		4'b0110: begin //arithmetic right shift(ASR)
			o_data_w = i_data_a_r >>> i_data_b_r;
		end
		4'b0111: begin //left rotation
			i_data_a_concate_twice = {i_data_a_r, i_data_a_r};
			o_data_w = i_data_a_concate_twice[(2*DATA_W - 1 - i_data_b_r[4:0]) -:DATA_W];
		end
		4'b1000: begin //counting leading zeros
			if(i_data_a_r[cnt15_r]==1'b1)
				o_data_w = 15 - cnt15_r; 
			else if(i_data_a_r[cnt15_r]==1'b0 && cnt15_r == 4'd0)
				o_data_w = 16;
		end
		4'b1001: begin //reverse match 4
			for(i = 0; i <= (DATA_W-4); i = i + 1)
				o_data_w[i] = (i_data_a_r[i +: 4] == i_data_b_r[(DATA_W-1-i) -: 4]);
		end
		default:begin //error W71 even though default value is given 
			o_data_w = 0;
			for(i = 0; i < 16; i = i + 1)begin
				data_acc_w[i] = data_acc_r[i];
			end
		end
		endcase
	end

end








// ------------------------------------------------------------------
// Sequential Blocks
// ------------------------------------------------------------------
//state
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n) st <= RESET;
	else st <= nst;
end
//output FF
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin
		o_busy_r <= 1'b1;
		o_out_valid_r <= 1'b0;
		o_data_r <= 0;
	end
	else begin
		o_busy_r <= o_busy_w;
		o_out_valid_r <= o_out_valid_w;
		o_data_r <= o_data_w;
	end
end
//input FF
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin
		i_inst_r <= 0;
		i_data_a_r <= 0;
		i_data_b_r <= 0;
	end
	else begin
	    i_inst_r <= i_inst_w;
		i_data_a_r <= i_data_a_w;
		i_data_b_r <= i_data_b_w;
	end
end
//accum_array & counter
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin
		for(i = 0; i < 16; i = i + 1)begin
			data_acc_r[i] <= 20'b0;
		end
		cnt15_r <= 4'd15;
	end
	else begin
	    for(i = 0; i < 16; i = i + 1)begin
			data_acc_r[i] <= data_acc_w[i];
		end
		cnt15_r <= cnt15_w;
	end
end




endmodule
