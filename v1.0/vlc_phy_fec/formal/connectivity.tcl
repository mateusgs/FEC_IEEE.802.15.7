proc generate_csv {name complexity sources destinations} {
    append name .csv
    puts "generating_csv"
    check_conn -generate_candidates -complexity $complexity -src\
    $sources -dest $destinations
    check_conn -generate_connection_map [check_conn -list candidate\
    -silent] -save_as $name -force -remove_unreachable
    check_conn -clear candidate
    puts "generating_csv end"
}

proc fec_connectivity {mode op mcs_id} {
    set file_name connections
    if {$mode=={SFW}} {
        set sources {vlc_phy_fec\
                     vlc_phy_fec_controller\
                     vlc_phy_rs_codec\
                     vlc_phy_fec_interleaver\
                     parallel_to_serial\
                     convolutional_encoder\
                     vlc_phy_puncturing\
                     vlc_phy_depuncturing\
                     dec_viterbi_wrapper\
                     serial_to_parallel}
        set destinations $sources
        generate_csv $file_name straightforward $sources $destinations
    } elseif {$mode=={ENC}} {
        append file_name _enc_ $mcs_id
        if {$op=="01101"} {
            set sources {\
            VPFE.RS_ENCODER_UNIT.RS_15_7.GEN_ENCODER.ENCODER_INST\
            VPFE.INTERLEAVER_UNIT.GEN_INTERLEAVER.RIT\
            VPFE.CONV0.PTS\
            VPFE.CONV0.CE\
            VPFE.CONV0.VPP.P14}
            set destinations [concat vlc_phy_fec $sources]
            generate_csv $file_name conditional $sources $destinations
        } elseif {$op=="10010"} {
            set sources {\
            VPFE.RS_ENCODER_UNIT.RS_15_11.GEN_ENCODER.ENCODER_INST\
            VPFE.INTERLEAVER_UNIT.GEN_INTERLEAVER.RIT\
            VPFE.CONV0.PTS\
            VPFE.CONV0.CE\
            VPFE.CONV0.VPP.P13}
            set destinations [concat vlc_phy_fec $sources]
            generate_csv $file_name conditional $sources $destinations
        } elseif {$op=="10011"} {
            set sources {\
            VPFE.RS_ENCODER_UNIT.RS_15_11.GEN_ENCODER.ENCODER_INST\
            VPFE.INTERLEAVER_UNIT.GEN_INTERLEAVER.RIT\
            VPFE.CONV0.PTS\
            VPFE.CONV0.CE\
            VPFE.CONV0.VPP.P23}
            set destinations [concat vlc_phy_fec $sources]
            generate_csv $file_name conditional $sources $destinations
        } elseif {$op=="10000"} {
            set sources {\
            VPFE.RS_ENCODER_UNIT.RS_15_11.GEN_ENCODER.ENCODER_INST}
            set destinations [concat vlc_phy_fec $sources]
            generate_csv $file_name conditional $sources $destinations
        } elseif {$op=="00000"} {
            set sources {\
            i_last_data_enc\
	    i_valid_enc\
            i_data_enc}
            set destinations [concat vlc_phy_fec o_in_ready_enc $sources]
            generate_csv $file_name conditional $sources $destinations
        } elseif {$op=="00100"} {
            set sources {\
            VPFE.RS_ENCODER_UNIT.RS_15_2.GEN_ENCODER.ENCODER_INST}
            set destinations [concat vlc_phy_fec $sources]
            generate_csv $file_name conditional $sources $destinations
        } elseif {$op=="01000"} {
            set sources {\
            VPFE.RS_ENCODER_UNIT.RS_15_4.GEN_ENCODER.ENCODER_INST}
            set destinations [concat vlc_phy_fec $sources]
            generate_csv $file_name conditional $sources $destinations
        } elseif {$op=="01100"} {
            set sources {\
            VPFE.RS_ENCODER_UNIT.RS_15_7.GEN_ENCODER.ENCODER_INST}
            set destinations [concat vlc_phy_fec $sources]
            generate_csv $file_name conditional $sources $destinations
        } elseif {$op=="10100"} {
            set sources {\
            VPFE.RS_ENCODER_UNIT.RS_64_32.GEN_ENCODER.ENCODER_INST}
            set destinations [concat vlc_phy_fec $sources]
            generate_csv $file_name conditional $sources $destinations
        } elseif {$op=="11000"} {
            set sources {\
            VPFE.RS_ENCODER_UNIT.RS_160_128.GEN_ENCODER.ENCODER_INST}
            set destinations [concat vlc_phy_fec $sources]
            generate_csv $file_name conditional $sources $destinations
        }
    } else {
        append file_name _dec_ $mcs_id
        if {$op=="01101"} {
            set sources {\
            VPFD.VIT.VLC_PHY_DEPUNC\
            VPFD.VIT.VLC_PHY_DEPUNC.DEPUNC_1_4\
            VPFD.VIT.VIT_WRAPPER\
            VPFD.VIT.BUFFER_SERIAL_TO_PARALLEL\
            VPFD.DEINT.GEN_DEINTERLEAVER.RDI\
            VPFD.RS.RS_15_7.GEN_DECODER.DECODER_INST}
            set destinations [concat vlc_phy_fec $sources]
            generate_csv $file_name conditional $sources $destinations
        } elseif {$op=="10010"} {
            set sources {\
            VPFD.VIT.VLC_PHY_DEPUNC\
            VPFD.VIT.VLC_PHY_DEPUNC.DEPUNC_1_3\
            VPFD.VIT.VIT_WRAPPER\
            VPFD.VIT.BUFFER_SERIAL_TO_PARALLEL\
            VPFD.DEINT.GEN_DEINTERLEAVER.RDI\
            VPFD.RS.RS_15_11.GEN_DECODER.DECODER_INST}
            set destinations [concat vlc_phy_fec $sources]
            generate_csv $file_name conditional $sources $destinations
        } elseif {$op=="10011"} {
            set sources {\
            VPFD.VIT.VLC_PHY_DEPUNC\
            VPFD.VIT.VLC_PHY_DEPUNC.DEPUNC_2_3\
            VPFD.VIT.VIT_WRAPPER\
            VPFD.VIT.BUFFER_SERIAL_TO_PARALLEL\
            VPFD.DEINT.GEN_DEINTERLEAVER.RDI\
            VPFD.RS.RS_15_11.GEN_DECODER.DECODER_INST}
            set destinations [concat vlc_phy_fec $sources]
            generate_csv $file_name conditional $sources $destinations
        } elseif {$op=="10000"} {
            set sources {\
            VPFD.RS.RS_15_11.GEN_DECODER.DECODER_INST}
            set destinations [concat vlc_phy_fec $sources]
            generate_csv $file_name conditional $sources $destinations
        } elseif {$op=="00000"} {
            set sources {\
            i_last_data_dec\
	    i_valid_dec\
            i_data_dec}
            set destinations [concat vlc_phy_fec o_in_ready_dec $sources]
            generate_csv $file_name conditional $sources $destinations
        } elseif {$op=="00100"} {
            set sources {\
            VPFD.RS.RS_15_2.GEN_DECODER.DECODER_INST}
            set destinations [concat vlc_phy_fec $sources]
            generate_csv $file_name conditional $sources $destinations
        } elseif {$op=="01000"} {
            set sources {\
            VPFD.RS.RS_15_4.GEN_DECODER.DECODER_INST}
            set destinations [concat vlc_phy_fec $sources]
            generate_csv $file_name conditional $sources $destinations
        } elseif {$op=="01100"} {
            set sources {\
            VPFD.RS.RS_15_7.GEN_DECODER.DECODER_INST}
            set destinations [concat vlc_phy_fec $sources]
            generate_csv $file_name conditional $sources $destinations
        } elseif {$op=="10100"} {
            set sources {\
            VPFD.RS.RS_64_32.GEN_DECODER.DECODER_INST}
            set destinations [concat vlc_phy_fec $sources]
            generate_csv $file_name conditional $sources $destinations
        } elseif {$op=="11000"} {
            set sources {\
            VPFD.RS.RS_160_128.GEN_DECODER.DECODER_INST}
            set destinations [concat vlc_phy_fec $sources]
            generate_csv $file_name conditional $sources $destinations
        }
    }
}
