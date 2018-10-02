set god_ [God instance]

$god_ set-dist 1 2 2
$god_ set-dist 0 2 3
$god_ set-dist 0 1 1

for {set j 0} {$j < $opt(nn)} {incr j} {
	$node_($j) set Z_ 0.0
	$node_($j) set Y_ 0.0
	$node_($j) set X_ 0.0
	$ns_ at [expr $initial_time_ + ( $j * $seconds_between_cars_ ) ] "$node_($j) setdest 199.99 0.01 $car_speed_mps_" ;# a new car starts moving every $seconds_between_cars_
	$ns_ at [expr $initial_time_ + ( $j * $seconds_between_cars_ ) ] "puts \"car $j starts moving\""
}

