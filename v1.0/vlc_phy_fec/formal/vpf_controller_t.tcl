clear -all
set_elaborate_single_run_mode off

proc dut_compilation {CONV_SEL MCS_ID_LENGTH RS_CODEC_SEL PA_MODE} {
	analyze -vhdl08 -L GENERIC_TYPES ../../generic_components/rtl/generic_types.vhd
	analyze -vhdl08 -L GENERIC_FUNCTIONS ../../generic_components/rtl/generic_functions.vhd
	analyze -vhdl08 -L GENERIC_COMPONENTS ../../generic_components/rtl/generic_components.vhd
	analyze -vhdl08 -L VLC_PHY_FEC_COMPONENTS ../rtl/vlc_phy_fec_components.vhd
	analyze -vhdl08 ../rtl/vlc_phy_fec_controller.vhd\
			../rtl/vlc_phy_mcs_id_dec.vhd\
			../rtl/vlc_phy_fec_pmc.vhd\
			../../generic_components/rtl/sync_ld_dff.vhd
	
	elaborate -vhdl -top vlc_phy_fec_controller\
		-parameter CONV_SEL $CONV_SEL\
		-parameter MCS_ID_LENGTH $MCS_ID_LENGTH\
		-parameter RS_CODEC_SEL $RS_CODEC_SEL\
		-parameter PA_MODE $PA_MODE\
}




proc formal_setup {} {
	clock clk
	reset rst
}

dut_compilation 2 6 3 false

assert {i_release_fec and not i_sync_fec and o_busy |=> not o_busy}
cover {i_release_fec and not i_sync_fec and o_busy|=> not o_busy}

assert {i_sync_fec and not o_busy and not i_release_fec |=> o_busy and o_mode = $past(i_mode)}
cover {i_sync_fec and not o_busy and not i_release_fec|=> o_busy and o_mode = $past(i_mode)}

assert {i_sync_fec and not o_busy and i_mcs_id = "000000" |=> o_rs_codec_sel = "011" and o_conv_sel = "01"}
cover {i_sync_fec and not o_busy and i_mcs_id = "000000" |=> o_rs_codec_sel = "011" and o_conv_sel = "01"}

assert {i_sync_fec and not o_busy and i_mcs_id = "000001" |=> o_rs_codec_sel = "100" and o_conv_sel = "10"}
cover {i_sync_fec and not o_busy and i_mcs_id = "000001" |=> o_rs_codec_sel = "100" and o_conv_sel = "10"}

assert {i_sync_fec and not o_busy and i_mcs_id = "000010" |=> o_rs_codec_sel = "100" and o_conv_sel = "11"}
cover {i_sync_fec and not o_busy and i_mcs_id = "000010" |=> o_rs_codec_sel = "100" and o_conv_sel = "11"}

assert {i_sync_fec and not o_busy and i_mcs_id = "000011" |=> o_rs_codec_sel = "100" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "000011" |=> o_rs_codec_sel = "100" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "000100" |=> o_rs_codec_sel = "000" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "000100" |=> o_rs_codec_sel = "000" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "000101" |=> o_rs_codec_sel = "001" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "000101" |=> o_rs_codec_sel = "001" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "000110" |=> o_rs_codec_sel = "010" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "000110" |=> o_rs_codec_sel = "010" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "000111" |=> o_rs_codec_sel = "011" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "000111" |=> o_rs_codec_sel = "011" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "001000" |=> o_rs_codec_sel = "000" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "001000" |=> o_rs_codec_sel = "000" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "010000" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "010000" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "010001" |=> o_rs_codec_sel = "110" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "010001" |=> o_rs_codec_sel = "110" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "010010" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "010010" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "010011" |=> o_rs_codec_sel = "110" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "010011" |=> o_rs_codec_sel = "110" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "010100" |=> o_rs_codec_sel = "000" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "010100" |=> o_rs_codec_sel = "000" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "010101" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "010101" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "010110" |=> o_rs_codec_sel = "110" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "010110" |=> o_rs_codec_sel = "110" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "010111" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "010111" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "011000" |=> o_rs_codec_sel = "110" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "011000" |=> o_rs_codec_sel = "110" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "011001" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "011001" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "011010" |=> o_rs_codec_sel = "110" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "011010" |=> o_rs_codec_sel = "110" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "011011" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "011011" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "011100" |=> o_rs_codec_sel = "110" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "011100" |=> o_rs_codec_sel = "110" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "011101" |=> o_rs_codec_sel = "000" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "011101" |=> o_rs_codec_sel = "000" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "100000" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "100000" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "100001" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "100001" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "100010" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "100010" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "100011" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "100011" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "100100" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "100100" |=> o_rs_codec_sel = "101" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "100101" |=> o_rs_codec_sel = "000" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "100101" |=> o_rs_codec_sel = "000" and o_conv_sel = "00"}

assert {i_sync_fec and not o_busy and i_mcs_id = "100110" |=> o_rs_codec_sel = "000" and o_conv_sel = "00"}
cover {i_sync_fec and not o_busy and i_mcs_id = "100110" |=> o_rs_codec_sel = "000" and o_conv_sel = "00"}

formal_setup

prove -all

check_return {get_property_list -include {status {cex unreachable}} -task func} {}

