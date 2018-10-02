
#### procedure that is called every tick ####
proc bps-car-server_ { udp_source_ udp_sink_ outfile interval_ } {
	global ns_ ;# global variables used in this procedure
	global holdtime holdseq holdrate1

	set bytes_received_ [$udp_sink_ set bytes_]
	#set packets_lost_ [$udp_sink_ set nlost_]
	#set last_packet_time_ [$udp_sink_ set lastPktTime_]
	#set num_packets_received [$udp_sink_ set npkts_]

    set now [$ns_ now]
	# Record Bit Rate in Trace Files
	puts $outfile "$now\t[expr $bytes_received_ * 8 / $interval_ ]"
	#puts $outfile "$now $bytes_received_"

	# Reset Variables
	$udp_sink_ set bytes_ 0
	#$sink set nlost_ 0
	#set holdtime $bw8
	#set holdseq $bw9
	#set  holdrate1 $bw0

	# Schedule Record after $time interval sec
	$ns_ at [expr $now + $interval_] "bps-car-server_ $udp_source_ $udp_sink_ $outfile $interval_"
	puts "$now"
}

#### procedure which is called every tick ####
proc loss-delay-car-server_ { car_ udp_source_up_ udp_sink_up_ loss_outfile_up_ delay_outfile_up_ interval_ holdtime_up_ holdseq_up_ args} {
	upvar $holdtime_up_ holdt_up_
	upvar $holdseq_up_ holds_up_
	global ns_ ;# global variables used in this procedure

	set packets_lost_up_ [$udp_sink_up_ set nlost_]
	set packets_received_up_ [$udp_sink_up_ set npkts_]
	set last_packet_time_up_ [$udp_sink_up_ set lastPktTime_]

    set now [$ns_ now]

	# Record packet loss in trace file
	if { [expr $packets_lost_up_ + $packets_received_up_ - $holds_up_($car_) ] > 0 } {
		puts $loss_outfile_up_ "$now\t[expr $packets_lost_up_ / ( $packets_lost_up_ + $packets_received_up_ - $holds_up_($car_) ) ]" ;#lost in this interval / (lost + totalreceived - received in previous intervals)
	} else {
		puts $loss_outfile_up_ "$now\t0"
	}

	# Record delay in Trace Files
	if { $packets_received_up_ > $holds_up_($car_) } { ;# some new packet have arrived
		puts $delay_outfile_up_ "$now\t[expr ( $last_packet_time_up_ - $holdt_up_($car_) ) / ( $packets_received_up_ - $holds_up_($car_) ) ]"
	} else {
		# no new packets have arrived
		puts $delay_outfile_up_ "$now\t[expr ( $last_packet_time_up_ - $holdt_up_($car_))]"
	}

    set holdt_($car_) $last_packet_time_up_
    set holds_($car_) $packets_received_up_
	
	# Reset Variables
	$udp_sink_up_ set nlost_ 0

	# Schedule delay-car-server_ after interval sec
	$ns_ at [expr $now + $interval_] "loss-delay-car-server_ $car_ $udp_source_up_ $udp_sink_up_ $loss_outfile_up_ $delay_outfile_up_ $interval_ holdtime_up_ holdseq_up_"   
}

proc stop {} {

    global ns_ tracefd summary_movement_file_ ;#namtrace
	$ns_ flush-trace
    close $tracefd
	close $summary_movement_file_
    #close $namtrace
}