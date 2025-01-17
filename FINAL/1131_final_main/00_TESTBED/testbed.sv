/********************************************************************
* Filename: testbed.v
* Authors:
*     Yu-Cheng Lin
* Description:
*     testbench for final project of CVSD 2024 Fall
* Parameters:
*
* Note:
*
* Review History:
*     2024.10.02             Yu-Cheng Lin
*     2024.11.28             Yu-Cheng Lin
*********************************************************************/

`timescale 1ns/10ps
`define PERIOD     9.0
`define MAX_CYCLE 1_000_000
`define RST_CYCLE 5

`define I_DELAY 1
`define O_DELAY 1

`ifdef GATE
    `define SDF
    `define SDF_FILE "../03_GATE/ed25519_syn.sdf" // Modify your sdf file name
`elsif POST
    `define SDF
    `define SDF_FILE "../05_POST/ed25519_pr.sdf"  // Modify your sdf file name
`endif

`include "../00_TESTBED/pattern/tb_dat.sv"

// TODO: You should make sure your design can correctly handle the random IO handshake
// `define RANDOM_IO_HANDSHAKE

module testbench #(
    parameter DATA_W = 64,
    parameter PATN_W = 256,
    parameter IO_CYCLE = PATN_W/DATA_W
) ();

`ifdef PAT0
    import dat_0::*;
`elsif PAT1
    import dat_1::*;
`elsif PAT2
    import dat_2::*;
`elsif PAT3
    import dat_3::*;
`else 
    import dat_0::*;
`endif

    // Ports
    wire              clk;
    wire              rst;

    reg               in_valid;
    wire              in_ready;
    reg  [DATA_W-1:0] in_data;

    wire              out_valid;
    reg               out_ready;
    wire [DATA_W-1:0] out_data;

    // TB variables
    reg  [PATN_W*2-1:0] output_data;

    integer input_end, output_end;
    integer i, j, k;

    // Cycle counting
    reg [31:0] cycle_count;   // To count the number of clock cycles

    clk_gen u_clk_gen (
        .clk   (clk  ),
        .rst   (rst  ),
        .rst_n (     )
    );

    ed25519 u_ed25519 (
        .i_clk       (clk      ),
        .i_rst       (rst      ),
        .i_in_valid  (in_valid ),
        .o_in_ready  (in_ready ),
        .i_in_data   (in_data  ),
        .o_out_valid (out_valid),
        .i_out_ready (out_ready),
        .o_out_data  (out_data )
    );

`ifdef SDF
    initial begin
        $sdf_annotate(`SDF_FILE, u_ed25519);
    `ifdef FSDB
        $fsdbDumpfile("ed25519_gate.fsdb");
        $fsdbDumpvars(0, testbench, "+mda");
    `elsif VCD
        $dumpfile("ed25519_gate.vcd");
        $dumpvars();
    `endif
    end
`else
    `ifdef FSDB
    initial begin
        $fsdbDumpfile("ed25519.fsdb");
        $fsdbDumpvars(0, testbench, "+mda");
    end
    `endif
`endif

    reg valid_signal;

    // IO valid signal
    initial begin
        valid_signal = 1'b0;

        // reset
        wait (rst === 1'b1);
        wait (rst === 1'b0);

        while (!input_end) begin
            @(posedge clk);
            #(`I_DELAY);
`ifdef RANDOM_IO_HANDSHAKE
            valid_signal = $random() % 2;
`else
            valid_signal = 1'b1;
`endif
        end
    end

    assign in_valid = valid_signal && (input_end == 0);

    // IO valid signal
    initial begin
        out_ready = 1'b0;

        // reset
        wait (rst === 1'b1);
        wait (rst === 1'b0);

        while (!output_end) begin
            @(posedge clk);
            #(`I_DELAY);
`ifdef RANDOM_IO_HANDSHAKE
            out_ready = $random() % 2;
`else
            out_ready = 1'b1;
`endif
        end

        out_ready = 1'b0;
    end
    
    // Input
    initial begin
        input_end = 0;
        in_data = 64'b0;

        // reset
        wait (rst === 1'b1);
        wait (rst === 1'b0);

        // loop
        for (i = 3 * IO_CYCLE - 1; i >= 0; i = i - 1) begin

            in_data = input_data[DATA_W*i +: DATA_W];

            @(posedge clk);
            while (!(in_valid && (in_ready === 1'b1))) begin
                @(posedge clk);
            end
            #(`I_DELAY);
        end
        
        // final
        input_end = 1;        
        in_data   = 64'bx;
        $display("==> Send Input Done...");
        $display("==> Waiting Calculation...");
    end

    // Output
    initial begin
        output_end = 0;
        wait (j < 0);
        output_end = 1;
        $display("==> Receive Output Done...");
    end

    initial begin
        // reset
        wait (rst === 1'b1);
        wait (rst === 1'b0);
        
        // loop
        j = 2 * IO_CYCLE - 1;
        while ((j >= 0) && (j < 2 * IO_CYCLE)) begin
            if ((out_valid === 1'b1) && out_ready) begin
                output_data[DATA_W*j +: DATA_W] = out_data;
                j = j - 1;
            end
            @(posedge clk);
        end
    end

    // count calculation time
    initial begin
        cycle_count = 0;
        wait (rst === 1'b1);
        wait (rst === 1'b0);

        while (1) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
        end
    end

    // Result
    initial begin
        wait (input_end && output_end);

        $display("----------------------------------------------");
        if (output_data === golden_data) begin
            $display("                 PAT%2d PASS!                 ", pat_num);
        end
        else begin
            $display(
                "Scalar:  %h, \nInput:  (%h, %h), \nGolden: (%h, %h), \nYours:  (%h, %h)",
                input_data[2*PATN_W +: PATN_W],
                input_data[  PATN_W +: PATN_W],
                input_data[       0 +: PATN_W],
                golden_data[  PATN_W +: PATN_W],
                golden_data[       0 +: PATN_W],
                output_data[  PATN_W +: PATN_W],
                output_data[       0 +: PATN_W]
            );
            $display("----------------------------------------------");
            $display("                 PAT%2d FAIL!                 ", pat_num);
        end
        $display("----------------------------------------------");
        $display("Simulation Cycle: %6d, Time: %11.2f ns", cycle_count, `PERIOD*(cycle_count));
        $display("**********************************************");

        # (2 * `PERIOD);
        $finish;
    end

endmodule


module clk_gen (
    output reg clk,
    output reg rst,
    output reg rst_n
);

    always #(`PERIOD / 2.0) clk = ~clk;

    initial begin
        $display("**********************************************");
        clk = 1'b1;
        rst = 1'b0; rst_n = 1'b1; 
        @(posedge clk);
        #(`I_DELAY);
        rst = 1'b1; rst_n = 1'b0; 
        #(`RST_CYCLE * `PERIOD);
        rst = 1'b0; rst_n = 1'b1; 
		$display("---------------------- reset done ----------------------");
        #(`MAX_CYCLE * `PERIOD);
        $display("----------------------------------------------");
        $display("Error! Runtime exceeded!");
        $display("----------------------------------------------");
        $finish;
    end

	//initial begin
	//	force clk = 1'b0;
	//	#1000;
	//	release clk;
	//end
endmodule
