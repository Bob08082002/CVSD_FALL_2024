###################################################################

# Created by write_sdc on Sat Dec 14 03:50:00 2024

###################################################################
set sdc_version 1.8

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_operating_conditions slow -library slow
set_load -pin_load 1 [get_ports o_in_ready]
set_load -pin_load 1 [get_ports o_out_valid]
set_load -pin_load 1 [get_ports {o_out_data[63]}]
set_load -pin_load 1 [get_ports {o_out_data[62]}]
set_load -pin_load 1 [get_ports {o_out_data[61]}]
set_load -pin_load 1 [get_ports {o_out_data[60]}]
set_load -pin_load 1 [get_ports {o_out_data[59]}]
set_load -pin_load 1 [get_ports {o_out_data[58]}]
set_load -pin_load 1 [get_ports {o_out_data[57]}]
set_load -pin_load 1 [get_ports {o_out_data[56]}]
set_load -pin_load 1 [get_ports {o_out_data[55]}]
set_load -pin_load 1 [get_ports {o_out_data[54]}]
set_load -pin_load 1 [get_ports {o_out_data[53]}]
set_load -pin_load 1 [get_ports {o_out_data[52]}]
set_load -pin_load 1 [get_ports {o_out_data[51]}]
set_load -pin_load 1 [get_ports {o_out_data[50]}]
set_load -pin_load 1 [get_ports {o_out_data[49]}]
set_load -pin_load 1 [get_ports {o_out_data[48]}]
set_load -pin_load 1 [get_ports {o_out_data[47]}]
set_load -pin_load 1 [get_ports {o_out_data[46]}]
set_load -pin_load 1 [get_ports {o_out_data[45]}]
set_load -pin_load 1 [get_ports {o_out_data[44]}]
set_load -pin_load 1 [get_ports {o_out_data[43]}]
set_load -pin_load 1 [get_ports {o_out_data[42]}]
set_load -pin_load 1 [get_ports {o_out_data[41]}]
set_load -pin_load 1 [get_ports {o_out_data[40]}]
set_load -pin_load 1 [get_ports {o_out_data[39]}]
set_load -pin_load 1 [get_ports {o_out_data[38]}]
set_load -pin_load 1 [get_ports {o_out_data[37]}]
set_load -pin_load 1 [get_ports {o_out_data[36]}]
set_load -pin_load 1 [get_ports {o_out_data[35]}]
set_load -pin_load 1 [get_ports {o_out_data[34]}]
set_load -pin_load 1 [get_ports {o_out_data[33]}]
set_load -pin_load 1 [get_ports {o_out_data[32]}]
set_load -pin_load 1 [get_ports {o_out_data[31]}]
set_load -pin_load 1 [get_ports {o_out_data[30]}]
set_load -pin_load 1 [get_ports {o_out_data[29]}]
set_load -pin_load 1 [get_ports {o_out_data[28]}]
set_load -pin_load 1 [get_ports {o_out_data[27]}]
set_load -pin_load 1 [get_ports {o_out_data[26]}]
set_load -pin_load 1 [get_ports {o_out_data[25]}]
set_load -pin_load 1 [get_ports {o_out_data[24]}]
set_load -pin_load 1 [get_ports {o_out_data[23]}]
set_load -pin_load 1 [get_ports {o_out_data[22]}]
set_load -pin_load 1 [get_ports {o_out_data[21]}]
set_load -pin_load 1 [get_ports {o_out_data[20]}]
set_load -pin_load 1 [get_ports {o_out_data[19]}]
set_load -pin_load 1 [get_ports {o_out_data[18]}]
set_load -pin_load 1 [get_ports {o_out_data[17]}]
set_load -pin_load 1 [get_ports {o_out_data[16]}]
set_load -pin_load 1 [get_ports {o_out_data[15]}]
set_load -pin_load 1 [get_ports {o_out_data[14]}]
set_load -pin_load 1 [get_ports {o_out_data[13]}]
set_load -pin_load 1 [get_ports {o_out_data[12]}]
set_load -pin_load 1 [get_ports {o_out_data[11]}]
set_load -pin_load 1 [get_ports {o_out_data[10]}]
set_load -pin_load 1 [get_ports {o_out_data[9]}]
set_load -pin_load 1 [get_ports {o_out_data[8]}]
set_load -pin_load 1 [get_ports {o_out_data[7]}]
set_load -pin_load 1 [get_ports {o_out_data[6]}]
set_load -pin_load 1 [get_ports {o_out_data[5]}]
set_load -pin_load 1 [get_ports {o_out_data[4]}]
set_load -pin_load 1 [get_ports {o_out_data[3]}]
set_load -pin_load 1 [get_ports {o_out_data[2]}]
set_load -pin_load 1 [get_ports {o_out_data[1]}]
set_load -pin_load 1 [get_ports {o_out_data[0]}]
set_max_fanout 20 [get_ports i_clk]
set_max_fanout 20 [get_ports i_rst]
set_max_fanout 20 [get_ports i_in_valid]
set_max_fanout 20 [get_ports {i_in_data[63]}]
set_max_fanout 20 [get_ports {i_in_data[62]}]
set_max_fanout 20 [get_ports {i_in_data[61]}]
set_max_fanout 20 [get_ports {i_in_data[60]}]
set_max_fanout 20 [get_ports {i_in_data[59]}]
set_max_fanout 20 [get_ports {i_in_data[58]}]
set_max_fanout 20 [get_ports {i_in_data[57]}]
set_max_fanout 20 [get_ports {i_in_data[56]}]
set_max_fanout 20 [get_ports {i_in_data[55]}]
set_max_fanout 20 [get_ports {i_in_data[54]}]
set_max_fanout 20 [get_ports {i_in_data[53]}]
set_max_fanout 20 [get_ports {i_in_data[52]}]
set_max_fanout 20 [get_ports {i_in_data[51]}]
set_max_fanout 20 [get_ports {i_in_data[50]}]
set_max_fanout 20 [get_ports {i_in_data[49]}]
set_max_fanout 20 [get_ports {i_in_data[48]}]
set_max_fanout 20 [get_ports {i_in_data[47]}]
set_max_fanout 20 [get_ports {i_in_data[46]}]
set_max_fanout 20 [get_ports {i_in_data[45]}]
set_max_fanout 20 [get_ports {i_in_data[44]}]
set_max_fanout 20 [get_ports {i_in_data[43]}]
set_max_fanout 20 [get_ports {i_in_data[42]}]
set_max_fanout 20 [get_ports {i_in_data[41]}]
set_max_fanout 20 [get_ports {i_in_data[40]}]
set_max_fanout 20 [get_ports {i_in_data[39]}]
set_max_fanout 20 [get_ports {i_in_data[38]}]
set_max_fanout 20 [get_ports {i_in_data[37]}]
set_max_fanout 20 [get_ports {i_in_data[36]}]
set_max_fanout 20 [get_ports {i_in_data[35]}]
set_max_fanout 20 [get_ports {i_in_data[34]}]
set_max_fanout 20 [get_ports {i_in_data[33]}]
set_max_fanout 20 [get_ports {i_in_data[32]}]
set_max_fanout 20 [get_ports {i_in_data[31]}]
set_max_fanout 20 [get_ports {i_in_data[30]}]
set_max_fanout 20 [get_ports {i_in_data[29]}]
set_max_fanout 20 [get_ports {i_in_data[28]}]
set_max_fanout 20 [get_ports {i_in_data[27]}]
set_max_fanout 20 [get_ports {i_in_data[26]}]
set_max_fanout 20 [get_ports {i_in_data[25]}]
set_max_fanout 20 [get_ports {i_in_data[24]}]
set_max_fanout 20 [get_ports {i_in_data[23]}]
set_max_fanout 20 [get_ports {i_in_data[22]}]
set_max_fanout 20 [get_ports {i_in_data[21]}]
set_max_fanout 20 [get_ports {i_in_data[20]}]
set_max_fanout 20 [get_ports {i_in_data[19]}]
set_max_fanout 20 [get_ports {i_in_data[18]}]
set_max_fanout 20 [get_ports {i_in_data[17]}]
set_max_fanout 20 [get_ports {i_in_data[16]}]
set_max_fanout 20 [get_ports {i_in_data[15]}]
set_max_fanout 20 [get_ports {i_in_data[14]}]
set_max_fanout 20 [get_ports {i_in_data[13]}]
set_max_fanout 20 [get_ports {i_in_data[12]}]
set_max_fanout 20 [get_ports {i_in_data[11]}]
set_max_fanout 20 [get_ports {i_in_data[10]}]
set_max_fanout 20 [get_ports {i_in_data[9]}]
set_max_fanout 20 [get_ports {i_in_data[8]}]
set_max_fanout 20 [get_ports {i_in_data[7]}]
set_max_fanout 20 [get_ports {i_in_data[6]}]
set_max_fanout 20 [get_ports {i_in_data[5]}]
set_max_fanout 20 [get_ports {i_in_data[4]}]
set_max_fanout 20 [get_ports {i_in_data[3]}]
set_max_fanout 20 [get_ports {i_in_data[2]}]
set_max_fanout 20 [get_ports {i_in_data[1]}]
set_max_fanout 20 [get_ports {i_in_data[0]}]
set_max_fanout 20 [get_ports i_out_ready]
set_ideal_network [get_ports i_clk]
create_clock [get_ports i_clk]  -period 9  -waveform {0 4.5}
set_clock_latency 0.5  [get_clocks i_clk]
set_clock_uncertainty 0.1  [get_clocks i_clk]
set_input_delay -clock i_clk  1  [get_ports i_rst]
set_input_delay -clock i_clk  1  [get_ports i_in_valid]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[63]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[62]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[61]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[60]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[59]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[58]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[57]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[56]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[55]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[54]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[53]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[52]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[51]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[50]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[49]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[48]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[47]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[46]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[45]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[44]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[43]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[42]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[41]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[40]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[39]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[38]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[37]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[36]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[35]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[34]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[33]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[32]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[31]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[30]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[29]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[28]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[27]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[26]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[25]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[24]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[23]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[22]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[21]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[20]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[19]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[18]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[17]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[16]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[15]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[14]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[13]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[12]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[11]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[10]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[9]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[8]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[7]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[6]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[5]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[4]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[3]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[2]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[1]}]
set_input_delay -clock i_clk  1  [get_ports {i_in_data[0]}]
set_input_delay -clock i_clk  1  [get_ports i_out_ready]
set_output_delay -clock i_clk  1  [get_ports o_in_ready]
set_output_delay -clock i_clk  1  [get_ports o_out_valid]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[63]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[62]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[61]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[60]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[59]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[58]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[57]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[56]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[55]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[54]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[53]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[52]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[51]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[50]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[49]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[48]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[47]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[46]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[45]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[44]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[43]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[42]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[41]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[40]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[39]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[38]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[37]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[36]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[35]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[34]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[33]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[32]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[31]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[30]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[29]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[28]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[27]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[26]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[25]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[24]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[23]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[22]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[21]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[20]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[19]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[18]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[17]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[16]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[15]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[14]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[13]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[12]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[11]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[10]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[9]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[8]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[7]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[6]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[5]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[4]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[3]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[2]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[1]}]
set_output_delay -clock i_clk  1  [get_ports {o_out_data[0]}]
set_drive 1  [get_ports i_clk]
set_drive 1  [get_ports i_rst]
set_drive 1  [get_ports i_in_valid]
set_drive 1  [get_ports {i_in_data[63]}]
set_drive 1  [get_ports {i_in_data[62]}]
set_drive 1  [get_ports {i_in_data[61]}]
set_drive 1  [get_ports {i_in_data[60]}]
set_drive 1  [get_ports {i_in_data[59]}]
set_drive 1  [get_ports {i_in_data[58]}]
set_drive 1  [get_ports {i_in_data[57]}]
set_drive 1  [get_ports {i_in_data[56]}]
set_drive 1  [get_ports {i_in_data[55]}]
set_drive 1  [get_ports {i_in_data[54]}]
set_drive 1  [get_ports {i_in_data[53]}]
set_drive 1  [get_ports {i_in_data[52]}]
set_drive 1  [get_ports {i_in_data[51]}]
set_drive 1  [get_ports {i_in_data[50]}]
set_drive 1  [get_ports {i_in_data[49]}]
set_drive 1  [get_ports {i_in_data[48]}]
set_drive 1  [get_ports {i_in_data[47]}]
set_drive 1  [get_ports {i_in_data[46]}]
set_drive 1  [get_ports {i_in_data[45]}]
set_drive 1  [get_ports {i_in_data[44]}]
set_drive 1  [get_ports {i_in_data[43]}]
set_drive 1  [get_ports {i_in_data[42]}]
set_drive 1  [get_ports {i_in_data[41]}]
set_drive 1  [get_ports {i_in_data[40]}]
set_drive 1  [get_ports {i_in_data[39]}]
set_drive 1  [get_ports {i_in_data[38]}]
set_drive 1  [get_ports {i_in_data[37]}]
set_drive 1  [get_ports {i_in_data[36]}]
set_drive 1  [get_ports {i_in_data[35]}]
set_drive 1  [get_ports {i_in_data[34]}]
set_drive 1  [get_ports {i_in_data[33]}]
set_drive 1  [get_ports {i_in_data[32]}]
set_drive 1  [get_ports {i_in_data[31]}]
set_drive 1  [get_ports {i_in_data[30]}]
set_drive 1  [get_ports {i_in_data[29]}]
set_drive 1  [get_ports {i_in_data[28]}]
set_drive 1  [get_ports {i_in_data[27]}]
set_drive 1  [get_ports {i_in_data[26]}]
set_drive 1  [get_ports {i_in_data[25]}]
set_drive 1  [get_ports {i_in_data[24]}]
set_drive 1  [get_ports {i_in_data[23]}]
set_drive 1  [get_ports {i_in_data[22]}]
set_drive 1  [get_ports {i_in_data[21]}]
set_drive 1  [get_ports {i_in_data[20]}]
set_drive 1  [get_ports {i_in_data[19]}]
set_drive 1  [get_ports {i_in_data[18]}]
set_drive 1  [get_ports {i_in_data[17]}]
set_drive 1  [get_ports {i_in_data[16]}]
set_drive 1  [get_ports {i_in_data[15]}]
set_drive 1  [get_ports {i_in_data[14]}]
set_drive 1  [get_ports {i_in_data[13]}]
set_drive 1  [get_ports {i_in_data[12]}]
set_drive 1  [get_ports {i_in_data[11]}]
set_drive 1  [get_ports {i_in_data[10]}]
set_drive 1  [get_ports {i_in_data[9]}]
set_drive 1  [get_ports {i_in_data[8]}]
set_drive 1  [get_ports {i_in_data[7]}]
set_drive 1  [get_ports {i_in_data[6]}]
set_drive 1  [get_ports {i_in_data[5]}]
set_drive 1  [get_ports {i_in_data[4]}]
set_drive 1  [get_ports {i_in_data[3]}]
set_drive 1  [get_ports {i_in_data[2]}]
set_drive 1  [get_ports {i_in_data[1]}]
set_drive 1  [get_ports {i_in_data[0]}]
set_drive 1  [get_ports i_out_ready]