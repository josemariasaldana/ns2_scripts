###### Calculation of the packet loss rate of each flow (the packet loss includes the ACKs)
###### Calculation of the next packet loss. Each one is stored in a file in the folder "wow_packetloss_files"
######
###### WoW
######		- packet_loss_wow_uplink_node0-node1_aggregate.txt			packet loss in the uplink of the wow connections node0-node1 
######		- packet_loss_wow_uplink_node0-node1_flow_0.txt				packet loss in the uplink of the wow connection XX node0-node1 
######		- packet_loss_wow_uplink_node6-node7_aggregate.txt			packet loss in the uplink of the wow connections node6-node7 
######		- packet_loss_wow_uplink_node6-node7_flow_1.txt				packet loss in the uplink of the wow connection XX node6-node7 
######		- packet_loss_wow_downlink_node0-node1_aggregate.txt		packet loss in the downlink of the wow connections node0-node1 
######		- packet_loss_wow_downlink_node0-node1_flow_0.txt			packet loss in the downlink of the wow connection XX node0-node1 
######		- packet_loss_wow_downlink_node6-node7_aggregate.txt		packet loss in the downlink of the wow connections node6-node7 
######		- packet_loss_wow_downlink_node6-node7_flow_1.txt			packet loss in the downlink of the wow connection XX node6-node7 
######
###### FTP
######	upload
######		- packet_loss_FTP_upload_aggregate.txt						packet loss in the uplink of the upload FTP connections node2-node3
######		- packet_loss_FTP_upload_flow_0.txt							packet loss in the uplink of the upload FTP connection 0 node2-node3
######	 note that the packet loss of FTP ACKs of download FTP connections is not included here
######
######	download
######		- packet_loss_FTP_download_aggregate.txt					packet loss in the downlink of the download FTP connections node2-node3
######		- packet_loss_FTP_download_flow_0.txt						packet loss in the downlink of the download FTP connection 0 node2-node3
######	 note that the packet loss of FTP ACKs of upload FTP connections is not included here
######
###### CBR
######	uplink
######		- packet_loss_cbr_uplink_aggregate.txt						packet loss in the uplink of the CBR flows node2-node3
######		- packet_loss_cbr_uplink_small_.txt							packet loss in the uplink of the CBR small packets node2-node3
######		- packet_loss_cbr_uplink_medium_.txt						packet loss in the uplink of the CBR medium packets node2-node3
######		- packet_loss_cbr_uplink_large_.txt							packet loss in the uplink of the CBR large packets node2-node3
######
######	downlink
######		- packet_loss_cbr_downlink_aggregate.txt					packet loss in the downlink of the CBR flows node2-node3
######		- packet_loss_cbr_downlink_small_.txt						packet loss in the downlink of the CBR small packets node2-node3
######		- packet_loss_cbr_downlink_medium_.txt						packet loss in the downlink of the CBR medium packets node2-node3
######		- packet_loss_cbr_downlink_large_.txt						packet loss in the downlink of the CBR large packets node2-node3


# the procedure requires the use of loss.pl, located in the folder /perl_scripts

proc calculate_loss_ { } {
	global ns tick_interval_ number_of_wow_connections_0_1_ number_of_wow_connections_6_7_ total_number_of_connections_ \
			number_of_FTP_upload_connections_ number_of_FTP_download_connections_ \
			number_of_FTP_upload_connections_2_3_ number_of_FTP_download_connections_2_3_ \
			number_of_FTP_upload_connections_12_13_ number_of_FTP_download_connections_12_13_ \
			calculate_loss_individual_ calculate_loss_aggregate_ \
			uplink_UDP_traffic_mix_kbps_ downlink_UDP_traffic_mix_kbps_ folder_loss_output_name_

	set remove_intermediate_files_ 1	;# set this to 1 if you want to remove all the intermediate files

	# This is the folder where these data will be stored
	file mkdir $folder_loss_output_name_

	####### WOW traffic ##################################################

	############ UPLINK ##################################################

	############### node0-node1 connections ##############################

	#################### aggregate packet loss ##########################

	if { $calculate_loss_aggregate_ == 1 } {
		if { $number_of_wow_connections_0_1_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_uplink_node0-node1_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: aggregate wow uplink of connections node0-node1"

			# First, using GREP
			# Look for all the packets from node 0 to node 8, belonging to node0-node1 connections (beginning with 11)
			# this includes tcp client-server packets (111xxx), and ACKs corresponding to server-client packets (112xxx)
			puts $script_file_ "grep 'r '.*' 0 8 '.*'- 11' ../out.tr > sent_uplink_node0-node1.tr"	
			
			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 4 5 '.*'- 11' ../out.tr > discarded_uplink_node0-node1.tr"	


			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_uplink_node0-node1.tr discarded_uplink_node0-node1.tr $tick_interval_ > packet_loss_wow_uplink_node0-node1_aggregate.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_uplink_node0-node1.tr"
				puts $script_file_ "rm discarded_uplink_node0-node1.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

			# execute the script
			exec chmod +x script_selecting_uplink_node0-node1_packets.txt
			exec ./script_selecting_uplink_node0-node1_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_uplink_node0-node1_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}

	#################### Individual packet loss ##########################

	if { $calculate_loss_individual_ == 1 } {
		for {set connection_id_ 0} { $connection_id_ < $number_of_wow_connections_0_1_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_uplink_node0-node1_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: individual wow uplink of connection $connection_id_ node0-node1"

			# First, using GREP
			# Look for all the packets from node 0 to node 8, belonging to node0-node1 connections (beginning with 11)
			# this includes tcp client-server packets (111xxx), and ACKs corresponding to server-client packets (112xxx)
			puts $script_file_ "grep 'r '.*' 0 8 '.*'- 11'.*'$connection_id_ 0.' ../out.tr > sent_uplink_node0-node1_$connection_id_.tr"	

			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 4 5 '.*'- 11'.*'$connection_id_ 0.' ../out.tr > discarded_uplink_node0-node1_$connection_id_.tr"	


			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_uplink_node0-node1_$connection_id_.tr discarded_uplink_node0-node1_$connection_id_.tr $tick_interval_ > packet_loss_wow_uplink_node0-node1_flow_$connection_id_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_uplink_node0-node1_$connection_id_.tr"
				puts $script_file_ "rm discarded_uplink_node0-node1_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

			# execute the script
			exec chmod +x script_selecting_uplink_node0-node1_packets.txt
			exec ./script_selecting_uplink_node0-node1_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_uplink_node0-node1_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}

	############### node6-node7 connections ##############################

	#################### aggregate packet loss ##########################

	if { $calculate_loss_aggregate_ == 1 } {
		if { $number_of_wow_connections_6_7_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_uplink_node6-node7_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: aggregate wow uplink of connections node6-node7"

			# First, using GREP
			# Look for all the packets from node 6 to node 9, belonging to node6-node7 connections (beginning with 33)
			# this includes tcp client-server packets (331xxx), and ACKs corresponding to server-client packets (332xxx)
			puts $script_file_ "grep 'r '.*' 6 9 '.*'- 33' ../out.tr > sent_uplink_node6-node7.tr"	
			
			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 4 5 '.*'- 33' ../out.tr > discarded_uplink_node6-node7.tr"	


			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_uplink_node6-node7.tr discarded_uplink_node6-node7.tr $tick_interval_ > packet_loss_wow_uplink_node6-node7_aggregate.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_uplink_node6-node7.tr"
				puts $script_file_ "rm discarded_uplink_node6-node7.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

			# execute the script
			exec chmod +x script_selecting_uplink_node6-node7_packets.txt
			exec ./script_selecting_uplink_node6-node7_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_uplink_node6-node7_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}


	#################### Individual packet loss ##########################

	if { $calculate_loss_individual_ == 1 } {
		for {set connection_id_ $number_of_wow_connections_0_1_ } { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_uplink_node6-node7_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: individual wow uplink of connection $connection_id_ node6-node7"

			# First, using GREP
			# Look for all the packets from node 6 to node 9, belonging to node6-node7 connections (beginning with 33)
			# this includes tcp client-server packets (331xxx), and ACKs corresponding to server-client packets (332xxx)
			puts $script_file_ "grep 'r '.*' 6 9 '.*'- 33'.*'$connection_id_ 6.' ../out.tr > sent_uplink_node6-node7_$connection_id_.tr"	

			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 4 5 '.*'- 33'.*'$connection_id_ 6.' ../out.tr > discarded_uplink_node6-node7_$connection_id_.tr"	


			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_uplink_node6-node7_$connection_id_.tr discarded_uplink_node6-node7_$connection_id_.tr $tick_interval_ > packet_loss_wow_uplink_node6-node7_flow_$connection_id_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_uplink_node6-node7_$connection_id_.tr"
				puts $script_file_ "rm discarded_uplink_node6-node7_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

			# execute the script
			exec chmod +x script_selecting_uplink_node6-node7_packets.txt
			exec ./script_selecting_uplink_node6-node7_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_uplink_node6-node7_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}


	############ DownLINK ################################################

	############### node0-node1 connections ##############################

	#################### aggregate packet loss ##########################

	if { $calculate_loss_aggregate_ == 1 } {
		if { $number_of_wow_connections_0_1_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_downlink_node0-node1_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: aggregate wow downlink of connections node0-node1"

			# First, using GREP
			# Look for all the packets from node 1 to node 5, belonging to node0-node1 connections (beginning with 11)
			# this includes tcp client-server packets (111xxx), and ACKs corresponding to server-client packets (112xxx)
			puts $script_file_ "grep 'r '.*' 1 5 '.*'- 11' ../out.tr > sent_downlink_node0-node1.tr"	
			
			# look for the discarded packets in the bottleneck (connection node5-node4)
			puts $script_file_ "grep 'd '.*' 5 4 '.*'- 11' ../out.tr > discarded_downlink_node0-node1.tr"	


			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_downlink_node0-node1.tr discarded_downlink_node0-node1.tr $tick_interval_ > packet_loss_wow_downlink_node0-node1_aggregate.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_downlink_node0-node1.tr"
				puts $script_file_ "rm discarded_downlink_node0-node1.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

			# execute the script
			exec chmod +x script_selecting_downlink_node0-node1_packets.txt
			exec ./script_selecting_downlink_node0-node1_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_downlink_node0-node1_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}

	#################### Individual packet loss ##########################

	if { $calculate_loss_individual_ == 1 } {
		for {set connection_id_ 0} { $connection_id_ < $number_of_wow_connections_0_1_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_downlink_node0-node1_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: individual wow downlink of connection $connection_id_ node0-node1"

			# First, using GREP
			# Look for all the packets from node 1 to node 5, belonging to node0-node1 connections (beginning with 11)
			# this includes tcp client-server packets (111xxx), and ACKs corresponding to server-client packets (112xxx)
			puts $script_file_ "grep 'r '.*' 1 5 '.*'- 11'.*'$connection_id_ 1.' ../out.tr > sent_downlink_node0-node1_$connection_id_.tr"	

			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 5 4 '.*'- 11'.*'$connection_id_ 1.' ../out.tr > discarded_downlink_node0-node1_$connection_id_.tr"	


			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_downlink_node0-node1_$connection_id_.tr discarded_downlink_node0-node1_$connection_id_.tr $tick_interval_ > packet_loss_wow_downlink_node0-node1_flow_$connection_id_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_downlink_node0-node1_$connection_id_.tr"
				puts $script_file_ "rm discarded_downlink_node0-node1_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

			# execute the script
			exec chmod +x script_selecting_downlink_node0-node1_packets.txt
			exec ./script_selecting_downlink_node0-node1_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_downlink_node0-node1_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}

	############### node6-node7 connections ##############################

	#################### aggregate packet loss ##########################

	if { $calculate_loss_aggregate_ == 1 } {
		if { $number_of_wow_connections_6_7_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_downlink_node6-node7_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: aggregate wow downlink of connections node6-node7"

			# First, using GREP
			# Look for all the packets from node 7 to node 5, belonging to node6-node7 connections (beginning with 33)
			# this includes tcp client-server packets (331xxx), and ACKs corresponding to server-client packets (332xxx)
			puts $script_file_ "grep 'r '.*' 7 5 '.*'- 33' ../out.tr > sent_downlink_node6-node7.tr"	
			
			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 5 4 '.*'- 33' ../out.tr > discarded_downlink_node6-node7.tr"	


			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_downlink_node6-node7.tr discarded_downlink_node6-node7.tr $tick_interval_ > packet_loss_wow_downlink_node6-node7_aggregate.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_downlink_node6-node7.tr"
				puts $script_file_ "rm discarded_downlink_node6-node7.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

			# execute the script
			exec chmod +x script_selecting_downlink_node6-node7_packets.txt
			exec ./script_selecting_downlink_node6-node7_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_downlink_node6-node7_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}


	#################### Individual packet loss ##########################

	if { $calculate_loss_individual_ == 1 } {
		for {set connection_id_ $number_of_wow_connections_0_1_ } { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_downlink_node6-node7_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: individual wow downlink of connection $connection_id_ node6-node7"

			# First, using GREP
			# Look for all the packets from node 7 to node 5, belonging to node6-node7 connections (beginning with 33)
			# this includes tcp client-server packets (331xxx), and ACKs corresponding to server-client packets (332xxx)
			puts $script_file_ "grep 'r '.*' 7 5 '.*'- 33'.*'$connection_id_ 7.' ../out.tr > sent_downlink_node6-node7_$connection_id_.tr"	

			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 5 4 '.*'- 33'.*'$connection_id_ 7.' ../out.tr > discarded_downlink_node6-node7_$connection_id_.tr"	


			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_downlink_node6-node7_$connection_id_.tr discarded_downlink_node6-node7_$connection_id_.tr $tick_interval_ > packet_loss_wow_downlink_node6-node7_flow_$connection_id_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_downlink_node6-node7_$connection_id_.tr"
				puts $script_file_ "rm discarded_downlink_node6-node7_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

			# execute the script
			exec chmod +x script_selecting_downlink_node6-node7_packets.txt
			exec ./script_selecting_downlink_node6-node7_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_downlink_node6-node7_packets.txt
			}

			# return to the original directory
			cd ..
		}
	}

	####### FTP traffic ##################################################

	############ UPLOAD ##################################################

	#################### aggregate packet loss uplink flows from node2 to node3 ##########################

	if { $calculate_loss_aggregate_ == 1 } {
		if { $number_of_FTP_upload_connections_2_3_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_ftp_upload_packets_2_3_.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: aggregate FTP upload node2-node3"

			# First, using GREP, the .tr file is split into the sent and discarded packets of every connection
			# Look for all the packets from node 2 to node 10, belonging to the FTP upload connections (beginning with 555)
			puts $script_file_ "grep '+ '.*' 2 10 '.*'- 555' ../out.tr > sent_ftp_upload_aggregate.tr"
			
			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 4 5 '.*'- 555' ../out.tr > discarded_upload_aggregate.tr"	


			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_ftp_upload_aggregate.tr discarded_upload_aggregate.tr $tick_interval_ > packet_loss_FTP_upload_aggregate_2_3_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_ftp_upload_aggregate.tr"
				puts $script_file_ "rm discarded_upload_aggregate.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

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

	#################### aggregate packet loss uplink flows from node12 to node13 ##########################

	if { $calculate_loss_aggregate_ == 1 } {
		if { $number_of_FTP_upload_connections_12_13_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_ftp_upload_packets_12_13_.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: aggregate FTP upload node12-node13"

			# First, using GREP, the .tr file is split into the sent and discarded packets of every connection
			# Look for all the packets from node 12 to node 11, belonging to the FTP upload connections (beginning with 888)
			puts $script_file_ "grep '+ '.*' 12 11 '.*'- 888' ../out.tr > sent_ftp_upload_aggregate.tr"
			
			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 4 5 '.*'- 888' ../out.tr > discarded_upload_aggregate.tr"	


			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_ftp_upload_aggregate.tr discarded_upload_aggregate.tr $tick_interval_ > packet_loss_FTP_upload_aggregate_12_13_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_ftp_upload_aggregate.tr"
				puts $script_file_ "rm discarded_upload_aggregate.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

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


	#################### Individual packet loss flows from node2 to node3 ##########################

	if { $calculate_loss_individual_ == 1 } {
		for {set connection_id_ 0} { $connection_id_ < $number_of_FTP_upload_connections_2_3_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_ftp_upload_packets_$connection_id_.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: individual FTP upload connection $connection_id_"

			# First, using GREP, the .tr file is split into the sent and discarded packets of every connection
			# Look for all the packets from node 2 to node 10, belonging to the FTP upload connections (beginning with 555)
			puts $script_file_ "grep '+ '.*' 2 10 '.*'[expr 555000 + $connection_id_]' ../out.tr > sent_ftp_upload_$connection_id_.tr"
			
			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 4 5 '.*'- 555'.*'$connection_id_ 3.' ../out.tr > discarded_upload_$connection_id_.tr"	

			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_ftp_upload_$connection_id_.tr discarded_upload_$connection_id_.tr $tick_interval_ > packet_loss_FTP_upload_flow_$connection_id_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_ftp_upload_$connection_id_.tr"
				puts $script_file_ "rm discarded_upload_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

			# execute the script
			exec chmod +x script_selecting_ftp_upload_packets_$connection_id_.txt
			exec ./script_selecting_ftp_upload_packets_$connection_id_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_ftp_upload_packets_$connection_id_.txt
			}

			# return to the original directory
			cd ..
		}
	}

	#################### Individual packet loss flows from node12 to node13 ##########################

	if { $calculate_loss_individual_ == 1 } {
		for {set connection_id_ $number_of_FTP_upload_connections_2_3_} { $connection_id_ < $number_of_FTP_upload_connections_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_ftp_upload_packets_$connection_id_.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: individual FTP upload connection $connection_id_"

			# First, using GREP, the .tr file is split into the sent and discarded packets of every connection
			# Look for all the packets from node 12 to node 11, belonging to the FTP upload connections (beginning with 888)
			puts $script_file_ "grep '+ '.*' 12 11 '.*'[expr 888000 + $connection_id_]' ../out.tr > sent_ftp_upload_$connection_id_.tr"
			
			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 4 5 '.*'- 888'.*'$connection_id_ 12.' ../out.tr > discarded_upload_$connection_id_.tr"	

			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_ftp_upload_$connection_id_.tr discarded_upload_$connection_id_.tr $tick_interval_ > packet_loss_FTP_upload_flow_$connection_id_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_ftp_upload_$connection_id_.tr"
				puts $script_file_ "rm discarded_upload_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

			# execute the script
			exec chmod +x script_selecting_ftp_upload_packets_$connection_id_.txt
			exec ./script_selecting_ftp_upload_packets_$connection_id_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_ftp_upload_packets_$connection_id_.txt
			}

			# return to the original directory
			cd ..
		}
	}

	
	####### FTP traffic ####################################################

	############ DOWNLOAD #################################################

	#################### aggregate packet loss flows from node2 to node3 ##########################

	if { $calculate_loss_aggregate_ == 1 } {
		if { $number_of_FTP_download_connections_2_3_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_ftp_download_packets_2_3_.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: aggregate FTP download node2-node3"

			# First, using GREP, the .tr file is split into the sent and discarded packets of every connection
			# Look for all the packets from node 3 to node 5, belonging to the FTP download connections (beginning with 666)
			puts $script_file_ "grep '+ '.*' 3 5 '.*'- 666' ../out.tr > sent_ftp_download_aggregate.tr"
			
			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 5 4 '.*'- 666' ../out.tr > discarded_ftp_download_aggregate.tr"	


			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_ftp_download_aggregate.tr discarded_ftp_download_aggregate.tr $tick_interval_ > packet_loss_FTP_download_aggregate_2_3_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_ftp_download_aggregate.tr"
				puts $script_file_ "rm discarded_ftp_download_aggregate.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

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


	#################### aggregate packet loss flows from node12 to node13 ##########################

	if { $calculate_loss_aggregate_ == 1 } {
		if { $number_of_FTP_download_connections_12_13_ > 0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_ftp_download_packets_12_13_.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: aggregate FTP download node2-node3"

			# First, using GREP, the .tr file is split into the sent and discarded packets of every connection
			# Look for all the packets from node 13 to node 5, belonging to the FTP download connections (beginning with 666)
			puts $script_file_ "grep '+ '.*' 13 5 '.*'- 999' ../out.tr > sent_ftp_download_aggregate.tr"
			
			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 5 4 '.*'- 999' ../out.tr > discarded_ftp_download_aggregate.tr"	


			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_ftp_download_aggregate.tr discarded_ftp_download_aggregate.tr $tick_interval_ > packet_loss_FTP_download_aggregate_12_13_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_ftp_download_aggregate.tr"
				puts $script_file_ "rm discarded_ftp_download_aggregate.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

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


	#################### Individual packet loss flows from node2 to node3 ##########################

	if { $calculate_loss_individual_ == 1 } {
		for {set connection_id_ 0} { $connection_id_ < $number_of_FTP_download_connections_2_3_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_ftp_download_packets_$connection_id_.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: individual FTP download connection $connection_id_"

			# First, using GREP, the .tr file is split into the sent and discarded packets of every connection
			# Look for all the packets from node 3 to node 5, belonging to the FTP download connections (beginning with 666)
			puts $script_file_ "grep '+ '.*' 3 5 '.*'[expr 666000 + $connection_id_]' ../out.tr > sent_ftp_download_$connection_id_.tr"
			
			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 5 4 '.*'- 666'.*'$connection_id_ 3.' ../out.tr > discarded_ftp_download_$connection_id_.tr"	

			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_ftp_download_$connection_id_.tr discarded_ftp_download_$connection_id_.tr $tick_interval_ > packet_loss_FTP_download_flow_$connection_id_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_ftp_download_$connection_id_.tr"
				puts $script_file_ "rm discarded_ftp_download_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

			# execute the script
			exec chmod +x script_selecting_ftp_download_packets_$connection_id_.txt
			exec ./script_selecting_ftp_download_packets_$connection_id_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_ftp_download_packets_$connection_id_.txt
			}

			# return to the original directory
			cd ..
		}
	}

	#################### Individual packet loss flows from node12 to node13 ##########################

	if { $calculate_loss_individual_ == 1 } {
		for {set connection_id_ $number_of_FTP_download_connections_2_3_ } { $connection_id_ < $number_of_FTP_download_connections_ } { incr connection_id_ } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_ftp_download_packets_$connection_id_.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: individual FTP download connection $connection_id_"

			# First, using GREP, the .tr file is split into the sent and discarded packets of every connection
			# Look for all the packets from node 13 to node 5, belonging to the FTP download connections (beginning with 999)
			puts $script_file_ "grep '+ '.*' 13 5 '.*'[expr 999000 + $connection_id_]' ../out.tr > sent_ftp_download_$connection_id_.tr"
			
			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 5 4 '.*'- 999'.*'$connection_id_ 13.' ../out.tr > discarded_ftp_download_$connection_id_.tr"	

			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_ftp_download_$connection_id_.tr discarded_ftp_download_$connection_id_.tr $tick_interval_ > packet_loss_FTP_download_flow_$connection_id_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_ftp_download_$connection_id_.tr"
				puts $script_file_ "rm discarded_ftp_download_$connection_id_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

			# execute the script
			exec chmod +x script_selecting_ftp_download_packets_$connection_id_.txt
			exec ./script_selecting_ftp_download_packets_$connection_id_.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_ftp_download_packets_$connection_id_.txt
			}

			# return to the original directory
			cd ..
		}
	}

	
	####### CBR traffic ##################################################

	############ UPLINK ##################################################

	#################### aggregate packet loss ##########################

	if { $calculate_loss_aggregate_ == 1 } {
		if { $uplink_UDP_traffic_mix_kbps_ > 0.0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_sent_cbr_uplink_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: aggregate uplink CBR sent traffic node2-node3"

			# First, using GREP, the .tr file is split into the sent and discarded packets of every connection
			# Look for all the packets from node 2 to node 10, belonging to the CBR uplink connections (beginning with 71)
			puts $script_file_ "grep '+ '.*' 2 10 '.*'- 71' ../out.tr > sent_cbr_uplink_aggregate.tr"
			
			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 4 5 '.*'- 71' ../out.tr > discarded_cbr_uplink_aggregate.tr"	


			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_cbr_uplink_aggregate.tr discarded_cbr_uplink_aggregate.tr $tick_interval_ > packet_loss_cbr_uplink_aggregate.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_cbr_uplink_aggregate.tr"
				puts $script_file_ "rm discarded_cbr_uplink_aggregate.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

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

	#################### Individual packet loss ##########################

	if { $calculate_loss_individual_ == 1 } {
		if { $uplink_UDP_traffic_mix_kbps_ > 0.0 } {

			#### small packets
			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_sent_cbr_uplink_small_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: small-packets uplink CBR sent traffic node2-node3"

			# First, using GREP, the .tr file is split into the sent and discarded packets of every connection
			# Look for all the packets from node 2 to node 10, belonging to the CBR uplink connections (beginning with 711)
			puts $script_file_ "grep '+ '.*' 2 10 '.*'- 711' ../out.tr > sent_cbr_uplink_small_.tr"

			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 4 5 '.*'- 711' ../out.tr > discarded_cbr_uplink_small_.tr"	

			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_cbr_uplink_small_.tr discarded_cbr_uplink_small_.tr $tick_interval_ > packet_loss_cbr_uplink_small_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_cbr_uplink_small_.tr"
				puts $script_file_ "rm discarded_cbr_uplink_small_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_cbr_uplink_small_packets.txt
			exec ./script_selecting_sent_cbr_uplink_small_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_cbr_uplink_small_packets.txt
			}

			# return to the original directory
			cd ..



			#### medium packets
			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_sent_cbr_uplink_medium_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: medium-packets uplink CBR sent traffic node2-node3"

			# First, using GREP, the .tr file is split into the sent and discarded packets of every connection
			# Look for all the packets from node 2 to node 10, belonging to the CBR uplink connections (beginning with 712)
			puts $script_file_ "grep '+ '.*' 2 10 '.*'- 712' ../out.tr > sent_cbr_uplink_medium_.tr"

			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 4 5 '.*'- 712' ../out.tr > discarded_cbr_uplink_medium_.tr"	

			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_cbr_uplink_medium_.tr discarded_cbr_uplink_medium_.tr $tick_interval_ > packet_loss_cbr_uplink_medium_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_cbr_uplink_medium_.tr"
				puts $script_file_ "rm discarded_cbr_uplink_medium_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_cbr_uplink_medium_packets.txt
			exec ./script_selecting_sent_cbr_uplink_medium_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_cbr_uplink_medium_packets.txt
			}

			# return to the original directory
			cd ..


			#### large packets
			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_sent_cbr_uplink_large_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: large-packets uplink CBR sent traffic node2-node3"

			# First, using GREP, the .tr file is split into the sent and discarded packets of every connection
			# Look for all the packets from node 2 to node 10, belonging to the CBR uplink connections (beginning with 713)
			puts $script_file_ "grep '+ '.*' 2 10 '.*'- 713' ../out.tr > sent_cbr_uplink_large_.tr"

			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 4 5 '.*'- 713' ../out.tr > discarded_cbr_uplink_large_.tr"	

			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_cbr_uplink_large_.tr discarded_cbr_uplink_large_.tr $tick_interval_ > packet_loss_cbr_uplink_large_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_cbr_uplink_large_.tr"
				puts $script_file_ "rm discarded_cbr_uplink_large_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_cbr_uplink_large_packets.txt
			exec ./script_selecting_sent_cbr_uplink_large_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_cbr_uplink_large_packets.txt
			}

			# return to the original directory
			cd ..

		}
	}

	
	####### CBR traffic ####################################################

	############ DOWNLINK ##################################################

	#################### aggregate packet loss ##########################

	if { $calculate_loss_aggregate_ == 1 } {
		if { $downlink_UDP_traffic_mix_kbps_ > 0.0 } {

			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_sent_cbr_downlink_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: aggregate downlink CBR sent traffic node2-node3"

			# First, using GREP, the .tr file is split into the sent and discarded packets of every connection
			# Look for all the packets from node 3 to node 5, belonging to the CBR downlink connections (beginning with 72)
			puts $script_file_ "grep '+ '.*' 3 5 '.*'- 72' ../out.tr > sent_cbr_downlink_aggregate.tr"
			
			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 5 4 '.*'- 72' ../out.tr > discarded_cbr_downlink_aggregate.tr"	


			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_cbr_downlink_aggregate.tr discarded_cbr_downlink_aggregate.tr $tick_interval_ > packet_loss_cbr_downlink_aggregate.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_cbr_downlink_aggregate.tr"
				puts $script_file_ "rm discarded_cbr_downlink_aggregate.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

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

	#################### Individual packet loss ##########################

	if { $calculate_loss_individual_ == 1 } {
		if { $downlink_UDP_traffic_mix_kbps_ > 0.0 } {

			#### small packets
			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_sent_cbr_downlink_small_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: small-packets downlink CBR sent traffic node2-node3"

			# First, using GREP, the .tr file is split into the sent and discarded packets of every connection
			# Look for all the packets from node 3 to node 5, belonging to the CBR downlink connections (beginning with 721)
			puts $script_file_ "grep '+ '.*' 3 5 '.*'- 721' ../out.tr > sent_cbr_downlink_small_.tr"

			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 5 4 '.*'- 721' ../out.tr > discarded_cbr_downlink_small_.tr"	

			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_cbr_downlink_small_.tr discarded_cbr_downlink_small_.tr $tick_interval_ > packet_loss_cbr_downlink_small_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_cbr_downlink_small_.tr"
				puts $script_file_ "rm discarded_cbr_downlink_small_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_cbr_downlink_small_packets.txt
			exec ./script_selecting_sent_cbr_downlink_small_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_cbr_downlink_small_packets.txt
			}

			# return to the original directory
			cd ..



			#### medium packets
			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_sent_cbr_downlink_medium_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: medium-packets downlink CBR sent traffic node2-node3"

			# First, using GREP, the .tr file is split into the sent and discarded packets of every connection
			# Look for all the packets from node 3 to node 5, belonging to the CBR downlink connections (beginning with 722)
			puts $script_file_ "grep '+ '.*' 3 5 '.*'- 722' ../out.tr > sent_cbr_downlink_medium_.tr"

			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 5 4 '.*'- 722' ../out.tr > discarded_cbr_downlink_medium_.tr"	

			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_cbr_downlink_medium_.tr discarded_cbr_downlink_medium_.tr $tick_interval_ > packet_loss_cbr_downlink_medium_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_cbr_downlink_medium_.tr"
				puts $script_file_ "rm discarded_cbr_downlink_medium_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_cbr_downlink_medium_packets.txt
			exec ./script_selecting_sent_cbr_downlink_medium_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_cbr_downlink_medium_packets.txt
			}

			# return to the original directory
			cd ..


			#### large packets
			#create a file with the script to execute in order to obtain the results
			set file_name_ [concat $folder_loss_output_name_/script_selecting_sent_cbr_downlink_large_packets.txt ]
			set script_file_ [open $file_name_ w]

			puts "packet loss: large-packets downlink CBR sent traffic node2-node3"

			# First, using GREP, the .tr file is split into the sent and discarded packets of every connection
			# Look for all the packets from node 3 to node 5, belonging to the CBR downlink connections (beginning with 723)
			puts $script_file_ "grep '+ '.*' 3 5 '.*'- 723' ../out.tr > sent_cbr_downlink_large_.tr"

			# look for the discarded packets in the bottleneck (connection node4-node5)
			puts $script_file_ "grep 'd '.*' 5 4 '.*'- 723' ../out.tr > discarded_cbr_downlink_large_.tr"	

			# Using a perl script, calculate the packet loss rate
			puts $script_file_ "perl ../perl_scripts/loss.pl sent_cbr_downlink_large_.tr discarded_cbr_downlink_large_.tr $tick_interval_ > packet_loss_cbr_downlink_large_.txt"

			if { $remove_intermediate_files_ == 1 } {
				puts $script_file_ "rm sent_cbr_downlink_large_.tr"
				puts $script_file_ "rm discarded_cbr_downlink_large_.tr"
			}

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_loss_output_name_

			# execute the script
			exec chmod +x script_selecting_sent_cbr_downlink_large_packets.txt
			exec ./script_selecting_sent_cbr_downlink_large_packets.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_selecting_sent_cbr_downlink_large_packets.txt
			}

			# return to the original directory
			cd ..

		}
	}


}