/*`include "controller.v"
`include "program_counter.v"
`include "imm_ext.v"
`include "decoder.v"
`include "reg_file.v"
`include "alu.v"
`include "FPU_add_sub.v"
`include "FPU_cmp.v"
`include "mux_2to1.v"
`include "Reg_N.v"
`include "Reg_I.v"
`include "Reg_D.v"
`include "Reg_A.v"
`include "define.v"
*/
module core #( // DO NOT MODIFY INTERFACE!!!
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) ( 
    input i_clk,
    input i_rst_n,

    // Testbench IOs
    output [2:0] o_status,       //ok
    output       o_status_valid, //ok

    // Memory IOs
    output [ADDR_WIDTH-1:0] o_addr, //ok
    output [DATA_WIDTH-1:0] o_wdata, //ok
    output                  o_we, //ok
    input  [DATA_WIDTH-1:0] i_rdata  //ok
);

// ---------------------------------------------------------------------------
// Wires for module connection
// ---------------------------------------------------------------------------
wire branch_flag; // controller to program_counter
wire invalid_pc;  //  program_counter to controller
wire [ADDR_WIDTH-1:0] pc_next;   //program_counter to Reg_N
wire mem_addr_IM_DM_mux_sel; //controller to mem_addr_IM_DM_mux
wire [DATA_WIDTH-1:0] imm; // imm_ext to Reg_D
wire [6:0]opcode_decode; // decoder to controller
wire [6:0]func7_decode;  // decoder to controller 
wire [2:0]func3_decode;  // decoder to controller
wire rd_wen; // contorller to reg_file
wire fd_wen; // contorller to reg_file
wire [4:0]r_f_1_idx; // decoder to reg_file
wire [4:0]r_f_2_idx; // decoder to reg_file
wire [4:0]r_f_d_idx; // decoder to Reg_D
wire [DATA_WIDTH-1:0] read_data_out_r1; // regfile to r_f_mux
wire [DATA_WIDTH-1:0] read_data_out_r2; // regfile to r_f_mux
wire [DATA_WIDTH-1:0] read_data_out_f1; // regfile to r_f_mux
wire [DATA_WIDTH-1:0] read_data_out_f2; // regfile to r_f_mux
wire r_f_flag_1;  // decoder to decoder mux sel
wire r_f_flag_2;  // decoder to decoder mux sel
wire [DATA_WIDTH-1:0] rf1;  // r_f_mux to Reg_D
wire [DATA_WIDTH-1:0] rf2;  // r_f_mux to Reg_D
wire imm_rf2_mux_sel; // contorller to imm_rf2_mux 
wire [6:0]opcode_alu; // controller to alu
wire [6:0]func7_alu;  // controller to alu
wire [2:0]func3_alu;  // controller to alu
wire invalid_alu; // alu to controller
wire [DATA_WIDTH-1:0] alu_result; // alu to Reg_A, controller, mem_addr_IM_DM_mux
wire [DATA_WIDTH-1:0] imm_rf2_mux_OUT; // imm_rf2_mux to alu
wire alu_lw_mux_sel; // controller to alu_lw_mux
wire [DATA_WIDTH-1:0] alu_lw_mux_OUT; // alu_lw_mux to regfile


wire [DATA_WIDTH-1:0] Reg_D_imm; // Reg_D to program_counter & imm_rf2_mux
wire [ADDR_WIDTH-1:0] Reg_N_pc;  // Reg_N to program_counter & mem_addr_IM_DM_mux
wire [DATA_WIDTH-1:0] Reg_I_inst;  // Reg_I to imm_ext & decoder 
wire [DATA_WIDTH-1:0] Reg_D_rf1; // Reg_D to alu
wire [DATA_WIDTH-1:0] Reg_D_rf2; // Reg_D to imm_rf2_mux & DM
wire [4:0] Reg_D_rfd_idx; // Reg_D to regfile
wire [DATA_WIDTH-1:0] Reg_A_rfd; // Reg_A to alu_lw_mux

wire Reg_I_en; // controller to stage Reg
wire Reg_D_en; // controller to stage Reg
wire Reg_A_en; // controller to stage Reg
wire Reg_N_en; // controller to stage Reg





controller controller_u( 
// ----------- inputs of controller ----------- 
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.i_opcode(opcode_decode),  // opcode from decode stage
.i_func7(func7_decode),   // func7  from decode stage
.i_func3(func3_decode),   // func3  from decode stage
.i_invalid_pc(invalid_pc),    // 0: valid, 1: invalid => pc is fetching an invalid memory index(ex: fetching DM: idx > 1023)				   
.i_invalid_alu(invalid_alu),   // 0: valid, 1: invalid => operation of instruction is valid : 1.integer arithmetic overflow  2.floating point arithmetic in or out is Nan or INF 3.load, store instruction memory
.i_branch_cond(alu_result[0]),   // 0: no branch, 1: branch to $pc + imm

// ----------- outputs of controller ----------- 
// ---- MEM ----
.mem_addr_IM_DM_mux_sel(mem_addr_IM_DM_mux_sel), // 0: IM address, 1: DM address
.mem_wen(o_we),                // 0: read, 1: write
// ---- REGFILE ----
.rd_wen(rd_wen),            // 0: read, 1: write // integer regfile
.fd_wen(fd_wen),            // 0: read, 1: write // floating point regfile
.alu_lw_mux_sel(alu_lw_mux_sel),    // 0: rd or fd is from alu, 1: rd or fd is loaded from Data Memory
// ---- STAGE REG ----
.Reg_I_en(Reg_I_en),     // 0: keep, 1: store new value // INST_FETCH stage
.Reg_D_en(Reg_D_en),     // 0: keep, 1: store new value // DECODE stage
.Reg_A_en(Reg_A_en),     // 0: keep, 1: store new value // ALU stage
.Reg_N_en(Reg_N_en),     // 0: keep, 1: store new value // NEXT_PC_GEN stage
// ---- ALU ----
.imm_rf2_mux_sel(imm_rf2_mux_sel), // choose ALU operand 2 ==> 0: imm, 1: rf2
.o_opcode(opcode_alu),        // opcode to alu stage
.o_func7(func7_alu),   		// func7  to alu stage
.o_func3(func3_alu),   		// func3  to alu stage
// ---- PC ----
.branch_flag(branch_flag),  // 0: no branch, 1: branch to $pc + imm 
// ---- STATUS -----
.status(o_status), 
.status_valid(o_status_valid)
);


program_counter program_counter_u( 
.pc_cur(Reg_N_pc),  // current pc  // unsigned to signed:  -2^31 ~ 2^31 - 1
.simm(Reg_D_imm),    //signed-ext immediate //signed number
.branch_flag(branch_flag), // 0: no branch, 1: branch to $pc + imm 
	
.pc_next(pc_next),   // next pc
.invalid_pc(invalid_pc) //invalif if pc is fetching an invalid memory index(ex: fetching DM: idx[12:2] > 1023)
);


imm_ext imm_ext_u( 
.inst(Reg_I_inst), 

.imm(imm)
);


decoder decoder_u( 
.inst(Reg_I_inst), 
	
.opcode(opcode_decode),  
.func7(func7_decode),   
.func3(func3_decode), 	   
.r_f_1_idx(r_f_1_idx),  // integer regfile r1 index or floating point regfile f1 index
.r_f_2_idx(r_f_2_idx),  // integer regfile r2 index or floating point regfile f2 index
.r_f_d_idx(r_f_d_idx),  // integer regfile rd index or floating point regfile fd index		   
.r_f_flag_1(r_f_flag_1),  // 0: integer regfile(r1), 1: floating point regfile(f1) // write back rd or fd is controlled by rd_wen & fd_en
.r_f_flag_2(r_f_flag_2)   // 0: integer regfile(r2), 1: floating point regfile(f2) // write back rd or fd is controlled by rd_wen & fd_en
);


// integer register file
reg_file integer_reg_file( 
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.wen(rd_wen),
.read_index_1(r_f_1_idx),
.read_index_2(r_f_2_idx),
.dest_index(Reg_D_rfd_idx),
.wb_data(alu_lw_mux_OUT),

.read_data_out_1(read_data_out_r1),
.read_data_out_2(read_data_out_r2)
);
// floating point register file
reg_file fp_reg_file( 
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.wen(fd_wen),
.read_index_1(r_f_1_idx),
.read_index_2(r_f_2_idx),
.dest_index(Reg_D_rfd_idx),
.wb_data(alu_lw_mux_OUT),

.read_data_out_1(read_data_out_f1),
.read_data_out_2(read_data_out_f2)
);


alu alu_u( 
.opcode(opcode_alu), // opcode to alu stage
.func7(func7_alu),   // func7  to alu stage
.func3(func3_alu),   // func3  to alu stage
.operand_1(Reg_D_rf1),
.operand_2(imm_rf2_mux_OUT),

.alu_result(alu_result),
.invalid_alu(invalid_alu) // Is operation valid? invalid if 1.integer arithmetic overflow  2.floating point arithmetic in or out is Nan or INF 3.load, store instruction memory
);



mux_2to1 mem_addr_IM_DM_mux( 
.A(Reg_N_pc), 
.B(alu_result),    
.sel(mem_addr_IM_DM_mux_sel), 

.mux_OUT(o_addr)
);

mux_2to1 r_f_1_mux( 
.A(read_data_out_r1), 
.B(read_data_out_f1),    
.sel(r_f_flag_1), 

.mux_OUT(rf1)
);

mux_2to1 r_f_2_mux( 
.A(read_data_out_r2), 
.B(read_data_out_f2),    
.sel(r_f_flag_2), 

.mux_OUT(rf2)
);

mux_2to1 imm_rf2_mux( 
.A(Reg_D_imm), 
.B(Reg_D_rf2),    
.sel(imm_rf2_mux_sel), 

.mux_OUT(imm_rf2_mux_OUT)
);

mux_2to1 alu_lw_mux( 
.A(Reg_A_rfd), 
.B(i_rdata),    
.sel(alu_lw_mux_sel), 

.mux_OUT(alu_lw_mux_OUT)
);






Reg_N Reg_N_u( 
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.Reg_N_en(Reg_N_en),  
.Reg_N_pc_in(pc_next),
.Reg_N_pc_out(Reg_N_pc)
);

Reg_I Reg_I_u( 
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.Reg_I_en(Reg_I_en),  
.Reg_I_inst_in(i_rdata),
.Reg_I_inst_out(Reg_I_inst)
);

Reg_D Reg_D_u( 
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.Reg_D_en(Reg_D_en),  
.Reg_D_imm_in(imm),
.Reg_D_imm_out(Reg_D_imm),
.Reg_D_rf1_in(rf1),
.Reg_D_rf1_out(Reg_D_rf1),
.Reg_D_rf2_in(rf2),
.Reg_D_rf2_out(Reg_D_rf2),
.Reg_D_rfd_idx_in(r_f_d_idx),
.Reg_D_rfd_idx_out(Reg_D_rfd_idx)
);
assign o_wdata = Reg_D_rf2;

Reg_A Reg_A_u( 
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.Reg_A_en(Reg_A_en),  
.Reg_A_rfd_in(alu_result),
.Reg_A_rfd_out(Reg_A_rfd)
);


endmodule