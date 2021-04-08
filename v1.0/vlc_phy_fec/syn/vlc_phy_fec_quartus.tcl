# Copyright (C) 1991-2012 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.

# Quartus II: Generate Tcl File for Project
# File: vlc_phy_fec.tcl
# Generated on: Wed Jun 17 08:59:29 2020

# Load Quartus II Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

cd ..
cd ..
cd ..


if {[file isdirectory UFMG_digital_design]} {
		
	if {![file isdirectory vpf_quartus_proj2]} {
		file mkdir vpf_quartus_proj2
	}
	
	cd vpf_quartus_proj2

	# Check that the right project is open
	if {[is_project_open]} {
		if {[string compare $quartus(project) "vlc_phy_fec"]} {
			puts "Project vlc_phy_fec is not open"
			set make_assignments 0
		}
	} else {
		# Only open if not already open
		if {[project_exists vlc_phy_fec]} {
			project_open -revision vlc_phy_fec vlc_phy_fec
		} else {
			project_new -revision vlc_phy_fec vlc_phy_fec
		}
		set need_to_close_project 1
	}

	# Make assignments
	if {$make_assignments} {
		set_global_assignment -name FAMILY "Cyclone V"
		set_global_assignment -name DEVICE 5CGXFC7C6F23I7
		set_global_assignment -name ORIGINAL_QUARTUS_VERSION 12.0
		set_global_assignment -name PROJECT_CREATION_TIME_DATE "08:30:13  JUNE 17, 2020"
		set_global_assignment -name LAST_QUARTUS_VERSION 12.0
		set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
		set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008
		set_global_assignment -name VHDL_SHOW_LMF_MAPPING_MESSAGES OFF
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/generic_components.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/generic_functions.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/generic_types.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/incrementer.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/flop_cascade.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/decrementer.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/up_counter.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/sync_ld_dff.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/single_port_linear_ram.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/single_port_2D_ram.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/shifter_left.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/serial_to_parallel.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/reg_fifo_array.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/reg_fifo.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/parallel_to_serial.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/no_rst_dff.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/multiplexer_array.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/half_subtractor_unit.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/half_adder_unit.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/demultiplexer_array.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/d_sync_flop.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/config_dff_array.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/comparator.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/async_dff.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/adder.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/sync_dff_array.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_functions.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_types.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_viterbi_decoder.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_rs_codec.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_interleaver.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_convolutional_encoder.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_mcs_id_dec.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_decoder.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_encoder.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_controller.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_pmc.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_pmc_enables.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_components.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_depuncturing.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/packages/pkg_trellis.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/packages/pkg_components.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/packages/pkg_types.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/packages/pkg_param_derived.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/rtl/pkg_param.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/packages/pkg_helper.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_components.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_functions.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_constants.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_types.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/block_interleaver/rtl/block_interleaver_components.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/convolutional_codes/convolutional_encoder/rtl/convolutional_encoder_components.vhd
		set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
		set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/convolutional_codes/convolutional_encoder/rtl/convolutional_encoder.vhd
                set_global_assignment -name VHDL_FILE ../UFMG_digital_design/convolutional_codes/puncturing/rtl/puncturing_1_3.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/convolutional_codes/puncturing/rtl/puncturing_1_4.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/convolutional_codes/puncturing/rtl/puncturing_2_3.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_puncturing.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/convolutional_codes/convolutional_encoder/rtl/convolutional_encoder_components/conv_flop_cascade.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/up_down_counter.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/block_interleaver/rtl/rectangular_interleaver.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/block_interleaver/rtl/rectangular_deinterleaver.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/block_interleaver/rtl/interleaver_data_path.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/block_interleaver/rtl/deinterleaver_data_path.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/block_interleaver/rtl/block_interleaver_components/simplified_m2D_index_counter.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/block_interleaver/rtl/block_interleaver_components/m2D_index_counter.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/block_interleaver/rtl/block_interleaver_components/wr_rd_status_selector.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/block_interleaver/rtl/block_interleaver_components/m2D_index_counter_core.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/block_interleaver/rtl/block_interleaver_components/flag_signals_generator.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/block_interleaver/rtl/interleaver_controller.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/rtl/dec_viterbi_wrapper.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/src/dec_viterbi.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/src/ram_ctrl.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/src/traceback.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/src/reorder.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/src/recursion.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/src/generic_sp_ram.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/src/branch_distance.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/src/axi4s_buffer.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/src/acs.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/depuncturing/rtl/depuncturing_2_3.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/depuncturing/rtl/depuncturing_1_4.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/viterbi_decoder/depuncturing/rtl/depuncturing_1_3.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_codec.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_encoder_wrapper.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_decoder.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_syndrome.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_encoder.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_chien_forney.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_syndrome_subunit.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_remainder_unit.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_forney.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_chien.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_multiplier.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_berlekamp_massey.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_full_multiplier.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_reduce_adder.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_multiplier_lut.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_inverse.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_full_multiplier_core.vhd
		set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_adder.vhd

		# Commit assignments
		export_assignments

		#custom script start
		source ../UFMG_digital_design/scripts/syn/run_syn.tcl
		run_syn vlc_phy_fec [pwd] ../UFMG_digital_design/scripts/syn ../UFMG_digital_design/vlc_phy_fec/sim
		#custom script end

		# Close project
		if {$need_to_close_project} {
			project_close
		}
	}
}
