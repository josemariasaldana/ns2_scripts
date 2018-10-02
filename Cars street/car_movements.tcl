############################################
#### Reading the speeds and positions from a file
############################################
proc car_movements_ { ns_ node_ car_number_ initial_time_ street_length_ trace_to_use_ \
						prediction_each_car_ prediction_moment_each_car_ \
						moment_enters_coverage_each_car_ moment_gets_out_coverage_each_car_ args } {

	global uniform_ \
		ftp_up_ ftp_up_mask_ ftp_down_ ftp_down_mask_ \
		voip_up_ voip_up_mask_ voip_down_ voip_down_mask_ \
		fps_up_ fps_up_mask_ fps_down_ fps_down_mask_ \
		summary_movement_file_ \
		trace_group_ movement_group_allowed_ \
		simulation_duration_ tick_interval_ \
		calculate_prediction_ factor_widen_prediction_ prediction_init_position_ prediction_end_position_ \
		coverage_init_position_ coverage_end_position_

	upvar $prediction_each_car_ prediction_car_									;# this variable is an array for storing the prediction of this car
	upvar $prediction_moment_each_car_ prediction_moment_car_					;# this variable is an array for storing the moment in which the prediction of this car is available
	upvar $moment_enters_coverage_each_car_ moment_enters_coverage_car_			;# an array storing the moment in which each car enters in coverage
	upvar $moment_gets_out_coverage_each_car_ moment_gets_out_coverage_car_		;# an array storing the moment in which each car gets out of coverage

	# node_ is the car
	# car_number_ is the number of the car
	# initial_time_ is the moment in which the car begins to move. It is added to the moments in which speed varies, etc
	# trace_to_use_ is a string with 3 numbers: 000, 001 - 111

	# the cars move until they reach street_length_. There are two cases:
	#
	#	- random trace (000): a trace is selected until it ends. Then, another one is selected, and on and on until the car arrives to the end of the street
	#	- fixed trace  (057): trace 057 is used the number of times until the car arrives to the end of the street

	# using movement_traces_absolute_time.tcl, I have make the traces begin in t=0

	set movement_verbose_ 0		;# set this to 1 in order to make the movements appear in the screen

	set current_position_ 0.0
	set first_position_of_this_trace_ 0.0				;# initial position of the current movement trace
	set initial_time_this_trace_ $initial_time_			;# initial time of the current movement trace. It depends on the moment the car enters the street
	set coverage_init_moment_stored_ 0
	set coverage_end_moment_stored_ 0

	# variables used for the calculation of the prediction of the connection time
	# I check if this car is running any application and initialize the variables
	if { [expr $ftp_up_mask_($car_number_) + $ftp_down_mask_($car_number_) + $voip_up_mask_($car_number_) + $voip_down_mask_($car_number_) + $fps_up_mask_($car_number_) + $fps_down_mask_($car_number_) ] > 0 } {

		# variables used for calculating the prediction
		set prediction_status_ -1						;# it is -1 at the beginning; it is 0 while the car is in the prediction zone; it is 1 when the prediction has finished
		#set prediction_car_($car_number_) 0.0
		#set prediction_initial_moment_ 0.0				;# the moment the car enters in the prediction zone
		#set prediction_moment_car_($car_number_) 0.0
	}


	while { ( $current_position_ < $street_length_ ) } {

		######### BEGIN select trace ##################
		set tracefile_name_ "movement_traces/via benedetto croce_"

		# if $trace_to_use_ is 000, then a random trace belonging to the authorized trace groups is selected
		if { $trace_to_use_ == "000" } {

			set probability_ [$uniform_ value]
			set trace_ [expr ceil($probability_ * 111) ]

			# I check if the group to which the trace belongs is allowed
			while { $movement_group_allowed_($trace_group_([format "%.0f" $trace_])) != 1 } {
				set probability_ [$uniform_ value]
				set trace_ [expr ceil($probability_ * 111) ]
			}

			# I add 00 for the first 9 traces, and 0 for traces 10 to 99
			if {$trace_ < 10} {
				append tracefile_name_ "00"
			} else {
				if {$trace_ < 100 } {
					append tracefile_name_ "0"
				}
			}
			append tracefile_name_ [format "%.0f" $trace_ ]

		} else {	;# I select the required trace
			append tracefile_name_ "$trace_to_use_"
			set trace_ $trace_to_use_
		}
		if { $movement_verbose_ == 1 } {
			puts "movement trace: $trace_to_use_"
		}
		puts $summary_movement_file_ "car:\t$car_number_\tat\t$initial_time_this_trace_\tmovement trace:\t$trace_"

		append tracefile_name_ ".txt"
		set tracefile_ [open $tracefile_name_ r]
		######### END select trace ##################

		# Read the first line of the movement trace file
		gets $tracefile_ line_													;# read the first line and parse it
		set fields [split $line_ "\t"]											;# Split into fields on tabs
		lassign $fields time_ position_ other_ speed_		;# Assign each column of the txt file to the corresponding variable

		set current_position_ $first_position_of_this_trace_
		set previous_position_ $current_position_

		#set current_moment_ $initial_time_this_trace_

		# Read the rest of the lines until I pass the street length or finish the trace
		while { ( $current_position_ < $street_length_ ) && ($line_ != "") } {
			set current_moment_ [expr $time_ + $initial_time_this_trace_]

			#### calculation of the prediction of the connection time
			#by now, I am considering that all the street is under coverage when doing the prediction

			# I check if this car is running any application
			if { [expr $ftp_up_mask_($car_number_) + $ftp_down_mask_($car_number_) + $voip_up_mask_($car_number_) + $voip_down_mask_($car_number_) + $fps_up_mask_($car_number_) + $fps_down_mask_($car_number_) ] > 0 } {

				# calculation of the prediction
				if { ($calculate_prediction_ == 1) && ($prediction_status_ < 1 ) } {

					# if the prediction has not begun, and I pass the first threshold
					if { ($current_position_ > $prediction_init_position_) && ($prediction_status_ == -1 ) } {

						# The car gets inside the "prediction zone"
						set prediction_status_ 0
						set prediction_initial_moment_ $current_moment_

					} else {
						if { $current_position_ >= $prediction_end_position_ } {

							# the prediction has just finished
							set prediction_status_ 1

							# I have to predict the remaining connection time, so I divide the remaining part of the street between the average speed in the prediction zone
							set prediction_car_($car_number_) [expr $factor_widen_prediction_ * (($street_length_ - $prediction_end_position_) / ($prediction_end_position_ - $prediction_init_position_)) * ( $current_moment_ - $prediction_initial_moment_)]

							# I also store the moment in which the prediction has been obtained
							set prediction_moment_car_($car_number_) $current_moment_
						}
					}
				}
			}
			# end of the calculation of the prediction


			# the time and the speed are the previous. The position is the one in the current line. The Y_ position is 0.0001
			if { $current_position_ == 0.0 } {
				set current_position_ 0.001
				set previous_position_ 0.001
			}
			#$ns_ at [expr $initial_time_this_trace_ + $time_ ] "$node_ setdest $current_position_ 0.0001 $speed_"
			#$ns_ at $current_moment_ "$node_ setdest $current_position_ 0.0001 $speed_" ;# this is wrong
			$ns_ at $current_moment_ "$node_ setdest $current_position_ 0.0001 [expr ( $current_position_ - $previous_position_ ) / $tick_interval_ ]"

			if { $movement_verbose_ == 1 } {
				puts "car $car_number_ at [expr $initial_time_this_trace_ + $time_ ] destination_X:$current_position_ speed: $speed_"
			}

			# store the moment in which the car enters and gets out of coverage
			if { ($current_position_ > $coverage_init_position_) && ( $coverage_init_moment_stored_ == 0) } {
				set moment_enters_coverage_car_($car_number_) $current_moment_
				set coverage_init_moment_stored_ 1
			}
			if { ($current_position_ > $coverage_end_position_) && ( $coverage_end_moment_stored_ == 0) } {
				set moment_gets_out_coverage_car_($car_number_) $current_moment_
				set coverage_end_moment_stored_ 1
			}

			# Read another line
			gets $tracefile_ line_												;# read the  line and parse it
			if { $line_ != "" } {
				set fields [split $line_ "\t"]										;# Split into fields on tabs
				lassign $fields time_ position_ other_ speed_						;# Assign fields to variables

				set previous_position_ $current_position_
				set current_position_ [expr $position_ + $first_position_of_this_trace_]
			}
		}

		# if I have finished the trace, I have to take another trace
		if { $line_ == "" } {
			set first_position_of_this_trace_ $current_position_
			set initial_time_this_trace_ [expr $initial_time_this_trace_ + $time_ + 1.0 ]

		# if the street has not finished, I can go out the loop doing nothing
		}
	} ;# the car has ended the street

	# if the car has been always under coverage, I have to set the value of the $moment_gets_out_coverage_car_ to the end moment
	if { $coverage_end_moment_stored_ == 0 } {
		set moment_gets_out_coverage_car_($car_number_) $current_moment_
	}


	#puts "car $car_number_ enters coverage: $moment_enters_coverage_car_($car_number_)"
	#puts "car $car_number_ gets out of coverage: $moment_gets_out_coverage_car_($car_number_)"

	# in order to avoid interactions between cars, at the end, the car is sent far away, and the applications of the car are stopped
	$ns_ at [expr $initial_time_this_trace_ + $time_ + 1.0 ] "car_finishes_ $ns_ $node_ $car_number_"

	# if this car is running any application, this time is the moment in which it ends. So it could be the new value for the duration of the simulation
	if { [expr $initial_time_this_trace_ + $time_ + 1.0 ] > $simulation_duration_ } {
		# if the car is running some application
		if { [expr $ftp_down_mask_($car_number_) + $ftp_up_mask_($car_number_) + $voip_down_mask_($car_number_) + $voip_up_mask_($car_number_) + $fps_down_mask_($car_number_) + $fps_up_mask_($car_number_)] > 0 } {
			set simulation_duration_ [expr $initial_time_this_trace_ + $time_ + 1.0 ]
			#puts "new simulation duration $simulation_duration_"
		}
	}
}



proc car_finishes_ { ns_ node_ car_number_ } {

# this procedure sends a car far away and stops all its running applications

	global	ftp_up_ ftp_up_mask_ ftp_down_ ftp_down_mask_ \
			voip_up_ voip_up_mask_ voip_down_ voip_down_mask_ \
			fps_up_ fps_up_mask_ fps_down_ fps_down_mask_ \
			summary_movement_file_ street_length_

	puts "[$ns_ now]\tcar\t$car_number_\tfinishes"

	puts $summary_movement_file_ "car\t$car_number_\tfinishes at:\t[$ns_ now]"
		
	# in order to avoid interactions with the cars still in the street, the cars are sent towards X=10*street_length at 100 mps
	$node_ setdest [expr $street_length_ * 10.0 ] 0.0001 100.0

	# I stop the applications in order to avoid extra calculations
	if { $ftp_up_mask_($car_number_) == 1} {
		stop_ftp_up_ $ns_ $node_ $car_number_
	}
	if { $ftp_down_mask_($car_number_) == 1} {
		stop_ftp_down_ $ns_ $node_ $car_number_
	}
	if { $voip_up_mask_($car_number_) == 1} {
		stop_voip_up_ $ns_ $node_ $car_number_
	}
	if { $voip_down_mask_($car_number_) == 1} {
		stop_voip_down_ $ns_ $node_ $car_number_
	}
	if { $fps_up_mask_($car_number_) == 1} {
		stop_fps_up_ $ns_ $node_ $car_number_
	}
	if { $fps_down_mask_($car_number_) == 1} {
		stop_fps_down_ $ns_ $node_ $car_number_
	}
}


proc stop_ftp_up_ { ns_ node_ car_number_ } {
	global ftp_up_ ftp_up_mask_

	$ftp_up_($car_number_) stop
}

proc stop_ftp_down_ { ns_ node_ car_number_ } {
	global ftp_down_ ftp_down_mask_

	$ftp_down_($car_number_) stop
}

proc stop_voip_up_ { ns_ node_ car_number_ } {
	global voip_up_ voip_up_mask_

	$voip_up_($car_number_) stop
}

proc stop_voip_down_ { ns_ node_ car_number_ } {
	global voip_down_ voip_down_mask_

	$fps_down_($car_number_) stop
}

proc stop_fps_up_ { ns_ node_ car_number_ } {
	global fps_up_ fps_up_mask_

	$fps_up_($car_number_) stop
}

proc stop_fps_down_ { ns_ node_ car_number_ } {
	global fps_down_ fps_down_mask_

	$fps_down_($car_number_) stop
}