#----------------------------------------
# JasperGold Version Info
# tool      : JasperGold 2019.06
# platform  : Linux 3.10.0-1062.4.3.el7.x86_64
# version   : 2019.06p001 64 bits
# build date: 2019.08.01 18:19:57 PDT
#----------------------------------------
# started Tue Apr 21 22:50:34 BRT 2020
# hostname  : optmaS1
# pid       : 5212
# arguments : '-label' 'session_0' '-console' 'optmaS1:36920' '-style' 'windows' '-data' 'AQAAADx/////AAAAAAAAA3oBAAAAEABMAE0AUgBFAE0ATwBWAEU=' '-proj' '/home/Mateus/Área de trabalho/UFMG_digital_design/block_interleaver/formal/mem_size_438_2/sessionLogs/session_0' '-init' '-hidden' '/home/Mateus/Área de trabalho/UFMG_digital_design/block_interleaver/formal/mem_size_438_2/.tmp/.initCmds.tcl' 't.tcl'
clear -all
set_elaborate_single_run_mode off

proc dut_compilation {MEM_SIZE ROW_NUM WIDTH MODE FUNC_REQ} {
analyze -vhdl08 -L GENERIC_TYPES ../../generic_components/generic_types.vhd
analyze -vhdl08 -L GENERIC_FUNCTIONS ../../generic_components/generic_functions.vhd
analyze -vhdl08 -L GENERIC_COMPONENTS ../../generic_components/generic_components.vhd
analyze -vhdl08 -L BLOCK_INTERLEAVER_COMPONENTS ../rtl/block_interleaver_components.vhd
analyze -vhdl08 ../rtl/block_interleaver.vhd\
		../rtl/rectangular_interleaver.vhd\
		../rtl/interleaver_controller.vhd\
		../rtl/interleaver_data_path.vhd\
		../rtl/block_interleaver_components/flag_signals_generator.vhd\
		../rtl/block_interleaver_components/m2D_index_counter.vhd\
		../rtl/block_interleaver_components/wr_rd_status_selector.vhd\
		../rtl/rectangular_deinterleaver.vhd\
		../rtl/deinterleaver_data_path.vhd\
		../rtl/block_interleaver_components/simplified_m2D_index_counter.vhd\
		../rtl/block_interleaver_components/m2D_index_counter_core.vhd\
		../rtl/block_interleaver_components/wr_rd_status_selector.vhd\
		../../generic_components/adder/adder.vhd\
		../../generic_components/single_port_2D_ram/single_port_2D_ram.vhd\
		../../generic_components/single_port_linear_ram/single_port_linear_ram.vhd\
		../../generic_components/decrementer/half_subtractor_unit.vhd\
		../../generic_components/decrementer/decrementer.vhd\
		../../generic_components/incrementer/half_adder_unit.vhd\
		../../generic_components/incrementer/incrementer.vhd\
		../../generic_components/up_down_counter/up_down_counter.vhd\
		../../generic_components/sync_ld_dff/sync_ld_dff.vhd\
		../../generic_components/comparator/comparator.vhd
if {$FUNC_REQ} {
	analyze -vhdl08 rtl/block_interleaver_func_verification_model.vhd
	elaborate -vhdl -top block_interleaver_func_verification_model -parameter NUMBER_OF_ELEMENTS $MEM_SIZE -parameter NUMBER_OF_LINES $ROW_NUM -parameter WORD_LENGTH $WIDTH -bbox_a 900000

} else {
	analyze -sv09 block_interleaver_fv.sv
	elaborate -vhdl -top block_interleaver -parameter NUMBER_OF_ELEMENTS $MEM_SIZE -parameter NUMBER_OF_LINES $ROW_NUM -parameter WORD_LENGTH $WIDTH -parameter MODE $MODE -bbox_a 900000
}
}

proc formal_setup {} {
	clock clk
	reset rst
}

proc func_req_constraints {MEM_SIZE ROW_NUM WIDTH } {
clear -all
dut_compilation $MEM_SIZE $ROW_NUM $WIDTH false 1
set_property_compile_time_limit 30s

task -create func -set
#Forcing i_start_cw to 1 for the first cycle
assume -bound 1 i_start_cw
assume {i_start_cw |=> not i_start_cw} 
assume {not i_start_cw |=> not i_start_cw} 

set bound [expr {$MEM_SIZE - 1}]
set CMD "assume \{i_start_cw |-> not i_end_cw and i_valid \[*1:$bound\] ##1 i_end_cw and i_valid\}"
eval $CMD
assume {i_end_cw |=> not i_valid}
assume {not i_valid |=> not i_valid}
#Not required anymore
#assume {not i_valid |-> not i_end_cw}

#External blocks always ready to consume info.
assume {i_consume_int}
assume {i_consume_deint}


#assume  {DEINTERLEAVER_INST.i_consume = INTERLEAVER_INST.o_valid}
assume {not INTERLEAVER_INST.GEN_INT.INTERLEAVER_INST.IDP.w_wr_rd_status |-> not w_valid}
assume {not DEINTERLEAVER_INST.GEN_INT.DEINTERLEAVER_INST.IDP.w_wr_rd_status |-> not o_valid}
assert {o_valid and o_cnt = 1 |-> o_saved_data = o_data}
cover {o_valid and o_cnt = 1 |-> o_saved_data = o_data}
cover {o_end_cw}

clock clk
reset rst
set proof_bound [expr {$MEM_SIZE*2 + 2}]
set_prove_target_bound $proof_bound
set_max_trace_length $proof_bound
set_prove_time_limit 80h
set_engine_mode {Tri Ht}
prove -task func
check_return {get_property_list -include {status {cex unreachable}} -task func} {}
set_prove_target_bound 0
set_max_trace_length 0
}


proc interface_control_and_reset_req {MEM_SIZE ROW_NUM WIDTH is_interleaver} {
clear -all
dut_compilation $MEM_SIZE $ROW_NUM $WIDTH $is_interleaver 0
connect -bind -auto block_interleaver_fv block_interleaver_top -auto -elaborate -parameter NUMBER_OF_ELEMENTS $MEM_SIZE -parameter NUMBER_OF_LINES $ROW_NUM -parameter WORD_LENGTH $WIDTH
formal_setup
task -create reset -set -source_task <embedded> -copy_stopats -copy_abstractions all -copy_assumes -copy <embedded>::block_interleaver.block_interleaver_top.REQ_INTER_001_CHECK_01
task -set reset
reset -none
check_return {prove -task reset} "proven"
reset rst
task -set <embedded>
assert -disable <embedded>::block_interleaver.block_interleaver_top.REQ_INTER_001_CHECK_01
prove -all
check_return {get_property_list -include {status {cex unreachable}}} {}
task -create stall -set
if {$is_interleaver == false} {
assert {GEN_INT.INTERLEAVER_INST.IC.w_current_state = 1 and not i_valid and not GEN_INT.INTERLEAVER_INST.IC.i_full_ram |=> ##1 $past(GEN_INT.INTERLEAVER_INST.IDP.r_col_cnt) = GEN_INT.INTERLEAVER_INST.IDP.r_col_cnt and\
					     $past(GEN_INT.INTERLEAVER_INST.IDP.w_ram_wr_en = 0) and\
				             $past(GEN_INT.INTERLEAVER_INST.IDP.r_lin_cnt) = GEN_INT.INTERLEAVER_INST.IDP.r_lin_cnt}
check_code "proven" [prove -task stall]
} else {
#assert {GEN_INT.DEINTERLEAVER_INST.IC.w_current_state = 1 and not i_valid and not GEN_INT.DEINTERLEAVER_INST.IC.i_full_ram ##1 i_end_cw = 0 |=> $past(GEN_INT.DEINTERLEAVER_INST.IDP.w_ram_wr_en) = 0 and\
						       $past(GEN_INT.DEINTERLEAVER_INST.IDP.w_ram_addr) = GEN_INT.DEINTERLEAVER_INST.IDP.w_ram_addr}
}


}

set MEM_SIZE 438
set ROW_NUM 15
set WIDTH 4
#time [interface_control_and_reset_req $MEM_SIZE $ROW_NUM $WIDTH false]
#time [interface_control_and_reset_req $MEM_SIZE $ROW_NUM $WIDTH true]
time [func_req_constraints $MEM_SIZE $ROW_NUM $WIDTH]
