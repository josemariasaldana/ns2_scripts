############################################
#### This script is for using it only one time
#### it copies the movement trace files, adding the average speed to the name of each file
#### later, I manually rename each file with its order
############################################

for {set i 0 } { $i <= 110 } { incr i} {

	set tracefile_name_ "original_movement_traces/via benedetto croce-"
	append tracefile_name_ "$i"
	append tracefile_name_ ".txt"

	set tracefile_ [open $tracefile_name_ r]

	set summary_file_name_ "speed-time-of-each-trace.txt"
	set summary_file_ [open $summary_file_name_ w]

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
	puts "file $i; $float_duration_ final position_X: $float_position_ final; speed: $speed_; average speed: [format "%.3f"  $float_average_speed_]"

	set destinationfile_name_ "movement_traces/via benedetto croce-"
	if { $float_average_speed_ < 10.0 } {
		append destinationfile_name_ "0"
	}
	append destinationfile_name_ [format "%.3f"  $float_average_speed_]
	append destinationfile_name_ "-$float_position_"
	append destinationfile_name_ "-$i"
	append destinationfile_name_ ".txt"
	puts $destinationfile_name_

	exec cp $tracefile_name_ $destinationfile_name_

}