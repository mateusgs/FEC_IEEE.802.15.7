proc get_parameters {} {
    set parameters [list]
    for {set i 4} {$i <= 4} {incr i $i} {
        for {set j 15} {$j <= 15} {incr j 5} {
            for {set k 50} {$k <= 200} {incr k 10} {
                set param [list $k $j $i]
                set parameters [linsert $parameters end $param]
            }
        }
    }
    return $parameters
}
