proc prove_conn_fec {args} {

    set file_name new_connections

    assume {w_en_datapath} -env
    
    set MCS_IDs {0 1 2 3 4 5 6 7 8 16 17 18 19 20 21 22 23 24 25 26\
                 27 28 29 32 33 34 35 36 37 38}
    set connections {}
    set ltotal {TOTAL}
    set total 0
    set reduce 0

    if {[llength $args]==0} {
        set file_name new_connections_enc_
        assume {!w_mode} -env
        
        set total 0
        set it 0
        while {$it<30} {
            lappend connections [lindex $MCS_IDs $it]
            if {$it==0||$it==1||$it==2} {
                set reduce 3
            } elseif {$it==4||$it==8||$it==13||\
            $it==22||$it==28||$it==29} {
                set reduce 1
            } elseif {$it==3||$it==5||$it==6||\
            $it==7||$it==9||$it==11||$it==14||\
            $it==16||$it==18||$it==20||$it==23\
            ||$it==24||$it==25||$it==26||$it==27\
            ||$it==10||$it==12||$it==15||$it==17\
            ||$it==19||$it==21} {
                    set reduce 0
                }
            check_conn -load [join [list $file_name [lindex $MCS_IDs $it] .csv] ""]
            prove -all
            set reduce [expr {[llength [check_conn -list connection]] - $reduce}]
            set connections [lreplace $connections $it $it [list [lindex $connections $it] $reduce]]
            set total [expr {$total + $reduce}]
            check_conn -clear
            set it [expr {$it + 1}]
        }
        assume -env -clear
        lappend ltotal $total

	set file_name new_connections_dec_
        assume {w_en_datapath} -env
        assume {w_mode} -env
         
        set total 0
        set it 0
        while {$it<30} {
            if {$it==0||$it==1||$it==2} {
                set reduce 1
            } elseif {$it==4||$it==8||$it==13||\
            $it==22||$it==28||$it==29} {
                set reduce 1
            } elseif {$it==3||$it==5||$it==6||\
            $it==7||$it==9||$it==11||$it==14||\
            $it==16||$it==18||$it==20||$it==23\
            ||$it==24||$it==25||$it==26||$it==27\
            ||$it==10||$it==12||$it==15||$it==17\
            ||$it==19||$it==21} {
                set reduce 0
            }
            check_conn -load [join [list $file_name [lindex $MCS_IDs $it] .csv] ""]
            prove -all
            set reduce [expr {[llength [check_conn -list connection]] - $reduce}]
            set connections [lreplace $connections $it $it [concat [lindex $connections $it]\
            $reduce [expr {$reduce + [lindex [lindex $connections $it] 1]}]]]
            set total [expr {$total + $reduce}]
            check_conn -clear
            set it [expr {$it + 1}]    
        }
        assume -env -clear
        lappend ltotal $total
        lappend ltotal [expr {[lindex $ltotal 1] + [lindex $ltotal 2]}]

        set connections [concat [list [list MCS_ID ENCODER DECODER SUM]] $connections [list $ltotal]]

        set it 0
        while {$it<32} {
            puts stdout [lindex $connections $it]
            set connections [lreplace $connections $it $it [join [lindex $connections $it] ","]]
            set it [expr {$it + 1}]
        }
        set connections [join $connections "\n"]

        set fp [open "connections_results.csv" w]
        puts $fp $connections
        close $fp

    } else {
        if {[lindex $args 0]=={ENC}} {
            append file_name _enc_
            assume {!w_mode} -env
        } else {
            append file_name _dec_
            assume {w_mode} -env
        }
        
        if {[llength $args]>1} {
            check_conn -load [join [list $file_name [lindex $args 1] .csv] ""]
            prove -all
        } else {
            set it 0
            while {$it<30} {
                check_conn -load [join [list $file_name [lindex $MCS_IDs $it] .csv] ""]
                prove -all
                check_conn -clear
                set it [expr {$it + 1}]    
            }
            assume -env -clear
        }
    }
}
