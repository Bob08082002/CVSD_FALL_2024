module ModularAdd(
    input [254:0] X,
    input [254:0] Y,
    output [254:0] Result 
);

   wire [255:0] x_add_y;
   wire [255:0] x_add_y_sub_q;

   assign x_add_y = X + Y; // X + Y
   assign x_add_y_sub_q = x_add_y - `Q;  // X + Y - q
   assign Result = (x_add_y_sub_q[255])? x_add_y[254:0] : x_add_y_sub_q[254:0]; // if X + Y - q < 0, Result = X + Y, else Result = X + Y - q

endmodule