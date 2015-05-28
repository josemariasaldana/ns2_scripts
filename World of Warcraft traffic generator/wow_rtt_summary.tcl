# the procedure requires the use of rtt_summary.pl, located in the folder /perl_scripts

######################################################
# after executing the simulation, you have to do:
# cd wow_other_output_files
# ./calculate_summary_rtt.txt
#####################################################

proc rtt_summary_ { } {

	global total_number_of_connections_ folder_other_output_name_ rtt_seconds_begin_

	set remove_intermediate_files_ 1	;# set this to 1 if you want to remove all the intermediate files

		for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {
			set file_name_ "$folder_other_output_name_/rtt_wow_full_conn_"
			append file_name_ "$connection_id_"
			append file_name_ ".txt"
			
			set script_name_ [concat $folder_other_output_name_/script_calculating_avg_rtt_$connection_id_.txt ]
			set script_file_ [open $script_name_ w]

			puts $script_file_ "perl ../perl_scripts/rtt_summary.pl rtt_wow_full_conn_$connection_id_.txt $connection_id_ $rtt_seconds_begin_"

			# close the script file
			close $script_file_

			# move to the output directory
			cd ./$folder_other_output_name_

			exec cat script_calculating_avg_rtt_$connection_id_.txt >> calculate_summary_rtt.txt

			# remove the script
			if { $remove_intermediate_files_ == 1 } {
				exec rm script_calculating_avg_rtt_$connection_id_.txt
			}

			# return to the original directory
			cd ..

		}


}