proc compile_design {is_power_aware is_only_encoder is_simplified} {
	puts "###GENUS(start): design compilation"
	read_hdl -vhdl {../../generic_components/rtl/generic_types.vhd\
			../../generic_components/rtl/generic_functions.vhd\
			../../generic_components/rtl/generic_components.vhd\
			../../generic_components/rtl/adder.vhd\
			../../generic_components/rtl/async_dff.vhd\
			../../generic_components/rtl/comparator.vhd\
			../../generic_components/rtl/config_dff_array.vhd\
			../../generic_components/rtl/d_sync_flop.vhd\
			../../generic_components/rtl/demultiplexer_array.vhd\
			../../generic_components/rtl/half_subtractor_unit.vhd\
			../../generic_components/rtl/half_adder_unit.vhd\
			../../generic_components/rtl/multiplexer_array.vhd\
			../../generic_components/rtl/no_rst_dff.vhd\
			../../generic_components/rtl/parallel_to_serial.vhd\
			../../generic_components/rtl/reg_fifo.vhd\
			../../generic_components/rtl/reg_fifo_array.vhd\
			../../generic_components/rtl/serial_to_parallel.vhd\
			../../generic_components/rtl/shifter_left.vhd\
			../../generic_components/rtl/single_port_2D_ram.vhd\
			../../generic_components/rtl/single_port_linear_ram.vhd\
			../../generic_components/rtl/sync_dff_array.vhd\
			../../generic_components/rtl/sync_ld_dff.vhd\
			../../generic_components/rtl/up_counter.vhd\
			../../generic_components/rtl/decrementer.vhd\
			../../generic_components/rtl/flop_cascade.vhd\
			../../generic_components/rtl/incrementer.vhd\
			../../generic_components/rtl/up_down_counter.vhd\
			../../rs_codec/rtl/rs_types.vhd}
	if {$is_simplified} {
		read_hdl -vhdl {../../rs_codec/rtl/rs_constants_simplified.vhd}
		read_hdl -vhdl {../../rs_codec/rtl/rs_functions_simplified.vhd}
		read_hdl -vhdl {../../rs_codec/rtl/rs_inverse_simplified.vhd}
	} else {
		read_hdl -vhdl {../../rs_codec/rtl/rs_constants.vhd}
		read_hdl -vhdl {../../rs_codec/rtl/rs_functions.vhd}
		read_hdl -vhdl {../../rs_codec/rtl/rs_inverse.vhd}
	}
	read_hdl -vhdl {../../rs_codec/rtl/rs_components.vhd\
			../../rs_codec/rtl/rs_adder.vhd\
			../../rs_codec/rtl/rs_full_multiplier_core.vhd\
			../../rs_codec/rtl/rs_multiplier_lut.vhd\
			../../rs_codec/rtl/rs_reduce_adder.vhd\
			../../rs_codec/rtl/rs_full_multiplier.vhd\
			../../rs_codec/rtl/rs_berlekamp_massey.vhd\
			../../rs_codec/rtl/rs_multiplier.vhd\
			../../rs_codec/rtl/rs_chien.vhd\
			../../rs_codec/rtl/rs_forney.vhd\
			../../rs_codec/rtl/rs_remainder_unit.vhd\
			../../rs_codec/rtl/rs_syndrome_subunit.vhd\
			../../rs_codec/rtl/rs_chien_forney.vhd\
			../../rs_codec/rtl/rs_encoder.vhd\
			../../rs_codec/rtl/rs_syndrome.vhd\
			../../rs_codec/rtl/rs_decoder.vhd\
			../../rs_codec/rtl/rs_encoder_wrapper.vhd\
			../../rs_codec/rtl/rs_codec.vhd\
			../../block_interleaver/rtl/block_interleaver_components.vhd\
			../../block_interleaver/rtl/interleaver_controller.vhd\
			../../block_interleaver/rtl/block_interleaver_components/wr_rd_status_selector.vhd\
			../../block_interleaver/rtl/block_interleaver_components/m2D_index_counter_core.vhd\
			../../block_interleaver/rtl/block_interleaver_components/flag_signals_generator.vhd\
			../../block_interleaver/rtl/block_interleaver_components/m2D_index_counter.vhd\
			../../block_interleaver/rtl/block_interleaver_components/simplified_m2D_index_counter.vhd\
			../../block_interleaver/rtl/deinterleaver_data_path.vhd\
			../../block_interleaver/rtl/interleaver_data_path.vhd\
			../../block_interleaver/rtl/rectangular_deinterleaver.vhd\
			../../block_interleaver/rtl/rectangular_interleaver.vhd\
			../../convolutional_codes/convolutional_encoder/rtl/convolutional_encoder_components.vhd\
			../../convolutional_codes/convolutional_encoder/rtl/convolutional_encoder_components/conv_flop_cascade.vhd\
			../../convolutional_codes/convolutional_encoder/rtl/convolutional_encoder.vhd\
		../../viterbi_decoder/depuncturing/rtl/depuncturing_1_3.vhd\
				../../viterbi_decoder/depuncturing/rtl/depuncturing_1_4.vhd\
				../../viterbi_decoder/depuncturing/rtl/depuncturing_2_3.vhd\
				../../convolutional_codes/puncturing/rtl/puncturing_1_3.vhd\
                        ../../convolutional_codes/puncturing/rtl/puncturing_1_4.vhd\
                        ../../convolutional_codes/puncturing/rtl/puncturing_2_3.vhd}

	read_hdl -vhdl -library dec_viterbi {../../viterbi_decoder/viterbi_decoder_axi4s/trunk/packages/pkg_helper.vhd\
						../../viterbi_decoder/rtl/pkg_param.vhd\
						../../viterbi_decoder/viterbi_decoder_axi4s/trunk/packages/pkg_param_derived.vhd\
						../../viterbi_decoder/viterbi_decoder_axi4s/trunk/packages/pkg_types.vhd\
						../../viterbi_decoder/viterbi_decoder_axi4s/trunk/packages/pkg_components.vhd\
						../../viterbi_decoder/viterbi_decoder_axi4s/trunk/packages/pkg_trellis.vhd\
				../../viterbi_decoder/viterbi_decoder_axi4s/trunk/src/acs.vhd\
				../../viterbi_decoder/viterbi_decoder_axi4s/trunk/src/axi4s_buffer.vhd\
				../../viterbi_decoder/viterbi_decoder_axi4s/trunk/src/branch_distance.vhd\
				../../viterbi_decoder/viterbi_decoder_axi4s/trunk/src/generic_sp_ram.vhd\
				../../viterbi_decoder/viterbi_decoder_axi4s/trunk/src/recursion.vhd\
				../../viterbi_decoder/viterbi_decoder_axi4s/trunk/src/reorder.vhd\
				../../viterbi_decoder/viterbi_decoder_axi4s/trunk/src/traceback.vhd\
		../../viterbi_decoder/viterbi_decoder_axi4s/trunk/src/ram_ctrl.vhd\
		../../viterbi_decoder/viterbi_decoder_axi4s/trunk/src/dec_viterbi.vhd}

	read_hdl -vhdl {../../viterbi_decoder/rtl/dec_viterbi_wrapper.vhd\
		../rtl/vlc_types.vhd\
		../rtl/vlc_phy_fec_components.vhd\
		../rtl/vlc_phy_fec.vhd\
		../rtl/vlc_phy_fec_RX.vhd\
		../rtl/vlc_phy_fec_TX.vhd\
		../rtl/vlc_phy_fec_pmc.vhd\
		../rtl/vlc_phy_fec_pmc_fsm.vhd\
		../rtl/vlc_phy_fec_pmc_enables.vhd\
		../rtl/vlc_phy_fec_controller.vhd\
		../rtl/vlc_phy_fec_encoder.vhd\
		../rtl/vlc_phy_fec_decoder.vhd\
		../rtl/vlc_phy_mcs_id_dec.vhd\
		../rtl/vlc_phy_convolutional_encoder.vhd\
		../rtl/vlc_phy_fec_interleaver.vhd\
		../rtl/vlc_phy_rs_codec.vhd\
		../rtl/vlc_phy_viterbi_decoder.vhd\
		../rtl/vlc_phy_puncturing.vhd\
		../rtl/vlc_phy_depuncturing.vhd}
	if {$is_only_encoder} {
		elaborate vlc_phy_fec_TX
	} else {
		if {$is_power_aware} {
			elaborate vlc_phy_fec -parameter {{PA_MODE true}}
		} else {
			elaborate vlc_phy_fec -parameter {{PA_MODE false}}
		}
	}
	puts "###GENUS(end): design compilation"
}

proc setup_syn_flow {} {
	#setup commands
	puts "###GENUS(start): setup syntehsis flow"
	::legacy::set_attribute script_search_path ./
	::legacy::set_attribute init_hdl_search_path ../
	::legacy::set_attribute information_level 9
	set DK_PATH "/home/tools/TSMC180/TSMCHOME/digital"
	::legacy::set_attribute library "${DK_PATH}/Front_End/timing_power_noise/NLDM/tcb018gbwp7t_270a/tcb018gbwp7ttc.lib"
	::legacy::set_attribute lef_library "${DK_PATH}/Back_End/lef/tcb018gbwp7t_270a/lef/tcb018gbwp7t_6lm.lef"
	::legacy::set_attribute cap_table_file "${DK_PATH}/Back_End/lef/tcb018gbwp7t_270a/techfiles/captable/t018lo_1p6m_typical.captable"
	::legacy::set_attribute hdl_vhdl_read_version {2008}
	::legacy::set_attribute lp_power_unit uW
	::legacy::set_attribute auto_ungroup none
	::legacy::set_attribute hdl_track_filename_row_col true
	puts "###GENUS(end): setup syntehsis flow"
}

proc transform_pa_design {} {
	set cd_orig [pwd]
	cd ../../upf
	read_power_intent -1801 vlc_phy_fec.upf -version 2.1 -module vlc_phy_fec_PA_MODE1
	cd $cd_orig
	apply_power_intent
	commit_power_intent
}

proc pa_static_check {} {
	#TODO: NO Conformal lec available
	#set_attribute <path_to_lec>
	#check_cpf
	#check_power_structure -pre_synthesis
}

proc lp_opmization_tunning {} {
	::legacy::set_attribute max_leakage_power 100 vlc_phy_fec_PA_MODE0
	::legacy::set_attribute leakage_power_effort medium
	::legacy::set_attribute max_dynamic_power 100 vlc_phy_fec_PA_MODE0
	#leakage power is less than 10% in 180nm 
	::legacy::set_attribute lp_power_optimization_weight 0.99 vlc_phy_fec_PA_MODE0
}

proc enable_clock_gating {} {
	puts "###GENUS(start): clock gating"
	#TODO: Configure clock gating in genus
	#::legacy::set_attribute lp_insert_clock_gating true
	#::legacy::set_attribute lp_clock_gating_style latch vlc_phy_fec_PA_MODE1
	#::legacy::set_attribute lp_clock_gating_max_flops 16 */des*/*
	#::legacy::set_attribute lp_clock_gating_min_flops 4 */des*/*
	puts "###GENUS(end): clock gating"
}

proc lp_library_setup {} {
	#TODO: Not sure if it should be set. Should it include the isolation cell?
	#::legacy::set_attribute lib_search_path <path>
	#create_library_domain {domain1 domain2 ...}
	#::legacy::set_attribute library lib1 domain1
	#check_library
}

proc run_report_cmd {dir} {
	#cd $dir
	puts "###GENUS(start): report_low_power_intent"
	report_low_power_intent > $dir/low_power_intent.rpt
	puts "###GENUS(end): report_low_power_intent"
	puts "###GENUS(start): report_clock_gating"
	report_clock_gating > $dir/clock_gating.rpt
	puts "###GENUS(end): report_clock_gating"
	puts "###GENUS(start): report_gates"
	report_gates -power > $dir/gates_power_consumption.rpt
	puts "###GENUS(end): report_gates"
	#report_power -depth 9 > $dir/power_consumptio.rpt
	puts "###GENUS(start): report_dp"
	report_dp > $dir/datapath.rpt
	puts "###GENUS(end): report_dp"
	puts "###GENUS(start): report_area"
	report_area > $dir/area.rpt
	report_area -depth 4 > $dir/area_simplified.rpt
	report_area -depth 4 -normalize_with_gate AO21D1BWP7T > $dir/area_simplified_normalized.rpt
	puts "###GENUS(end): report_area"
	puts "###GENUS(start): report_gates"
	report_gates > $dir/gates.rpt
	puts "###GENUS(end): report_gates"
	puts "###GENUS(start): report_timing"
	report_timing > $dir/timing.rpt
	report_timing -lint > $dir/timing_lint.rpt
	puts "###GENUS(end): report_timing"
	puts "###GENUS(start): report_power"
	report_power -by_hierarchy -levels 6 > $dir/detailed_power.rpt
	puts "###GENUS(end): report_power"
	#cd ..
}

proc synthesize {} {
	#cd $dir
	#TODO: Redirect output to files
	puts "###GENUS(start): syn_generic"
	syn_generic
	puts "###GENUS(end): syn_generic"
	puts "###GENUS(start): syn_map"
	syn_map
	puts "###GENUS(end): syn_map"
	puts "###GENUS(start): syn_physical"
	syn_opt -physical
	puts "###GENUS(end): syn_physical"
	puts "###GENUS(start): write_design -innovus"
	write_design -innovus -base_name innovus/vlc_phy_fec_tx
	puts "###GENUS(end): write_design -innovus"
	#cd ..
}

proc export_design {dir} {
	write_hdl > $dir/genus_netlist.v
}

proc run_synthesis_flow {is_power_aware is_only_encoder is_simplified} {
	setup_syn_flow
	enable_clock_gating
	compile_design $is_power_aware $is_only_encoder $is_simplified
	puts "###GENUS(start): read_sdc"
	read_sdc design.sdc
	puts "###GENUS(end): read_sdc"

	synthesize
	run_report_cmd genus_reports_fec_encoder
	export_design genus_reports_fec_encoder
}

rm genus_reports_fec_encoder -rf
mkdir genus_reports_fec_encoder
run_synthesis_flow 0 1 1
