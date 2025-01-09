//`include "define.v"
module mux_2to1 #( 
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) ( 
	input [31:0] A, 
	input [31:0] B,    
	input sel, 
	output [31:0] mux_OUT
);

assign mux_OUT = (sel)? B: A; 

endmodule