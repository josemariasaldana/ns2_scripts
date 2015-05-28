###### Calculation of the throughput of each flow (the throughput includes the ACKs)
###### Calculation of the next throughputs. Each one is stored in a file in the folder "wow_throughput_files"
######
###### WoW
######		- throughput_sent_c_s_X.txt			throughput sent by the client of the connection X
######		- throughput_received_c_s_X.txt		throughput received by the server of the connection X
######		- throughput_sent_s_c_X.txt			throughput sent by the server of the connection X
######		- throughput_received_s_c_X.txt		throughput received by the client of the connection X
######
###### FTP
######	upload
######		- throughput_sent_ftp_upload_aggregate.txt			throughput sent by all the FTP upload connections
######		- throughput_sent_ftp_upload_X.txt					throughput sent by the X FTP upload connections
######		- throughput_received_ftp_upload_aggregate.txt		throughput rececived by all the FTP upload connections
######		- throughput_received_ftp_upload_X.txt				throughput received by the X FTP upload connections
######	note that the throughput of the ACKs of download FTP connections is not included here
######
######	download
######		- throughput_sent_ftp_download_aggregate.txt		throughput sent by all the FTP download connections
######		- throughput_sent_ftp_download_X.txt				throughput sent by the X FTP download connections
######		- throughput_received_ftp_download_aggregate.txt	throughput rececived by all the FTP download connections
######		- throughput_received_ftp_download_X.txt			throughput received by the X FTP download connections
######	note that the throughput of the ACKs of upload FTP connections is not included here
######
###### CBR
######	uplink
######		- throughput_sent_cbr_upload_.txt					throughput sent by all the CBR upload connections
######		- throughput_sent_small_cbr_upload_.txt				throughput sent by the small-packets CBR upload connection
######		- throughput_sent_medium_cbr_upload_.txt			throughput sent by the medium-packets CBR upload connection
######		- throughput_sent_large_cbr_upload_.txt				throughput sent by the large-packets CBR upload connection
######		- throughput_received_cbr_upload_.txt				throughput received by all the CBR upload connections
######		- throughput_received_small_cbr_upload_.txt			throughput received by the small-packets CBR upload connection
######		- throughput_received_medium_cbr_upload_.txt		throughput received by the medium-packets CBR upload connection
######		- throughput_received_large_cbr_upload_.txt			throughput received by the large-packets CBR upload connection
######
######	downlink
######		- throughput_sent_cbr_download_.txt					throughput sent by all the CBR download connections
######		- throughput_sent_small_cbr_download_.txt			throughput sent by the small-packets CBR download connection
######		- throughput_sent_medium_cbr_download_.txt			throughput sent by the medium-packets CBR download connection
######		- throughput_sent_large_cbr_download_.txt			throughput sent by the large-packets CBR download connection
######		- throughput_received_cbr_download_.txt				throughput received by all the CBR download connections
######		- throughput_received_small_cbr_download_.txt		throughput received by the small-packets CBR download connection
######		- throughput_received_medium_cbr_download_.txt		throughput received by the medium-packets CBR download connection
######		- throughput_received_large_cbr_download_.txt		throughput received by the large-packets CBR download connection


# the procedure requires the use of throughput.pl, located in the folder /perl_scripts

proc calculate_throughput_ { } {
	global	ns tick_interval_ number_of_wow_connections_0_1_ number_of_wow_connections_6_7_ total_number_of_connections_ \
			number_of_FTP_upload_connections_2_3_ number_of_FTP_download_connections_2_3_ \
			number_of_FTP_upload_connections_12_13_ number_of_FTP_download_connections_12_13_ \
			number_of_FTP_upload_connections_ number_of_FTP_download_connections_ \
			calculate_throughput_individual_ calculate_throughput_aggregate_ \
			uplink_UDP_traffic_mix_kbps_ downlink_UDP_traffic_mix_kbps_ folder_throughput_output_name_

	set remove_intermediate_files_ 1	;# set this to 1 if you want to remove all the intermediate files

	# This is the folder where these data will be stored
	file mkdir $folder_throughput_output_name_


	########### WOW traffic ##########################################################

	##########################################################################
	############# I. client-server sent packets ##############################
	##########################################################################

	######## I.A. Aggregate throughput of client-server flows beginning in node 0 ###########
	if { $calculate_throughput_aggregate_ == 1 } {
		if { $number_of_wow_connections_0_1_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_sent_c_s_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate wow client-sever sent of connections node0-node1"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 0 to node 8, belonging to the client-server connections (beginning with 11)
			# this includes tcp client-server packets (111xxx), and ACKs corresponding to server-client packets (112xxx)
			puts $script_file_ "grep '+ '.*' 0 8 '.*'- 11' ../out.tr > sent_c_s_connections_node_0.tr"	
			#puts $script_file_ "grep '+ '.*' 0 8 ' ../out.tr > sent_c_s_connections_node_0.tr"		!!!! delete this line
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_c_s_connections_node_0.tr + 0 8 $tick_interval_ all > throughput_sent_c_s_connections_node_0.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_c_s_connections_node_0.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_c_s_packets.txt
			exec ./script_selecting_sent_c_s_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_c_s_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## I.B. Aggregate throughput of client-server flows node6-node7 ###########

	if { $calculate_throughput_aggregate_ == 1 } {
		if { $number_of_wow_connections_6_7_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_sent_c_s_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate wow client-sever sent of connections node6-node7"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 6 to node 9, belonging to the client-server connections (beginning with 33)
			# this includes tcp client-server packets (331xxx), and ACKs corresponding to server-client packets (332xxx)
			puts $script_file_ "grep '+ '.*' 6 9 '.*'- 33' ../out.tr > sent_c_s_connections_node_6.tr"
			#puts $script_file_ "grep '+ '.*' 6 9 ' ../out.tr > sent_c_s_connections_node_6.tr"	!!!! delete this line
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_c_s_connections_node_6.tr + 6 9 $tick_interval_ all > throughput_sent_c_s_connections_node_6.txt"
		
			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_c_s_connections_node_6.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_c_s_packets.txt
			exec ./script_selecting_sent_c_s_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_c_s_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## I.C. throughput of each individual flow ###########

	# calculate the throughput of each individual flow
	if { $calculate_throughput_individual_ == 1 } {
		for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_sent_c_s_packets.txt ]
			set script_file_ [open $file_name_ w]

			# First, calculate the throughput of connections node0-node1
			if { $connection_id_ < $number_of_wow_connections_0_1_ } {
				puts "throughput: individual wow connection $connection_id_"

				# First, using GREP, the .tr file is split into the sent and received packets of each connection
				# Look for packets from node 0 to node 8, belonging to client-server flows (1110XX)
				# this includes tcp client-server packets (111xxx), and ACKs corresponding to server-client packets (112xxx)
				puts $script_file_ "grep '+ '.*' 0 8 '.*'$connection_id_ 0.' ../out.tr > sent_c_s_$connection_id_.tr" 
			
				# Using a perl script, calculate the throughput
				puts $script_file_ "perl ../perl_scripts/throughput.pl sent_c_s_$connection_id_.tr + 0 8 $tick_interval_ all > throughput_sent_c_s_$connection_id_.txt"
		
			# connections from node 6 to node 7
			} else {
				puts "throughput: individual wow connection $connection_id_"

				# First, using GREP, the .tr file is split into the sent and received packets of each connection
				# Look for packets from node 6 to node 9, belonging to client-server flows (3310XX)
				# this includes tcp client-server packets (331xxx), and ACKs corresponding to server-client packets (332xxx)
				puts $script_file_ "grep '+ '.*' 6 9 '.*'$connection_id_ 6.' ../out.tr > sent_c_s_$connection_id_.tr"
			
				# Using a perl script, calculate the throughput
				puts $script_file_ "perl ../perl_scripts/throughput.pl sent_c_s_$connection_id_.tr + 6 9 $tick_interval_ all > throughput_sent_c_s_$connection_id_.txt"

			}
			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_c_s_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_c_s_packets.txt
			exec ./script_selecting_sent_c_s_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_c_s_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}

	###############################################################################
	############# II. client-server received packets ##############################
	###############################################################################

	######## II.A. Aggregate throughput of client-server flows node0-node1 ###########

	if { $calculate_throughput_aggregate_ == 1 } {
			if { $number_of_wow_connections_0_1_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_c_s_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate wow client-sever received of connections node0-node1"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 5 to node 1, belonging to the client-server connections (beginning with 111)
			# this includes tcp client-server packets (111xxx), and ACKs corresponding to server-client packets (112xxx)
			puts $script_file_ "grep 'r '.*' 5 1 '.*'- 11' ../out.tr > received_c_s_connections_node_0.tr"
			#puts $script_file_ "grep 'r '.*' 5 1 ' ../out.tr > received_c_s_connections_node_0.tr"	!!!! delete this line
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_c_s_connections_node_0.tr r 5 1 $tick_interval_ all > throughput_received_c_s_connections_node_0.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_c_s_connections_node_0.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_c_s_packets.txt
			exec ./script_selecting_received_c_s_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_c_s_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## II.B. Aggregate throughput of client-server flows node6-node7 ###########

	if { $calculate_throughput_aggregate_ == 1 } {
		if { $number_of_wow_connections_6_7_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_c_s_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate wow client-sever received of connections node6-node7"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 5 to node 7, belonging to the client-server connections (beginning with 331)
			# this includes tcp client-server packets (331xxx), and ACKs corresponding to server-client packets (332xxx)
			puts $script_file_ "grep 'r '.*' 5 7 '.*'- 33' ../out.tr > received_c_s_connections_node_6.tr"
			#puts $script_file_ "grep 'r '.*' 5 7 ' ../out.tr > received_c_s_connections_node_6.tr" 	!!!! delete this line
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_c_s_connections_node_6.tr r 5 7 $tick_interval_ all > throughput_received_c_s_connections_node_6.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_c_s_connections_node_6.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_c_s_packets.txt
			exec ./script_selecting_received_c_s_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_c_s_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## II.C. throughput of each individual flow ###########

	if { $calculate_throughput_individual_ == 1 } {
		for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_c_s_packets.txt ]
			set script_file_ [open $file_name_ w]

			# First, calculate the throughput of connections node0-node1
			if { $connection_id_ < $number_of_wow_connections_0_1_ } {
				puts "throughput: individual wow connection $connection_id_"

				# First, using GREP, the .tr file is split into the sent and received packets of each connection
				# Look for packets from node 5 to node 1, belonging to client-server flows (11xXXX)
				puts $script_file_ "grep 'r '.*' 5 1 '.*'$connection_id_ 0.' ../out.tr > received_c_s_$connection_id_.tr"
			
				# Using a perl script, calculate the throughput
				puts $script_file_ "perl ../perl_scripts/throughput.pl received_c_s_$connection_id_.tr r 5 1 $tick_interval_ all > throughput_received_c_s_$connection_id_.txt"
		
			# connections from node 6 to node 7
			} else {
				puts "throughput: individual wow connection $connection_id_"

				# First, using GREP, the .tr file is split into the sent and received packets of each connection
				# Look for packets from node 5 to node 7, belonging to client-server flows (33xXXX)
				puts $script_file_ "grep 'r '.*' 5 7 '.*'$connection_id_ 6.' ../out.tr > received_c_s_$connection_id_.tr"
			
				# Using a perl script, calculate the throughput
				puts $script_file_ "perl ../perl_scripts/throughput.pl received_c_s_$connection_id_.tr r 5 7 $tick_interval_ all > throughput_received_c_s_$connection_id_.txt"

			}
			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_c_s_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_c_s_packets.txt
			exec ./script_selecting_received_c_s_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_c_s_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}

	###############################################################################################################################################################################

	##########################################################################
	############# III. server-client sent packets ############################
	##########################################################################


	######## III.A. Aggregate throughput of server-client flows node0-node1 ###########

	if { $calculate_throughput_aggregate_ == 1 } {
		if { $number_of_wow_connections_0_1_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_sent_s_c_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate wow server-client sent of connections node0-node1"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 1 to node 5, belonging to the server-client connections (beginning with 11)
			# this includes tcp server-client packets (112xxx), and ACKs corresponding to client-server packets (111xxx)
			puts $script_file_ "grep '+ '.*' 1 5 '.*'- 11' ../out.tr > sent_s_c_connections_node_1.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_s_c_connections_node_1.tr + 1 5 $tick_interval_ all > throughput_sent_s_c_connections_node_1.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_s_c_connections_node_1.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_s_c_packets.txt
			exec ./script_selecting_sent_s_c_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_s_c_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## III.B. Aggregate throughput of server-client flows node6-node7 ###########

	if { $calculate_throughput_aggregate_ == 1 } {
		if { $number_of_wow_connections_6_7_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_sent_s_c_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate wow server-client sent of connections node6-node7"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 7 to node 5, belonging to the server-client connections (beginning with 332)
			# this includes tcp server-client packets (332xxx), and ACKs corresponding to client-server packets (331xxx)
			puts $script_file_ "grep '+ '.*' 7 5 '.*'- 33' ../out.tr > sent_s_c_connections_node_7.tr"
			#puts $script_file_ "grep '+ '.*' 7 5 ' ../out.tr > sent_s_c_connections_node_7.tr"	!!!! delete this line
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_s_c_connections_node_7.tr + 7 5 $tick_interval_ all > throughput_sent_s_c_connections_node_7.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_s_c_connections_node_7.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_s_c_packets.txt
			exec ./script_selecting_sent_s_c_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_s_c_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## III.C. throughput of each individual flow ###########

	# calculate the throughput of each individual flow
	if { $calculate_throughput_individual_ == 1 } {
		for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_sent_s_c_packets.txt ]
			set script_file_ [open $file_name_ w]

			# First, calculate the throughput of connections node0-node1
			if { $connection_id_ < $number_of_wow_connections_0_1_ } {
				puts "throughput: individual wow connection $connection_id_"

				# First, using GREP, the .tr file is split into the sent and received packets of each connection
				# Look for packets from node 1 to node 5, belonging to server-client flows (11xXXX)
				puts $script_file_ "grep '+ '.*' 1 5 '.*'$connection_id_ 1.' ../out.tr > sent_s_c_$connection_id_.tr"
			
				# Using a perl script, calculate the throughput
				puts $script_file_ "perl ../perl_scripts/throughput.pl sent_s_c_$connection_id_.tr + 1 5 $tick_interval_ all > throughput_sent_s_c_$connection_id_.txt"
		
			# connections from node 7 to node 6
			} else {
				puts "throughput: individual wow connection $connection_id_"

				# First, using GREP, the .tr file is split into the sent and received packets of each connection
				# Look for packets from node 7 to node 5, belonging to server-client flows (33xXXX)
				puts $script_file_ "grep '+ '.*' 7 5 '.*'$connection_id_ 7.' ../out.tr > sent_s_c_$connection_id_.tr"
			
				# Using a perl script, calculate the throughput
				puts $script_file_ "perl ../perl_scripts/throughput.pl sent_s_c_$connection_id_.tr + 7 5 $tick_interval_ all > throughput_sent_s_c_$connection_id_.txt"

			}
			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_s_c_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_s_c_packets.txt
			exec ./script_selecting_sent_s_c_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_s_c_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}

	###############################################################################
	############# IV. server-client received packets ##############################
	###############################################################################

	######## IV.A. Aggregate received throughput of server-client flows node0-node1 ###########

	if { $calculate_throughput_aggregate_ == 1 } {
		if { $number_of_wow_connections_0_1_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_s_c_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate wow server-client received of connections node0-node1"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 8 to node 0, belonging to the server-client connections (beginning with 112)
			# this includes tcp client-server packets (111xxx), and ACKs corresponding to server-client packets (112xxx)
			puts $script_file_ "grep 'r '.*' 8 0 '.*'- 11' ../out.tr > received_s_c_connections_node_1.tr"
			#puts $script_file_ "grep 'r '.*' 8 0 ' ../out.tr > received_s_c_connections_node_1.tr"	!!!! delete this line
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_s_c_connections_node_1.tr r 8 0 $tick_interval_ all > throughput_received_s_c_connections_node_1.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_s_c_connections_node_1.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_s_c_packets.txt
			exec ./script_selecting_received_s_c_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_s_c_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## IV.B. Aggregate received throughput of server-client flows node6-node7 ###########

	if { $calculate_throughput_aggregate_ == 1 } {
		if { $number_of_wow_connections_6_7_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_s_c_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate wow server-client received of connections node6-node7"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 9 to node 6, belonging to the server-client connections (beginning with 332)
			# this includes tcp server-client packets (332xxx), and ACKs corresponding to client-server packets (331xxx)
			puts $script_file_ "grep 'r '.*' 9 6 '.*'- 33' ../out.tr > received_s_c_connections_node_7.tr"
			#puts $script_file_ "grep 'r '.*' 9 6 ' ../out.tr > received_s_c_connections_node_7.tr"	!!!! delete this line
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_s_c_connections_node_7.tr r 9 6 $tick_interval_ all > throughput_received_s_c_connections_node_7.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_s_c_connections_node_7.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_s_c_packets.txt
			exec ./script_selecting_received_s_c_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_s_c_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## IV.C. received throughput of each server-client individual flow ###########

	if { $calculate_throughput_individual_ == 1 } {
		for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_s_c_packets.txt ]
			set script_file_ [open $file_name_ w]

			# First, calculate the throughput of connections node0-node1
			if { $connection_id_ < $number_of_wow_connections_0_1_ } {
				puts "throughput: individual wow connection $connection_id_"

				# First, using GREP, the .tr file is split into the sent and received packets of each connection
				# Look for packets from node 8 to node 0, belonging to server-client flows (1120XX)
				puts $script_file_ "grep 'r '.*' 8 0 '.*'$connection_id_ 1.' ../out.tr > received_s_c_$connection_id_.tr"
			
				# Using a perl script, calculate the throughput
				puts $script_file_ "perl ../perl_scripts/throughput.pl received_s_c_$connection_id_.tr r 8 0 $tick_interval_ all > throughput_received_s_c_$connection_id_.txt"
		
			# connections from node 6 to node 7
			} else {
				puts "throughput: individual wow connection $connection_id_"

				# First, using GREP, the .tr file is split into the sent and received packets of each connection
				# Look for packets from node 9 to node 6, belonging to server-client flows (3320XX)
				puts $script_file_ "grep 'r '.*' 9 6 '.*'$connection_id_ 7.' ../out.tr > received_s_c_$connection_id_.tr"
			
				# Using a perl script, calculate the throughput
				puts $script_file_ "perl ../perl_scripts/throughput.pl received_s_c_$connection_id_.tr r 9 6 $tick_interval_ all > throughput_received_s_c_$connection_id_.txt"

			}
			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_s_c_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_s_c_packets.txt
			exec ./script_selecting_received_s_c_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_s_c_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}



	########### Background FTP traffic ##########################################################

	##########################################################################
	####################### FTP uplink sent packets ##########################
	##########################################################################

	######## Aggregate sent throughput of FTP uplink flows from node2 to node3 ###########
	if { $calculate_throughput_aggregate_ == 1 } {
		if { $number_of_FTP_upload_connections_2_3_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_ftp_upload_packets_2_3_.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate FTP upload sent of connections node2-node3"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 2 to node 10, belonging to the FTP upload connections (beginning with 555)
			puts $script_file_ "grep '+ '.*' 2 10 '.*'- 555' ../out.tr > sent_ftp_upload_aggregate.tr"	;# this does not include ACKs of 666 connections
			#puts $script_file_ "grep '+ '.*' 2 10 ' ../out.tr > sent_ftp_upload_aggregate.tr"			;# this would include ACKs of 666 connections and CBR traffic
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_ftp_upload_aggregate.tr + 2 10 $tick_interval_ all > throughput_sent_ftp_upload_aggregate_2_3.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_ftp_upload_aggregate.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_ftp_upload_packets_2_3_.txt
			exec ./script_selecting_ftp_upload_packets_2_3_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_ftp_upload_packets_2_3_.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## Aggregate sent throughput of FTP uplink flows from node12 to node13 ###########
	if { $calculate_throughput_aggregate_ == 1 } {
		if { $number_of_FTP_upload_connections_12_13_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_ftp_upload_packets_12_13_.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate FTP upload sent of connections node12-node13"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 12 to node 11, belonging to the FTP upload connections (beginning with 888)
			puts $script_file_ "grep '+ '.*' 12 11 '.*'- 888' ../out.tr > sent_ftp_upload_aggregate.tr"	;# this does not include ACKs of 999 connections
			#puts $script_file_ "grep '+ '.*' 12 11 ' ../out.tr > sent_ftp_upload_aggregate.tr"			;# this would include ACKs of 999 connections and CBR traffic
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_ftp_upload_aggregate.tr + 12 11 $tick_interval_ all > throughput_sent_ftp_upload_aggregate_12_13.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_ftp_upload_aggregate.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_ftp_upload_packets_12_13_.txt
			exec ./script_selecting_ftp_upload_packets_12_13_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_ftp_upload_packets_12_13_.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## Individual throughput of FTP uplink flows from node2 to node3 ###########

	if { $calculate_throughput_individual_ == 1 } {
		for {set connection_id_ 0} { $connection_id_ < $number_of_FTP_upload_connections_2_3_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_ftp_upload_packets_2_3_.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: individual FTP upload connection $connection_id_ sent"

			# First, using GREP, the .tr file is split into the sent and received packets of each connection
			# Look for packets from node 2 to node 10, belonging to client-server flows (5550XX)
			puts $script_file_ "grep '+ '.*' 2 10 '.*'[expr 555000 + $connection_id_]' ../out.tr > sent_ftp_upload_$connection_id_.tr"
			#puts $script_file_ "grep '+ '.*' 2 10 '.*'$connection_id_ 3.' ../out.tr > sent_ftp_upload_$connection_id_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_ftp_upload_$connection_id_.tr + 2 10 $tick_interval_ all > throughput_sent_ftp_upload_$connection_id_.txt"
		
			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_ftp_upload_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_ftp_upload_packets_2_3_.txt
			exec ./script_selecting_ftp_upload_packets_2_3_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_ftp_upload_packets_2_3_.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## Individual throughput of FTP uplink flows from node12 to node13 ###########

	if { $calculate_throughput_individual_ == 1 } {
		for {set connection_id_ $number_of_FTP_upload_connections_2_3_} { $connection_id_ < $number_of_FTP_upload_connections_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_ftp_upload_packets_12_13_.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: individual FTP upload connection $connection_id_ sent"

			# First, using GREP, the .tr file is split into the sent and received packets of each connection
			# Look for packets from node 12 to node 11, (8880XX)
			puts $script_file_ "grep '+ '.*' 12 11 '.*'[expr 888000 + $connection_id_]' ../out.tr > sent_ftp_upload_$connection_id_.tr"
			#puts $script_file_ "grep '+ '.*' 12 11 '.*'$connection_id_ 2.' ../out.tr > sent_ftp_upload_$connection_id_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_ftp_upload_$connection_id_.tr + 12 11 $tick_interval_ all > throughput_sent_ftp_upload_$connection_id_.txt"
		
			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_ftp_upload_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_ftp_upload_packets_12_13_.txt
			exec ./script_selecting_ftp_upload_packets_12_13_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_ftp_upload_packets_12_13_.txt
			}

			# return to the original directory
			cd ..
		}
	}

	##########################################################################
	####################### FTP uplink received packets ######################
	##########################################################################

	######## Aggregate received throughput of FTP uplink flows from node2 to node3 ###########
	if { $calculate_throughput_aggregate_ == 1 } {
		if { $number_of_FTP_upload_connections_2_3_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_ftp_upload_packets_2_3_.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate FTP upload received of connections node2-node3"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 5 to node 3, belonging to the FTP upload connections (beginning with 555)
			puts $script_file_ "grep '+ '.*' 5 3 '.*'- 555' ../out.tr > received_ftp_upload_aggregate.tr"	;# this does not include ACKs of 666 connections
			#puts $script_file_ "grep '+ '.*' 5 3 ' ../out.tr > received_ftp_upload_aggregate.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_ftp_upload_aggregate.tr + 5 3 $tick_interval_ all > throughput_received_ftp_upload_aggregate_2_3_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_ftp_upload_aggregate.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_ftp_upload_packets_2_3_.txt
			exec ./script_selecting_received_ftp_upload_packets_2_3_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_ftp_upload_packets_2_3_.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## Aggregate received throughput of FTP uplink flows from node12 to node13 ###########
	if { $calculate_throughput_aggregate_ == 1 } {
		if { $number_of_FTP_upload_connections_12_13_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_ftp_upload_packets_12_13_.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate FTP upload received of connections node12-node13"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 5 to node 13, belonging to the FTP upload connections (beginning with 888)
			puts $script_file_ "grep '+ '.*' 5 13 '.*'- 888' ../out.tr > received_ftp_upload_aggregate.tr"	;# this does not include ACKs of 999 connections
			#puts $script_file_ "grep '+ '.*' 5 13 ' ../out.tr > received_ftp_upload_aggregate.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_ftp_upload_aggregate.tr + 5 13 $tick_interval_ all > throughput_received_ftp_upload_aggregate_12_13_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_ftp_upload_aggregate.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_ftp_upload_packets_12_13_.txt
			exec ./script_selecting_received_ftp_upload_packets_12_13_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_ftp_upload_packets_12_13_.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## Individual throughput of FTP uplink flows from node2 to node3 ###########

	if { $calculate_throughput_individual_ == 1 } {
		for {set connection_id_ 0} { $connection_id_ < $number_of_FTP_upload_connections_2_3_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_ftp_upload_packets_2_3_.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: individual FTP upload connection $connection_id_ received"

			# First, using GREP, the .tr file is split into the sent and received packets of each connection
			# Look for packets from node 5 to node 3, belonging to client-server flows (5550XX)
			puts $script_file_ "grep '+ '.*' 5 3 '.*'[expr 555000 + $connection_id_]' ../out.tr > received_ftp_upload_$connection_id_.tr"	;# this does not include ACKs of 666 connections
			#puts $script_file_ "grep '+ '.*' 5 3 '.*'$connection_id_ 3.' ../out.tr > received_ftp_upload_$connection_id_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_ftp_upload_$connection_id_.tr + 5 3 $tick_interval_ all > throughput_received_ftp_upload_$connection_id_.txt"
		
			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_ftp_upload_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_ftp_upload_packets_2_3_.txt
			exec ./script_selecting_received_ftp_upload_packets_2_3_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_ftp_upload_packets_2_3_.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## Individual throughput of FTP uplink flows from node12 to node13 ###########

	if { $calculate_throughput_individual_ == 1 } {
		for {set connection_id_ $number_of_FTP_upload_connections_2_3_ } { $connection_id_ < $number_of_FTP_upload_connections_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_ftp_upload_packets_12_13_.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: individual FTP upload connection $connection_id_ received"

			# First, using GREP, the .tr file is split into the sent and received packets of each connection
			# Look for packets from node 5 to node 13, belonging to client-server flows (8880XX)
			puts $script_file_ "grep '+ '.*' 5 13 '.*'[expr 888000 + $connection_id_]' ../out.tr > received_ftp_upload_$connection_id_.tr"	;# this does not include ACKs of 999 connections
			#puts $script_file_ "grep '+ '.*' 5 13 '.*'$connection_id_ 3.' ../out.tr > received_ftp_upload_$connection_id_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_ftp_upload_$connection_id_.tr + 5 13 $tick_interval_ all > throughput_received_ftp_upload_$connection_id_.txt"
		
			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_ftp_upload_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_ftp_upload_packets_12_13_.txt
			exec ./script_selecting_received_ftp_upload_packets_12_13_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_ftp_upload_packets_12_13_.txt
			}

			# return to the original directory
			cd ..
		}
	}


	##########################################################################
	####################### FTP downlink sent packets ########################
	##########################################################################

	######## Aggregate sent throughput of FTP downlink flows from node2 to node3 ###########
	if { $calculate_throughput_aggregate_ == 1 } {
		if { $number_of_FTP_download_connections_2_3_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_ftp_download_packets_2_3_.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate FTP download sent of connections node2-node3"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 3 to node 5, belonging to the FTP download connections (beginning with 666)
			puts $script_file_ "grep '+ '.*' 3 5 '.*'- 666' ../out.tr > sent_ftp_download_aggregate.tr"	;# this does not include ACKs of 555 connections
			#puts $script_file_ "grep '+ '.*' 3 5 ' ../out.tr > sent_ftp_download_aggregate.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_ftp_download_aggregate.tr + 3 5 $tick_interval_ all > throughput_sent_ftp_download_aggregate_2_3.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_ftp_download_aggregate.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_ftp_download_packets_2_3_.txt
			exec ./script_selecting_ftp_download_packets_2_3_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_ftp_download_packets_2_3_.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## Aggregate sent throughput of FTP downlink flows from node12 to node13 ###########
	if { $calculate_throughput_aggregate_ == 1 } {
		if { $number_of_FTP_download_connections_12_13_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_ftp_download_packets_12_13_.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate FTP download sent of connections node12-node13"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 3 to node 5, belonging to the FTP download connections (beginning with 666)
			puts $script_file_ "grep '+ '.*' 13 5 '.*'- 999' ../out.tr > sent_ftp_download_aggregate.tr"	;# this does not include ACKs of 888 connections
			#puts $script_file_ "grep '+ '.*' 13 5 ' ../out.tr > sent_ftp_download_aggregate.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_ftp_download_aggregate.tr + 13 5 $tick_interval_ all > throughput_sent_ftp_download_aggregate_12_13.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_ftp_download_aggregate.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_ftp_download_packets_12_13_.txt
			exec ./script_selecting_ftp_download_packets_12_13_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_ftp_download_packets_12_13_.txt
			}

			# return to the original directory
			cd ..
		}
	}



	######## Individual throughput of FTP downlink flows from node2 to node3 ###########

	if { $calculate_throughput_individual_ == 1 } {
		for {set connection_id_ 0 } { $connection_id_ < $number_of_FTP_download_connections_2_3_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_ftp_download_packets_2_3_.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: individual FTP download connection $connection_id_ sent"

			# First, using GREP, the .tr file is split into the sent and received packets of each connection
			# Look for packets from node 3 to node 5, belonging to client-server flows (9990XX)
			puts $script_file_ "grep '+ '.*' 3 5 '.*'[expr 666000 + $connection_id_]' ../out.tr > sent_ftp_download_$connection_id_.tr"	;# this does not include ACKs of 555 connections
			#puts $script_file_ "grep '+ '.*' 3 5 '.*'$connection_id_ 3.' ../out.tr > sent_ftp_download_$connection_id_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_ftp_download_$connection_id_.tr + 3 5 $tick_interval_ all > throughput_sent_ftp_download_$connection_id_.txt"
		
			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_ftp_download_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_ftp_download_packets_2_3_.txt
			exec ./script_selecting_ftp_download_packets_2_3_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_ftp_download_packets_2_3_.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## Individual throughput of FTP downlink flows from node12 to node13 ###########

	if { $calculate_throughput_individual_ == 1 } {
		for {set connection_id_ $number_of_FTP_download_connections_2_3_ } { $connection_id_ < $number_of_FTP_download_connections_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_ftp_download_packets_12_13_.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: individual FTP download connection $connection_id_ sent"

			# First, using GREP, the .tr file is split into the sent and received packets of each connection
			# Look for packets from node 13 to node 5, belonging to client-server flows (9990XX)
			puts $script_file_ "grep '+ '.*' 13 5 '.*'[expr 999000 + $connection_id_]' ../out.tr > sent_ftp_download_$connection_id_.tr"	;# this does not include ACKs of 888 connections
			#puts $script_file_ "grep '+ '.*' 13 5 '.*'$connection_id_ 13.' ../out.tr > sent_ftp_download_$connection_id_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_ftp_download_$connection_id_.tr + 13 5 $tick_interval_ all > throughput_sent_ftp_download_$connection_id_.txt"
		
			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_ftp_download_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_ftp_download_packets_12_13_.txt
			exec ./script_selecting_ftp_download_packets_12_13_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_ftp_download_packets_12_13_.txt
			}

			# return to the original directory
			cd ..
		}
	}

	##########################################################################
	####################### FTP downlink received packets ####################
	##########################################################################

	######## Aggregate received throughput of FTP downlink flows from node2 to node3 ###########
	if { $calculate_throughput_aggregate_ == 1 } {
		if { $number_of_FTP_download_connections_2_3_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_ftp_download_packets_2_3_.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate FTP download received of connections node2-node3"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 10 to node 2, belonging to the FTP download connections (beginning with 666)
			puts $script_file_ "grep '+ '.*' 10 2 '.*'- 666' ../out.tr > received_ftp_download_aggregate.tr"	;# this does not include ACKs of 555 connections
			#puts $script_file_ "grep '+ '.*' 10 2 ' ../out.tr > received_ftp_download_aggregate.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_ftp_download_aggregate.tr + 10 2 $tick_interval_ all > throughput_received_ftp_download_aggregate_2_3.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_ftp_download_aggregate.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_ftp_download_packets_2_3_.txt
			exec ./script_selecting_received_ftp_download_packets_2_3_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_ftp_download_packets_2_3_.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## Aggregate received throughput of FTP downlink flows from node12 to node13 ###########
	if { $calculate_throughput_aggregate_ == 1 } {
		if { $number_of_FTP_download_connections_12_13_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_ftp_download_packets_12_13_.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate FTP download received of connections node12-node13"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 11 to node 12, belonging to the FTP download connections (beginning with 999)
			puts $script_file_ "grep '+ '.*' 11 12 '.*'- 999' ../out.tr > received_ftp_download_aggregate.tr"	;# this does not include ACKs of 888 connections
			#puts $script_file_ "grep '+ '.*' 11 12 ' ../out.tr > received_ftp_download_aggregate.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_ftp_download_aggregate.tr + 11 12 $tick_interval_ all > throughput_received_ftp_download_aggregate_12_13.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_ftp_download_aggregate.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_ftp_download_packets_12_13_.txt
			exec ./script_selecting_received_ftp_download_packets_12_13_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_ftp_download_packets_12_13_.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## Individual throughput of FTP downlink flows from node2 to node3 ###########

	if { $calculate_throughput_individual_ == 1 } {
		for {set connection_id_ 0} { $connection_id_ < $number_of_FTP_download_connections_2_3_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_ftp_download_packets_2_3_.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: individual FTP download connection $connection_id_ received"

			# First, using GREP, the .tr file is split into the sent and received packets of each connection
			# Look for packets from node 10 to node 2, belonging to client-server flows (6660XX)
			puts $script_file_ "grep '+ '.*' 10 2 '.*'[expr 666000 + $connection_id_]' ../out.tr > received_ftp_download_$connection_id_.tr"	;# this does not include ACKs of 555 connections
			#puts $script_file_ "grep '+ '.*' 10 2 '.*'$connection_id_ 3.' ../out.tr > received_ftp_download_$connection_id_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_ftp_download_$connection_id_.tr + 10 2 $tick_interval_ all > throughput_received_ftp_download_$connection_id_.txt"
		
			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_ftp_download_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_ftp_download_packets_2_3_.txt
			exec ./script_selecting_received_ftp_download_packets_2_3_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_ftp_download_packets_2_3_.txt
			}

			# return to the original directory
			cd ..
		}
	}

	######## Individual throughput of FTP downlink flows from node12 to node13 ###########

	if { $calculate_throughput_individual_ == 1 } {
		for {set connection_id_ $number_of_FTP_download_connections_2_3_ } { $connection_id_ < $number_of_FTP_download_connections_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_ftp_download_packets_12_13_.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: individual FTP download connection $connection_id_ received"

			# First, using GREP, the .tr file is split into the sent and received packets of each connection
			# Look for packets from node 11 to node 12, belonging to client-server flows (6660XX)
			puts $script_file_ "grep '+ '.*' 11 12 '.*'[expr 999000 + $connection_id_]' ../out.tr > received_ftp_download_$connection_id_.tr"	;# this does not include ACKs of 888 connections
			#puts $script_file_ "grep '+ '.*' 11 12 '.*'$connection_id_ 3.' ../out.tr > received_ftp_download_$connection_id_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_ftp_download_$connection_id_.tr + 11 12 $tick_interval_ all > throughput_received_ftp_download_$connection_id_.txt"
		
			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_ftp_download_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_ftp_download_packets_12_13_.txt
			exec ./script_selecting_received_ftp_download_packets_12_13_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_ftp_download_packets_12_13_.txt
			}

			# return to the original directory
			cd ..
		}
	}

	########### Background CBR UDP traffic ##########################################################

	##########################################################################
	####################### CBR uplink sent packets ##########################
	##########################################################################
	
	######## Aggregate sent throughput of CBR uplink flows from node2 to node3 ###########
	# it includes small, medium and large packets
	if { $calculate_throughput_aggregate_ == 1 } {
		if { $uplink_UDP_traffic_mix_kbps_ > 0.0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_sent_cbr_uplink_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate uplink CBR sent traffic node2-node3"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 2 to node 10, belonging to the CBR upload connections (beginning with 71)
			puts $script_file_ "grep '+ '.*' 2 10 '.*'- 71' ../out.tr > sent_cbr_upload_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_cbr_upload_.tr + 2 10 $tick_interval_ all > throughput_sent_cbr_upload_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_cbr_upload_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_cbr_uplink_packets.txt
			exec ./script_selecting_sent_cbr_uplink_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_cbr_uplink_packets.txt
			}

			# return to the original directory
			cd ..

		}
	}

	######## Individual sent throughput of CBR uplink flows from node2 to node3 ###########
	# it includes small, medium and large packets
	if { $calculate_throughput_individual_ == 1 } {
		if { $uplink_UDP_traffic_mix_kbps_ > 0.0 } {

			#### small packets
			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_sent_small_cbr_uplink_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: small-packets uplink CBR sent traffic node2-node3"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 2 to node 10, belonging to the CBR upload connections (beginning with 711)
			puts $script_file_ "grep '+ '.*' 2 10 '.*'- 711' ../out.tr > sent_small_cbr_upload_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_small_cbr_upload_.tr + 2 10 $tick_interval_ all > throughput_sent_small_cbr_upload_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_small_cbr_upload_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_small_cbr_uplink_packets.txt
			exec ./script_selecting_sent_small_cbr_uplink_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_small_cbr_uplink_packets.txt
			}

			# return to the original directory
			cd ..

			#### medium packets
			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_sent_medium_cbr_uplink_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: medium-packets uplink CBR sent traffic node2-node3"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 2 to node 10, belonging to the CBR upload connections (beginning with 712)
			puts $script_file_ "grep '+ '.*' 2 10 '.*'- 712' ../out.tr > sent_medium_cbr_upload_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_medium_cbr_upload_.tr + 2 10 $tick_interval_ all > throughput_sent_medium_cbr_upload_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_medium_cbr_upload_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_medium_cbr_uplink_packets.txt
			exec ./script_selecting_sent_medium_cbr_uplink_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_medium_cbr_uplink_packets.txt
			}

			# return to the original directory
			cd ..

			#### large packets
			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_sent_large_cbr_uplink_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: large-packets uplink CBR sent traffic node2-node3"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 2 to node 10, belonging to the CBR upload connections (beginning with 713)
			puts $script_file_ "grep '+ '.*' 2 10 '.*'- 713' ../out.tr > sent_large_cbr_upload_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_large_cbr_upload_.tr + 2 10 $tick_interval_ all > throughput_sent_large_cbr_upload_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_large_cbr_upload_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_large_cbr_uplink_packets.txt
			exec ./script_selecting_sent_large_cbr_uplink_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_large_cbr_uplink_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}



	##########################################################################
	####################### CBR uplink received packets ######################
	##########################################################################
	
	######## Aggregate received throughput of CBR uplink flows from node2 to node3 ###########
	# it includes small, medium and large packets
	if { $calculate_throughput_aggregate_ == 1 } {
		if { $uplink_UDP_traffic_mix_kbps_ > 0.0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_cbr_uplink_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate uplink CBR received traffic node2-node3"

			# First, using GREP, the .tr file is split into the received and received packets of every connection
			# Look for all the packets from node 5 to node 3, belonging to the CBR upload connections (beginning with 71)
			puts $script_file_ "grep '+ '.*' 5 3 '.*'- 71' ../out.tr > received_cbr_upload_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_cbr_upload_.tr + 5 3 $tick_interval_ all > throughput_received_cbr_upload_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_cbr_upload_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_cbr_uplink_packets.txt
			exec ./script_selecting_received_cbr_uplink_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_cbr_uplink_packets.txt
			}

			# return to the original directory
			cd ..

		}
	}

	######## Individual received throughput of CBR uplink flows from node2 to node3 ###########
	# it includes small, medium and large packets
	if { $calculate_throughput_individual_ == 1 } {
		if { $uplink_UDP_traffic_mix_kbps_ > 0.0 } {

			#### small packets
			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_small_cbr_uplink_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: small-packets uplink CBR received traffic node2-node3"

			# First, using GREP, the .tr file is split into the received and received packets of every connection
			# Look for all the packets from node 5 to node 3, belonging to the CBR upload connections (beginning with 711)
			puts $script_file_ "grep '+ '.*' 5 3 '.*'- 711' ../out.tr > received_small_cbr_upload_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_small_cbr_upload_.tr + 5 3 $tick_interval_ all > throughput_received_small_cbr_upload_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_small_cbr_upload_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_small_cbr_uplink_packets.txt
			exec ./script_selecting_received_small_cbr_uplink_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_small_cbr_uplink_packets.txt
			}

			# return to the original directory
			cd ..

			#### medium packets
			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_medium_cbr_uplink_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: medium-packets uplink CBR received traffic node2-node3"

			# First, using GREP, the .tr file is split into the received and received packets of every connection
			# Look for all the packets from node 5 to node 3, belonging to the CBR upload connections (beginning with 712)
			puts $script_file_ "grep '+ '.*' 5 3 '.*'- 712' ../out.tr > received_medium_cbr_upload_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_medium_cbr_upload_.tr + 5 3 $tick_interval_ all > throughput_received_medium_cbr_upload_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_medium_cbr_upload_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_medium_cbr_uplink_packets.txt
			exec ./script_selecting_received_medium_cbr_uplink_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_medium_cbr_uplink_packets.txt
			}

			# return to the original directory
			cd ..

			#### large packets
			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_large_cbr_uplink_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: large-packets uplink CBR received traffic node2-node3"

			# First, using GREP, the .tr file is split into the received and received packets of every connection
			# Look for all the packets from node 5 to node 3, belonging to the CBR upload connections (beginning with 713)
			puts $script_file_ "grep '+ '.*' 5 3 '.*'- 713' ../out.tr > received_large_cbr_upload_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_large_cbr_upload_.tr + 5 3 $tick_interval_ all > throughput_received_large_cbr_upload_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_large_cbr_upload_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_large_cbr_uplink_packets.txt
			exec ./script_selecting_received_large_cbr_uplink_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_large_cbr_uplink_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}



	##########################################################################
	####################### CBR downlink sent packets ########################
	##########################################################################
	
	######## Aggregate sent throughput of CBR downlink flows from node3 to node5 ###########
	# it includes small, medium and large packets
	if { $calculate_throughput_aggregate_ == 1 } {
		if { $downlink_UDP_traffic_mix_kbps_ > 0.0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_sent_cbr_downlink_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate downlink CBR sent traffic node3-node2"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 3 to node 5, belonging to the CBR download connections (beginning with 72)
			puts $script_file_ "grep '+ '.*' 3 5 '.*'- 72' ../out.tr > sent_cbr_download_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_cbr_download_.tr + 3 5 $tick_interval_ all > throughput_sent_cbr_download_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_cbr_download_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_cbr_downlink_packets.txt
			exec ./script_selecting_sent_cbr_downlink_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_cbr_downlink_packets.txt
			}

			# return to the original directory
			cd ..

		}
	}

	######## Individual sent throughput of CBR downlink flows from node2 to node3 ###########
	# it includes small, medium and large packets
	if { $calculate_throughput_individual_ == 1 } {
		if { $downlink_UDP_traffic_mix_kbps_ > 0.0 } {

			#### small packets
			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_sent_small_cbr_downlink_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: small-packets downlink CBR sent traffic node3-node2"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 3 to node 5, belonging to the CBR download connections (beginning with 721)
			puts $script_file_ "grep '+ '.*' 3 5 '.*'- 721' ../out.tr > sent_small_cbr_download_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_small_cbr_download_.tr + 3 5 $tick_interval_ all > throughput_sent_small_cbr_download_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_small_cbr_download_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_small_cbr_downlink_packets.txt
			exec ./script_selecting_sent_small_cbr_downlink_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_small_cbr_downlink_packets.txt
			}

			# return to the original directory
			cd ..

			#### medium packets
			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_sent_medium_cbr_downlink_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: medium-packets downlink CBR sent traffic node3-node2"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 3 to node 5, belonging to the CBR download connections (beginning with 722)
			puts $script_file_ "grep '+ '.*' 3 5 '.*'- 722' ../out.tr > sent_medium_cbr_download_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_medium_cbr_download_.tr + 3 5 $tick_interval_ all > throughput_sent_medium_cbr_download_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_medium_cbr_download_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_medium_cbr_downlink_packets.txt
			exec ./script_selecting_sent_medium_cbr_downlink_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_medium_cbr_downlink_packets.txt
			}

			# return to the original directory
			cd ..

			#### large packets
			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_sent_large_cbr_downlink_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: large-packets downlink CBR sent traffic node3-node2"

			# First, using GREP, the .tr file is split into the sent and received packets of every connection
			# Look for all the packets from node 3 to node 5, belonging to the CBR download connections (beginning with 723)
			puts $script_file_ "grep '+ '.*' 3 5 '.*'- 723' ../out.tr > sent_large_cbr_download_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl sent_large_cbr_download_.tr + 3 5 $tick_interval_ all > throughput_sent_large_cbr_download_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_large_cbr_download_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_large_cbr_downlink_packets.txt
			exec ./script_selecting_sent_large_cbr_downlink_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_large_cbr_downlink_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}



	##########################################################################
	####################### CBR downlink received packets ####################
	##########################################################################
	
	######## Aggregate received throughput of CBR downlink flows from node3 to node2 ###########
	# it includes small, medium and large packets
	if { $calculate_throughput_aggregate_ == 1 } {
		if { $downlink_UDP_traffic_mix_kbps_ > 0.0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_cbr_downlink_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: aggregate downlink CBR received traffic node3-node2"

			# First, using GREP, the .tr file is split into the received and received packets of every connection
			# Look for all the packets from node 10 to node 2, belonging to the CBR download connections (beginning with 72)
			puts $script_file_ "grep '+ '.*' 10 2 '.*'- 72' ../out.tr > received_cbr_download_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_cbr_download_.tr + 10 2 $tick_interval_ all > throughput_received_cbr_download_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_cbr_download_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_cbr_downlink_packets.txt
			exec ./script_selecting_received_cbr_downlink_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_cbr_downlink_packets.txt
			}

			# return to the original directory
			cd ..

		}
	}

	######## Individual received throughput of CBR downlink flows from node3 to node2 ###########
	# it includes small, medium and large packets
	if { $calculate_throughput_individual_ == 1 } {
		if { $downlink_UDP_traffic_mix_kbps_ > 0.0 } {

			#### small packets
			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_small_cbr_downlink_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: small-packets downlink CBR received traffic node3-node2"

			# First, using GREP, the .tr file is split into the received and received packets of every connection
			# Look for all the packets from node 10 to node 2, belonging to the CBR download connections (beginning with 721)
			puts $script_file_ "grep '+ '.*' 10 2 '.*'- 721' ../out.tr > received_small_cbr_download_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_small_cbr_download_.tr + 10 2 $tick_interval_ all > throughput_received_small_cbr_download_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_small_cbr_download_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_small_cbr_downlink_packets.txt
			exec ./script_selecting_received_small_cbr_downlink_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_small_cbr_downlink_packets.txt
			}

			# return to the original directory
			cd ..

			#### medium packets
			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_medium_cbr_downlink_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: medium-packets downlink CBR received traffic node3-node2"

			# First, using GREP, the .tr file is split into the received and received packets of every connection
			# Look for all the packets from node 10 to node 2, belonging to the CBR download connections (beginning with 722)
			puts $script_file_ "grep '+ '.*' 10 2 '.*'- 722' ../out.tr > received_medium_cbr_download_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_medium_cbr_download_.tr + 10 2 $tick_interval_ all > throughput_received_medium_cbr_download_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_medium_cbr_download_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_medium_cbr_downlink_packets.txt
			exec ./script_selecting_received_medium_cbr_downlink_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_medium_cbr_downlink_packets.txt
			}

			# return to the original directory
			cd ..

			#### large packets
			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_throughput_output_name_/script_selecting_received_large_cbr_downlink_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "throughput: large-packets downlink CBR received traffic node3-node2"

			# First, using GREP, the .tr file is split into the received and received packets of every connection
			# Look for all the packets from node 10 to node 2, belonging to the CBR download connections (beginning with 723)
			puts $script_file_ "grep '+ '.*' 10 2 '.*'- 723' ../out.tr > received_large_cbr_download_.tr"
			
			# Using a perl script, calculate the throughput
			puts $script_file_ "perl ../perl_scripts/throughput.pl received_large_cbr_download_.tr + 10 2 $tick_interval_ all > throughput_received_large_cbr_download_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm received_large_cbr_download_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_throughput_output_name_

			# execute the script
			exec chmod +x script_selecting_received_large_cbr_downlink_packets.txt
			exec ./script_selecting_received_large_cbr_downlink_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_received_large_cbr_downlink_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}
}