####################################################################################
proc write_file_for_calculating_ftp_results_ {} {
    global number_of_wifi_cars_ folder_output_name_ ftp_down_mask_ ftp_up_mask_ remove_intermediate_files_ original_directory_

	# This procedure generates two files for every application and car, including all the packets with the sending and arrival times
	# it requires some PERL scripts to be in the ./perl scripts/ directory:
	# extract_num_time_wired_trace.pl
	# extract_num_time_wireless_trace.pl
	# join_up_files.pl
	# join_down_files.pl
	# calculate_mos_up_down.pl

	############### ATTENTION: FTP uplink results calculation still not implemented ############################################

	####### Results for TCP traffic

	# preselection of the interesting traffic
	puts "Selecting FTP downlink packets from the trace..."

	#create a file with the script to execute in order to obtain the results
	set file_name_ [concat $folder_output_name_/script_selecting_ftp_down_packets.txt ]
	set script_file_ [open $file_name_ w]

	#puts $script_file_ "grep 'r'.*'-Hd -2'.*'-It tcp' cars_street.tr > cars_street_ftp_up_sent.tr"
	#puts $script_file_ "echo FTP uplink sent selection finished"

	#puts $script_file_ "grep 'r'.*'1 0 tcp'.*'1.0.' cars_street.tr > cars_street_ftp_up_received.tr"
	#puts $script_file_ "echo FTP uplink received selection finished"

	puts $script_file_ "grep '+'.*'0 1 tcp'.*'0.0.0.' cars_street.tr > cars_street_ftp_down_sent.tr"
	puts $script_file_ "echo FTP downlink sent selection finished"

	puts $script_file_ "grep 'r '.*'-Nl MAC'.*'-It tcp' cars_street.tr > cars_street_ftp_down_received.tr"
	puts $script_file_ "echo FTP downlink received selection finished"

	# close the script file
	close $script_file_

	# move to the output directory
	cd ./$folder_output_name_

	# execute the script
	exec chmod +x script_selecting_ftp_down_packets.txt
	exec ./script_selecting_ftp_down_packets.txt

	# return to the original directory
	cd ..


	# For each car running a FTP downlink, I obtain an output file: packets_down_car_$i.txt
	# these files include three columns: packet number, departure time and arrival time
	# if the packet has not arrived, then the arrival time is -1

	# First, I build a script file which, using grep and perl, extracts info from the traces
	# Finally, I execute the script and delete all the intermediate files, including the script
	for {set i 1} { $i <= $number_of_wifi_cars_ } { incr i } {
		if { $ftp_down_mask_($i) == 1 } {

			puts "Calculating results FTP downlink car $i..."

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_output_name_/script_calculating_results_ftp_down_car_ ]
			append file_name_ "$i"
			append file_name_ ".txt"
			set script_file_ [open $file_name_ w]

			# Calculate port numbers. Does not work with FTP
			#set up_flow_id_ [expr 10000 + $i ]
			#set down_flow_id_ [expr 20000 + $i ]

			# Create the script file (http://nsnam.isi.edu/nsnam/index.php/NS-2_Trace_Formats#New_Wireless_Trace_Formats)

			# select the sent packets
			puts $script_file_ "grep '+'.*'0 1 tcp'.*'0 0.0.0.' cars_street_ftp_down_sent.tr > cars_street_ftp_down_sent.txt"

			# extract number and time sent
			puts $script_file_ "perl $original_directory_/perl_scripts/extract_num_time_wired_trace.pl cars_street_ftp_down_sent.txt > cars_street_ftp_down_sent_num_tiempo.txt"
			
			# select the received packets
			# Ni is the number of wireless node, which corresponds to i+1
			puts $script_file_ "grep 'r '.*'-Ni [expr $i + 1]'.*'-It tcp' cars_street_ftp_down_received.tr > cars_street_ftp_down_received.txt"
			# extrat number and time sent
			puts $script_file_ "perl $original_directory_/perl_scripts/extract_num_time_wireless_trace.pl cars_street_ftp_down_received.txt > cars_street_ftp_down_received_num_tiempo.txt"
			# join the two files
			puts $script_file_ "perl $original_directory_/perl_scripts/join_down_files.pl cars_street_ftp_down_sent_num_tiempo.txt cars_street_ftp_down_received_num_tiempo.txt > packets_ftp_down_car_$i.txt"

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_output_name_

			# execute the script
			exec chmod +x script_calculating_results_ftp_down_car_$i.txt
			exec ./script_calculating_results_ftp_down_car_$i.txt

			puts "removing intermediate files..."

			# remove intermediate files
			if { $remove_intermediate_files_ ==1 } {
				exec rm cars_street_ftp_down_sent.txt
				exec rm cars_street_ftp_down_sent_num_tiempo.txt
				exec rm cars_street_ftp_down_received.txt
				exec rm cars_street_ftp_down_received_num_tiempo.txt

				# remove the script file
				exec rm script_calculating_results_ftp_down_car_$i.txt
			}
			# return to the original directory
			cd ..
		}
	}
}


####################################################################################
proc calculate_ftp_throughput_ { tick_ } {
    global number_of_wifi_cars_ folder_output_name_ ftp_down_mask_ ftp_up_mask_ original_directory_

	# This procedure calculates the throughput for each car running an FTP
	# It calculates the average during a tick_, which is expressed in seconds
	# it uses the files packets_ftp_down_car_$i.txt or packets_ftp_up_car_$i.txt which have been generated with the previous procedure

	## Calculate throughput 
	
	for {set i 1} { $i <= $number_of_wifi_cars_ } { incr i } {
		# downlink
		if { $ftp_down_mask_($i) == 1 } {

			puts "Calculating throughput for FTP down car $i..."
			set file_name_down_ packets_ftp_down_car_$i.txt

			# move to the output directory
			cd ./$folder_output_name_
			# execute the PERL script
			exec perl $original_directory_/perl_scripts/calculate_throughput.pl $file_name_down_ $tick_ > throughput_ftp_down_car_$i.txt
			# return to the original directory
			cd ..
		}

		# uplink
		if { $ftp_up_mask_($i) == 1 } {

			puts "Calculating throughput for FTP up car $i..."
			set file_name_up_ packets_fps_up_car_$i.txt

			# move to the output directory
			cd ./$folder_output_name_
			# execute the PERL script
			exec perl $original_directory_/perl_scripts/calculate_throughput.pl $file_name_up_ $tick_ > throughput_ftp_up_car_$i.txt
			# return to the original directory
			cd ..
		}
	}
}



####################################################################################
proc calculate_summary_ftp_all_cars_ { } {
    global number_of_wifi_cars_ folder_output_name_ ftp_down_mask_ ftp_up_mask_ original_directory_

	# define the name of the output file
	set file_name_output_ summary_ftp_all_cars.txt

	# move to the output directory
	cd ./$folder_output_name_

	set output_file_ [open $file_name_output_ w]
	# I put this first line in the output file, including the title for each column
	puts $output_file_ "car_number\tinitial_best_interval_time\tfinal_interval_time\tinitial_best_interval_x_position\tfinal_x_position\taverage_delay_best_interval_ms\taverage_jitter_best_interval_ms\taverage_loss_best_interval\taverage_mos_best_interval";
	#close the file
	close $output_file_

	set output_file_ [open MOS_3.5_1_joker_$file_name_output_ w]
	# I put this first line in the output file, including the title for each column
	puts $output_file_ "car_number\tinitial_best_interval_time\tfinal_interval_time\tinitial_best_interval_x_position\tfinal_x_position\taverage_delay_best_interval_ms\taverage_jitter_best_interval_ms\taverage_loss_best_interval\taverage_mos_best_interval";
	#close the file
	close $output_file_

	set output_file_ [open MOS_3_$file_name_output_ w]
	# I put this first line in the output file, including the title for each column
	puts $output_file_ "car_number\tinitial_best_interval_time\tfinal_interval_time\tinitial_best_interval_x_position\tfinal_x_position\taverage_delay_best_interval_ms\taverage_jitter_best_interval_ms\taverage_loss_best_interval\taverage_mos_best_interval";
	#close the file
	close $output_file_

	set output_file_ [open MOS_3_1_joker_$file_name_output_ w]
	# I put this first line in the output file, including the title for each column
	puts $output_file_ "car_number\tinitial_best_interval_time\tfinal_interval_time\tinitial_best_interval_x_position\tfinal_x_position\taverage_delay_best_interval_ms\taverage_jitter_best_interval_ms\taverage_loss_best_interval\taverage_mos_best_interval";
	#close the file
	close $output_file_

	puts "Summarizing the results of FTP for every car ..."

	# For each car which has run a FPS application
	for {set i 1} { $i <= $number_of_wifi_cars_ } { incr i } {
		if { ($fps_down_mask_($i) == 1 ) && ($fps_up_mask_($i) == 1 ) } {

			set file_name_input_ delay_jitter_mos_car_$i.txt

			# in the column 13 of the input file it is the MOS. The script counts the number of ticks above 3.5 or 3
			# the script also considers the possibility of using a number of "joker". I use 0, 1 or 2

			# execute the PERL script
			exec perl $original_directory_/perl_scripts/calculate_summary_one_car.pl $file_name_input_ $i 3.5 0 >> MOS_3.5_$file_name_output_

			# execute the PERL script
			exec perl $original_directory_/perl_scripts/calculate_summary_one_car.pl $file_name_input_ $i 3.5 1 >> MOS_3.5_1_joker_$file_name_output_

			# execute the PERL script
			exec perl $original_directory_/perl_scripts/calculate_summary_one_car.pl $file_name_input_ $i 3.5 2 >> MOS_3.5_2_joker_$file_name_output_

			# execute the PERL script
			exec perl $original_directory_/perl_scripts/calculate_summary_one_car.pl $file_name_input_ $i 3 0 >> MOS_3_$file_name_output_

			# execute the PERL script
			exec perl $original_directory_/perl_scripts/calculate_summary_one_car.pl $file_name_input_ $i 3 1 >> MOS_3_1_joker_$file_name_output_

			# execute the PERL script
			exec perl $original_directory_/perl_scripts/calculate_summary_one_car.pl $file_name_input_ $i 3 2 >> MOS_3_2_joker_$file_name_output_
		}
	}


	# return to the original directory
	cd ..
}