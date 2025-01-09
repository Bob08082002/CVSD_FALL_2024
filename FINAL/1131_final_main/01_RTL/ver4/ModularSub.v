module ModularSub(    
    input [254:0] X,
    input [254:0] Y,
    output [254:0] Result 
);

   wire [255:0] x_sub_y;
   wire [255:0] x_add_q_sub_y;

   assign x_sub_y = X - Y;  // X - Y
   assign x_add_q_sub_y = x_sub_y + `Q; // X - Y + `Q
   assign Result = (x_sub_y[255])? x_add_q_sub_y[254:0]:x_sub_y[254:0]; // if X - Y < 0, Result = X - Y + `Q, else Result = X - Y

endmodule