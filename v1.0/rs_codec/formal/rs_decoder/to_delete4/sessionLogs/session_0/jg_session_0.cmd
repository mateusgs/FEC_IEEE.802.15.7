#----------------------------------------
# JasperGold Version Info
# tool      : JasperGold 2019.06
# platform  : Linux 3.10.0-1127.13.1.el7.x86_64
# version   : 2019.06p001 64 bits
# build date: 2019.08.01 18:19:57 PDT
#----------------------------------------
# started Thu Jul 30 01:10:42 BRT 2020
# hostname  : optmaS1
# pid       : 11079
# arguments : '-label' 'session_0' '-console' 'optmaS1:33068' '-style' 'windows' '-data' 'AQAAADx/////AAAAAAAAA3oBAAAAEABMAE0AUgBFAE0ATwBWAEU=' '-proj' '/home/Mateus/workspace/UFMG_digital_design/rs_codec/formal/rs_decoder/to_delete4/sessionLogs/session_0' '-init' '-hidden' '/home/Mateus/workspace/UFMG_digital_design/rs_codec/formal/rs_decoder/to_delete4/.tmp/.initCmds.tcl' 'run_formal_reset_and_interface_control_reqs.tcl'
clear -all

source compilation.itcl
source requirements.itcl

foreach param [get_parameters] {
    set N [lindex $param 0]
    set K [lindex $param 1] 
    set RS_GF [lindex $param 2]
    set NUM_PARITY [expr {$N - $K}]
    run_design_compilation $N $K $RS_GF "only_decoder"
    #assume -env {i_consume}
    clock clk
    reset -none
    set rs_decoder_requirements [get_requirements]
    set rs_decoder_requirements [create_properties $rs_decoder_requirements "reset" $NUM_PARITY]
    prove -task reset

    reset rst
    set rs_decoder_requirements [create_properties $rs_decoder_requirements "protocol" $NUM_PARITY]
    prove -task protocol

    #TODO: Add functional requirement here.
}
