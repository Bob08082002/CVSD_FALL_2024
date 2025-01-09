// To store input point P or pre-calculated LUT
module LUTFile(
    input clk,
    input rst,
    input [254:0] X_in_data,
    input [254:0] Y_in_data,
    input [254:0] Z_in_data,
    input [254:0] T_in_data,
    input X_we,
    input Y_we,
    input Z_we,
    input T_we,
    output[254:0] X_out_data,
    output[254:0] Y_out_data,
    output[254:0] Z_out_data,
    output[254:0] T_out_data
);

    reg [254:0] X_lut, Y_lut, Z_lut, T_lut; 
    wire [254:0] X_w, Y_w, Z_w, T_w;

    assign X_w = (X_we)? X_in_data : X_lut;
    assign Y_w = (Y_we)? Y_in_data : Y_lut;
    assign Z_w = (Z_we)? Z_in_data : Z_lut;
    assign T_w = (T_we)? T_in_data : T_lut;

    //output assignment
    assign X_out_data = X_lut;
    assign Y_out_data = Y_lut;
    assign Z_out_data = Z_lut;
    assign T_out_data = T_lut;

    //sequential part
    always@(posedge clk)begin
		// Extended representation: X_lut = x, Y_lut = y, Z_lut = 1, T_lut = X_lut*Y_lut
		// after pre-calculation: X_lut = A2_lut = Y_lut - X_lut, Y_lut = B2_lut = Y_lut + X_lut, Z_lut = 1, T_lut = Td_lut = X_lut*Y_lut*d
        if(rst)begin   
            X_lut <= 0;
            Y_lut <= 0;
            Z_lut <= 1; // init to 1
            T_lut <= 0;
        end
        else begin
            X_lut <= X_w;
            Y_lut <= Y_w;
            Z_lut <= Z_w;
            T_lut <= T_w;
        end
    end
endmodule