###################################################################################
####### Results for FPS traffic. It has to be an uplink and a downlink flow #######

proc write_file_for_calculating_fps_results_ {} {
    global number_of_wifi_cars_ folder_output_name_ fps_down_mask_ fps_up_mask_ v2v_ remove_intermediate_files_ one-way-delay-wired_part_ original_directory_

	# This procedure generates two files for every application and car, including all the packets with the sending and arrival times
	# it requires some PERL scripts to be in the ./perl scripts/ directory:
	# extract_num_time_wired_trace.pl
	# extract_num_time_wireless_trace.pl
	# join_up_files.pl
	# join_down_files.pl
	# calculate_mos_up_down.pl

	# preselection of the interesting traffic
	puts "Selecting FPS packets from the trace..."

	#create a file with the script to execute in order to obtain the results
	set file_name_ [concat $folder_output_name_/script_selecting_fps_packets.txt ]
	set script_file_ [open $file_name_ w]

	# If I am using v2v routing, I use the wired trace for selecting the packets
	if { $v2v_ == 1 } {
		puts $script_file_ "grep 'r -t'.*'-Hd -2'.*'-It udp'.*'-If 5' cars_street.tr > cars_street_fps_up_sent.tr"
		puts $script_file_ "echo FPS uplink sent selection finished"

		puts $script_file_ "grep 'r'.*'1 0 udp'.*'1.0.' cars_street.tr > cars_street_fps_up_received.tr"
		puts $script_file_ "echo FPS uplink received selection finished"

		puts $script_file_ "grep '+'.*'0 1 udp'.*'0.0.0.' cars_street.tr > cars_street_fps_down_sent.tr"
		puts $script_file_ "echo FPS downlink sent selection finished"

	# If I am not using v2v routing, I use the wireless trace for selecting the packets
	} else {
		puts $script_file_ "grep 's -t'.*'-Hd -2'.*'-Ms 0'.*'-It udp'.*'-If 5' cars_street.tr > cars_street_fps_up_sent.tr"
		puts $script_file_ "echo FPS uplink sent selection finished"

		puts $script_file_ "grep 'r '.*'-Mt 800'.*'-It udp'.*'-If 5' cars_street.tr > cars_street_fps_up_received.tr"
		puts $script_file_ "echo FPS uplink received selection finished"

		puts $script_file_ "grep 's -t'.*'-Md 0 -Ms 0'.*'-It udp'.*'-If 6' cars_street.tr > cars_street_fps_down_sent.tr"
		puts $script_file_ "echo FPS downlink sent selection finished"
	}
	puts $script_file_ "grep 'r '.*'-Ni'.*'-It udp'.*'-If 6' cars_street.tr > cars_street_fps_down_received.tr"
	puts $script_file_ "echo FPS down received selection finished"

	#puts $script_file_ "rm cars_street.tr"

	# close the script file
	close $script_file_

	# move to the output directory
	cd ./$folder_output_name_

	# execute the script
	exec chmod +x script_selecting_fps_packets.txt
	exec ./script_selecting_fps_packets.txt

	# return to the original directory
	cd ..


	# For each car running a FPS uplink and downlink, I obtain two output files: packets_up_car_$i.txt and packets_down_car_$i.txt
	# these files include three columns: packet number, departure time and arrival time
	# if the packet has not arrived, then the arrival time is -1

	# First, I build a script file which, using grep and perl, extracts info from the traces
	# Finally, I execute the script and delete all the intermediate files, including the script
	for {set i 1} { $i <= $number_of_wifi_cars_ } { incr i } {
		if { ($fps_down_mask_($i) == 1 ) && ($fps_up_mask_($i) == 1 ) } {

			puts "Calculating results FPS car $i..."

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_output_name_/script_calculating_results_fps_car_ ]
			append file_name_ "$i"
			append file_name_ ".txt"
			set script_file_ [open $file_name_ w]


	####### Results for VoIP traffic
	# this part has not been implemented
	# it is the same as FPS, but changing the port number
	#set up_flow_id_ [expr 30000 + $i ]
	#set down_flow_id_ [expr 40000 + $i ]


			# Calculate port numbers
			set up_flow_id_ [expr 50000 + $i ]

			set down_flow_id_ [expr 60000 + $i ]

			# Create the script file (http://nsnam.isi.edu/nsnam/index.php/NS-2_Trace_Formats#New_Wireless_Trace_Formats)
			# -Hd -1 means that the packet is a broadcast packet, and -2 means that the destination node has not been set
			# -Hd -2 is typically seen for packets that are passed between the agent (-Nl AGT) and routing (-Nl RTR) levels.

			# uplink part

			# select the sent packets of this car
			puts $script_file_ "grep 's'.*'-Hd -2'.*'-It udp'.*'-If $up_flow_id_' cars_street_fps_up_sent.tr > cars_street_fps_up_sent.txt"
			# extrat number and time sent
			puts $script_file_ "perl $original_directory_/perl_scripts/extract_num_time_wireless_trace.pl cars_street_fps_up_sent.txt > cars_street_fps_up_sent_num_tiempo.txt"
			
			if { $v2v_ == 1 } {
				# select the received packets
				puts $script_file_ "grep 'r'.*'1 0 udp'.*'$up_flow_id_ 1.0.$i.' cars_street_fps_up_received.tr > cars_street_fps_up_received.txt"
				# extract number and time sent
				puts $script_file_ "perl $original_directory_/perl_scripts/extract_num_time_wired_trace.pl cars_street_fps_up_received.txt > cars_street_fps_up_received_num_tiempo.txt"
			} else {
				# select the received packets
				puts $script_file_ "grep  'r'.*'-If $up_flow_id_' cars_street_fps_up_received.tr > cars_street_fps_up_received.txt"
				# extract number and time sent
				puts $script_file_ "perl $original_directory_/perl_scripts/extract_num_time_wireless_trace.pl cars_street_fps_up_received.txt > cars_street_fps_up_received_num_tiempo.txt"
			}
			# join the two files
			puts $script_file_ "perl $original_directory_/perl_scripts/join_up_files.pl cars_street_fps_up_sent_num_tiempo.txt cars_street_fps_up_received_num_tiempo.txt > packets_fps_up_car_$i.txt"

			# downlink part

			# select the sent packets
			if { $v2v_ == 1 } {
				puts $script_file_ "grep '+'.*'0 1 udp'.*'$down_flow_id_ 0.0.0.' cars_street_fps_down_sent.tr > cars_street_fps_down_sent.txt"
				# extract number and time sent
				puts $script_file_ "perl $original_directory_/perl_scripts/extract_num_time_wired_trace.pl cars_street_fps_down_sent.txt > cars_street_fps_down_sent_num_tiempo.txt"
			} else {
				puts $script_file_ "grep 's'.*'-If $down_flow_id_' cars_street_fps_down_sent.tr > cars_street_fps_down_sent.txt"
				# extract number and time sent
				puts $script_file_ "perl $original_directory_/perl_scripts/extract_num_time_wireless_trace.pl cars_street_fps_down_sent.txt > cars_street_fps_down_sent_num_tiempo.txt"
			}
			
			# select the received packets
			# Ni is the number of wireless node, which corresponds to i+1
			puts $script_file_ "grep 'r '.*'-Ni [expr $i + 1]'.*'-It udp'.*'-If $down_flow_id_' cars_street_fps_down_received.tr > cars_street_fps_down_received.txt"
			# extract number and time sent
			puts $script_file_ "perl $original_directory_/perl_scripts/extract_num_time_wireless_trace.pl cars_street_fps_down_received.txt > cars_street_fps_down_received_num_tiempo.txt"
			# join the two files
			puts $script_file_ "perl $original_directory_/perl_scripts/join_down_files.pl cars_street_fps_down_sent_num_tiempo.txt cars_street_fps_down_received_num_tiempo.txt > packets_fps_down_car_$i.txt"

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_output_name_

			# execute the script
			exec chmod +x script_calculating_results_fps_car_$i.txt
			exec ./script_calculating_results_fps_car_$i.txt

			# remove intermediate files
			if { $remove_intermediate_files_ ==1 } {
				puts "removing intermediate files..."
				exec rm cars_street_fps_up_sent.txt
				exec rm cars_street_fps_up_sent_num_tiempo.txt
				exec rm cars_street_fps_up_received.txt
				exec rm cars_street_fps_up_received_num_tiempo.txt
				exec rm cars_street_fps_down_sent.txt
				exec rm cars_street_fps_down_sent_num_tiempo.txt
				exec rm cars_street_fps_down_received.txt
				exec rm cars_street_fps_down_received_num_tiempo.txt

				# remove the script file
				exec rm script_calculating_results_fps_car_$i.txt
			}
			# return to the original directory
			cd ..
		}
	}
}


####################################################################################
proc calculate_fps_delay_jitter_loss_mos_ { tick_ } {
    global number_of_wifi_cars_ folder_output_name_ fps_down_mask_ fps_up_mask_ one_way_delay_wired_part_ v2v_ original_directory_

	# This procedure calculates delay, jitter, loss and MOS for each car running an application
	# It calculates the average during a tick_, which is expressed in seconds
	# values smaller than 100 ms for the tick have no sense for FPS, since the number of downlink packets to do the average is small
	# it uses the files packets_fps_down_car_$i.txt and packets_fps_up_car_$i.txt which have been generated with the previous procedure

	##### Calculate for FPS

	## Calculate average delay
	# we calculate the delay for the uplink and the delay for the downlink, and sum them
	
	for {set i 1} { $i <= $number_of_wifi_cars_ } { incr i } {
		if { ($fps_down_mask_($i) == 1 ) && ($fps_up_mask_($i) == 1 ) } {

			puts "Calculating delay, jitter, loss and MOS for FPS car $i..."
			set file_name_down_ packets_fps_down_car_$i.txt

			set file_name_up_ packets_fps_up_car_$i.txt

			# move to the output directory
			cd ./$folder_output_name_
			# execute the PERL script. 
			if { $v2v_ == 1 } {
				exec perl $original_directory_/perl_scripts/calculate_mos_up_down.pl $file_name_up_ $file_name_down_ $tick_ 0 > delay_jitter_mos_car_$i.txt
			
			# If I am not using adhoc mode, I have to artificially add the OWD for the wired part
			} else {
				exec perl $original_directory_/perl_scripts/calculate_mos_up_down.pl $file_name_up_ $file_name_down_ $tick_ $one_way_delay_wired_part_ > delay_jitter_mos_car_$i.txt
			}
			# return to the original directory
			cd ..
		}
	}
}



####################################################################################
proc calculate_summary_fps_all_cars_ { } {
    global number_of_wifi_cars_ folder_output_name_ fps_down_mask_ fps_up_mask_ original_directory_

	# define the name of the output file
	set file_name_output_ summary_fps_all_cars.txt

	# move to the output directory
	cd ./$folder_output_name_

	set output_file_ [open MOS_3.5_$file_name_output_ w]
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

	puts "Summarizing the results of FPS for every car ..."

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