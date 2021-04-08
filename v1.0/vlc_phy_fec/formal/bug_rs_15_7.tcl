source compilation.itcl

proc load_trace_and_save_vcd {coding_type frame_type mcs_id start_cycle end_cycle} {
	puts "INFO: Loading SHM trace for mcs_id=$mcs_id and $coding_type mode fron $start_cycle to $end_cycle"
	visualize -load -shm [get_proj_dir]/shm_mcs_id_$mcs_id \
		-hier_map -from vlc_phy_fec_tb.DUT -to vlc_phy_fec \
		-start_time $start_cycle -end_time $end_cycle -time_scale 10ns
	set signals [get_design_info -list signal]
	foreach sig $signals { visualize -add_sig $sig }
	visualize -save -vcd ../traces/vcd_${frame_type}_${coding_type}_mcs_id_${mcs_id} -force
}

proc save_trace {mcs_id\
		 frame_type} {
	catch {visualize -remove_sig clk -reset_window}
	set inputs [get_design_info -instance DUT -list input]
	foreach sig $inputs { visualize -add_sig dut.$sig -reset_window }
	#TODO: Do we need time scale here?
	#TODO: visualize -time_scale 36ns -save -shm [get_proj_dir]/shm_mcs_id_$mcs_id -hier_map -from vlc_phy_fec_tb -to . -reset_window -force
	set last_decoder_cycle [check_end END_FLOW]
	set last_encoder_cycle [check_end CONFIG_DECODER]
	set first_encoder_cycle 0
	set first_decoder_cycle [expr {$last_encoder_cycle + 1}]
	visualize -save -shm [get_proj_dir]/shm_mcs_id_$mcs_id -reset_window -force -last_cycle $last_decoder_cycle
	clear -all
	compile_end_to_end
	clock clk
	reset -none
	load_trace_and_save_vcd encoder $frame_type $mcs_id $first_encoder_cycle $last_encoder_cycle
	load_trace_and_save_vcd decoder $frame_type $mcs_id $first_decoder_cycle $last_decoder_cycle
}

proc check_end {state} {
	set r_state_values [visualize -get_value FEC_CHECKER.FSM_CHECKER.r_state -reset_window]
	set result [lsearch -exact $r_state_values $state]
	if {$result == -1} {
		error "ERROR: $state was not reached"
	} else {
		set result [expr {$result - 1}]
		puts "INFO: $state reached"
	}
	return $result
}

proc check_values {} {
	set dec_valid [visualize -get_value w_o_valid_dec -reset_window]
	set dec_valid_ids [lsearch -exact $dec_valid "1'b1"]
	set dec_values [visualize -get_value w_o_data_dec -reset_window]
	set enc_values [visualize -get_value FEC_CHECKER.r_rom_enc_output -reset_window]
	set result 1
	foreach id $dec_valid_ids {
		set dec [lindex $dec_values $id]
		set enc [lindex $enc_values $id]
		if {$dec != $enc} {
			error "ERROR: Wrong values ($dec (dec) != $enc (enc)) - cycle $id"
		}
	}
	puts "INFO: dec == enc!"
}

proc get_dec_frame_size {FRAME_SIZE N K HAS_RATE RATE_2_3} {
	set after_rs_size [expr {$FRAME_SIZE + ($FRAME_SIZE/$K)*($N-$K)}]
	set last_cw [expr {$FRAME_SIZE%$K}]
	if  {$last_cw != 0} {
		set after_rs_size [expr {$after_rs_size + $N - $K}]
	}
	if {$HAS_RATE} {
		if {$RATE_2_3} {
			set after_rs_size [expr {$after_rs_size*2 + 3}]
		} else {
			set after_rs_size [expr {$after_rs_size*4 + 6}]
		}
	}
	return $after_rs_size
}

proc get_test_parameters {MCS_ID frame_type} {
	set frame_size 0
	if {$frame_type == "short"} {
		#original
		#set frame_size 63
		set frame_size 64
	} else {
		set frame_size 1023
	}
	if {$MCS_ID == 0} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 15 7 1 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 1} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 15 11 1 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 2} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 15 11 1 1]\
			$MCS_ID]
	} elseif {$MCS_ID == 3} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 15 11 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 4} {
		return [list $frame_size\
			     $frame_size\
			     $MCS_ID]
	} elseif {$MCS_ID == 5} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 15 2 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 6} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 15 4 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 7} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 15 7 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 8} {
		return [list $frame_size\
			     $frame_size\
			     $MCS_ID]
	} elseif {$MCS_ID == 16} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 64 32 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 17} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 160 128 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 18} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 64 32 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 19} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 160 128 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 20} {
		return [list $frame_size\
			     $frame_size\
			     $MCS_ID]
	} elseif {$MCS_ID == 21} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 64 32 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 22} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 160 128 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 23} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 64 32 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 24} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 160 128 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 25} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 64 32 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 26} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 160 128 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 27} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 64 32 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 28} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 160 128 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 29} {
		return [list $frame_size\
			     $frame_size\
			     $MCS_ID]
	} elseif {$MCS_ID == 32} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 64 32 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 33} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 64 32 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 34} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 64 32 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 35} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 64 32 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 36} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 64 32 0 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 37} {
		return [list $frame_size\
			     $frame_size\
			     $MCS_ID]
	} elseif {$MCS_ID == 38} {
		return [list $frame_size\
			     $frame_size\
			     $MCS_ID]
	} else {
		error "ERROR: invalid MCS ID"
	}
}

proc generate_fec_constants {} {
	exec python vhd_generator_for_rs_constants.py 
	exec mv vlc_phy_fec_constants.vhd ../../rtl
}

proc load_design {params} {
	clear -all
	set input_frame_size [lindex $params 0]
	set encoded_frame_size [lindex $params 1]
	set mcs_id [lindex $params 2]
	puts "INFO : Compiling vlc_phy_fec for input_frame_size=$input_frame_size,\
					       encoded_frame_size=$encoded_frame_size,\
					       and mcs_id=$mcs_id"
	compile_end_to_end_tb $input_frame_size\
			      $encoded_frame_size\
			      $mcs_id
	stopat -env clk
	clock clk
	reset -sequence seq
}

proc check_end_to_end {mcs_id frame_type save_trace} {
	set params [get_test_parameters $mcs_id $frame_type]
	load_design $params
	visualize -reset
	check_end END_FLOW
	check_values
	if {$save_trace} {
		save_trace $mcs_id $frame_type
	}
}


clear -all
#set mcs_id {0 1 2 3 4 5 6 7 8 16 17 18 19 20 21 22 23 24 25 26 27 28 29 32 33 34 35 36 37 38}
set mcs_id {7}
set has_short_frame 1
set has_long_frame 0
set generate_fec_constants 0
set save_trace 0

if {$generate_fec_constants} { 
	generate_fec_constants 
}

foreach id $mcs_id {
	if {$has_short_frame} {
		check_end_to_end $id short $save_trace
	}
	if {$has_long_frame} {
		check_end_to_end $id long $save_trace
	}
}
