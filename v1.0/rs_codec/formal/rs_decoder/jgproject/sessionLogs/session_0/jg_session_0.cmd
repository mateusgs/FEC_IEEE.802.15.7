#----------------------------------------
# JasperGold Version Info
# tool      : JasperGold 2019.06
# platform  : Linux 3.10.0-1127.13.1.el7.x86_64
# version   : 2019.06p001 64 bits
# build date: 2019.08.01 18:19:57 PDT
#----------------------------------------
# started Sat Aug 15 19:19:53 BRT 2020
# hostname  : optmaS1
# pid       : 23313
# arguments : '-label' 'session_0' '-console' 'optmaS1:34506' '-style' 'windows' '-data' 'AQAAADx/////AAAAAAAAA3oBAAAAEABMAE0AUgBFAE0ATwBWAEU=' '-proj' '/home/Mateus/workspace/UFMG_digital_design/rs_codec/formal/rs_decoder/jgproject/sessionLogs/session_0' '-init' '-hidden' '/home/Mateus/workspace/UFMG_digital_design/rs_codec/formal/rs_decoder/jgproject/.tmp/.initCmds.tcl' 'run_formal_functional_reqs.tcl'
proc run_checks_with_disturber {N K RS_GF} {
    clear -all
    run_design_compilation $N $K $RS_GF "disturber"
    clock clk
    reset rst
    #TODO:Remove this constraint
    assume -env i_consume
    set TWO_TIMES_T [expr {$N - $K}]
    rs_decoder_stall_checks $TWO_TIMES_T
    rs_decoder_reset_checks $N $TWO_TIMES_T
    rs_decoder_codeword_check $N $K $TWO_TIMES_T "disturber"
}

proc run_checks_with_post_syndrome {N K RS_GF} {
    clear -all
    run_design_compilation $N $K $RS_GF "syndrome"
    clock clk
    reset rst
    set TWO_TIMES_T [expr {$N - $K}]
    rs_decoder_consume_checks
    rs_decoder_stall_checks $TWO_TIMES_T
    rs_decoder_reset_checks $N $TWO_TIMES_T
    rs_decoder_codeword_check $N $K $TWO_TIMES_T "syndrome"
}

clear -all
source requirements.itcl
source compilation.itcl
source procs.itcl

set params [get_parameters]

foreach param $params {
    set N [lindex $param 0]
    set K [lindex $param 1] 
    set RS_GF [lindex $param 2] 
    
    #run_checks_with_disturber $N $K $RS_GF
    run_checks_with_post_syndrome $N $K $RS_GF
}
assert {w_error_counter = 0 and DUT.w_syndrome_valid |-> DUT.w_syndrome_fifo_input}
prove -bg -property {formal::property:17}
assert {w_error_counter = 0 and DUT.w_syndrome_valid |-> DUT.w_syndrome_fifo_input = 0}
prove -bg -property {formal::property:18}
visualize -violation -property formal::property:18 -new_window
assert {o_syn = 0 and w_error_counter = 0 and DUT.w_syndrome_valid |-> DUT.w_syndrome_fifo_input = 0}
assert {o_syndrome = 0 and w_error_counter = 0 and DUT.w_syndrome_valid |-> DUT.w_syndrome_fifo_input = 0}
prove -bg -property {formal::property:19}
assert {o_syndrome = 0 and w_error_counter > 0 and DUT.w_syndrome_valid |-> DUT.w_syndrome_fifo_input /= 0}
prove -bg -property {formal::property:20}
visualize -violation -property formal::property:20 -new_window
assert {o_syndrome = 0 and w_error_counter = 1 and DUT.w_syndrome_valid |-> DUT.w_syndrome_fifo_input /= 0}
prove -bg -property {formal::property:21}
assert {o_syndrome = 0 and w_error_counter = 2 and DUT.w_syndrome_valid |-> DUT.w_syndrome_fifo_input /= 0}
prove -bg -property {formal::property:22}
source {procs.itcl}
include {run_formal_functional_reqs.tcl}
include {run_formal_functional_reqs.tcl}
include {run_formal_functional_reqs.tcl}
include {run_formal_functional_reqs.tcl}
include {run_formal_functional_reqs.tcl}
include {run_formal_functional_reqs.tcl}
include {run_formal_functional_reqs.tcl}
source {procs.itcl}
source {compilation.itcl}
source {requirements.itcl}
source {requirements.itcl}
include {run_formal_functional_reqs.tcl}
include {run_formal_functional_reqs.tcl}
include {run_formal_functional_reqs.tcl}
include {run_formal_functional_reqs.tcl}
include {run_formal_functional_reqs.tcl}
include {run_formal_functional_reqs.tcl}
assert { w_consume_error |-> w_erroneous_symbol = o_symbol}
prove -bg -property {formal::property:21}
visualize -violation -property formal::property:21 -new_window
assert { w_consume_error and w_error_counter = 2 |-> w_erroneous_symbol = o_symbol}
prove -bg -property {formal::property:22}
assert { w_consume_error and w_error_counter = 1 |-> w_erroneous_symbol = o_symbol}
prove -bg -property {formal::property:23}
visualize -violation -property formal::property:23 -new_window
include {run_formal_functional_reqs.tcl}
include {run_formal_functional_reqs.tcl}
prove -bg -property {formal::property:17}
prove -bg -property {formal::property:18}
prove -bg -property {formal::property:19}
visualize -violation -property formal::property:18 -new_window
include {run_formal_functional_reqs.tcl}
prove -bg -property {formal::property:21}
prove -bg -property {formal::property:22}
prove -bg -property {formal::property:23}
prove -bg -property {formal::property:17}
prove -bg -property {formal::property:18}
visualize -violation -property formal::property:18 -new_window
include {run_formal_functional_reqs.tcl}
prove -bg -property {formal::property:17}
prove -bg -property {formal::property:18}
prove -bg -property {formal::property:19}
complexity_manager -property {formal::property:19}
complexity_manager -property {formal::property:18}
formal_profiler -property {formal::property:23} -engine B
assert {always w_error_counter = 2 |-> o_syndrome = 0 and w_consume_error and w_error_counter = 2 |-> w_erroneous_symbol = o_symbol}
prove -bg -property {formal::property:24}
prove -bg -property {formal::property:24} -mode Ht
prove -bg -property {formal::property:24} -engine Ht
assert {always w_error_counter = 2 |-> o_syndrome = 0 and w_consume_error |-> w_erroneous_symbol = o_symbol}
prove -bg -property {formal::property:25}
prove -all ht
prove -add ht
prove -add Tri
always w_error_counter = 2 |-> o_syndrome = 0 and w_consume_error |-> w_erroneous_symbol = o_symbol
assert {always w_error_counter = 2 |-> o_syndrome = 0 and w_consume_error |-> w_erroneous_symbol = o_symbol
}
assert {always w_error_counter = 1 and o_syndrome = 0 and !w_consume_error |-> DUT.w_symbol_correction = 0}
assert {always w_error_counter = 1 and o_syndrome = 0 and not w_consume_error |-> DUT.w_symbol_correction = 0}
prove -bg -property {formal::property:27}
assert {o_valid and w_error_counter = 1 and o_syndrome = 0 and not w_consume_error |-> DUT.w_symbol_correction = 0}
prove -bg -property {formal::property:28}
assume always w_error_counter = 2 |-> o_syndrome = 0 and w_consume_error |-> w_erroneous_symbol = o_symbol
assume w_inc_error_counter -bound 2
prove -bg -property {formal::property:25}
assume -disable formal::assume:8
assume w_inc_error_counter -bound 1
prove -bg -property {formal::property:25}
assume -disable formal::assume:9
prove -bg -property {formal::property:25}
cover {DUT.RS_CHIEN_FORNEY_INST.w_has_error}
prove -bg -property {formal::cover:4}
visualize -property formal::cover:4 -new_window
assert { w_consume_error |-> w_erroneous_symbol = o_symbol}
cover {o_valid and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error)}
prove -bg -property {formal::cover:5}
visualize -property formal::cover:5 -new_window
cover {o_syndrome = 0 and o_valid and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error)}
prove -bg -property {formal::cover:6}
visualize -property formal::cover:6 -new_window
assert {always w_error_counter = 2 |-> o_syndrome = 0 and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error) |-> w_consume_error}
prove -bg -property {formal::property:30}
assert {always w_error_counter = 2 |-> o_syndrome = 0 and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error) and o_valid|-> w_consume_error}
prove -bg -property {formal::property:31}
visualize -violation -property formal::property:31 -new_window
always w_error_counter = 2 |-> $past(DUT.RS_CHIEN_FORNEY_INST.w_select_input) and o_syndrome = 0 and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error) and o_valid |-> w_consume_error
always w_error_counter = 2 |-> $past(DUT.RS_CHIEN_FORNEY_INST.w_select_input) and o_syndrome = 0 and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error) and o_valid |-> w_consume_error
always w_error_counter = 2 |->  o_syndrome = 0 and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error) and o_valid and $past(DUT.RS_CHIEN_FORNEY_INST.w_select_input) |-> w_consume_error
assert {always w_error_counter = 2 |->  o_syndrome = 0 and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error) and o_valid and $past(DUT.RS_CHIEN_FORNEY_INST.w_select_input) |-> w_consume_error}
prove -bg -property {formal::property:32}
assume -enable formal::assume:9
prove -bg -property {formal::property:32}
assume -bound 2 -name {formal::assume:9} {##1 1 |-> w_inc_error_counter} -type temporary -update_db -replace;
prove -bg -property {formal::cover:6}
visualize -property formal::cover:6 -new_window
cover {always w_error_counter = 2 |->  o_syndrome = 0 and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error) and o_valid and $past(DUT.RS_CHIEN_FORNEY_INST.w_select_input) |-> w_consume_error
}
prove -bg -property {formal::cover:7}
visualize -property formal::cover:7 -new_window
visualize -property formal::cover:7 -new_window
prove -bg -property {formal::property:32}
set_engine_mode ht
prove -bg -property {formal::property:32}
set_engine_mode auto
assume -bound 1 -name {formal::assume:9} {w_inc_error_counter} -type temporary -update_db -replace;
prove -bg -property {formal::property:32}
prove -bg -property {formal::cover:7}
visualize -property formal::cover:7 -new_window
visualize -property formal::cover:7 -new_window
assume -remove formal::assume:9
assume {not w_inc_error_counter ##1 w_inc_error_counter} -bound 2
prove -bg -property {formal::cover:7}
assume {not w_inc_error_counter |=>1 w_inc_error_counter} -bound 2
assume {not w_inc_error_counter |=> w_inc_error_counter} -bound 2
assume -disable formal::assume:10
assume -remove formal::assume:10
assert -disable formal:::noConflict
prove -bg -property {formal::cover:7}
visualize -property formal::cover:7 -new_window
assume -remove formal::assume:11
assume {not w_inc_error_counter} -bound 1
prove -bg -property {formal::property:32}
prove -bg -property {formal::cover:7}
cover {always w_error_counter = 2 |->  o_syndrome = 0 and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error) and o_valid and $past(DUT.RS_CHIEN_FORNEY_INST.w_select_input) |-> w_consume_error
}
cover {w_error_counter = 2 and  o_syndrome = 0 and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error) and o_valid and $past(DUT.RS_CHIEN_FORNEY_INST.w_select_input) |-> w_consume_error
}
prove -bg -property {formal::cover:9}
assume -disable formal::assume:12
prove -bg -property {formal::cover:9}
assume -enable formal::assume:12
prove -bg -property {formal::cover:9}
assume -disable formal::assume:12
assume {w_disturb_input = 0} -bound 1
prove -bg -property {formal::cover:9}
cover {w_disturb_input = 1}
prove -bg -property {formal::cover:10}
visualize -property formal::cover:10 -new_window
cover {w_error_counter = 2 and  o_syndrome = 0 and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error) and o_valid and $past(DUT.RS_CHIEN_FORNEY_INST.w_select_input) |-> w_consume_error
}
cover {w_error_counter = 1 and  o_syndrome = 0 and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error) and o_valid and $past(DUT.RS_CHIEN_FORNEY_INST.w_select_input) |-> w_consume_error
}
prove -bg -property {formal::cover:12}
w_error_counter = 1 and  o_syndrome = 0 and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error) and o_valid and $past(DUT.RS_CHIEN_FORNEY_INST.w_select_input) |-> w_consume_error
w_error_counter = 1 and  o_syndrome = 0 and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error) and o_valid and $past(DUT.RS_CHIEN_FORNEY_INST.w_select_input) |-> w_consume_error
w_error_counter = 1 and  o_syndrome = 0 and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error) and o_valid and $past(DUT.RS_CHIEN_FORNEY_INST.w_select_input) |-> w_consume_error
assert {w_error_counter = 2 and  o_syndrome = 0 and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error) and o_valid and not $past(DUT.RS_CHIEN_FORNEY_INST.w_select_input) |-> w_consume_error}
assert {w_error_counter = 2 and  o_syndrome = 0 and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error) and o_valid and $past(not DUT.RS_CHIEN_FORNEY_INST.w_select_input) |-> w_consume_error}
prove -bg -property {formal::property:33}
assume -disable formal::assume:13
assume -enable formal::assume:8
prove -bg -property {formal::property:33}
visualize -violation -property formal::property:33 -new_window
visualize -violation -property formal::property:33 -new_window
assert {w_error_counter = 2 and  o_syndrome = 0 and DUT.RS_CHIEN_FORNEY_INST.w_has_error and o_valid  |-> w_consume_error}
prove -bg -property {formal::property:34}
assume -bound 1 -name {formal::assume:8} {w_inc_error_counter} -type temporary -update_db -replace;
prove -bg -property {formal::property:34}
prove -bg -property {formal::formal_req_2}
assert -disable formal::formal_req_2
assume -disable formal::assume:8
assume {w_inc_error_counter
fffff}
assume {not w_inc_error_counter ##1 w_inc_error_counter} -bound 2
prove -bg -property {formal::property:34}
prove -bg -property {formal::property:33}
prove -bg -property {formal::cover:12}
prove -bg -property {formal::cover:11}
prove -bg -property {formal::cover:10}
prove -bg -property {formal::cover:9}
assume -bound 2 -name {formal::assume:14} {not w_inc_error_counter |=> w_inc_error_counter} -type temporary -update_db -replace;
prove -bg -property {formal::cover:12}
prove -bg -property {formal::property:34}
visualize -property formal::cover:12 -new_window
assume -disable formal::assume:14
assume -bound 1 -name {formal::assume:14} {not w_inc_error_counter} -type temporary -update_db -replace;
assume {not w_inc_error_counter
dd
}
assume {not w_inc_error_counter |=> w_inc_error_counter}
assume -remove formal::assume:15
assume {not w_inc_error_counter |=> w_inc_error_counter} -bound 2
prove -bg -property {formal::property:34}
w_error_counter = 1 and  o_syndrome = 0 and $past(DUT.RS_CHIEN_FORNEY_INST.w_has_error) and o_valid and $past(DUT.RS_CHIEN_FORNEY_INST.w_select_input) |-> w_consume_error
cover {w_error_counter = 2 and  o_syndrome = 0 and DUT.RS_CHIEN_FORNEY_INST.w_has_error and o_valid |-> w_consume_error}
prove -bg -property {formal::cover:13}
visualize -property formal::cover:13 -new_window
