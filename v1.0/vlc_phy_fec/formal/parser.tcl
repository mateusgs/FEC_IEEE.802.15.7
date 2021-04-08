proc parse_csv {file_name mcs_id} {
    set fp [open $file_name r]
    set file_data [read $fp]
    close $fp
    set file_data [split $file_data "\n"]
    set data {}
    set it 0
    while {$it<[expr {[llength $file_data] - 1}]} {
        lappend data [split [lindex $file_data $it] ","]
        set it [expr {$it + 1}]
    }
    set rit 0
    set cit 0
    set it1 0
    set done 0
    set row N
    set str ""
    set match {}
    set fix 1
    set matchaux {}
    while {$rit<[llength $data]} {
        set cit 0
        set row [lindex $data $rit]
        while {$cit<[llength $row]} {
#            set done 0
            set it 7
            while {$it>0} {
                if {$it>4} {
                    set it1 [expr {$it - 4}]
                } else {
                    set it1 1
                }
                set str [join [list {(.*)((( &&  )?~\(\(\S+ (==|~\^)\
                \S+i_conv_sel\)\))} "{" $it1 "}" {|(( && \
                )?~\(\(\S+i_sel (==|~\^) \S+\)\))} "{" $it "}"\
                {)(.*)}] ""]
                set match [regexp -inline $str [lindex $row $cit]]
                if {$match=={}} {
                    set str [join [list {(.*)((( && )?( ~\()?\(\S+ (==|~\^)\
                    \S+i_conv_sel\)\)?)} "{" $it1 "}" {|(( &&\
                    )?( ~\()?\(\S+i_sel (==|~\^) \S+\)\)?)} "{" $it "}"\
                    {)(.*)}] ""]
                    set match [regexp -inline $str [lindex $row $cit]]
                }
                if {$match!={}} {
#                    set done 1
                    set str ""
                    append str [lindex $match 1] "(6'd" $mcs_id " == VPFC.w_mcs_id)" [lindex $match [expr {[llength $match] - 1}]]
#                    set it 1
#                    while {$it<[llength mcs_id]} {
#                        append str " && (6'b" [lindex $mcs_id $it] " == VPFC.w_mcs_id)" 
#                        set it [expr {$it + 1}]
#                    }
#                    append str [lindex $match [expr {[llength $match] - 1}]]
                    set data [lreplace $data $rit $rit [lreplace $row $cit $cit $str]]
                    set row [lindex $data $rit]
                    puts stdout "Match in row [expr {$rit + 1}]:\nInput: [lindex\
                    $match 0]\nOutput: [lindex [lindex $data $rit] $cit]"
                    puts stdout\
                    "-------------------------------------------------------------"
                    break
                }
                set it [expr {$it - 1}]
            }
            set fix 1
            if {$mcs_id==4||$mcs_id==8||$mcs_id==20||$mcs_id==29||$mcs_id==37||$mcs_id==38} {
                set str [join [list {(.*)~\(\(1'b1 == \w+\.w_fec_enable\)\)(.*)}] ""]
                set fix 1                
            } else {
                set str [join [list {(.*)\(1'b1 == \w+\.w_fec_enable\)(.*)}] ""]
                set fix 0
            }
            set match [regexp -inline $str [lindex $row $cit]]
            if {$match!={}} {
                if {$fix} {
                    set str ""
#                   if {$done==0} {
#                       set done 1
                    append str [lindex $match 1] "(6'd" $mcs_id " == VPFC.w_mcs_id)" [lindex $match [expr {[llength $match] - 1}]]
#                   } else {
#                       append str [lindex $match 1] "(1)" [lindex $match [expr {[llength $match] - 1}]]
#                   }
                    set data [lreplace $data $rit $rit [lreplace $row $cit $cit $str]]
                    set row [lindex $data $rit]
                    puts stdout "Match in row [expr {$rit + 1}]:\nInput: [lindex\
                    $match 0]\nOutput: [lindex [lindex $data $rit] $cit]"
                    puts stdout\
                    "-------------------------------------------------------------"
                } else {
                    set fix 1
                    set str [join [list {(.*)~\(\(1'b1 == \w+\.w_fec_enable\)\)(.*)}] ""]  
                    set matchaux [regexp -inline $str [lindex $row $cit]]
                    if {$matchaux=={}} {
                        set str ""
#                       if {$done==0} {
#                           set done 1
                        append str [lindex $match 1] "(6'd" $mcs_id " == VPFC.w_mcs_id)" [lindex $match [expr {[llength $match] - 1}]]
#                       } else {
#                           append str [lindex $match 1] "(1)" [lindex $match [expr {[llength $match] - 1}]]
#                       }
                        set data [lreplace $data $rit $rit [lreplace $row $cit $cit $str]]
                        set row [lindex $data $rit]
                        puts stdout "Match in row [expr {$rit + 1}]:\nInput: [lindex\
                        $match 0]\nOutput: [lindex [lindex $data $rit] $cit]"
                        puts stdout\
                        "-------------------------------------------------------------"
                    }
                }
            }
            if {$mcs_id==4||$mcs_id==8||$mcs_id==20||$mcs_id==29||$mcs_id==37||$mcs_id==38} {
                set str [join [list {(.*)\(\w+\.w_fec_enable\) == 0(.*)}] ""]
                set fix 1                
            } else {
                set str [join [list {(.*)\(\w+\.w_fec_enable\) == 1(.*)}] ""]
                set fix 1
            }
            set match [regexp -inline $str [lindex $row $cit]]
            if {$match!={}} {
                set str ""
#                if {$done==0} {
#                    set done 1
                 append str [lindex $match 1] "(6'd" $mcs_id " == VPFC.w_mcs_id)" [lindex $match [expr {[llength $match] - 1}]]
#                } else {
#                    append str [lindex $match 1] "(1)" [lindex $match [expr {[llength $match] - 1}]]
#                }
                set data [lreplace $data $rit $rit [lreplace $row $cit $cit $str]]
                set row [lindex $data $rit]
                puts stdout "Match in row [expr {$rit + 1}]:\nInput: [lindex\
                $match 0]\nOutput: [lindex [lindex $data $rit] $cit]"
                puts stdout\
                "-------------------------------------------------------------"
            }
            if {$mcs_id==0||$mcs_id==1||$mcs_id==2} {
                set str [join [list {(.*)\(1'b1 == \w+\.w_full_fec\)(.*)}] ""]
                set fix 0             
            } else {
                set str [join [list {(.*)~\(\(1'b1 == \w+\.w_full_fec\)\)(.*)}] ""]
                set fix 1
            }
            set match [regexp -inline $str [lindex $row $cit]]
            if {$match!={}} {
                if {$fix} {
                    set str ""
#                   if {$done==0} {
#                       set done 1
                    append str [lindex $match 1] "(6'd" $mcs_id " == VPFC.w_mcs_id)" [lindex $match [expr {[llength $match] - 1}]]
#                   } else {
#                       append str [lindex $match 1] "(1)" [lindex $match [expr {[llength $match] - 1}]]
#                   }
                    set data [lreplace $data $rit $rit [lreplace $row $cit $cit $str]]
                    set row [lindex $data $rit]
                    puts stdout "Match in row [expr {$rit + 1}]:\nInput: [lindex\
                    $match 0]\nOutput: [lindex [lindex $data $rit] $cit]"
                    puts stdout\
                    "-------------------------------------------------------------"
                } else {
                    set fix 1
                    set str [join [list {(.*)~\(\(1'b1 == \w+\.w_full_fec\)\)(.*)}] ""] 
                    set matchaux [regexp -inline $str [lindex $row $cit]]
                    if {$matchaux=={}} {
                        set str ""
#                       if {$done==0} {
#                           set done 1
                        append str [lindex $match 1] "(6'd" $mcs_id " == VPFC.w_mcs_id)" [lindex $match [expr {[llength $match] - 1}]]
#                       } else {
#                           append str [lindex $match 1] "(1)" [lindex $match [expr {[llength $match] - 1}]]
#                       }
                        set data [lreplace $data $rit $rit [lreplace $row $cit $cit $str]]
                        set row [lindex $data $rit]
                        puts stdout "Match in row [expr {$rit + 1}]:\nInput: [lindex\
                        $match 0]\nOutput: [lindex [lindex $data $rit] $cit]"
                        puts stdout\
                        "-------------------------------------------------------------"
                    }
                }
            }
            if {$mcs_id==0||$mcs_id==1||$mcs_id==2} {
                set str [join [list {(.*)\(\w+\.w_full_fec\) == 1(.*)}] ""]
                set fix 1             
            } else {
                set str [join [list {(.*)\(\w+\.w_full_fec\) == 0(.*)}] ""]
                set fix 1
            }
            set match [regexp -inline $str [lindex $row $cit]]
            if {$match!={}} {
                set str ""
#                if {$done==0} {
#                    set done 1
                 append str [lindex $match 1] "(6'd" $mcs_id " == VPFC.w_mcs_id)" [lindex $match [expr {[llength $match] - 1}]]
#                } else {
#                    append str [lindex $match 1] "(1)" [lindex $match [expr {[llength $match] - 1}]]
#                }
                set data [lreplace $data $rit $rit [lreplace $row $cit $cit $str]]
                set row [lindex $data $rit]
                puts stdout "Match in row [expr {$rit + 1}]:\nInput: [lindex\
                $match 0]\nOutput: [lindex [lindex $data $rit] $cit]"
                puts stdout\
                "-------------------------------------------------------------"
            }
            if {$mcs_id==0||$mcs_id==1||$mcs_id==2||$mcs_id==4||$mcs_id==8||$mcs_id==20||$mcs_id==29||$mcs_id==37||$mcs_id==38} {
                set str [join [list {(.*)~\(\(1'b1 == \w+\.w_rs_only\)\)(.*)}] ""]
                set fix 1
            } else {
                set str [join [list {(.*)\(1'b1 == \w+\.w_rs_only\)(.*)}] ""]
                set fix 0
            }
            set match [regexp -inline $str [lindex $row $cit]]
            if {$match!={}} {
                if {$fix} {
                     set str ""
#                    if {$done==0} {
#                        set done 1
                     append str [lindex $match 1] "(6'd" $mcs_id " == VPFC.w_mcs_id)" [lindex $match [expr {[llength $match] - 1}]]
#                    } else {
#                        append str [lindex $match 1] "(1)" [lindex $match [expr {[llength $match] - 1}]]
#                    }
                     set data [lreplace $data $rit $rit [lreplace $row $cit $cit $str]]
                     set row [lindex $data $rit]
                     puts stdout "Match in row [expr {$rit + 1}]:\nInput: [lindex\
                     $match 0]\nOutput: [lindex [lindex $data $rit] $cit]"
                     puts stdout\
                     "-------------------------------------------------------------"
                } else {
                    set fix 1
                    set str [join [list {(.*)~\(\(1'b1 == \w+\.w_rs_only\)\)(.*)}] ""]   
                    set matchaux [regexp -inline $str [lindex $row $cit]]
                    if {$matchaux=={}} {
                        set str ""
#                       if {$done==0} {
#                           set done 1
                        append str [lindex $match 1] "(6'd" $mcs_id " == VPFC.w_mcs_id)" [lindex $match [expr {[llength $match] - 1}]]
#                       } else {
#                           append str [lindex $match 1] "(1)" [lindex $match [expr {[llength $match] - 1}]]
#                       }
                        set data [lreplace $data $rit $rit [lreplace $row $cit $cit $str]]
                        set row [lindex $data $rit]
                        puts stdout "Match in row [expr {$rit + 1}]:\nInput: [lindex\
                        $match 0]\nOutput: [lindex [lindex $data $rit] $cit]"
                        puts stdout\
                        "-------------------------------------------------------------"
                    }
                }
            }
            if {$mcs_id==0||$mcs_id==1||$mcs_id==2||$mcs_id==4||$mcs_id==8||$mcs_id==20||$mcs_id==29||$mcs_id==37||$mcs_id==38} {
                set str [join [list {(.*)\(\w+\.w_rs_only\) == 0(.*)}] ""]
                set fix 1    
            } else {
                set str [join [list {(.*)\(\w+\.w_rs_only\) == 1(.*)}] ""]
                set fix 1
            }
            set match [regexp -inline $str [lindex $row $cit]]
            if {$match!={}} {
                set str ""
#                if {$done==0} {
#                    set done 1
                 append str [lindex $match 1] "(6'd" $mcs_id " == VPFC.w_mcs_id)" [lindex $match [expr {[llength $match] - 1}]]
#                } else {
#                    append str [lindex $match 1] "(1)" [lindex $match [expr {[llength $match] - 1}]]
#                }
                set data [lreplace $data $rit $rit [lreplace $row $cit $cit $str]]
                set row [lindex $data $rit]
                puts stdout "Match in row [expr {$rit + 1}]:\nInput: [lindex\
                $match 0]\nOutput: [lindex [lindex $data $rit] $cit]"
                puts stdout\
                "-------------------------------------------------------------"
            }
            if {$mcs_id==0||$mcs_id==1||$mcs_id==2} {
                set str [join [list {(.*)\(1'b1 == \w+\.w_inner_code_enable\)(.*)}] ""]
                set fix 0
            } else {
                set str [join [list {(.*)~\(\(1'b1 == \w+\.w_inner_code_enable\)\)(.*)}] ""]
                set fix 1 
            }
            set match [regexp -inline $str [lindex $row $cit]]
            if {$match!={}} {
                if {$fix} {
                    set str ""
#                   if {$done==0} {
#                       set done 1
                    append str [lindex $match 1] "(6'd" $mcs_id " == VPFC.w_mcs_id)" [lindex $match [expr {[llength $match] - 1}]]
#                   } else {
#                       append str [lindex $match 1] "(1)" [lindex $match [expr {[llength $match] - 1}]]
#                   }
                    set data [lreplace $data $rit $rit [lreplace $row $cit $cit $str]]
                    set row [lindex $data $rit]
                    puts stdout "Match in row [expr {$rit + 1}]:\nInput: [lindex\
                    $match 0]\nOutput: [lindex [lindex $data $rit] $cit]"
                    puts stdout\
                    "-------------------------------------------------------------"
                } else {
                    set fix 1
                    set str [join [list {(.*)~\(\(1'b1 == \w+\.w_inner_code_enable\)\)(.*)}] ""]  
                    set matchaux [regexp -inline $str [lindex $row $cit]]
                    if {$matchaux=={}} {
                        set str ""
#                       if {$done==0} {
#                           set done 1
                        append str [lindex $match 1] "(6'd" $mcs_id " == VPFC.w_mcs_id)" [lindex $match [expr {[llength $match] - 1}]]
#                       } else {
#                           append str [lindex $match 1] "(1)" [lindex $match [expr {[llength $match] - 1}]]
#                       }
                        set data [lreplace $data $rit $rit [lreplace $row $cit $cit $str]]
                        set row [lindex $data $rit]
                        puts stdout "Match in row [expr {$rit + 1}]:\nInput: [lindex\
                        $match 0]\nOutput: [lindex [lindex $data $rit] $cit]"
                        puts stdout\
                        "-------------------------------------------------------------"
                    }
                }
            }
            if {$mcs_id==0||$mcs_id==1||$mcs_id==2} {
                set str [join [list {(.*)\(\w+\.w_inner_code_enable\) == 1(.*)}] ""]
                set fix 1
            } else {
                set str [join [list {(.*)\(\w+\.w_inner_code_enable\) == 0(.*)}] ""]
                set fix 1 
            }
            set match [regexp -inline $str [lindex $row $cit]]
            if {$match!={}} {
                set str ""
#                if {$done==0} {
#                    set done 1
                 append str [lindex $match 1] "(6'd" $mcs_id " == VPFC.w_mcs_id)" [lindex $match [expr {[llength $match] - 1}]]
#                } else {
#                    append str [lindex $match 1] "(1)" [lindex $match [expr {[llength $match] - 1}]]
#                }
                set data [lreplace $data $rit $rit [lreplace $row $cit $cit $str]]
                set row [lindex $data $rit]
                puts stdout "Match in row [expr {$rit + 1}]:\nInput: [lindex\
                $match 0]\nOutput: [lindex [lindex $data $rit] $cit]"
                puts stdout\
                "-------------------------------------------------------------"
            }
            set cit [expr {$cit + 1}]
        }
        set rit [expr {$rit + 1}]
    }
    set rit 0
    set file_data ""
    set temp {}
    while {$rit<[llength $data]} {
        set cit 0
        set row [lindex $data $rit]
        set str ""
        while {$cit<[llength $row]} {
            if {$cit==0} {
                append str [lindex $row $cit]
            } else {
                append str "," [lindex $row $cit]
            }
            set cit [expr {$cit + 1}]
        }
        append file_data $str "\n"
        set rit [expr {$rit + 1}]
    }
    #puts stdout $data
    #puts stdout $file_data
    set fp [open [join [list "new_" $file_name] ""] w]
    puts $fp $file_data
    close $fp
    #exit
}
