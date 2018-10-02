############################################
#### This script is for using it only one time
#### it copies the movement trace files, making the time begin in 0
############################################

for {set i 1 } { $i <= 111 } { incr i} {

	set tracefile_name_ "movement_traces_with_relative_time/via benedetto croce_"
	if {$i < 10} {
		append tracefile_name_ "00"
	} else {
		if {$i < 100 } {
			append tracefile_name_ "0"
		}
	}
	append tracefile_name_ [format "%.0f" $i ]
	append tracefile_name_ ".txt"

	set tracefile_ [open $tracefile_name_ r]

	set output_file_name_ "movement_traces/via benedetto croce_"
	if {$i < 10} {
		append output_file_name_ "00"
	} else {
		if {$i < 100 } {
			append output_file_name_ "0"
		}
	}
	append output_file_name_ [format "%.0f" $i ]
	append output_file_name_ ".txt"

	set output_file_ [open $output_file_name_ w]

	# Read the first line
	gets $tracefile_ line_													;# read the first line and parse it
	set fields [split $line_ "\t"]											;# Split into fields on tabs
	lassign $fields time_0_ position_ other_ speed_							;# Assign fields to variables

	# Read the rest of the lines until the last one
	while { [eof $tracefile_] == 0} {
		set fields [split $line_ "\t"]										;# Split into fields on tabs
		lassign $fields time_ position_ other_ speed_						;# Assign fields to variables
		gets $tracefile_ line_

		puts $output_file_ "[expr $time_ - $time_0_]\t$position_\t$other_\t$speed_"
	}

	close $output_file_
}