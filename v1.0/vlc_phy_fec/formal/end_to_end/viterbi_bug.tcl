source ../UFMG_digital_design/vlc_phy_fec/formal/compilation.tcl

proc get_dec_frame_size {FRAME_SIZE N K HAS_RATE RATE_2_3} {
	set after_rs_size [expr {$FRAME_SIZE + ($FRAME_SIZE/$K)*($N-$K)}]
	set last_cw [expr {$FRAME_SIZE%$K}]
	if  {$last_cw != 0} {
		set after_rs_size [expr {$after_rs_size + $N - $K}]
	}
	if {$HAS_RATE} {
		if {$RATE_2_3} {
			set after_rs_size [expr {$after_rs_size*4}]
		} else {
			set after_rs_size [expr {$after_rs_size*2}]
		}
	}
	return $after_rs_size
}

proc get_test_parameters {MCS_ID short_frame} {
	set frame_size 0
	if {$short_frame} {
		set frame_size 64
	} else {
		set frame_size 1023
	}
	if {$MCS_ID == 0} {
		return [list $frame_size\
			[get_dec_frame_size $frame_size 15 7 1 0]\
			$MCS_ID]
	} elseif {$MCS_ID == 1} {a
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
		puts "ERROR: invalid MCS ID"
		stop
	}
}

set mcs_id {3 4 5 6 7 8 16 17 18 19 20 21 22 23 24 25 26 27 28 29 32 33 34 35 36 37 38}


proc prove_end_to_end {mcs_id} {
clear -all
set param [get_test_parameters $mcs_id 1]
puts "param : $param"
exec cp ../UFMG_digital_design/vlc_phy_fec/scripts/vlc_phy_fec_constants.vhd ../UFMG_digital_design/vlc_phy_fec/rtl
compile_end_to_end [lindex $param 0]\
		   [lindex $param 1]\
		   [lindex $param 2]
reset rst
stopat -env clk
clock clk
cover {DUT.VPFD.VIT.VLC_PHY_DEPUNC.o_last_parity} -name bug
visualize -property <embedded>::bug -new_window
#plot DUT.VPFD.VIT.VLC_PHY_DEPUNC.o_valid
prove -all
}

prove_end_to_end 0
