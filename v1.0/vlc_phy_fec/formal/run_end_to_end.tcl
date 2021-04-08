source compilation.itcl
source jg_procs.itcl

clear -all
set mcs_id {0 1 2 3 4 5 6 7 8 16 17 18 19 20 21 22 23 24 25 26 27 28 29 32 33 34 35 36 37 38}
set short_decoder_trace_length {3120 1736 1205 204 152 1520 561 309 152 530 528 530 528 152 530 528 530 528 530 528 530 528 152 530 530 530 530 530 152 152}
set short_encoder_trace_length {707 467 467 111 86 503 263 159 86 151 119 151 119 86 151 119 151 119 151 119 151 119 86 151 151 151 151 151 86 86}
set unique_short_decoder_trace_length {3120 1736 1205 204 152 1520 561 309 530 528}
set unique_mcs_id {0 1 2 3 4 5 6 7 16 17}
#set mcs_id {3 4 5 6 7 8 16 17 18 19 20 21 22 23 24 25 26 27 28 29 32 33 34 35 36 37 38}
set has_short_frame 1
set has_long_frame 1
set generate_fec_constants 0
set save_rtl_trace 0
set save_gate_level_trace 0
set report_cycles 1
set do_checks 0
if {$generate_fec_constants} { 
	generate_fec_constants 
}

#set unique_short_decoder_trace_length {204 152 1520 561 309 530 528}
set unique_short_decoder_trace_length {200 200 1600 600 350 600 600 3200 1800 1500}
set unique_mcs_id {3 4 5 6 7 16 17 0 1 2}
foreach id $unique_mcs_id trace_length $unique_short_decoder_trace_length {
	puts "INFO: processing mcs_id $id"
	if {$has_short_frame} {
		check_end_to_end $id short $save_rtl_trace $save_gate_level_trace $report_cycles $do_checks $trace_length
	}
#	if {$has_long_frame} {
#		check_end_to_end $id long $save_rtl_trace $save_gate_level_trace $report_cycles $do_checks $trace_length
#	}
}
