proc analyze_fec {} {
	#GENERIC_COMPONENTS
	analyze -vhdl08 -L GENERIC_TYPES ../UFMG_digital_design/generic_components/rtl/generic_types.vhd
	analyze -vhdl08 -L GENERIC_FUNCTIONS ../UFMG_digital_design/generic_components/rtl/generic_functions.vhd
	analyze -vhdl08 -L GENERIC_COMPONENTS ../UFMG_digital_design/generic_components/rtl/generic_components.vhd
	analyze -vhdl08	../UFMG_digital_design/generic_components/rtl/adder.vhd\
			../UFMG_digital_design/generic_components/rtl/async_dff.vhd\
			../UFMG_digital_design/generic_components/rtl/comparator.vhd\
			../UFMG_digital_design/generic_components/rtl/config_dff_array.vhd\
		        ../UFMG_digital_design/generic_components/rtl/d_sync_flop.vhd\
		        ../UFMG_digital_design/generic_components/rtl/demultiplexer_array.vhd\
  			../UFMG_digital_design/generic_components/rtl/half_subtractor_unit.vhd\
			../UFMG_digital_design/generic_components/rtl/half_adder_unit.vhd\
		        ../UFMG_digital_design/generic_components/rtl/multiplexer_array.vhd\
		        ../UFMG_digital_design/generic_components/rtl/no_rst_dff.vhd\
			../UFMG_digital_design/generic_components/rtl/parallel_to_serial.vhd\
		        ../UFMG_digital_design/generic_components/rtl/reg_fifo.vhd\
		        ../UFMG_digital_design/generic_components/rtl/reg_fifo_array.vhd\
			../UFMG_digital_design/generic_components/rtl/serial_to_parallel.vhd\
			../UFMG_digital_design/generic_components/rtl/shifter_left.vhd\
			../UFMG_digital_design/generic_components/rtl/single_port_2D_ram.vhd\
			../UFMG_digital_design/generic_components/rtl/single_port_linear_ram.vhd\
			../UFMG_digital_design/generic_components/rtl/sync_dff_array.vhd\
		        ../UFMG_digital_design/generic_components/rtl/sync_ld_dff.vhd\
	 		../UFMG_digital_design/generic_components/rtl/up_counter.vhd\
			../UFMG_digital_design/generic_components/rtl/decrementer.vhd\
			../UFMG_digital_design/generic_components/rtl/flop_cascade.vhd\
			../UFMG_digital_design/generic_components/rtl/incrementer.vhd\
	   		../UFMG_digital_design/generic_components/rtl/up_down_counter.vhd
	#REED_SOLOMON
	analyze -vhdl08 -L RS_TYPES ../UFMG_digital_design/rs_codec/rtl/rs_types.vhd
	analyze -vhdl08 -L RS_CONSTANTS ../UFMG_digital_design/rs_codec/rtl/rs_constants.vhd
	analyze -vhdl08 -L RS_FUNCTIONS ../UFMG_digital_design/rs_codec/rtl/rs_functions.vhd
	analyze -vhdl08 -L RS_COMPONENTS ../UFMG_digital_design/rs_codec/rtl/rs_components.vhd
	#Layer 0
	analyze -vhdl08 ../UFMG_digital_design/rs_codec/rtl/rs_adder.vhd\
		        ../UFMG_digital_design/rs_codec/rtl/rs_full_multiplier_core.vhd\
		        ../UFMG_digital_design/rs_codec/rtl/rs_inverse.vhd\
		        ../UFMG_digital_design/rs_codec/rtl/rs_multiplier_lut.vhd\
		        ../UFMG_digital_design/rs_codec/rtl/rs_reduce_adder.vhd
	#Layer 1
	analyze -vhdl08	../UFMG_digital_design/rs_codec/rtl/rs_full_multiplier.vhd
	#Layer 2
	analyze -vhdl08	../UFMG_digital_design/rs_codec/rtl/rs_berlekamp_massey.vhd\
			../UFMG_digital_design/rs_codec/rtl/rs_multiplier.vhd
	#Layer 3
	analyze -vhdl08	../UFMG_digital_design/rs_codec/rtl/rs_chien.vhd\
		        ../UFMG_digital_design/rs_codec/rtl/rs_forney.vhd\
		        ../UFMG_digital_design/rs_codec/rtl/rs_remainder_unit.vhd\
		        ../UFMG_digital_design/rs_codec/rtl/rs_syndrome_subunit.vhd
	#Layer 4
	analyze -vhdl08	../UFMG_digital_design/rs_codec/rtl/rs_chien_forney.vhd\
			../UFMG_digital_design/rs_codec/rtl/rs_encoder.vhd\
			../UFMG_digital_design/rs_codec/rtl/rs_syndrome.vhd
	#Layer 5
	analyze -vhdl08	../UFMG_digital_design/rs_codec/rtl/rs_decoder.vhd\
			../UFMG_digital_design/rs_codec/rtl/rs_encoder_wrapper.vhd
	#Layer 6
	analyze -vhdl08	 ../UFMG_digital_design/rs_codec/rtl/rs_codec.vhd
	#BLOCK_INTERLEAVER
	analyze -vhdl08 -L BLOCK_INTERLEAVER_COMPONENTS ../UFMG_digital_design/block_interleaver/rtl/block_interleaver_components.vhd
	#Layer 0
	analyze -vhdl08	../UFMG_digital_design/block_interleaver/rtl/interleaver_controller.vhd\
			../UFMG_digital_design/block_interleaver/rtl/block_interleaver_components/wr_rd_status_selector.vhd\
			../UFMG_digital_design/block_interleaver/rtl/block_interleaver_components/m2D_index_counter_core.vhd\
			../UFMG_digital_design/block_interleaver/rtl/block_interleaver_components/flag_signals_generator.vhd
	#Layer 1
	analyze -vhdl08	../UFMG_digital_design/block_interleaver/rtl/block_interleaver_components/m2D_index_counter.vhd\
			../UFMG_digital_design/block_interleaver/rtl/block_interleaver_components/simplified_m2D_index_counter.vhd
	#Layer 2
	analyze -vhdl08	../UFMG_digital_design/block_interleaver/rtl/deinterleaver_data_path.vhd\
			../UFMG_digital_design/block_interleaver/rtl/interleaver_data_path.vhd
	#Layer 3
	analyze -vhdl08	../UFMG_digital_design/block_interleaver/rtl/rectangular_deinterleaver.vhd\
			../UFMG_digital_design/block_interleaver/rtl/rectangular_interleaver.vhd
	#CONVOLUTIONAL_ENCODER
	analyze -vhdl08 -L CONVOLUTIONAL_ENCODER_COMPONENTS ../UFMG_digital_design/convolutional_codes/convolutional_encoder/rtl/convolutional_encoder_components.vhd
	#Layer 1
	analyze -vhdl08 ../UFMG_digital_design/convolutional_codes/convolutional_encoder/rtl/convolutional_encoder_components/conv_flop_cascade.vhd\
                        ../UFMG_digital_design/convolutional_codes/puncturing/rtl/puncturing_1_3.vhd\
                        ../UFMG_digital_design/convolutional_codes/puncturing/rtl/puncturing_1_4.vhd\
                        ../UFMG_digital_design/convolutional_codes/puncturing/rtl/puncturing_2_3.vhd\
	
        #Layer 2
	analyze -vhdl08	../UFMG_digital_design/convolutional_codes/convolutional_encoder/rtl/convolutional_encoder.vhd

	#VITERBI_DECODER
	analyze -vhdl08 -lib dec_viterbi ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/packages/pkg_helper.vhd
	analyze -vhdl08 -lib dec_viterbi ../UFMG_digital_design/viterbi_decoder/rtl/pkg_param.vhd
	analyze -vhdl08 -lib dec_viterbi ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/packages/pkg_param_derived.vhd
	analyze -vhdl08 -lib dec_viterbi ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/packages/pkg_types.vhd
	analyze -vhdl08 -lib dec_viterbi ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/packages/pkg_components.vhd
	analyze -vhdl08 -lib dec_viterbi ../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/packages/pkg_trellis.vhd
	#Layer 0
	analyze -vhdl08	../UFMG_digital_design/viterbi_decoder/depuncturing/rtl/depuncturing_1_3.vhd\
			../UFMG_digital_design/viterbi_decoder/depuncturing/rtl/depuncturing_1_4.vhd\
			../UFMG_digital_design/viterbi_decoder/depuncturing/rtl/depuncturing_2_3.vhd\
			../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/src/acs.vhd\
			../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/src/axi4s_buffer.vhd\
			../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/src/branch_distance.vhd\
			../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/src/generic_sp_ram.vhd\
			../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/src/recursion.vhd\
			../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/src/reorder.vhd\
			../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/src/traceback.vhd
	#Layer 1
	analyze -vhdl08	../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/src/ram_ctrl.vhd
	#Layer 2
	analyze -vhdl08	../UFMG_digital_design/viterbi_decoder/viterbi_decoder_axi4s/trunk/src/dec_viterbi.vhd
	#Layer 3
	analyze -vhdl08	../UFMG_digital_design/viterbi_decoder/rtl/dec_viterbi_wrapper.vhd
	#VLC_PHY_FEC
	analyze -vhdl08 -L VLC_PHY_FEC_COMPONENTS ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_components.vhd
	analyze -vhdl08 -L VLC_PHY_FEC_CONSTANTS ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_constants.vhd
	analyze -vhdl08 ../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_tb.vhd\
			../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_checker.vhd\
			../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_checker_ctrl.vhd\
			../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec.vhd\
			../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_controller.vhd\
			../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_pmc.vhd\
			../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_pmc_enables.vhd\
			../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_pmc_fsm.vhd\
			../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_encoder.vhd\
			../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_decoder.vhd\
			../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_mcs_id_dec.vhd\
			../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_convolutional_encoder.vhd\
			../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_fec_interleaver.vhd\
			../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_rs_codec.vhd\
			../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_viterbi_decoder.vhd\
			../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_puncturing.vhd\
			../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_depuncturing.vhd\
			../UFMG_digital_design/vlc_phy_fec/rtl/vlc_phy_frame_mem.vhd
}

proc compile_fec {mode} {
	analyze_fec
        if {$mode=={CONN}} {
	    check_conn -bind_instance -top vlc_phy_fec
            elaborate -vhdl -top vlc_phy_fec -mode verilog -bbox_a\
            20000 -bbox_m rs_encoder -bbox_m rs_decoder -bbox_m\
            dec_viterbi_wrapper -bbox_m rectangular_interleaver\
            -bbox_m rectangular_deinterleaver -bbox_m\
            convolutional_encoder -bbox_m parallel_to_serial -bbox_m\
            serial_to_parallel -bbox_m puncturing_1_3 -bbox_m\
            puncturing_1_4 -bbox_m puncturing_2_3 -bbox_m\
            depuncturing_1_3 -bbox_m depuncturing_1_4 -bbox_m\
            depuncturing_2_3
        } else {
            elaborate -vhdl -top vlc_phy_fec -mode verilog -bbox_a\
            40000 -parameter PA_MODE true
        }
}

proc compile_end_to_end_tb {ENC_FRAME_SIZE \
			    DEC_FRAME_SIZE \
			    MCS_ID_VALUE} {
    analyze_fec
    elaborate -vhdl -top vlc_phy_fec_tb -mode verilog -bbox_a\
    40000 -parameter PA_MODE false\
	  -parameter ENC_FRAME_SIZE $ENC_FRAME_SIZE\
	  -parameter DEC_FRAME_SIZE $DEC_FRAME_SIZE\
	  -parameter MCS_ID_VALUE $MCS_ID_VALUE
}

proc compile_end_to_end {} {
    analyze_fec
    elaborate -vhdl -top vlc_phy_fec -mode verilog -bbox_a\
    40000 -parameter PA_MODE false
}
