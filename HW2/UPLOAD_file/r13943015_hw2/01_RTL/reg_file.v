//`include "define.v"
// integer reg file & floating point number reg file
module reg_file #( 
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) ( 
	input i_clk,
    input i_rst_n,
	
	input wen,
	input [4:0] read_index_1,
	input [4:0] read_index_2,
	input [4:0] dest_index,
	input  [DATA_WIDTH-1:0] wb_data,
	output [DATA_WIDTH-1:0] read_data_out_1,
	output [DATA_WIDTH-1:0] read_data_out_2
);

// reg file(with 32 registers)
reg [DATA_WIDTH-1:0] registers [0:31];

integer i;

// always read
assign	read_data_out_1 = registers[read_index_1];
assign	read_data_out_2 = registers[read_index_2];


always@(posedge i_clk or negedge i_rst_n)begin
	if(~i_rst_n)begin
		for(i = 0; i < 32; i=i+1)begin //register file to be zero when i_rst_n is low
			registers[i] <= 0;
		end
	end
	else begin
		if(wen)begin // allow to write back reg file only if wen = 1
			registers[dest_index] <= wb_data;
		end
	end
end















endmodule


