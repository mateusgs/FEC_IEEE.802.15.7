clear -all

cd ..
cd ..
cd ..

if {[file isdirectory UFMG_digital_design]} {

    if {![file isdirectory conn_output_files]} {
        file mkdir conn_output_files
    }

    cd conn_output_files

    set COMPILE CONN
    set MCS_IDs {0 1 2 3 4 5 6 7 8 16 17 18 19 20 21 22 23 24 25 26\
                 27 28 29 32 33 34 35 36 37 38}

    source ../UFMG_digital_design/vlc_phy_fec/formal/compilation.tcl
    compile_fec $COMPILE

    clock clk
    reset rst
    stopat {w_mode w_busy w_en_datapath} -env

    set file_name connections_enc_
    set it 0
    set MCS_ID 0
    while {$it<30} {

        set MCS_ID [lindex $MCS_IDs $it]
    
        if {$MCS_ID==0} {
            set OP_MODE "01101"
        } elseif {$MCS_ID==1} {
            set OP_MODE "10010"
        } elseif {$MCS_ID==2} {
            set OP_MODE "10011"
        } elseif {$MCS_ID==3} {
            set OP_MODE "10000"
        } elseif {$MCS_ID==4||$MCS_ID==8||$MCS_ID==20||\
        $MCS_ID==29||$MCS_ID==37||$MCS_ID==38} {
            set OP_MODE "00000"
        } elseif {$MCS_ID==5} {
            set OP_MODE "00100"
        } elseif {$MCS_ID==6} {
            set OP_MODE "01000"
        } elseif {$MCS_ID==7} {
            set OP_MODE "01100"
        } elseif {$MCS_ID==16||$MCS_ID==18||$MCS_ID==21||\
        $MCS_ID==23||$MCS_ID==25||$MCS_ID==27||$MCS_ID==32\
        ||$MCS_ID==33||$MCS_ID==34||$MCS_ID==35||$MCS_ID==36} {
            set OP_MODE "10100"
        } elseif {$MCS_ID==17||$MCS_ID==19||$MCS_ID==22||\
        $MCS_ID==24||$MCS_ID==26||$MCS_ID==28} {
            set OP_MODE "11000"
        }

        source ../UFMG_digital_design/vlc_phy_fec/formal/connectivity.tcl
        fec_connectivity ENC $OP_MODE $MCS_ID

        source ../UFMG_digital_design/vlc_phy_fec/formal/parser.tcl
        parse_csv [join [list $file_name $MCS_ID .csv] ""] $MCS_ID
        
        set it [expr {$it + 1}]    
    }

    set file_name connections_dec_
    set it 0
    while {$it<30} {

        set MCS_ID [lindex $MCS_IDs $it]
    
        if {$MCS_ID==0} {
            set OP_MODE "01101"
        } elseif {$MCS_ID==1} {
            set OP_MODE "10010"
        } elseif {$MCS_ID==2} {
            set OP_MODE "10011"
        } elseif {$MCS_ID==3} {
            set OP_MODE "10000"
        } elseif {$MCS_ID==4||$MCS_ID==8||$MCS_ID==20||\
        $MCS_ID==29||$MCS_ID==37||$MCS_ID==38} {
            set OP_MODE "00000"
        } elseif {$MCS_ID==5} {
            set OP_MODE "00100"
        } elseif {$MCS_ID==6} {
            set OP_MODE "01000"
        } elseif {$MCS_ID==7} {
            set OP_MODE "01100"
        } elseif {$MCS_ID==16||$MCS_ID==18||$MCS_ID==21||\
        $MCS_ID==23||$MCS_ID==25||$MCS_ID==27||$MCS_ID==32\
        ||$MCS_ID==33||$MCS_ID==34||$MCS_ID==35||$MCS_ID==36} {
            set OP_MODE "10100"
        } elseif {$MCS_ID==17||$MCS_ID==19||$MCS_ID==22||\
        $MCS_ID==24||$MCS_ID==26||$MCS_ID==28} {
            set OP_MODE "11000"
        }

        source ../UFMG_digital_design/vlc_phy_fec/formal/connectivity.tcl
        fec_connectivity DEC $OP_MODE $MCS_ID

        source ../UFMG_digital_design/vlc_phy_fec/formal/parser.tcl
        parse_csv [join [list $file_name $MCS_ID .csv] ""] $MCS_ID
        
        set it [expr {$it + 1}]    
    }

    source ../UFMG_digital_design/vlc_phy_fec/formal/prove.tcl
#    prove_conn_fec

    #exit
}
