source ../compilation.itcl

proc save_trace {params\
		 is_short_frame} {
	visualize -remove_sig clk -reset_window
	set inputs [get_design_info -instance DUT -list input]
	foreach sig $inputs { visualize -add_sig dut.$sig -reset_window }
	#TODO: Do we need time scale here?
	#TODO: visualize -time_scale 36ns -save -shm [get_proj_dir]/shm_mcs_id_$mcs_id -hier_map -from vlc_phy_fec_tb -to . -reset_window -force
	visualize -save -shm [get_proj_dir]/shm_mcs_id_$mcs_id -reset_window -force
	load_design $params
	visualize -load -shm [get_proj_dir]/shm_mcs_id_$mcs_id -hier_map -from vlc_phy_fec_tb.DUT -to vlc_phy_fec
	set frame_type [expr $is_short_frame == 1 ? "_short_" : "_long_"]
	visualize -save -vcd ../../traces/vcd_{$frame_type}_mcs_id_{$mcs_id} -force
	#TODO: Separate encoding and decoding procedures
}

proc check_end {} {
	set r_state_values [visualize -get_value FEC_CHECKER.FSM_CHECKER.r_state -reset_window]
	set result [lsearch -exact $r_state_values "END_FLOW"]
	if {$result == -1} {
		error "ERROR: END_FLOW was not reached"
	} else {
		puts "INFO: END_FLOW reached"
	}

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

proc get_test_parameters {MCS_ID short_frame} {
	set frame_size 0
	if {$short_frame} {
		#original
		#set frame_size 63
		set frame_size 63
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

proc check_end_to_end {mcs_id is_short_frame save_trace} {
	set params [get_test_parameters $mcs_id $is_short_frame]
	load_design $params
	visualize -reset
	check_end
	check_values
	if {$save_trace} {
		save_trace $params
	}
}

#set mcs_id {0 1 2 3 4 5 6 7 8 16 17 18 19 20 21 22 23 24 25 26 27 28 29 32 33 34 35 36 37 38}
set mcs_id {16}
set has_short_frame 1
set has_long_frame 0
set generate_fec_constants 0
set save_trace 1

if {$generate_fec_constants} { 
	generate_fec_constants 
}

foreach id $mcs_id {
	if {$has_short_frame} {
		check_end_to_end $id 1 $save_trace
	}
	if {$has_long_frame} {
		check_end_to_end $id 0 $save_trace
	}
}
