# Setting environment
sh mkdir -p Netlist
sh mkdir -p Report

define_design_lib work -path ./work

set company {NTUGIEE}
set designer {Student}

set search_path      ". /home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/SynopsysDC/db  $search_path ../ ./"
set target_library   "slow.db "              
set link_library     "* $target_library dw_foundation.sldb"
set symbol_library   "tsmc13.sdb generic.sdb"
set synthetic_library "dw_foundation.sldb"
set default_schematic_options {-size infinite}


# Import Design
set DESIGN "ed25519"

set hdlin_translate_off_skip_text "TRUE"
set edifout_netlist_only "TRUE"
set verilogout_no_tri true

set hdlin_enable_presto_for_vhdl "TRUE"
set sh_enable_line_editing true
set sh_line_editing_mode emacs
history keep 100
alias h history

#read_file -format sverilog  "../01_RTL/ver2/ed25519.sv"
#read_file -format verilog  "flist.v"
#read_file -format verilog  "../01_RTL/ver2/ed25519.v  ../01_RTL/ver2/ALU.v ../01_RTL/ver2/RegFile.v  ../01_RTL/ver2/LUTFile.v  ../01_RTL/ver2/Mul.v  ../01_RTL/ver2/ModQ.v  ../01_RTL/ver2/ModularAdd.v  ../01_RTL/ver2/ModularSub.v"
#read_file -format sverilog  "../01_RTL/ver2/ed25519.sv  ../01_RTL/ver2/ALU.v ../01_RTL/ver2/RegFile.v  ../01_RTL/ver2/LUTFile.v  ../01_RTL/ver2/Mul.v  ../01_RTL/ver2/ModQ.v  ../01_RTL/ver2/ModularAdd.v  ../01_RTL/ver2/ModularSub.v"
#read_file -format sverilog  "../01_RTL/ver3/ed25519.sv  ../01_RTL/ver3/ALU.v ../01_RTL/ver3/RegFile.v  ../01_RTL/ver3/LUTFile.v  ../01_RTL/ver3/Mul.v  ../01_RTL/ver3/ModQ.v  ../01_RTL/ver3/ModularAdd.v  ../01_RTL/ver3/ModularSub.v"
#read_file -format sverilog  "../01_RTL/ver3_1/ed25519.sv  ../01_RTL/ver3_1/ALU.v ../01_RTL/ver3_1/RegFile.v  ../01_RTL/ver3_1/LUTFile.v  ../01_RTL/ver3_1/Mul.v  ../01_RTL/ver3_1/ModQ.v  ../01_RTL/ver3_1/ModularAdd.v  ../01_RTL/ver3_1/ModularSub.v"
#read_file -format sverilog  "../01_RTL/ver2_1/ed25519.sv  ../01_RTL/ver2_1/ALU.v ../01_RTL/ver2_1/RegFile.v  ../01_RTL/ver2_1/LUTFile.v  ../01_RTL/ver2_1/Mul.v  ../01_RTL/ver2_1/ModQ.v  ../01_RTL/ver2_1/ModularAdd.v  ../01_RTL/ver2_1/ModularSub.v"
#read_file -format sverilog  "../01_RTL/ver2_2/ed25519.sv  ../01_RTL/ver2_2/ALU.v ../01_RTL/ver2_2/RegFile.v  ../01_RTL/ver2_2/LUTFile.v  ../01_RTL/ver2_2/Mul.v  ../01_RTL/ver2_2/ModQ.v  ../01_RTL/ver2_2/ModularAdd.v  ../01_RTL/ver2_2/ModularSub.v"
#read_file -format sverilog  "../01_RTL/ver4_1/ed25519.sv  ../01_RTL/ver4_1/ALU.v ../01_RTL/ver4_1/RegFile.v  ../01_RTL/ver4_1/LUTFile.v  ../01_RTL/ver4_1/Mul.v  ../01_RTL/ver4_1/ModQ.v  ../01_RTL/ver4_1/ModularAdd.v  ../01_RTL/ver4_1/ModularSub.v"
#read_file -format sverilog  "../01_RTL/ver5/ed25519.sv  ../01_RTL/ver5/ALU.v ../01_RTL/ver5/RegFile.v  ../01_RTL/ver5/LUTFile.v  ../01_RTL/ver5/Mul.v  ../01_RTL/ver5/ModQ.v  ../01_RTL/ver5/ModularAdd.v  ../01_RTL/ver5/ModularSub.v"
read_file -format sverilog  "../01_RTL/ver5_1/ed25519.sv  ../01_RTL/ver5_1/ALU.v ../01_RTL/ver5_1/RegFile.v  ../01_RTL/ver5_1/LUTFile.v  ../01_RTL/ver5_1/Mul.v  ../01_RTL/ver5_1/ModQ.v  ../01_RTL/ver5_1/ModularAdd.v  ../01_RTL/ver5_1/ModularSub.v"

current_design [get_designs $DESIGN]
link

source -echo -verbose ./ed25519_dc.sdc

# Compile Design
current_design [get_designs ${DESIGN}]

check_design > Report/check_design.txt
check_timing > Report/check_timing.txt
#set high_fanout_net_threshold 0

uniquify
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]

#set_clock_gating_style -max_fanout 4
set_host_options -max_cores 16
#compile_ultra -no_autoungroup
compile_ultra -retime
#optimize_netlist -area
#compile_ultra -inc
#optimize_netlist -area


# Report Output
current_design [get_designs ${DESIGN}]
report_timing -delay min -max_paths 10 > "./Report/${DESIGN}_syn.timing_min" 
report_timing -delay max -max_paths 10 > "./Report/${DESIGN}_syn.timing_max"
report_area -hierarchy > "./Report/${DESIGN}_syn.area"
report_clock_gating > "./Report/${DESIGN}_syn.cg"

# Output Design
current_design [get_designs ${DESIGN}]

set bus_inference_style {%s[%d]}
set bus_naming_style {%s[%d]}
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed {a-z A-Z 0-9 _} -max_length 255 -type cell
define_name_rules name_rule -allowed {a-z A-Z 0-9 _[]} -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
define_name_rules name_rule -case_insensitive
change_names -hierarchy -rules name_rule

remove_unconnected_ports -blast_buses [get_cells -hierarchical *]
set verilogout_higher_designs_first true
write -format ddc     -hierarchy -output "./Netlist/${DESIGN}_syn.ddc"
write -format verilog -hierarchy -output "../03_GATE/${DESIGN}_syn.v"
write_sdf -version 2.1  -context verilog -load_delay cell ../03_GATE/${DESIGN}_syn.sdf
write_sdc  ./Netlist/${DESIGN}_syn.sdc -version 1.8

#exit