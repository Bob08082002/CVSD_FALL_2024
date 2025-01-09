`timescale 1ns/100ps
`define CYCLE       10.0
`define HCYCLE      (`CYCLE/2)
`define MAX_CYCLE   120000

`ifdef p0
    `define INST_PATH "../00_TB/PATTERN/p0/inst.dat"
	`define DATA_PATH "../00_TB/PATTERN/p0/data.dat"
	`define STATUS_PATH "../00_TB/PATTERN/p0/status.dat"
	`define STATUS_LEN 47
`elsif p1
    `define INST_PATH "../00_TB/PATTERN/p1/inst.dat"
	`define DATA_PATH "../00_TB/PATTERN/p1/data.dat"
	`define STATUS_PATH "../00_TB/PATTERN/p1/status.dat"
	`define STATUS_LEN 12
`elsif p2
	`define INST_PATH "../00_TB/PATTERN/p2/inst.dat"
	`define DATA_PATH "../00_TB/PATTERN/p2/data.dat"
	`define STATUS_PATH "../00_TB/PATTERN/p2/status.dat"
	`define STATUS_LEN 8
`elsif p3
	`define INST_PATH "../00_TB/PATTERN/p3/inst.dat"
	`define DATA_PATH "../00_TB/PATTERN/p3/data.dat"
	`define STATUS_PATH "../00_TB/PATTERN/p3/status.dat"
	`define STATUS_LEN 27
`else
	`define INST_PATH "../00_TB/PATTERN/p0/inst.dat"
	`define DATA_PATH "../00_TB/PATTERN/p0/data.dat"
	`define STATUS_PATH "../00_TB/PATTERN/p0/status.dat"
	`define STATUS_LEN 47
`endif

`define MEM_WIDTH 32
`define MEM_DEPTH 2048
`define STATUS_WIDTH 3

module testbed;

	reg  rst_n;
	reg  clk = 0;
	wire            dmem_we;
	wire [ 31 : 0 ] dmem_addr;
	wire [ 31 : 0 ] dmem_wdata;
	wire [ 31 : 0 ] dmem_rdata;
	wire [  2 : 0 ] status;
	wire            status_valid;
	
	integer status_correct, status_error, data_correct, data_error;
	integer output_end, k, i;
	
	
	// TB variables
    reg  [`MEM_WIDTH-1:0]      golden_data [0:`MEM_DEPTH-1];
    reg  [`STATUS_WIDTH-1:0] golden_status [0:`STATUS_LEN-1];
	
	// dump waveform
    initial begin
       $fsdbDumpfile("core.fsdb");
       $fsdbDumpvars(0, testbed, "+mda");
    end
	
	
	core u_core (
		.i_clk(clk),
		.i_rst_n(rst_n),
		.o_status(status),
		.o_status_valid(status_valid),
		.o_we(dmem_we),
		.o_addr(dmem_addr),
		.o_wdata(dmem_wdata),
		.i_rdata(dmem_rdata)
	);

	data_mem  u_data_mem (
		.i_clk(clk),
		.i_rst_n(rst_n),
		.i_we(dmem_we),
		.i_addr(dmem_addr),
		.i_wdata(dmem_wdata),
		.o_rdata(dmem_rdata)
	);

	always #(`HCYCLE) clk = ~clk;
	// load data memory
	initial begin 
		rst_n = 1;
		#(0.25 * `CYCLE) rst_n = 0;
		#(`CYCLE) rst_n = 1;
		$readmemb (`INST_PATH, u_data_mem.mem_r);
	end
	
	// load TB variables
	initial begin
		$readmemb(`STATUS_PATH, golden_status);
		$readmemb(`DATA_PATH, golden_data);
	end
	
	// loop: check status
    initial begin
        status_correct = 0;
        status_error   = 0;
        output_end = 0;

        // reset
        wait (rst_n === 1'b0);
        wait (rst_n === 1'b1);

        // loop
        k = 0;
        while (k < `STATUS_LEN) begin
            @(negedge clk);
            if (status_valid) begin
                if (status === golden_status[k]) begin
                    status_correct = status_correct + 1;
                end
                else begin
                    status_error = status_error + 1;
                    $display(
                        "Test[%d]: Error! Golden status =%b (%d), Yours status =%b (%d)",
                        k,
                        golden_status[k],
                        golden_status[k],
                        status,
                        status
                    );
                end
                k = k+1;
            end
            #(0.05 * `CYCLE);
        end

        // final
        output_end = 1;
    end

    // Result: check output memory
    initial begin
        wait (output_end);
		
		data_correct = 0;
        data_error   = 0;
		
		for (i = 0; i < `MEM_DEPTH; i = i + 1)begin
			if (u_data_mem.mem_r[i] === golden_data[i]) begin
                    data_correct = data_correct + 1;
                end
                else begin
                    data_error = data_error + 1;
                    $display(
                        "MEM[%d]: Error! Golden Data =%b (%d), Yours Data =%b (%d)",
                        i,
                        golden_data[i],
                        golden_data[i],
                        u_data_mem.mem_r[i],
                        u_data_mem.mem_r[i]
                    );
                end
		
		end
		
		
        if (status_error === 0 && status_correct === `STATUS_LEN) begin
            $display("----------------------------------------------");
            $display("-             ALL STATUS PASS!               -");
            $display("----------------------------------------------");
        end
        else begin
            $display("----------------------------------------------");
            $display("  Wrong! Total STATUS Error: %d               ", status_error);
            $display("----------------------------------------------");
        end
		
		if (data_error === 0 && data_correct === `MEM_DEPTH) begin
            $display("\n\n\n----------------------------------------------");
            $display("-             ALL DATA PASS!               -");
            $display("----------------------------------------------");
        end
        else begin
            $display("----------------------------------------------");
            $display("  Wrong! Total DATA Error: %d               ", data_error);
            $display("----------------------------------------------");
        end
		
        # (2 * `CYCLE);
        $finish;
    end
	
	// Execution time exceed MAX_CYCLE
	initial begin
        // reset
        wait (rst_n === 1'b0);
        wait (rst_n === 1'b1);
        #( `MAX_CYCLE * `CYCLE);
        $display("Error! Runtime exceeded!");
        $finish;
    end

endmodule