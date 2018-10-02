############################################
#### This script is for using it only one time
#### it reads all the ordered traces and gets its duration, final speed and average speed
#### the format of the traces is "via benedetto croce_003.txt"
############################################

for {set i 1 } { $i <= 111 } { incr i} {

	set tracefile_name_ "movement_traces/via benedetto croce_"
	if { $i < 10 } {
		append tracefile_name_ "00"
	} else {
		if { $i < 100 } {
			append tracefile_name_ "0"
		}
	}
	append tracefile_name_ "$i"
	append tracefile_name_ ".txt"

	set tracefile_ [open $tracefile_name_ r]

	# Read the first line
	gets $tracefile_ line_													;# read the first line and parse it
	set fields [split $line_ "\t"]											;# Split into fields on tabs
	lassign $fields time_0_ position_0_ other_0_ speed_0_					;# Assign fields to variables

	# Read the rest of the lines until the last one
	while { [eof $tracefile_] == 0} {
		set fields [split $line_ "\t"]										;# Split into fields on tabs
		lassign $fields time_ position_ other_ speed_						;# Assign fields to variables
		gets $tracefile_ line_
	}

	set float_duration_ [expr 1.0 * ( $time_ - $time_0_ ) ]
	set float_position_ [expr 1.0 * $position_ ]
	set float_average_speed_ [expr $float_position_ / $float_duration_ ]

	# I add a line to the summary file 
	puts "trace\t$i\tduration:\t$float_duration_\tfinal position_X:\t$float_position_\tfinal speed:\t$speed_\taverage speed\t[format "%.3f"  $float_average_speed_]"

	close $tracefile_

}
