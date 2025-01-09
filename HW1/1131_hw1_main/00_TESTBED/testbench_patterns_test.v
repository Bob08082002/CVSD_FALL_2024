/********************************************************************
* Filename: testbench.v
* Authors:
*     Yi-Fan Shyu
* Description:
*     testbench for hw1 of CVSD 2024 Fall
* Parameters:
*
* Note:
*
* Review History:
*     2024.09.08             Yi-Fan Shyu
*********************************************************************/

`timescale 1ns/10ps
`define PERIOD    10.0
`define MAX_CYCLE 10000000
`define RST_DELAY 2.0

//`define ORIGIN
//`define MPLIN
//`define YP
//`define WU
//`define WONG
//`define MY

// original pattern
`ifdef ORIGIN
	`ifdef I0
		`define IDATA  "../00_TESTBED/pattern/INST0_I.dat"
		`define ODATA  "../00_TESTBED/pattern/INST0_O.dat"
		`define PAT_LEN 40
		`define SEQ_LEN 60
	`elsif I1
		`define IDATA  "../00_TESTBED/pattern/INST1_I.dat"
		`define ODATA  "../00_TESTBED/pattern/INST1_O.dat"
		`define PAT_LEN 40
		`define SEQ_LEN 60
	`elsif I2
		`define IDATA  "../00_TESTBED/pattern/INST2_I.dat"
		`define ODATA  "../00_TESTBED/pattern/INST2_O.dat"
		`define PAT_LEN 40
		`define SEQ_LEN 60
	`elsif I3
		`define IDATA  "../00_TESTBED/pattern/INST3_I.dat"
		`define ODATA  "../00_TESTBED/pattern/INST3_O.dat"
		`define PAT_LEN 40
		`define SEQ_LEN 60
	`elsif I4
		`define IDATA  "../00_TESTBED/pattern/INST4_I.dat"
		`define ODATA  "../00_TESTBED/pattern/INST4_O.dat"
		`define PAT_LEN 40
		`define SEQ_LEN 60
	`elsif I5
		`define IDATA  "../00_TESTBED/pattern/INST5_I.dat"
		`define ODATA  "../00_TESTBED/pattern/INST5_O.dat"
		`define PAT_LEN 40
		`define SEQ_LEN 60
	`elsif I6
		`define IDATA  "../00_TESTBED/pattern/INST6_I.dat"
		`define ODATA  "../00_TESTBED/pattern/INST6_O.dat"
		`define PAT_LEN 40
		`define SEQ_LEN 60
	`elsif I7
		`define IDATA  "../00_TESTBED/pattern/INST7_I.dat"
		`define ODATA  "../00_TESTBED/pattern/INST7_O.dat"
		`define PAT_LEN 40
		`define SEQ_LEN 60
	`elsif I8
		`define IDATA  "../00_TESTBED/pattern/INST8_I.dat"
		`define ODATA  "../00_TESTBED/pattern/INST8_O.dat"
		`define PAT_LEN 40
		`define SEQ_LEN 60
	`elsif I9
		`define IDATA  "../00_TESTBED/pattern/INST9_I.dat"
		`define ODATA  "../00_TESTBED/pattern/INST9_O.dat"
		`define PAT_LEN 40
		`define SEQ_LEN 60
	`elsif I10
		`define IDATA  "../00_TESTBED/pattern/INST10_I.dat"
		`define ODATA  "../00_TESTBED/pattern/INST10_O.dat"
		`define PAT_LEN 400
		`define SEQ_LEN 600
	`else
		`define IDATA  "../00_TESTBED/pattern/INST0_I.dat"
		`define ODATA  "../00_TESTBED/pattern/INST0_O.dat"
		`define PAT_LEN 40
		`define SEQ_LEN 60
	`endif
	
`elsif MPLIN
	//-------------------------------------------test pattern -------------------------------------------
	`define PAT_LEN 10000
	`define SEQ_LEN 50000
	
	`ifdef MIX
		`define IDATA  "../00_TESTBED/MPLIN_pattern/INST_10K_MIX_I.dat"
		`define ODATA  "../00_TESTBED/MPLIN_pattern/INST_10K_MIX_O.dat"
	`elsif I3
		`define IDATA  "../00_TESTBED/MPLIN_pattern/INST_10K_3_I.dat"
		`define ODATA  "../00_TESTBED/MPLIN_pattern/INST_10K_3_O.dat"
	`elsif I4
		`define IDATA  "../00_TESTBED/MPLIN_pattern/INST_10K_4_I.dat"
		`define ODATA  "../00_TESTBED/MPLIN_pattern/INST_10K_4_O.dat"
	`elsif I5
		`define IDATA  "../00_TESTBED/MPLIN_pattern/INST_10K_5_I.dat"
		`define ODATA  "../00_TESTBED/MPLIN_pattern/INST_10K_5_O.dat"
	`elsif I6
		`define IDATA  "../00_TESTBED/MPLIN_pattern/INST_10K_6_I.dat"
		`define ODATA  "../00_TESTBED/MPLIN_pattern/INST_10K_6_O.dat"
	`elsif I7
		`define IDATA  "../00_TESTBED/MPLIN_pattern/INST_10K_7_I.dat"
		`define ODATA  "../00_TESTBED/MPLIN_pattern/INST_10K_7_O.dat"
	`elsif I8
		`define IDATA  "../00_TESTBED/MPLIN_pattern/INST_10K_8_I.dat"
		`define ODATA  "../00_TESTBED/MPLIN_pattern/INST_10K_8_O.dat"
	`elsif I9
		`define IDATA  "../00_TESTBED/MPLIN_pattern/INST_10K_9_I.dat"
		`define ODATA  "../00_TESTBED/MPLIN_pattern/INST_10K_9_O.dat"
	`else
		`define IDATA  "../00_TESTBED/MPLIN_pattern/INST_10K_MIX_I.dat"
		`define ODATA  "../00_TESTBED/MPLIN_pattern/INST_10K_MIX_O.dat"
	`endif
	
`elsif YP
	`define SEQ_LEN 180
	`ifdef IMIX
		`define IDATA  "../00_TESTBED/YP_pattern/INST_10W_MIX_I.dat"
		`define ODATA  "../00_TESTBED/YP_pattern/INST_10W_MIX_O.dat"
		`define PAT_LEN 100
	`elsif IACC
		`define IDATA  "../00_TESTBED/YP_pattern/INST10W_acc_I.dat"
		`define ODATA  "../00_TESTBED/YP_pattern/INST10W_acc_O.dat"
		`define PAT_LEN 100
	`elsif ISOF
		`define IDATA  "../00_TESTBED/YP_pattern/INST10W_softplus_I.dat"
		`define ODATA  "../00_TESTBED/YP_pattern/INST10W_softplus_O.dat"
		`define PAT_LEN 100
	`elsif ICLZ
		`define IDATA  "../00_TESTBED/YP_pattern/INST10W_clz_I.dat"
		`define ODATA  "../00_TESTBED/YP_pattern/INST10W_clz_O.dat"
		`define PAT_LEN 100
	`elsif IM4
		`define IDATA  "../00_TESTBED/YP_pattern/INST10W_reverse_match_I.dat"
		`define ODATA  "../00_TESTBED/YP_pattern/INST10W_reverse_match_O.dat"
		`define PAT_LEN 100
	`endif

`elsif WU
	`ifdef TEST
		`define IDATA  "../00_TESTBED/WU_pattern/TEST_INST_I.dat"
		`define ODATA  "../00_TESTBED/WU_pattern/TEST_INST_O.dat"
		`define SEQ_LEN 120000
		`define PAT_LEN 100000
	`endif
`elsif WONG
	`ifdef I0
		`define IDATA  "../00_TESTBED/WONG_pattern/INST0_I.dat"
		`define ODATA  "../00_TESTBED/WONG_pattern/INST0_O.dat"
		`define VAL_PATH  "../00_TESTBED/WONG_pattern/VALID0.dat"
		`define PAT_LEN 100000
		`define SEQ_LEN 119992
	`elsif I1
		`define IDATA  "../00_TESTBED/WONG_pattern/INST1_I.dat"
		`define ODATA  "../00_TESTBED/WONG_pattern/INST1_O.dat"
		`define VAL_PATH  "../00_TESTBED/WONG_pattern/VALID1.dat"
		`define PAT_LEN 100000
		`define SEQ_LEN 120218
	`elsif I2
		`define IDATA  "../00_TESTBED/WONG_pattern/INST2_I.dat"
		`define ODATA  "../00_TESTBED/WONG_pattern/INST2_O.dat"
		`define VAL_PATH  "../00_TESTBED/WONG_pattern/VALID2.dat"
		`define PAT_LEN 500000
		`define SEQ_LEN 599842
	`elsif I3
		`define IDATA  "../00_TESTBED/WONG_pattern/INST3_I.dat"
		`define ODATA  "../00_TESTBED/WONG_pattern/INST3_O.dat"
		`define VAL_PATH  "../00_TESTBED/WONG_pattern/VALID3.dat"
		`define PAT_LEN 500000
		`define SEQ_LEN 600333
	`elsif I4
		`define IDATA  "../00_TESTBED/WONG_pattern/INST4_I.dat"
		`define ODATA  "../00_TESTBED/WONG_pattern/INST4_O.dat"
		`define VAL_PATH  "../00_TESTBED/WONG_pattern/VALID4.dat"
		`define PAT_LEN 65536
		`define SEQ_LEN 78626
	`elsif I5
		`define IDATA  "../00_TESTBED/WONG_pattern/INST5_I.dat"
		`define ODATA  "../00_TESTBED/WONG_pattern/INST5_O.dat"
		`define VAL_PATH  "../00_TESTBED/WONG_pattern/VALID5.dat"
		`define PAT_LEN 100000
		`define SEQ_LEN 120289
	`elsif I6
		`define IDATA  "../00_TESTBED/WONG_pattern/INST6_I.dat"
		`define ODATA  "../00_TESTBED/WONG_pattern/INST6_O.dat"
		`define VAL_PATH  "../00_TESTBED/WONG_pattern/VALID6.dat"
		`define PAT_LEN 1048576
		`define SEQ_LEN 1258531
	`elsif I7
		`define IDATA  "../00_TESTBED/WONG_pattern/INST7_I.dat"
		`define ODATA  "../00_TESTBED/WONG_pattern/INST7_O.dat"
		`define VAL_PATH  "../00_TESTBED/WONG_pattern/VALID7.dat"
		`define PAT_LEN 1048576
		`define SEQ_LEN 1258272
	`elsif I8
		`define IDATA  "../00_TESTBED/WONG_pattern/INST8_I.dat"
		`define ODATA  "../00_TESTBED/WONG_pattern/INST8_O.dat"
		`define VAL_PATH  "../00_TESTBED/WONG_pattern/VALID8.dat"
		`define PAT_LEN 65536
		`define SEQ_LEN 78724
	`elsif I9
		`define IDATA  "../00_TESTBED/WONG_pattern/INST9_I.dat"
		`define ODATA  "../00_TESTBED/WONG_pattern/INST9_O.dat"
		`define VAL_PATH  "../00_TESTBED/WONG_pattern/VALID9.dat"
		`define PAT_LEN 100000
		`define SEQ_LEN 120274
	`elsif I10
		`define IDATA  "../00_TESTBED/WONG_pattern/INST10_I.dat"
		`define ODATA  "../00_TESTBED/WONG_pattern/INST10_O.dat"
		`define VAL_PATH  "../00_TESTBED/WONG_pattern/VALID10.dat"
		`define PAT_LEN 100000
		`define SEQ_LEN 120279
	`else
		`define IDATA  "../00_TESTBED/WONG_pattern/INST0_I.dat"
		`define ODATA  "../00_TESTBED/WONG_pattern/INST0_O.dat"
		`define VAL_PATH  "../00_TESTBED/WONG_pattern/VALID0.dat"
		`define PAT_LEN 100000
		`define SEQ_LEN 119992
	`endif
`elsif YANG
	`ifdef I0
		`define IDATA  "../00_TESTBED/YANG_pattern/INST0_I.dat"
		`define ODATA  "../00_TESTBED/YANG_pattern/INST0_O.dat"
		`define PAT_LEN 40
		`define SEQ_LEN 60
	`elsif I1
		`define IDATA  "../00_TESTBED/YANG_pattern/INST1_I.dat"
		`define ODATA  "../00_TESTBED/YANG_pattern/INST1_O.dat"
		`define PAT_LEN 40
		`define SEQ_LEN 60
	`elsif I2
		`define IDATA  "../00_TESTBED/YANG_pattern/INST2_I.dat"
		`define ODATA  "../00_TESTBED/YANG_pattern/INST2_O.dat"
		`define PAT_LEN 40
		`define SEQ_LEN 60
	`elsif I3
		`define IDATA  "../00_TESTBED/YANG_pattern/INST3_I.dat"
		`define ODATA  "../00_TESTBED/YANG_pattern/INST3_O.dat"
		`define PAT_LEN 40
		`define SEQ_LEN 60
	`elsif I4
		`define IDATA  "../00_TESTBED/YANG_pattern/INST4_I.dat"
		`define ODATA  "../00_TESTBED/YANG_pattern/INST4_O.dat"
		`define PAT_LEN 40
		`define SEQ_LEN 60
	`else
		`define IDATA  "../00_TESTBED/YANG_pattern/INST0_I.dat"
		`define ODATA  "../00_TESTBED/YANG_pattern/INST0_O.dat"
		`define PAT_LEN 40
		`define SEQ_LEN 60
	`endif
`elsif MY
	//-------------------------------------------test pattern -------------------------------------------
	`define PAT_LEN 10000
	`define SEQ_LEN 20000
	
	`ifdef I0
		`define IDATA  "../00_TESTBED/MY_pattern/INST0_I.dat"
		`define ODATA  "../00_TESTBED/MY_pattern/INST0_O.dat"
	`elsif I1
		`define IDATA  "../00_TESTBED/MY_pattern/INST1_I.dat"
		`define ODATA  "../00_TESTBED/MY_pattern/INST1_O.dat"
	`elsif I2
		`define IDATA  "../00_TESTBED/MY_pattern/INST2_I.dat"
		`define ODATA  "../00_TESTBED/MY_pattern/INST2_O.dat"
	`elsif I3
		`define IDATA  "../00_TESTBED/MY_pattern/INST3_I.dat"
		`define ODATA  "../00_TESTBED/MY_pattern/INST3_O.dat"
	`elsif I4
		`define IDATA  "../00_TESTBED/MY_pattern/INST4_I.dat"
		`define ODATA  "../00_TESTBED/MY_pattern/INST4_O.dat"
	`elsif I5
		`define IDATA  "../00_TESTBED/MY_pattern/INST5_I.dat"
		`define ODATA  "../00_TESTBED/MY_pattern/INST5_O.dat"
	`elsif I6
		`define IDATA  "../00_TESTBED/MY_pattern/INST6_I.dat"
		`define ODATA  "../00_TESTBED/MY_pattern/INST6_O.dat"
	`elsif I7
		`define IDATA  "../00_TESTBED/MY_pattern/INST7_I.dat"
		`define ODATA  "../00_TESTBED/MY_pattern/INST7_O.dat"
	`elsif I8
		`define IDATA  "../00_TESTBED/MY_pattern/INST8_I.dat"
		`define ODATA  "../00_TESTBED/MY_pattern/INST8_O.dat"
	`elsif I9
		`define IDATA  "../00_TESTBED/MY_pattern/INST9_I.dat"
		`define ODATA  "../00_TESTBED/MY_pattern/INST9_O.dat"
	`elsif MIX
		`define PAT_LEN 100000
		`define SEQ_LEN 200000
		`define IDATA  "../00_TESTBED/MY_pattern/INST_MIX_I.dat"
		`define ODATA  "../00_TESTBED/MY_pattern/INST_MIX_O.dat"
	`else
		`define IDATA  "../00_TESTBED/MY_pattern/INST0_I.dat"
		`define ODATA  "../00_TESTBED/MY_pattern/INST0_O.dat"
	`endif

`endif


module testbench #(
    parameter INST_W = 4,
    parameter INT_W  = 6,
    parameter FRAC_W = 10,
    parameter DATA_W = INT_W + FRAC_W
) ();

    // Ports
    wire              clk;
    wire              rst_n;
    reg               in_valid;
    reg  [INST_W-1:0] inst;
    reg  [DATA_W-1:0] idata_a;
    reg  [DATA_W-1:0] idata_b;

    wire              busy;
    wire              out_valid;
    wire [DATA_W-1:0] odata;

    // TB variables
    reg                        valid_seq   [0:`SEQ_LEN-1];
    reg  [INST_W+2*DATA_W-1:0] input_data  [0:`PAT_LEN-1];
    reg  [         DATA_W-1:0] golden_data [0:`PAT_LEN-1];

    integer input_end, output_end, test_end;
    integer i, j, k;
    integer correct, error;

	initial begin
		`ifdef ORIGIN
			`ifdef I10
				$readmemb("../00_TESTBED/pattern/VALID_10.dat", valid_seq);
			`else
				$readmemb("../00_TESTBED/pattern/VALID.dat", valid_seq);
			`endif
		`elsif MPLIN
			$readmemb("../00_TESTBED/MPLIN_pattern/VALID_10K.dat", valid_seq);
		`elsif YP
			$readmemb("../00_TESTBED/YP_pattern/VALID.dat", valid_seq);
		`elsif WU
			$readmemb("../00_TESTBED/WU_pattern/TEST_VALID.dat", valid_seq);
		`elsif WONG
			$readmemb(`VAL_PATH, valid_seq);
		`elsif YANG
			$readmemb("../00_TESTBED/YANG_pattern/VALID.dat", valid_seq);
		`elsif MY
			`ifdef MIX
				$readmemb("../00_TESTBED/MY_pattern/VALID_MIX.dat", valid_seq);
			`else
				$readmemb("../00_TESTBED/MY_pattern/VALID.dat", valid_seq);
			`endif
		`endif
		$readmemb(`IDATA, input_data);
		$readmemb(`ODATA, golden_data);
	end



    clk_gen u_clk_gen (
        .clk   (clk  ),
        .rst   (     ),
        .rst_n (rst_n)
    );

    alu u_alu (
        .i_clk       (clk      ),
        .i_rst_n     (rst_n    ),
        .i_in_valid  (in_valid ),
        .o_busy      (busy     ),
        .i_inst      (inst     ),
        .i_data_a    (idata_a  ),
        .i_data_b    (idata_b  ),
        .o_out_valid (out_valid),
        .o_data      (odata    )
    );
	/*
    initial begin
       $fsdbDumpfile("alu.fsdb");
       $fsdbDumpvars(0, testbench, "+mda");
    end
	*/
    // Input
    initial begin
        input_end = 0;

        // reset
        wait (rst_n === 1'b0);
        in_valid =  1'b0;
        inst     =  4'b0;
        idata_a  = 16'b0;
        idata_b  = 16'b0;
        wait (rst_n === 1'b1);

        // start
        @(posedge clk);

        // loop
        i = 0; j = 0;
        while (i < `SEQ_LEN && j < `PAT_LEN) begin
            @(negedge clk);
            if (valid_seq[i]) begin
                if (!busy) begin
                    in_valid = 1'b1;
                    inst     = input_data[j][2*DATA_W +: INST_W];
                    idata_a  = input_data[j][  DATA_W +: DATA_W];
                    idata_b  = input_data[j][       0 +: DATA_W];
                    j = j+1;

                    i = i+1;
                end
                else begin
                    in_valid =  1'b0;
                    inst     =  4'bx;
                    idata_a  = 16'bx;
                    idata_b  = 16'bx;
                end
            end
            else begin
                in_valid =  1'b0;
                inst     =  4'bx;
                idata_a  = 16'bx;
                idata_b  = 16'bx;

                i = i+1;
            end
            @(posedge clk);
        end

        // final
        @(negedge clk);
        in_valid =  1'b0;
        inst     =  4'b0;
        idata_a  = 16'b0;
        idata_b  = 16'b0;

        input_end = 1;
    end

    // Output
    initial begin
        correct = 0;
        error   = 0;
        output_end = 0;

        // reset
        wait (rst_n === 1'b0);
        wait (rst_n === 1'b1);

        // start
        @(posedge clk);

        // loop
        k = 0;
        while (k < `PAT_LEN) begin
            @(negedge clk);
            if (out_valid) begin
                if (odata === golden_data[k]) begin
                    correct = correct + 1;
                end
                else begin
                    error = error + 1;
                    $display(
                        "Test[%d]: Error! Inst=%b, A=%b, B=%b, Golden=%b, Yours=%b",
                        k,
                        input_data[k][2*DATA_W +: INST_W],
                        input_data[k][  DATA_W +: DATA_W],
                        input_data[k][       0 +: DATA_W],
                        golden_data[k],
                        odata
                    );
                end
                k = k+1;
            end
            @(posedge clk);
        end

        // final
        output_end = 1;
    end

    // Result
    initial begin
        wait (input_end && output_end);

        if (error === 0 && correct === `PAT_LEN) begin
            $display("----------------------------------------------");
            $display("-                 ALL PASS!                  -");
            $display("----------------------------------------------");
        end
        else begin
            $display("----------------------------------------------");
            $display("  Wrong! Total Error: %d                      ", error);
            $display("----------------------------------------------");
        end

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
        clk = 1'b0;
        rst = 1'b0; rst_n = 1'b1; #(              0.25  * `PERIOD);
        rst = 1'b1; rst_n = 1'b0; #((`RST_DELAY - 0.25) * `PERIOD);
        rst = 1'b0; rst_n = 1'b1; #(         `MAX_CYCLE * `PERIOD);
        $display("Error! Runtime exceeded!");
        $finish;
    end

endmodule
