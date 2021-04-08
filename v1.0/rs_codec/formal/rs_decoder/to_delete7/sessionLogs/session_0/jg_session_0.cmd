#----------------------------------------
# JasperGold Version Info
# tool      : JasperGold 2019.06
# platform  : Linux 3.10.0-1127.13.1.el7.x86_64
# version   : 2019.06p001 64 bits
# build date: 2019.08.01 18:19:57 PDT
#----------------------------------------
# started Thu Jul 30 01:16:41 BRT 2020
# hostname  : optmaS1
# pid       : 25025
# arguments : '-label' 'session_0' '-console' 'optmaS1:38098' '-style' 'windows' '-data' 'AQAAADx/////AAAAAAAAA3oBAAAAEABMAE0AUgBFAE0ATwBWAEU=' '-proj' '/home/Mateus/workspace/UFMG_digital_design/rs_codec/formal/rs_decoder/to_delete7/sessionLogs/session_0' '-init' '-hidden' '/home/Mateus/workspace/UFMG_digital_design/rs_codec/formal/rs_decoder/to_delete7/.tmp/.initCmds.tcl' 'run_formal_functional_reqs.tcl'
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
prove -bg -all
