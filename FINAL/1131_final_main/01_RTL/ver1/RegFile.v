// To store accumulation result
module RegFile(
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
    output [254:0]X_out_data,
    output [254:0]Y_out_data,
    output [254:0]Z_out_data,
    output [254:0]T_out_data
);

    reg [254:0] X_reg, Y_reg, Z_reg, T_reg; 
    wire [254:0] X_w, Y_w, Z_w, T_w;

    assign X_w = (X_we)? X_in_data : X_reg;
    assign Y_w = (Y_we)? Y_in_data : Y_reg;
    assign Z_w = (Z_we)? Z_in_data : Z_reg;
    assign T_w = (T_we)? T_in_data : T_reg;

    //output assignment
    assign X_out_data = X_reg;
    assign Y_out_data = Y_reg;
    assign Z_out_data = Z_reg;
    assign T_out_data = T_reg;

    //sequential part
    always@(posedge clk)begin
        if(rst)begin   // Double and Add method: zero point
            X_reg <= 0;
            Y_reg <= 1;
            Z_reg <= 1;
            T_reg <= 0;
        end
        else begin
            X_reg <= X_w;
            Y_reg <= Y_w;
            Z_reg <= Z_w;
            T_reg <= T_w;
        end
    end
endmodule