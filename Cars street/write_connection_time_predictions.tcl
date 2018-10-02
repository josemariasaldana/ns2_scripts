####################################################################################
proc write_connection_time_predictions_ { } {
    global	number_of_wifi_cars_ folder_output_name_ original_directory_ \
			ftp_up_mask_ ftp_down_mask_ \
			voip_up_mask_ voip_down_mask_ \
			fps_up_mask_ fps_down_mask_ \
			prediction_each_car_ prediction_moment_each_car_ argument7 \
			begin_moment_each_car_ game_duration_ \
			moment_enters_coverage_each_car_ moment_gets_out_coverage_each_car_

	puts "Writing the prediction for every car running an application ..."

	# define the name of the output file
	set file_name_output_ connection_predictions.txt

	# move to the output directory
	cd ./$folder_output_name_

	set output_file_ [open $file_name_output_ w]

	# I put this first line in the output file, including the title for each column
	puts $output_file_ "car_number\tprediction_of_connection_time_\tprediction_moment_";

	# For each car which has run a FPS application
	for {set i 1} { $i <= $number_of_wifi_cars_ } { incr i } {

		# I check if this car is running any application
		if { [expr $ftp_up_mask_($i) + $ftp_down_mask_($i) + $voip_up_mask_($i) + $voip_down_mask_($i) + $fps_up_mask_($i) + $fps_down_mask_($i) ] > 0 } {

			if { $argument7 == "mechanism" } {

				# the prediction mechanism is active
				puts $output_file_ "$i\t$prediction_each_car_($i)\t$prediction_moment_each_car_($i)";

				if { $prediction_each_car_($i) < $game_duration_ } {
					# the mechanism has not allowed you to play

					if { [expr $begin_moment_each_car_($i) + $game_duration_ ] < $moment_gets_out_coverage_each_car_($i) } {
						# false negative: you could have played, but you haven't
						puts "Prediction result: false negative. you could have played. 0"
						set prediction_result_ -1
					} else {
						# the agent has worked properly: you weren't able to play
						puts "Prediction result: don't play. 0.5"
						set prediction_result_ 0
					}

				} else {
					# you have been allowed to play

					if { [expr $begin_moment_each_car_($i) + $game_duration_ ] < $moment_gets_out_coverage_each_car_($i) } {
						# the agent has allowed you to play and you have played
						puts "Prediction result: play. 1"
						set prediction_result_ 1
					} else {
						# false positive: you couldn't play, but you have begun the game, and it hasn't finished properly
						puts "Prediction result: false positive. bad game. 0"
						set prediction_result_ -2
					}

				}
			puts "car $i\tinit game: $begin_moment_each_car_($i)\tprediction: $prediction_each_car_($i)\tout of coverage: $moment_gets_out_coverage_each_car_($i)\tfinish game: [expr $game_duration_ + $begin_moment_each_car_($i)]"
			
			} else {

				# the prediction mechanism is not active
				if { $argument7 == "random" } {
					if { [expr $begin_moment_each_car_($i) + $game_duration_ ] < $moment_gets_out_coverage_each_car_($i) } {
						# you have played well
						puts "no mechanism. good game 1"
						set prediction_result_ 1
				} else {
						# the game has been interrupted
						puts "no mechanism. bad game 0"
						set prediction_result_ 0
					}
	
				puts "car $i\tinit game: $begin_moment_each_car_($i)\tout of coverage: $moment_gets_out_coverage_each_car_($i)\tfinish game: [expr $game_duration_ + $begin_moment_each_car_($i)]"
				}
			}	

		}
	}

	#close the file
	close $output_file_

	# return to the original directory
	cd ..

	# write in a file the result of this test, regarding the predictions
	cd $original_directory_
	exec printf "$prediction_result_\t" >> prediction_results_all_traces-$argument7-$game_duration_.txt
}