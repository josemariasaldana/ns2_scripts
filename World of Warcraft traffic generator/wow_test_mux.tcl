# This NS2 script generates these traffics:
# - World of Warcraft traffic, from client to server and vice versa
# - FTP traffic
# - cbr traffic
#
# It has been developed by Jose Saldana+ and Mirko Suznjevic*
# + EINA, University of Zaragoza, Spain
# * FER, University of Zagreb, Croatia
#
# This script can be freely used for Research and Academic purposes
#
# If you use this script, please cite the next open-source paper:
#
# Mirko Suznjevic, Jose Saldana, Maja Matijasevic, Julián Fernández-Navajas, and José Ruiz-Mas, 
# “Analyzing the Effect of TCP and Server Population on Massively Multiplayer Games,” 
# International Journal of Computer Games Technology, vol. 2014, Article ID 602403, 17 pages, 2014. doi:10.1155/2014/602403
# http://dx.doi.org/10.1155/2014/602403
#
#
# The Word of Warcraft player behaviour is modeled as exchanging between six different activities: dungeons, pvp, questing, raiding, trading, uncategorized
#
# The script includes statistical models for
#
# - First activity of the player
#
# - Duration of each activity
#		- If the activity is "raiding", then the duration depends on the hour of the day
#
# - Probability of exchange from one activity to other, depending on the hour of the day
#
# - IAT (Inter Arrival Time) and APDU (Application Payload Data Unit), for client-to-server and server-to-client traffic, depending on the activity
#
# - The APDU of Trading depends on the number of players in the server: numplayers_($connection_id_)
#
# - The APDU and IAT of PvP depend on the subactivity
#
# The script also simulates the hour of the day advance. Every 3600 seconds, the hour increases and the parameters which control the 
# activity exachange are modified
#
# ----------------------------------------------------------------------------------------------------------------------------
# The script uses this network scheme:
#
#   node0 o-------o node8                 o node1		- a "number_of_wow_connections_0_1_" of WoW are set from node0 (client) to node1 (server)
#                  \                     /
#            node9  \ node4      node5  / 
#   node6 o-----o----o-----------------o-----o node7	- a "number_of_wow_connections_6_7_" of WoW are set from node6 (client) to node7 (server)
#            node10/ |                 | \
#  node2  o------o  /                  |  o node3		- a "number_of_FTP_upload_" FTP background connections are set from node2 (origin) to node3 (destination)
#				   /				    \				- a "number_of_FTP_download_" FTP background connections are set from node3 (origin) to node2 (destination)
#  node12 o-------o						 o node13		- three UDP flows go from node2 to node3. The size of the packets of each flow can be defined
#				node11									- three UDP flows go from node3 to node2. The size of the packets of each flow can be defined
#
#														- a "number_of_FTP_upload_" FTP background connections are set from node12 (origin) to node13 (destination)
#														- a "number_of_FTP_download_" FTP background connections are set from node13 (origin) to node12 (destination)
#
#   the link between node4 and node5 is the bottleneck
#
#	optionally, an additional multiplexing delay is added from node8 to node4, from node9 to node4, from node10 to node4 and from node11 to node4
#
# --------------------------------------------------------------------------------------------------------------------------------
#	identifiers of the flows:	wow client to server node0-node1		111xxx
#								wow server to client node0-node1		112xxx
#								wow client to server node6-node7		331xxx
#								wow server to client node6-node7		332xxx
#								FTP background upload node2-node3		555xxx
#								FTP background download node2-node3		666xxx
#								UDP background upload node2-node3		711000	small packets  (40 bytes default)
#								UDP background download node3-node2		721000	small packets  (40 bytes default)
#								UDP background upload node2-node3		712000	medium packets (576 bytes default)
#								UDP background download node3-node2		722000	medium packets (576 bytes default)
#								UDP background upload node2-node3		713000	large packets  (1500 bytes default)
#								UDP background download node3-node2		723000	large packets  (1500 bytes default)
#								FTP background upload node12-node13		888xxx
#								FTP background download node12-node13	999xxx


#### Some additional TCL files are required, and they should be in the same directory as the main TCL script:
source wow_activities.tcl
source wow_calculate_apdu_iat.tcl
source wow_calculate_throughput.tcl
source wow_calculate_loss.tcl
source wow_sawtooth_delay.tcl
source wow_rtt_summary.tcl
source wow_packet_apdu_ratio.tcl

####################### DEFINING THE OUTPUT DATA ON THE SCREEN ####################################
set packet_verbose_ 0				;# Writes a line for every sent APDU
set activity_verbose_ 1				;# Writes a message for every activity exchange
set hour_verbose_ 1					;# Writes a message every time the hour changes
set sawtooth_verbose_ 0				;# Writes the additional delay added by multiplexing
set time_verbose_period_ 1.0		;# Writes the current time every period (simulation time)

####################### DEFINING THE RESULTS TO CALCULATE ##########################################
#### If it is set to 1, it writes a file with the activity exchanges of each client. Format: now \t hour_of_day_ \t client1 \t activity-name
set activity_files_ 1

#### If it is set to 1, it writes a file per client, with a line per packet, includint the APDU (bytes) and IAT (seconds)
set apdu_iat_files_ 1

#### If this is set to 1, a file with the average num_paq/num_APDUs is calculated for each flow
set packet_apdu_ratio_ 1

#### If it is set to 1, the aggregate throughput is calculated
set calculate_throughput_aggregate_ 1

#### If it is set to 1, the throughput of each flow is calculated and stored in an output file
set calculate_throughput_individual_ 0

#### If it is set to 1, the packet loss rate throughput is calculated
set calculate_loss_aggregate_ 0

#### If it is set to 1, the packet loss rate of each flow is calculated and stored in an output file
set calculate_loss_individual_ 0

#### If it is set to 1, the TCP window of each flow is calculated and stored in an output file
set calculate_window_ 1


#### If it is set to 1, the RTT of each flow is calculated and stored in an output file
set calculate_rtt_ 1

#### If this is set to 1, the average SRTT parameter of each MMORPG flow is calculated and put into a file
# in order to calculate the average RTT between all the MMORPG flows, after executing the simulation, you have to do:
# cd wow_other_output_files
# ./calculate_summary_rtt.txt
#
# you will obtain a set of columns
# now rtt_ rtt_smoothed_ rtt_variance_
#
# with one row corresponding to each flow

set calculate_rtt_summary_ 1
set rtt_seconds_begin_ 100.0		;# if you put 100, it only uses the simulation seconds above 100 for calculating the average


#### Add a random delay to the FTP connections
set random_delay_ftp_ 0.0			;# e.g. if you put 0.05, then a random delay from 0 to 5% of the simulation duration is added before starting each FTP background flow
									;# if you put 0.0, then all the FTP flows will begin at 0.0

#### If it is set to 1, the queuing delay of the bottleneck is calculated and stored in an output file
set queuing_delay_bottleneck_ 1

#### Tick interval in seconds for obtaining output parameters: throughput, packet loss, etc
set tick_interval_ 1.0

#### Tick interval in seconds for obtaining window size
set tick_interval_window_ 0.1

####################### END OF DEFINING THE RESULTS TO CALCULATE ##################################



####################### PARAMETER DEFINITION #######################################################

######## Hour of the day and duration of the simulation ##########

#### The model varies the transition probability between activities depending on the hour of day
#### The activity duration only depends on the hour of the day for the "raiding" activity
#### The traffic parameters (IAT and APDU size) do not depend on the hour of day

#### If you do not want the script to advance with the hour of the day, put a 0 here
set hour_advance_ 0
set hour_duration_ 3600 ;# Hours can be "abbreviated" if this parameter is smaller than 3600

#### This is the hour of the day in which the script begins. If hour_advance_ is 0, all the activity distribution will be of this hour
set current_hour_ 8

#### simulation duration in seconds. One day lasts 86400 seconds
set duration_ 200.01
#set duration_ 86400.0		;# 1 day
#set duration_ 8640000.0	;# 100 days


#### This is useful to run a first stage only with activity exchange, and then another stage sending packets
#### the idea is to avoid the non-stationary behaviour of the beginning of activity exchange

#set moment_begin_sending_packets_ -1		;# If you only want to only simulate the activity exchange, put a -1 here.
											;# In that case, no packets will be sent

set moment_begin_sending_packets_ 0.01		;# this is the normal option: packets are sent from the beginning of the simulation
#set moment_begin_sending_packets_ 2000.0	;# use this if you want to begin in a stationary activity distribution moment.
											;# For example, if you want to have:
											;# first, 2000.0 seconds without packets but exchanging activities in order to achieve a stationary activity exchange behaviour
											;# second, 1000.0 seconds of traffic
											;# then, the duration has to be set to 3000.0


######## Connections #########

#### Define the number of WoW connections between node0 and node1
set number_of_wow_connections_0_1_ 50

#### Define the number of WoW connections between node6 and node7
set number_of_wow_connections_6_7_ 50

#### if the total number of WoW connections is above 999, the calculation of the throughput will not work properly
set total_number_of_connections_ [expr $number_of_wow_connections_0_1_ + $number_of_wow_connections_6_7_ ]

#### Set the number of upload and download FTP background traffic connections node2-node3
set number_of_FTP_upload_connections_2_3_		0
set number_of_FTP_download_connections_2_3_		0

#### Set the number of upload and download FTP background traffic connections node12-node13
set number_of_FTP_upload_connections_12_13_		0
set number_of_FTP_download_connections_12_13_	0

#### Calculate the total number of upload and download FTP background traffic connections
set number_of_FTP_upload_connections_	[expr $number_of_FTP_upload_connections_2_3_ + $number_of_FTP_upload_connections_12_13_ ]
set number_of_FTP_download_connections_	[expr $number_of_FTP_download_connections_2_3_ + $number_of_FTP_download_connections_12_13_ ]

#### Set the bandwidth of the UDP traffic
set uplink_UDP_traffic_mix_kbps_	800.0		;# kbps of total UDP uplink background traffic
set downlink_UDP_traffic_mix_kbps_	0.0		;# kbps of total UDP downlink background traffic

#### Set the packet sizes and percentages of pps of the UDP background traffic
# take into account that the maximum size for CBR is 1000 bytes
set packet_size_(0) 40		;# this is the packet size (bytes) of the small-packets UDP background flow
set packet_size_(1) 576		;# this is the packet size (bytes) of the medium-packets UDP background flow
set packet_size_(2) 1500	;# this is the packet size (bytes) of the large-packets UDP background flow

# the sum must be 1.0
set ratio_pps_(0) 0.5		;# this is the ratio of pps with respect of the totat amount of pps of the small-packets UDP background flow
set ratio_pps_(1) 0.1		;# this is the ratio of pps with respect of the totat amount of pps of the medium-packets UDP background flow
set ratio_pps_(2) 0.4		;# this is the ratio of pps with respect of the totat amount of pps of the large-packets UDP background flow


######### Bottleneck and topology parameters #########

# bandwidth of all the links except the bottleneck
set bandwidth_ 10Mb

#### Bottleneck queues
set average_packet_size_ 1000		;# in bytes
set uplink_queue_length_ 100		;# in number of packets. When it is defined in bytes, the average_packet_size is used to obtain the size
set downlink_queue_length_ 100		;# in number of packets

#### Queue type
# select one of the next:
set queue_type_ default				;# the default ns2 queue, measured in packets
#set queue_type_ RED				;# the RED ns2 queue, measured in bytes

#### Bottleneck bandwidth and OWD (node4 --- node5)
#set uplink_bandwidth_ "10000Kb"	;# kbps
set uplink_bandwidth_ "1Mb"			;# Mbps
set uplink_owd_ 20					;# ms

#set downlink_bandwidth_ "10000Kb"	;# kbps
set downlink_bandwidth_ "10Mb"		;# Mbps
set downlink_owd_ 20				;# ms


#### OWD
set owd_8_4_ 2.5		;# owd between node8 and node4
set owd_9_4_ 2.5		;# owd between node9 and node4
set owd_10_4_ 2.5		;# owd between node10 and node4
set owd_11_4_ 2.5		;# owd between node11 and node4

set owd_0_8_ 2.5
set owd_6_9_ 2.5
set owd_2_10_ 2.5
set owd_12_11_ 2.5

set owd_5_1_ 5.0		;# owd between node5 and node1
set owd_5_7_ 5.0		;# owd between node5 and node7
set owd_5_3_ 5.0		;# owd between node5 and node3
set owd_5_13_ 5.0		;# owd between node5 and node13


######### Additional delay caused by multiplexing (sawtooth) ##########
# it can appear in three links:
# node8 -> node4
# node9 -> node4
# node10-> node4
# node11-> node4

# wow flows
set mux_period_8_4_ 10.0		;# milliseconds. set this to 0.0 if you do not want multiplexing delay added
set mux_period_9_4_ 0.0			;# milliseconds. set this to 0.0 if you do not want multiplexing delay added

# tcp flows
set mux_period_10_4_ 0.0		;# milliseconds. set this to 0.0 if you do not want multiplexing delay added
set mux_period_11_4_ 0.0		;# milliseconds. set this to 0.0 if you do not want multiplexing delay added

#define if you want to add an additional fixed delay of PE/2 in order to compensate when PE is competing with no delay
set add_additional_fixed_delays_ 0



######## Additional fixed delay added to some links in order to compensate for the multiplexing delay #######
# a delay of period/2 is added to the links where multiplexing delay is not used

if { $add_additional_fixed_delays_ == 1} {

	# wow flows
	set additional_fixed_delay_8_4_ [expr $mux_period_9_4_ / 2 ]	;# this delay is added unidirectionally
	set additional_fixed_delay_9_4_ [expr $mux_period_8_4_ / 2 ]	;# this delay is added unidirectionally

	# tcp flows
	set additional_fixed_delay_10_4_ [expr $mux_period_11_4_ / 2 ]	;# this delay is added unidirectionally
	set additional_fixed_delay_11_4_ [expr $mux_period_10_4_ / 2 ]	;# this delay is added unidirectionally
} else {
	# wow flows
	set additional_fixed_delay_8_4_ 0
	set additional_fixed_delay_9_4_ 0

	# tcp flows
	set additional_fixed_delay_10_4_ 0
	set additional_fixed_delay_11_4_ 0
}


######### Activities of the players #########

#### If you do not want the script to exchange from one activity to other, put a 0 here
set activity_change_ 0

#### If activity_change_ is 0, then current_activity_ will be the only one. If not, this is not significant
#set initial_activity_ trading
set initial_activity_ questing
#set initial_activity_ dungeons
#set initial_activity_ raiding
#set initial_activity_ pvp
#set initial_activity_ uncategorized

#### defining the initial activity for each connection
for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {
	set current_activity_($connection_id_) $initial_activity_
}

#### Set the first value for PvP subactivity. It modifies the APDU of the server packets. This subactivity will only be used if the first activity is PvP 
for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {
#	set pvp_subactivity_($connection_id_) alterac_valley
#	set pvp_subactivity_($connection_id_) arathi_basin
#	set pvp_subactivity_($connection_id_) warsong_gulch
#	set pvp_subactivity_($connection_id_) eye_of_the_storm
#	set pvp_subactivity_($connection_id_) strand_of_the_ancients
#	set pvp_subactivity_($connection_id_) arena_2v2
#	set pvp_subactivity_($connection_id_) arena_3v3
	set pvp_subactivity_($connection_id_) arena_5v5
}


######### Number of players in the servers #########

#### A parameter with the number of players in each server. It affects the APDU and IAT of server-to-client packets of Trading
#### The default number or players present in a server. This means that the server APDUs and IATs will be the ones generated by a server
#### with that population. The current user is included into the number
set default_numplayers_node1_ 100.0
set default_numplayers_node7_ 100.0

#### by default all the servers have the same number of players
for {set connection_id_ 0} { $connection_id_ < $number_of_wow_connections_0_1_ } { incr connection_id_ } {
	set numplayers_($connection_id_) $default_numplayers_node1_
}
for {set connection_id_ $number_of_wow_connections_0_1_ } { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {
	set numplayers_($connection_id_) $default_numplayers_node7_
}



######### Teletraffic parameters #########

#### Maximum Transference Unit of a packet, without the IP and TCP headers
set MTU_size_ 1460

#### Default value of the TCP Window parameter: bounds the window TCP uses, and is considered to play the role of the receiver’s advertised window in real-world TCP
set TCP_window_size_ 200

#### The maximum size of the APDU. As we are using Weibull and Lognormal distribution, they do not have a theoretical maximum.
#### So we limit it to the maximum size we have observed in the studied traces
set maximum_APDU_ 7300


#### TCP flavor for wow traffic. Select only one of them.
set flavor_wow_ FullTcp				;# the recommended one is FullTcp, since WoW has this behaviour. It uses Reno
#set flavor_wow_ FullTcp/Tahoe		;# this does not work properly
#set flavor_wow_ FullTcp/Newreno	;# this does not work properly
#set flavor_wow_ FullTcp/Sack		;# this does not work properly
#set flavor_wow_ Tahoe				;# Tahoe TCP
#set flavor_wow_ Reno
#set flavor_wow_ Newreno
#set flavor_wow_ Vegas
#set flavor_wow_ Sack1


#### TCP flavor for background traffic node2 to node3. Select only one of them
#set flavor_background_2_3_ Tahoe		;# Tahoe TCP
#set flavor_background_2_3_ Reno
#set flavor_background_2_3_ Newreno
set flavor_background_2_3_ Sack1
#set flavor_background_2_3_ Vegas


#### TCP flavor for background traffic node12 to node13. Select only one of them
#set flavor_background_12_13_ Tahoe		;# Tahoe TCP
#set flavor_background_12_13_ Reno
#set flavor_background_12_13_ Newreno
set flavor_background_12_13_ Sack1
#set flavor_background_12_13_ Vegas


################## END OF PARAMETER DEFINITION ##############################################################################



#############################################################################################################################

set folder_throughput_output_name_ wow_throughput_files
set folder_loss_output_name_ wow_packetloss_files

#### Prodcecure that finishes the simulation
proc finish file { 
	global	total_number_of_connections_ activity_files_ activity_file_id_ activity_file_id_total_ \
			apdu_iat_files_ apdu_iat_client_file_id_ apdu_iat_server_file_id_ \
			calculate_throughput_individual_ calculate_throughput_aggregate_ \
			calculate_loss_individual_ calculate_loss_aggregate_ \
			folder_throughput_output_name_ folder_loss_output_name_ folder_other_output_name_\
			calculate_rtt_summary_ rtt_seconds_begin_ \
			packet_apdu_ratio_

	# close the activity files
	if { $activity_files_ == 1 } {
		for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {
			close $activity_file_id_($connection_id_)
			#close $activity_file_id_total_
		}
	}

	# close the apdu_iat files
	if { $apdu_iat_files_ == 1 } {
		for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {
			close $apdu_iat_client_file_id_($connection_id_)
			close $apdu_iat_server_file_id_($connection_id_)
		}
	}

	# finish the simulation
	puts "Finishing simulation at [[Simulator instance] now]"

	# Call the procedure that calculates the throughput of each flow
	exec rm ./$folder_throughput_output_name_ -r -f

	if { ( $calculate_throughput_individual_ == 1 ) || ( $calculate_throughput_aggregate_ == 1 ) } {
		calculate_throughput_
	}

	# Call the procedure that calculates the packet loss rate of each flow
	exec rm ./$folder_loss_output_name_ -r -f

	if { ( $calculate_loss_individual_ == 1 ) || ( $calculate_loss_aggregate_ == 1 ) } {
		calculate_loss_
	}

	#### Summary of the RTT of each MMORPG connection

	if { $calculate_rtt_summary_ == 1 } {
		rtt_summary_
	}


	#### Calculate num_packets / APDU ratio for each MMORPG connection

	if { $packet_apdu_ratio_ == 1 } {
		apdu_packet_number_calculate_
	}

	exit 0
}


# Defining the output trace file
Simulator instproc openTrace { stopTime testName } {
    set traceFile [open out.tr w]
    $self at $stopTime "close $traceFile ; finish $testName"
    return $traceFile
}

# Creating the folder and the files for activity summary files
set folder_name_ wow_activity_files
exec rm ./$folder_name_ -r -f

if { $activity_files_ == 1 } {
	# create the folder
	file mkdir $folder_name_

	# create a file for including the activity changes of all the clients
	set file_name_ [concat wow_activity_files/activities_client_total_.txt ]
	set activity_file_id_total_ [open $file_name_ "w"]

	# create a file for each client
	for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {
		set file_name_ [concat wow_activity_files/activities_client_$connection_id_.txt ]
		set activity_file_id_($connection_id_) [open $file_name_ "w"]
	}
}

# Creating the folder and the files for apdu_iat_files for each client and server
set folder_name_ wow_apdu_iat_files
exec rm ./$folder_name_ -r -f

if { $apdu_iat_files_ == 1 } {
	# create the folder
	file mkdir $folder_name_

	# create a file for each client
	for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {
		set file_name_ [concat wow_apdu_iat_files/apdu_iat_client_$connection_id_.txt ]
		set apdu_iat_client_file_id_($connection_id_) [open $file_name_ "w"]
		#puts $apdu_iat_client_file_id_($connection_id_) "probando"
	}

	# create a file for each server
	for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {
		set file_name_ [concat wow_apdu_iat_files/apdu_iat_server_$connection_id_.txt ]
		set apdu_iat_server_file_id_($connection_id_) [open $file_name_ "w"]
		#puts $apdu_iat_server_file_id_($connection_id_) "probando"
	}
}

# Create the simulator.
set ns [new Simulator]

#################################################### Create the network topology ###########################################

set node0 [$ns node]
set node1 [$ns node]
set node2 [$ns node]
set node3 [$ns node]
set node4 [$ns node]
set node5 [$ns node]
set node6 [$ns node]
set node7 [$ns node]
set node8 [$ns node]
set node9 [$ns node]
set node10 [$ns node]
set node11 [$ns node]
set node12 [$ns node]
set node13 [$ns node]

#   node0 o-------o node8                 o node1		
#                  \                     /
#            node9  \ node4      node5  / 
#   node6 o-----o----o-----------------o-----o node7	
#            node10/ |                 | \
#  node2  o------o  /                  |  o node3		
#				   /				    \				
#  node12 o-------o						 o node13		
#				node11									


$ns duplex-link $node0 $node8 $bandwidth_ [expr $owd_0_8_]ms DropTail
$ns duplex-link $node6 $node9 $bandwidth_ [expr $owd_6_9_]ms DropTail
$ns duplex-link $node2 $node10 $bandwidth_ [expr $owd_2_10_]ms DropTail
$ns duplex-link $node12 $node11 $bandwidth_ [expr $owd_12_11_]ms DropTail

# this is defined as two links because it is possible to add the sawtooth delay in node0 -> node4 direction
$ns simplex-link $node8 $node4 $bandwidth_ [expr $owd_8_4_ + $additional_fixed_delay_8_4_ ]ms DropTail
$ns simplex-link $node4 $node8 $bandwidth_ [expr $owd_8_4_]ms DropTail

# this is defined as two links because it is possible to add the sawtooth delay in node6 -> node4 direction
$ns simplex-link $node9 $node4 $bandwidth_ [expr $owd_9_4_ + $additional_fixed_delay_9_4_ ]ms DropTail
$ns simplex-link $node4 $node9 $bandwidth_ [expr $owd_9_4_]ms DropTail

# this is defined as two links because it is possible to add the sawtooth delay in node6 -> node4 direction
$ns simplex-link $node10 $node4 $bandwidth_ [expr $owd_10_4_ + $additional_fixed_delay_10_4_ ]ms DropTail
$ns simplex-link $node4 $node10 $bandwidth_ [expr $owd_10_4_]ms DropTail

# this is defined as two links because it is possible to add the sawtooth delay in node6 -> node4 direction
$ns simplex-link $node11 $node4 $bandwidth_ [expr $owd_11_4_ + $additional_fixed_delay_11_4_ ]ms DropTail
$ns simplex-link $node4 $node11 $bandwidth_ [expr $owd_11_4_]ms DropTail

$ns duplex-link $node5 $node1 $bandwidth_ [expr $owd_5_1_]ms DropTail
$ns duplex-link $node5 $node7 $bandwidth_ [expr $owd_5_7_]ms DropTail
$ns duplex-link $node5 $node3 $bandwidth_ [expr $owd_5_3_]ms DropTail
$ns duplex-link $node5 $node13 $bandwidth_ [expr $owd_5_13_]ms DropTail



##### The bottleneck uplink #####
set folder_other_output_name_ wow_other_output_files

# If the queue is measured in number of packets
if { $queue_type_ == "default" } {
	$ns simplex-link $node4 $node5 $uplink_bandwidth_ [expr $uplink_owd_]ms DropTail
	set uplink_buffer_ [[$ns link $node4 $node5] queue]
	$uplink_buffer_ set limit_ $uplink_queue_length_

# We use RED in order to emulate a queue measured in bytes. We use min_th=max_th=size; and maxp=0;
} else { 
	if { $queue_type_ == "RED" } {
		$ns simplex-link $node4 $node5 $uplink_bandwidth_ [expr $uplink_owd_]ms RED
		set uplink_buffer_ [[$ns link $node4 $node5] queue]
		$uplink_buffer_ set mean_pktsize_ $average_packet_size_		;# size of the average packet in bytes
		$uplink_buffer_ set limit_ $uplink_queue_length_			;# number of packets. when multiplied by mean_pktsize, the number of bytes of the queue is obtained
		$uplink_buffer_ set bytes_ true								;# the queue length is measured in bytes
		$uplink_buffer_ set queue-in-bytes_ true					;# the queue length is measured in bytes
		$uplink_buffer_ set thresh_ $uplink_queue_length_			;# when multiplied by mean_pktsize, it means the minimum number of bytes in the queue for using RED
		$uplink_buffer_ set maxthresh_ $uplink_queue_length_		;# when multiplied by mean_pktsize, it means the maximum number of bytes in the queue for using RED
		$uplink_buffer_ set setbit_ false							;# if it is "false", RED discards packets. if it is "true", packets are only marked
		$uplink_buffer_ set wait_ false								;# if it is "true" a minimum interval between discarded packets is se
		$uplink_buffer_ set q_weight 1								;# the value of w_q, one of the parameters of the RED formula
		$uplink_buffer_ set drop-tail_ true							;# packets are discarded when buffer size or max_threshold are reached 
		$uplink_buffer_ set linterm_ 10000							;# the inverse of max_p; max_p the maximum value for the discard probability

		set traceq [open $folder_other_output_name_/uplink-queue-size.tr w]
		$uplink_buffer_ trace curq_			;# current queue value
		#$uplink_buffer_ trace ave_			;# average value
		$uplink_buffer_ attach $traceq
	}
}


##### The downlink of the bottleneck #####

# If the queue is measured in number of packets
if { $queue_type_ == "default" } {

	$ns simplex-link $node5 $node4 $downlink_bandwidth_ [expr $downlink_owd_]ms DropTail
	set downlink_buffer_ [[$ns link $node5 $node4] queue]
	$downlink_buffer_ set limit_ $downlink_queue_length_

# We use RED in order to emulate a queue measured in bytes. We use min_th=max_th=size; and maxp=0;
} else { 
	if { $queue_type_ == "RED" } {
		$ns simplex-link $node5 $node4 $downlink_bandwidth_ [expr $downlink_owd_]ms RED
		set downlink_buffer_ [[$ns link $node5 $node4] queue]
		$downlink_buffer_ set mean_pktsize_ $average_packet_size_		;# size of the average packet in bytes
		$downlink_buffer_ set limit_ $downlink_queue_length_			;# number of packets. when multiplied by mean_pktsize, the number of bytes of the queue is obtained
		$downlink_buffer_ set bytes_ true								;# the queue length is measured in bytes
		$downlink_buffer_ set queue-in-bytes_ true						;# the queue length is measured in bytes
		$downlink_buffer_ set thresh_ $downlink_queue_length_			;# when multiplied by mean_pktsize, it means the minimum number of bytes in the queue for using RED
		$downlink_buffer_ set maxthresh_ $downlink_queue_length_		;# when multiplied by mean_pktsize, it means the maximum number of bytes in the queue for using RED
		$downlink_buffer_ set setbit_ false								;# if it is "false", RED discards packets. if it is "true", packets are only marked
		$downlink_buffer_ set wait_ false								;# if it is "true" a minimum interval between discarded packets is se
		$downlink_buffer_ set q_weight 1								;# the value of w_q, one of the parameters of the RED formula
		$downlink_buffer_ set drop-tail_ true							;# packets are discarded when buffer size or max_threshold are reached 
		$downlink_buffer_ set linterm_ 10000							;# the inverse of max_p; max_p the maximum value for the discard probability

		set traceq [open $folder_other_output_name_/downlink-queue-size.tr w]
		$downlink_buffer_ trace curq_			;# current queue value
		#$downlink_buffer_ trace ave_			;# average value
		$downlink_buffer_ attach $traceq
	}
}

######################## end of network topology ###################################


######################## Define variables for counting APDUs and packets #######################
for {set connection_id_ 0 } { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {
	set number_apdu_client_server_($connection_id_) 0.0
	set number_apdu_server_client_($connection_id_) 0.0

	# this is the amount of packets that would be generated if each APDU is sent just in the moment it is generated
	# if an APDU is bigger than 1460, it may generate more than 1 packet, and this effect is not taken into account in number_apdu_client_server_
	set number_packets_no_saturation_client_server_($connection_id_) 0.0
	set number_packets_no_saturation_server_client_($connection_id_) 0.0

	set number_payload_packets_client_server_($connection_id_) 0.0
	set number_ack_client_server_($connection_id_) 0.0
	set number_payload_packets_server_client_($connection_id_) 0.0
	set number_ack_server_client_($connection_id_) 0.0

	set acum_size_payload_packets_client_server_($connection_id_) 0.0
	set acum_size_payload_packets_server_client_($connection_id_) 0.0

	set total_bytes_apdu_client_server_($connection_id_) 0.0
	set total_bytes_apdu_server_client_($connection_id_) 0.0

}

######################## Sending packets ###########################################

# call the procedure to create the random variables defining APDU and IAT
init_apdu_iat_variables_ $ns

# call the procedure to create the random variables of the activity durations
init_durations_ $ns

############## TCP connections for the wow traffic from node0 to node1 ###########
for {set connection_id_ 0 } { $connection_id_ < $number_of_wow_connections_0_1_ } { incr connection_id_ } {

	if { $flavor_wow_ == "FullTcp" } {
		Agent/TCP/FullTcp set segsperack_ 0			;# segs received before generating ACK; put 0 in order to send the ACK as soon as possible
		Agent/TCP/FullTcp set segsize_ $MTU_size_	;# segment size (MSS size for bulk xfers)
		Agent/TCP/FullTcp set tcprexmtthresh_ 3		;# dupACKs thresh to trigger fast rexmt
		Agent/TCP/FullTcp set iss_ 0				;# initial send sequence number
		Agent/TCP/FullTcp set nodelay_ false		;# disable sender-side Nagle algorithm
		Agent/TCP/FullTcp set data_on_syn_ false	;# send data on initial SYN?
		Agent/TCP/FullTcp set dupseg_fix_ true		;# avoid fast rxt due to dup segs+acks
		Agent/TCP/FullTcp set dupack_reset_ false	;# reset dupACK ctr on !0 len data segs containing dup ACKs
		Agent/TCP/FullTcp set interval_ 0.0			;# as in TCP above, (100ms is non-std). Put 0.0 in order to avoid delayed ACKs		;http://nsnam.isi.edu/nsnam/index.php/Manual:_TCP_Agents; http://en.wikipedia.org/wiki/TCP_delayed_acknowledgment

		set tcp_connection_client_server_($connection_id_) [new Agent/TCP/FullTcp]	;# create agent
		set tcp_connection_server_client_($connection_id_) [new Agent/TCP/FullTcp]	;# create agent
		$ns attach-agent $node0 $tcp_connection_client_server_($connection_id_)		;# bind src to node
		$ns attach-agent $node1 $tcp_connection_server_client_($connection_id_)		;# bind sink to node
		$tcp_connection_client_server_($connection_id_) set fid_ 0					;# set flow ID field
		$tcp_connection_server_client_($connection_id_) set fid_ 0					;# set flow ID field
		$ns connect $tcp_connection_client_server_($connection_id_) $tcp_connection_server_client_($connection_id_) ;# active connection src to sink
		
		# set up TCP-level connections
		$tcp_connection_server_client_($connection_id_) listen ;# will figure out who its peer is
		$tcp_connection_client_server_($connection_id_) set window_ $TCP_window_size_

	} else {
		if { $flavor_wow_ == "Tahoe" } {	;# tahoe TCP (the default one)
			set tcp_connection_client_server_($connection_id_) [$ns create-connection TCP $node0 TCPSink $node1 0]
			$tcp_connection_client_server_($connection_id_) set overhead_ 0

			# this connection is only created if the TCP connection is not FullTcp
			set tcp_connection_server_client_($connection_id_) [$ns create-connection TCP $node1 TCPSink $node0 0]
			$tcp_connection_server_client_($connection_id_) set overhead_ 0

		} else {
			set tcp_connection_client_server_($connection_id_) [$ns create-connection TCP/$flavor_wow_ $node0 TCPSink $node1 0]
			$tcp_connection_client_server_($connection_id_) set overhead_ 0

			# this connection is only created if the TCP connection is not FullTcp
			set tcp_connection_server_client_($connection_id_) [$ns create-connection TCP/$flavor_wow_ $node1 TCPSink $node0 0]
			$tcp_connection_server_client_($connection_id_) set overhead_ 0

		}
	}
}

############## TCP connections for the wow traffic from node6 to node7 ###########
for {set connection_id_ $number_of_wow_connections_0_1_ } { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {

	if { $flavor_wow_ == "FullTcp" } {
		Agent/TCP/FullTcp set segsperack_ 0 ;      # segs received before generating ACK
		Agent/TCP/FullTcp set segsize_ 1460 ;       # segment size (MSS size for bulk xfers)
		Agent/TCP/FullTcp set tcprexmtthresh_ 3 ;  # dupACKs thresh to trigger fast rexmt
		Agent/TCP/FullTcp set iss_ 0 ;             # initial send sequence number
		Agent/TCP/FullTcp set nodelay_ false ;     # disable sender-side Nagle algorithm
		Agent/TCP/FullTcp set data_on_syn_ false ; # send data on initial SYN?
		Agent/TCP/FullTcp set dupseg_fix_ true ;   # avoid fast rxt due to dup segs+acks
		Agent/TCP/FullTcp set dupack_reset_ false ;# reset dupACK ctr on !0 len data segs containing dup ACKs
		Agent/TCP/FullTcp set interval_ 0.0 ;      # as in TCP above, (100ms is non-std)

		set tcp_connection_client_server_($connection_id_) [new Agent/TCP/FullTcp] ;# create agent
		set tcp_connection_server_client_($connection_id_) [new Agent/TCP/FullTcp] ;# create agent
		$ns attach-agent $node6 $tcp_connection_client_server_($connection_id_) ;# bind src to node
		$ns attach-agent $node7 $tcp_connection_server_client_($connection_id_) ;# bind sink to node
		$tcp_connection_client_server_($connection_id_) set fid_ 0 ;# set flow ID field
		$tcp_connection_server_client_($connection_id_) set fid_ 0 ;# set flow ID field
		$ns connect $tcp_connection_client_server_($connection_id_) $tcp_connection_server_client_($connection_id_) ;# active connection src to sink
		
		# set up TCP-level connections
		$tcp_connection_server_client_($connection_id_) listen ;# will figure out who its peer is
		$tcp_connection_client_server_($connection_id_) set window_ $TCP_window_size_

	} else {
		if { $flavor_wow_ == "Tahoe" } {	;# tahoe TCP (the default one)
			set tcp_connection_client_server_($connection_id_) [$ns create-connection TCP $node6 TCPSink $node7 0]
			$tcp_connection_client_server_($connection_id_) set overhead_ 0

			set tcp_connection_server_client_($connection_id_) [$ns create-connection TCP $node7 TCPSink $node6 0]
			$tcp_connection_server_client_($connection_id_) set overhead_ 0

		} else {
			set tcp_connection_client_server_($connection_id_) [$ns create-connection TCP/$flavor_wow_ $node6 TCPSink $node7 0]
			$tcp_connection_client_server_($connection_id_) set overhead_ 0

			set tcp_connection_server_client_($connection_id_) [$ns create-connection TCP/$flavor_wow_ $node7 TCPSink $node6 0]
			$tcp_connection_server_client_($connection_id_) set overhead_ 0

		}
	}
}

############# TCP connections for the upload background traffic from node2 to node3 ###########
for {set connection_id_ 0 } { $connection_id_ < $number_of_FTP_upload_connections_2_3_ } { incr connection_id_ } {
	set agent_type_ Agent/TCP

	# if the agent is not Tahoe, I add the TCP flavor
	if { $flavor_background_2_3_ != "Tahoe" } {				;# tahoe TCP (the default one)
		append agent_type_ "/$flavor_background_2_3_"
	}

	set background_tcp_source_upload_($connection_id_) [new $agent_type_]		;# create sender agent;
	set background_tcp_sink_upload_($connection_id_) [new Agent/TCPSink]		;# create receiver agent;
	$ns attach-agent $node2 $background_tcp_source_upload_($connection_id_)		;# put sender on node2
	$ns attach-agent $node3 $background_tcp_sink_upload_($connection_id_)		;# put receiver on node3
	set tcp_connection_background_upload_($connection_id_) [$ns connect $background_tcp_source_upload_($connection_id_) $background_tcp_sink_upload_($connection_id_)]     ; # establish TCP connection;

	#if TCP Vegas is used, then packetSize has to be 1500
	if { $flavor_background_2_3_ == "Vegas" } {
		$tcp_connection_background_upload_($connection_id_) set packetSize_ 1500 #it is the total size of TCP packets
	} else {
		$tcp_connection_background_upload_($connection_id_) set packetSize_ 1460 #it is the payload of TCP
	}
	$tcp_connection_background_upload_($connection_id_) set overhead_ 0
	$tcp_connection_background_upload_($connection_id_) set window_ $TCP_window_size_
}

############# TCP connections for the download background traffic from node2 to node3 ###########
for {set connection_id_ 0 } { $connection_id_ < $number_of_FTP_download_connections_2_3_ } { incr connection_id_ } {
	set agent_type_ Agent/TCP

	# if the agent is not Tahoe, I add the TCP flavor
	if { $flavor_background_2_3_ != "Tahoe" } {				;# tahoe TCP (the default one)
		append agent_type_ "/$flavor_background_2_3_"
	}

	set background_tcp_source_download_($connection_id_) [new $agent_type_]		;# create sender agent;
	set background_tcp_sink_download_($connection_id_) [new Agent/TCPSink]		;# create receiver agent;
	$ns attach-agent $node3 $background_tcp_source_download_($connection_id_)	;# put sender on node3
	$ns attach-agent $node2 $background_tcp_sink_download_($connection_id_)		;# put receiver on node2
	set tcp_connection_background_download_($connection_id_) [$ns connect $background_tcp_source_download_($connection_id_) $background_tcp_sink_download_($connection_id_)]     ; # establish TCP connection;

	#if TCP Vegas is used, then packetSize has to be 1500
	if { $flavor_background_2_3_ == "Vegas" } {
		$tcp_connection_background_download_($connection_id_) set packetSize_ 1500 #it is the total size of TCP packets
	} else {
		$tcp_connection_background_download_($connection_id_) set packetSize_ 1460 #it is the payload of TCP
	}
	$tcp_connection_background_download_($connection_id_) set overhead_ 0
	$tcp_connection_background_download_($connection_id_) set window_ $TCP_window_size_
}

############# TCP connections for the upload background traffic from node12 to node13 ###########
for {set connection_id_ $number_of_FTP_upload_connections_2_3_ } { $connection_id_ < $number_of_FTP_upload_connections_ } { incr connection_id_ } {
	set agent_type_ Agent/TCP

	# if the agent is not Tahoe, I add the TCP flavor
	if { $flavor_background_12_13_ != "Tahoe" } {				;# tahoe TCP (the default one)
		append agent_type_ "/$flavor_background_12_13_"
	}

	set background_tcp_source_upload_($connection_id_) [new $agent_type_]		;# create sender agent;
	set background_tcp_sink_upload_($connection_id_) [new Agent/TCPSink]		;# create receiver agent;
	$ns attach-agent $node12 $background_tcp_source_upload_($connection_id_)		;# put sender on node2
	$ns attach-agent $node13 $background_tcp_sink_upload_($connection_id_)		;# put receiver on node3
	set tcp_connection_background_upload_($connection_id_) [$ns connect $background_tcp_source_upload_($connection_id_) $background_tcp_sink_upload_($connection_id_)]     ; # establish TCP connection;

	#if TCP Vegas is used, then packetSize has to be 1500
	if { $flavor_background_12_13_ == "Vegas" } {
		$tcp_connection_background_upload_($connection_id_) set packetSize_ 1500 #it is the total size of TCP packets
	} else {
		$tcp_connection_background_upload_($connection_id_) set packetSize_ 1460 #it is the payload of TCP
	}
	$tcp_connection_background_upload_($connection_id_) set overhead_ 0
	$tcp_connection_background_upload_($connection_id_) set window_ $TCP_window_size_
}

############# TCP connections for the download background traffic from node12 to node13 ###########
for {set connection_id_ $number_of_FTP_download_connections_2_3_ } { $connection_id_ < $number_of_FTP_download_connections_ } { incr connection_id_ } {
	set agent_type_ Agent/TCP

	# if the agent is not Tahoe, I add the TCP flavor
	if { $flavor_background_12_13_ != "Tahoe" } {				;# tahoe TCP (the default one)
		append agent_type_ "/$flavor_background_12_13_"
	}

	set background_tcp_source_download_($connection_id_) [new $agent_type_]		;# create sender agent;
	set background_tcp_sink_download_($connection_id_) [new Agent/TCPSink]		;# create receiver agent;
	$ns attach-agent $node13 $background_tcp_source_download_($connection_id_)	;# put sender on node3
	$ns attach-agent $node12 $background_tcp_sink_download_($connection_id_)		;# put receiver on node2
	set tcp_connection_background_download_($connection_id_) [$ns connect $background_tcp_source_download_($connection_id_) $background_tcp_sink_download_($connection_id_)]     ; # establish TCP connection;

	#if TCP Vegas is used, then packetSize has to be 1500
	if { $flavor_background_12_13_ == "Vegas" } {
		$tcp_connection_background_download_($connection_id_) set packetSize_ 1500 #it is the total size of TCP packets
	} else {
		$tcp_connection_background_download_($connection_id_) set packetSize_ 1460 #it is the payload of TCP
	}
	$tcp_connection_background_download_($connection_id_) set overhead_ 0
	$tcp_connection_background_download_($connection_id_) set window_ $TCP_window_size_
}


############# FTP applications #############
# if moment_begin_sending_packets_ is set to -1, it means that no traffic is sent. This may be useful to only calculate activity durations along the day
if { $moment_begin_sending_packets_ != -1 } {

	############# FTP applications for the wow traffic ###########

	# create the wow applications node0-node1
	for {set connection_id_ 0 } { $connection_id_ < $number_of_wow_connections_0_1_ } { incr connection_id_ } {

		######### FTP client-server application over TCP connection
		set ftp_application_client_server_($connection_id_) [$tcp_connection_client_server_($connection_id_) attach-app FTP]
		$tcp_connection_client_server_($connection_id_) set fid_ [expr 111000 + $connection_id_]			;# for distinguishing the flows

		######### FTP server-client application over TCP connection
		set ftp_application_server_client_($connection_id_) [$tcp_connection_server_client_($connection_id_) attach-app FTP]
		$tcp_connection_server_client_($connection_id_) set fid_ [expr 112000 + $connection_id_]			;# for distinguishing the flows
	}

	# create the wow applications node6-node7
	for {set connection_id_ $number_of_wow_connections_0_1_ } { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {

		######### FTP client-server application over TCP connection
		set ftp_application_client_server_($connection_id_) [$tcp_connection_client_server_($connection_id_) attach-app FTP]
		$tcp_connection_client_server_($connection_id_) set fid_ [expr 331000 + $connection_id_]			;# for distinguishing the flows

		######### FTP server-client application over TCP connection
		set ftp_application_server_client_($connection_id_) [$tcp_connection_server_client_($connection_id_) attach-app FTP]
		$tcp_connection_server_client_($connection_id_) set fid_ [expr 332000 + $connection_id_]			;# for distinguishing the flows
	}

	#start the wow applications at the moment $moment_begin_sending_packets_
	for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {

		########## Calculation of the client packets
		# Calculate the apdu and the inter arrival time
		$ns at $moment_begin_sending_packets_ "calculate_apdu_iat_client $ns $tcp_connection_client_server_($connection_id_) $ftp_application_client_server_($connection_id_) $connection_id_"

		############ Calculation of the server packets
		# Calculate the apdu and the inter arrival time
		$ns at $moment_begin_sending_packets_ "calculate_apdu_iat_server $ns $tcp_connection_server_client_($connection_id_) $ftp_application_server_client_($connection_id_) $connection_id_"
	}

	############# FTP applications for the upload background traffic from node2 to node3 ###########	
	#background FTP upload application over the TCP connection from node2 to node3
	for {set connection_id_ 0 } { $connection_id_ < $number_of_FTP_upload_connections_2_3_ } { incr connection_id_ } {
		set ftp_application_background_upload_($connection_id_) [$tcp_connection_background_upload_($connection_id_) attach-app FTP]
		$tcp_connection_background_upload_($connection_id_) set fid_ [expr 555000 + $connection_id_]	;# identifier for distinguishing the flows

		########### Start the background application
		# a random delay is added in order to avoid synchronization between different FTP flows
		if { ($number_of_FTP_upload_connections_2_3_ > 0  ) && ( $random_delay_ftp_ > 0.0 ) } {
			set random_beginning_delay_ [expr [$uniform_ value] * 0.01 * $duration_ * $random_delay_ftp_ ]		;# "uniform" returns a value between 0 and 100, so the delay is between 0 and "random_delay_ftp_"% of simulation duration
			#puts "$random_beginning_delay_"
		} else {
			set random_beginning_delay_ 0.0
		}
		$ns at [expr $moment_begin_sending_packets_ + $random_beginning_delay_] "$ftp_application_background_upload_($connection_id_) start"
	}

	############# FTP applications for the upload background traffic from node12 to node13 ###########	
	#background FTP upload application over the TCP connection from node12 to node13
	for {set connection_id_ $number_of_FTP_upload_connections_2_3_ } { $connection_id_ < $number_of_FTP_upload_connections_ } { incr connection_id_ } {
		set ftp_application_background_upload_($connection_id_) [$tcp_connection_background_upload_($connection_id_) attach-app FTP]
		$tcp_connection_background_upload_($connection_id_) set fid_ [expr 888000 + $connection_id_]	;# identifier for distinguishing the flows

		########### Start the background application
		# a random delay is added in order to avoid synchronization between different FTP flows
		if { ($number_of_FTP_upload_connections_12_13_ > 0  ) && ( $random_delay_ftp_ > 0.0 ) } {
			set random_beginning_delay_ [expr [$uniform_ value] * 0.01 * $duration_ * $random_delay_ftp_ ]		;# "uniform" returns a value between 0 and 100, so the delay is between 0 and "$random_delay_ftp_"% of simulation duration
			#puts "$random_beginning_delay_"
		} else {
			set random_beginning_delay_ 0.0
		}
		$ns at [expr $moment_begin_sending_packets_ + $random_beginning_delay_] "$ftp_application_background_upload_($connection_id_) start"
	}

	############# FTP applications for the download background traffic from node2 to node3 ###########	
	#background FTP download application over the TCP connection from node2 to node3
	for {set connection_id_ 0 } { $connection_id_ < $number_of_FTP_download_connections_2_3_ } { incr connection_id_ } {
		set ftp_application_background_download_($connection_id_) [$tcp_connection_background_download_($connection_id_) attach-app FTP]
		$tcp_connection_background_download_($connection_id_) set fid_ [expr 666000 + $connection_id_]	;# identifier for distinguishing the flows

		########### Start the background application
		# a random delay is added in order to avoid synchronization between different FTP flows
		if { ($number_of_FTP_download_connections_2_3_ > 0  ) && ( $random_delay_ftp_ > 0.0 ) } {
			set random_beginning_delay_ [expr [$uniform_ value] * 0.01 * $duration_ * $random_delay_ftp_ ]		;# "uniform" returns a value between 0 and 100, so the delay is between 0 and "$random_delay_ftp_"% of simulation duration
			#puts "$random_beginning_delay_"
		} else {
			set random_beginning_delay_ 0.0
		}
		$ns at [expr $moment_begin_sending_packets_ + $random_beginning_delay_] "$ftp_application_background_download_($connection_id_) start"
	}

	############# FTP applications for the download background traffic from node12 to node13 ###########	
	#background FTP download application over the TCP connection from node12 to node13
	for {set connection_id_ $number_of_FTP_download_connections_2_3_ } { $connection_id_ < $number_of_FTP_download_connections_ } { incr connection_id_ } {
		set ftp_application_background_download_($connection_id_) [$tcp_connection_background_download_($connection_id_) attach-app FTP]
		$tcp_connection_background_download_($connection_id_) set fid_ [expr 999000 + $connection_id_]	;# identifier for distinguishing the flows

		########### Start the background application
		# a random delay is added in order to avoid synchronization between different FTP flows
		if { ( $number_of_FTP_download_connections_12_13_ > 0 ) && ( $random_delay_ftp_ > 0.0 ) } {
			set random_beginning_delay_ [expr [$uniform_ value] * 0.01 * $duration_ * $random_delay_ftp_ ]		;# "uniform" returns a value between 0 and 100, so the delay is between 0 and "$random_delay_ftp_"% of simulation duration
			#puts "$random_beginning_delay_"
		} else {
			set random_beginning_delay_ 0.0
		}
		$ns at [expr $moment_begin_sending_packets_ + $random_beginning_delay_] "$ftp_application_background_download_($connection_id_) start"
	}
}


############# UDP connections for background traffic #############
Agent/UDP set packetSize_ 1500		;# you have to add this. Otherwise, the maximum size of the CBR connections is 1000, and packets are split

if { $uplink_UDP_traffic_mix_kbps_ > 0.0 } {

	# First, we calculate the amount of pps in the uplink and downlink, as a function of the bandwidth
	set total_uplink_UDP_pps_ [expr 1000.0 * $uplink_UDP_traffic_mix_kbps_ / ( 8 * ( ($packet_size_(0)*$ratio_pps_(0)) + ($packet_size_(1)*$ratio_pps_(1)) + ($packet_size_(2)*$ratio_pps_(2)) ) )] 

	set uplink_UDP_inter_packet_time_(0) [expr 1 / ( $total_uplink_UDP_pps_ * $ratio_pps_(0) ) ]
	set uplink_UDP_inter_packet_time_(1) [expr 1 / ( $total_uplink_UDP_pps_ * $ratio_pps_(1) ) ]
	set uplink_UDP_inter_packet_time_(2) [expr 1 / ( $total_uplink_UDP_pps_ * $ratio_pps_(2) ) ]

	############# UDP connections for the uplink background traffic ###########

	set udp_uplink_(0) [new Agent/UDP]
	set udp_uplink_(1) [new Agent/UDP]
	set udp_uplink_(2) [new Agent/UDP]
	$ns attach-agent $node2 $udp_uplink_(0)
	$ns attach-agent $node2 $udp_uplink_(1)
	$ns attach-agent $node2 $udp_uplink_(2)
	set null_uplink_(0) [new Agent/Null]
	set null_uplink_(1) [new Agent/Null]
	set null_uplink_(2) [new Agent/Null]
	$ns attach-agent $node3 $null_uplink_(0)
	$ns attach-agent $node3 $null_uplink_(1)
	$ns attach-agent $node3 $null_uplink_(2)
	$ns connect $udp_uplink_(0) $null_uplink_(0)
	$ns connect $udp_uplink_(1) $null_uplink_(1)
	$ns connect $udp_uplink_(2) $null_uplink_(2)
	$udp_uplink_(0) set fid_ 711000
	$udp_uplink_(1) set fid_ 712000
	$udp_uplink_(2) set fid_ 713000
}

if { $downlink_UDP_traffic_mix_kbps_ > 0.0 } {

	# First, we calculate the amount of pps in the uplink and downlink, as a function of the bandwidth
	set total_downlink_UDP_pps_ [expr 1000.0 * $downlink_UDP_traffic_mix_kbps_ / ( 8 * ( ($packet_size_(0)*$ratio_pps_(0)) + ($packet_size_(1)*$ratio_pps_(1)) + ($packet_size_(2)*$ratio_pps_(2)) ) )] 

	set downlink_UDP_inter_packet_time_(0) [expr 1 / ( $total_downlink_UDP_pps_ * $ratio_pps_(0) ) ]
	set downlink_UDP_inter_packet_time_(1) [expr 1 / ( $total_downlink_UDP_pps_ * $ratio_pps_(1) ) ]
	set downlink_UDP_inter_packet_time_(2) [expr 1 / ( $total_downlink_UDP_pps_ * $ratio_pps_(2) ) ]

	############# UDP connections for the downlink background traffic ###########
	set udp_downlink_(0) [new Agent/UDP]
	set udp_downlink_(1) [new Agent/UDP]
	set udp_downlink_(2) [new Agent/UDP]
	$ns attach-agent $node3 $udp_downlink_(0)
	$ns attach-agent $node3 $udp_downlink_(1)
	$ns attach-agent $node3 $udp_downlink_(2)
	set null_downlink_(0) [new Agent/Null]
	set null_downlink_(1) [new Agent/Null]
	set null_downlink_(2) [new Agent/Null]
	$ns attach-agent $node2 $null_downlink_(0)
	$ns attach-agent $node2 $null_downlink_(1)
	$ns attach-agent $node2 $null_downlink_(2)
	$ns connect $udp_downlink_(0) $null_downlink_(0)
	$ns connect $udp_downlink_(1) $null_downlink_(1)
	$ns connect $udp_downlink_(2) $null_downlink_(2)
	$udp_downlink_(0) set fid_ 721000
	$udp_downlink_(1) set fid_ 722000
	$udp_downlink_(2) set fid_ 723000
}

############# CBR applications for the background traffic ###########
# if moment_begin_sending_packets_ is set to -1, it means that no traffic is sent. This may be useful to only calculate activity durations along the day
if { ( $uplink_UDP_traffic_mix_kbps_ > 0.0 ) && ( $moment_begin_sending_packets_ != -1 ) } {

	############# CBR applications for the uplink background traffic ###########
	set cbr_uplink_(0) [new Application/Traffic/CBR]
	set cbr_uplink_(1) [new Application/Traffic/CBR]
	set cbr_uplink_(2) [new Application/Traffic/CBR]
	$cbr_uplink_(0) attach-agent $udp_uplink_(0)
	$cbr_uplink_(1) attach-agent $udp_uplink_(1)
	$cbr_uplink_(2) attach-agent $udp_uplink_(2)
	$cbr_uplink_(0) set packetSize_ $packet_size_(0)
	$cbr_uplink_(1) set packetSize_ $packet_size_(1)
	$cbr_uplink_(2) set packetSize_ $packet_size_(2)
	$cbr_uplink_(0) set interval_ $uplink_UDP_inter_packet_time_(0)
	$cbr_uplink_(1) set interval_ $uplink_UDP_inter_packet_time_(1)
	$cbr_uplink_(2) set interval_ $uplink_UDP_inter_packet_time_(2)
	$cbr_uplink_(0) set random_ true
	$cbr_uplink_(1) set random_ true
	$cbr_uplink_(2) set random_ true

	#### start the CBR uplink applications
	$ns at $moment_begin_sending_packets_ "$cbr_uplink_(0) start"
	$ns at $moment_begin_sending_packets_ "$cbr_uplink_(1) start"
	$ns at $moment_begin_sending_packets_ "$cbr_uplink_(2) start"
}

if { ( $downlink_UDP_traffic_mix_kbps_ > 0.0 ) && ( $moment_begin_sending_packets_ != -1 ) } {

	############# CBR applications for the downlink background traffic ###########
	set cbr_downlink_(0) [new Application/Traffic/CBR]
	set cbr_downlink_(1) [new Application/Traffic/CBR]
	set cbr_downlink_(2) [new Application/Traffic/CBR]
	$cbr_downlink_(0) attach-agent $udp_downlink_(0)
	$cbr_downlink_(1) attach-agent $udp_downlink_(1)
	$cbr_downlink_(2) attach-agent $udp_downlink_(2)
	$cbr_downlink_(0) set packetSize_ $packet_size_(0)
	$cbr_downlink_(1) set packetSize_ $packet_size_(1)
	$cbr_downlink_(2) set packetSize_ $packet_size_(2)
	$cbr_downlink_(0) set interval_ $downlink_UDP_inter_packet_time_(0)
	$cbr_downlink_(1) set interval_ $downlink_UDP_inter_packet_time_(1)
	$cbr_downlink_(2) set interval_ $downlink_UDP_inter_packet_time_(2)
	$cbr_downlink_(0) set random_ false
	$cbr_downlink_(1) set random_ false
	$cbr_downlink_(2) set random_ false

	#### start the CBR downlink applications
	$ns at $moment_begin_sending_packets_ "$cbr_downlink_(0) start"
	$ns at $moment_begin_sending_packets_ "$cbr_downlink_(1) start"
	$ns at $moment_begin_sending_packets_ "$cbr_downlink_(2) start"
}



######################## Start the activity change method ####################################
if { $activity_change_ == 1 } {
	for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {
		$ns at 0.0 "calculate_first_activity_ current_activity_ $ns $connection_id_" ;# at the end of the procedure, "calculate_next_activity_" is called
	}
} else {
	# There is only a fixed activity
	for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {
		if {$activity_verbose_ == 1 } {
			puts "************************************************************************************************************"
			puts "Client $connection_id_ [format "%.2f" [$ns now]] Fixed activity: $current_activity_($connection_id_)"
			puts "************************************************************************************************************"
		}
	}
}



####################### Start the hour advance method #########################################
if { $hour_advance_ == 1 } {
	$ns at $hour_duration_ "calculate_next_hour_ $ns"
}
if { ($hour_verbose_ == 1) && ( $total_number_of_connections_ > 0 ) } {
	puts "************************************************************************************************************"
	puts "[format "%.2f" [$ns now]] Hour of the day: $current_hour_:00"
	puts "************************************************************************************************************"
}


###################### Define the things to be included in the trace file ##################################################

# Test the objects.
Trace set show_tcphdr_ 0	;# displays extra TCP header info for FullTcp: ack number, tcp-specific flags, and header length
set tracefile [$ns openTrace $duration_ wow]

$ns trace-queue $node4 $node5 $tracefile
$ns trace-queue $node5 $node4 $tracefile

$ns trace-queue $node0 $node8 $tracefile
$ns trace-queue $node8 $node0 $tracefile

$ns trace-queue $node8 $node4 $tracefile
$ns trace-queue $node4 $node8 $tracefile

$ns trace-queue $node9 $node6 $tracefile
$ns trace-queue $node6 $node9 $tracefile

$ns trace-queue $node4 $node9 $tracefile
$ns trace-queue $node9 $node4 $tracefile

$ns trace-queue $node2 $node10 $tracefile
$ns trace-queue $node10 $node2 $tracefile

$ns trace-queue $node10 $node4 $tracefile
$ns trace-queue $node4 $node10 $tracefile

$ns trace-queue $node12 $node11 $tracefile
$ns trace-queue $node11 $node12 $tracefile

$ns trace-queue $node11 $node4 $tracefile
$ns trace-queue $node4 $node11 $tracefile

$ns trace-queue $node1 $node5 $tracefile
$ns trace-queue $node5 $node1 $tracefile

$ns trace-queue $node5 $node3 $tracefile
$ns trace-queue $node3 $node5 $tracefile

$ns trace-queue $node5 $node7 $tracefile
$ns trace-queue $node7 $node5 $tracefile

$ns trace-queue $node5 $node13 $tracefile
$ns trace-queue $node13 $node5 $tracefile


# Create a trace and arrange for all link
# events to be dumped to "out_h1_a_r1.tr"
#set tf [open out_h1_a_r1.tr w]
#$ns trace-queue $node_(h1) $node_(r1) $tf
set qmon_uplink_ [$ns monitor-queue $node4 $node5 ""]
set integ_uplink_ [$qmon_uplink_ get-bytes-integrator]

set qmon_downlink_ [$ns monitor-queue $node5 $node4 ""]
set integ_downlink_ [$qmon_downlink_ get-bytes-integrator]


######################### Procedures for calculating different output data #######################

# This is the folder where these data will be stored
exec rm ./$folder_other_output_name_ -r -f
file mkdir $folder_other_output_name_


##### rtt estimation of background traffic 
proc plot_rtt { tcpSource sink outfile interval_ } { 
	global ns 
	#Set the time after which the procedure should be called again
	#To know the meaning of each parameter, see page 211 of this book http://books.google.es/books?id=_VkTzFLnwD4C&lpg=PA211&ots=_Z35kn3upk&dq=ns2%20%20smoothed%20(averaged)%20rtt%3B&hl=es&pg=PA211#v=onepage&q&f=false
	set rtt [$tcpSource set rtt_]
	set rtt_smoothed_ [$tcpSource set srtt_]		;# the value of rtt_smoothed_ is a bit smaller than the actual RTT in the network
	set rtt_variance_ [$tcpSource set rttvar_] 
	set now [format "%.3f" [$ns now]]
	puts $outfile "$now $rtt $rtt_smoothed_ $rtt_variance_" 
	#Re-schedule the procedure 
	$ns at [expr $now + $interval_] "plot_rtt $tcpSource $sink $outfile $interval_" 
} 

if { ($calculate_rtt_ == 1) && ( $moment_begin_sending_packets_ != -1 ) } {

	##### MMORPG connections #####
	if { $flavor_wow_ == "FullTcp" } {
		for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {
			set file_name_ "$folder_other_output_name_/rtt_wow_full_conn_"
			append file_name_ "$connection_id_"
			append file_name_ ".txt"
			set wow_rtt_client_server_($connection_id_) [open $file_name_ w]
			puts $wow_rtt_client_server_($connection_id_) "now rtt_ rtt_smoothed_ rtt_variance_" 
			$ns at $moment_begin_sending_packets_ "plot_rtt $tcp_connection_client_server_($connection_id_) $tcp_connection_server_client_($connection_id_) $wow_rtt_client_server_($connection_id_) $tick_interval_"
		}

	} else {	;# not using FullTcp
		# Client-server connections
		for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {
			set file_name_ "$folder_other_output_name_/rtt_wow_c-s_conn_"
			append file_name_ "$connection_id_"
			append file_name_ ".txt"
			set wow_rtt_client_server_($connection_id_) [open $file_name_ w]
			puts $wow_rtt_client_server_($connection_id_) "now rtt_ rtt_smoothed_ rtt_variance_" 
			$ns at $moment_begin_sending_packets_ "plot_rtt $tcp_connection_client_server_($connection_id_) $tcp_connection_server_client_($connection_id_) $wow_rtt_client_server_($connection_id_) $tick_interval_"
		}

		# Server-client connections
		for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {
			set file_name_ "$folder_other_output_name_/rtt_wow_s-c_conn_"
			append file_name_ "$connection_id_"
			append file_name_ ".txt"
			set wow_rtt_server_client_($connection_id_) [open $file_name_ w]
			puts $wow_rtt_server_client_($connection_id_) "now rtt_ rtt_smoothed_ rtt_variance_" 
			$ns at $moment_begin_sending_packets_ "plot_rtt $tcp_connection_server_client_($connection_id_) $tcp_connection_client_server_($connection_id_) $wow_rtt_server_client_($connection_id_) $tick_interval_"
		}
	}

	##### FTP upload connections from node2 to node3 #####
	for {set connection_id_ 0 } { $connection_id_ < $number_of_FTP_upload_connections_2_3_ } { incr connection_id_ } {
		set file_name_ "$folder_other_output_name_/rtt_ftp_background_upload_"
		append file_name_ "$connection_id_"
		append file_name_ ".txt"
		set background_rtt_upload_($connection_id_) [open $file_name_ w]
		puts $background_rtt_upload_($connection_id_) "now rtt_ rtt_smoothed_ rtt_variance_" 
		$ns at $moment_begin_sending_packets_ "plot_rtt $tcp_connection_background_upload_($connection_id_) $background_tcp_sink_upload_($connection_id_) $background_rtt_upload_($connection_id_) $tick_interval_"
	}

	##### FTP download connections from node2 to node3 #####
	for {set connection_id_ 0 } { $connection_id_ < $number_of_FTP_download_connections_2_3_ } { incr connection_id_ } {
		set file_name_ "$folder_other_output_name_/rtt_ftp_background_download_"
		append file_name_ "$connection_id_"
		append file_name_ ".txt"
		set background_rtt_download_($connection_id_) [open $file_name_ w]
		puts $background_rtt_download_($connection_id_) "now rtt_ rtt_smoothed_ rtt_variance_" 
		$ns at $moment_begin_sending_packets_ "plot_rtt $tcp_connection_background_download_($connection_id_) $background_tcp_sink_download_($connection_id_) $background_rtt_download_($connection_id_) $tick_interval_"
	}

	##### FTP upload connections from node12 to node13 #####
	for {set connection_id_ $number_of_FTP_download_connections_2_3_ } { $connection_id_ < $number_of_FTP_upload_connections_ } { incr connection_id_ } {
		set file_name_ "$folder_other_output_name_/rtt_ftp_background_upload_"
		append file_name_ "$connection_id_"
		append file_name_ ".txt"
		set background_rtt_upload_($connection_id_) [open $file_name_ w]
		puts $background_rtt_upload_($connection_id_) "now rtt_ rtt_smoothed_ rtt_variance_" 
		$ns at $moment_begin_sending_packets_ "plot_rtt $tcp_connection_background_upload_($connection_id_) $background_tcp_sink_upload_($connection_id_) $background_rtt_upload_($connection_id_) $tick_interval_"
	}

	##### FTP download connections from node12 to node13 #####
	for {set connection_id_ $number_of_FTP_download_connections_2_3_ } { $connection_id_ < $number_of_FTP_download_connections_ } { incr connection_id_ } {
		set file_name_ "$folder_other_output_name_/rtt_ftp_background_download_"
		append file_name_ "$connection_id_"
		append file_name_ ".txt"
		set background_rtt_download_($connection_id_) [open $file_name_ w]
		puts $background_rtt_download_($connection_id_) "now rtt_ rtt_smoothed_ rtt_variance_" 
		$ns at $moment_begin_sending_packets_ "plot_rtt $tcp_connection_background_download_($connection_id_) $background_tcp_sink_download_($connection_id_) $background_rtt_download_($connection_id_) $tick_interval_"
	}
}


#### Queuing delay of the bottleneck
set delay_acum_uplink_ 0.0
# Dump the queueing delay on link every "interval" of simulation time.
proc plot_queuing_uplink { link interval outfile } {
	global ns integ_uplink_ delay_acum_uplink_
	$ns at [expr [$ns now] + $interval] "plot_queuing_uplink $link $interval $outfile"
	set delay [expr 8 * ([$integ_uplink_ set sum_] - $delay_acum_uplink_) / [[$link link] set bandwidth_]]
	set delay_acum_uplink_ [$integ_uplink_ set sum_]
	puts $outfile "[$ns now] \t $delay"
}

set delay_acum_downlink_ 0.0
# Dump the queueing delay on link every "interval" of simulation time.
proc plot_queuing_downlink { link interval outfile } {
	global ns integ_downlink_ delay_acum_downlink_
	$ns at [expr [$ns now] + $interval] "plot_queuing_downlink $link $interval $outfile"
	set delay [expr 8 * ([$integ_downlink_ set sum_] - $delay_acum_downlink_) / [[$link link] set bandwidth_]]
	set delay_acum_downlink_ [$integ_downlink_ set sum_]
	puts $outfile "[$ns now] \t $delay"
}

# Dump the queueing delay on link every "interval" of simulation time.
#proc plot_queuing { link interval outfile} {
#	global ns integ
#	$ns at [expr [$ns now] + $interval] "plot_queuing $link $interval $outfile"
#	set delay [expr 8 * [$integ set sum_] / [[$link link] set bandwidth_]]
#	puts $outfile "[$ns now] \t $delay"
#}


if { ($queuing_delay_bottleneck_ == 1) && ( $moment_begin_sending_packets_ != -1 ) } {
	#Generate a file with the uplink queuing delay between node4 and node5 (bottleneck)
	set file_name_ [concat $folder_other_output_name_/queuing_delay_bottleneck_uplink.txt ]
	set file_queue_delay_uplink_ [open $file_name_ w]
	$ns at $moment_begin_sending_packets_ "plot_queuing_uplink [$ns link $node4 $node5] $tick_interval_ $file_queue_delay_uplink_"

	#Generate a file with the downlink queuing delay between node5 and node4 (bottleneck)
	set file_name_ [concat $folder_other_output_name_/queuing_delay_bottleneck_downlink.txt ]
	set file_queue_delay_downlink_ [open $file_name_ w]
	$ns at $moment_begin_sending_packets_ "plot_queuing_downlink [$ns link $node5 $node4] $tick_interval_ $file_queue_delay_downlink_"
}


#### Write the current simulation time on the screen
#procedure to write the current time
proc puts_time { } {
	global ns time_verbose_period_ duration_

	set now [$ns now]
	puts "$now / [expr int($duration_ )] seconds"
	$ns at [expr $now + $time_verbose_period_] puts_time
}


#### Window size of each connection

#procedure obtain tcp window size every "interval" sec
proc plot_window {tcpSource outfile interval} {
	global ns NumbSrc ;# global variables used in this procedure
	set now [$ns now]
	set cwnd [$tcpSource set cwnd_]
	puts $outfile "$now \t $cwnd"
	$ns at [expr $now + $interval] "plot_window $tcpSource $outfile $interval"
}

if { $calculate_window_ == 1 } {
	#Generate a file with the window size of each client-server wow connection
	for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {
		set file_name_ [concat $folder_other_output_name_/window_size_wow_c_s_conn_ ]
		append file_name_ "$connection_id_"
		append file_name_ ".txt"
		set window_size [open $file_name_ w]
		if { $moment_begin_sending_packets_ != -1 } {
			$ns at $moment_begin_sending_packets_ "plot_window $tcp_connection_client_server_($connection_id_) $window_size $tick_interval_window_"
		}
	}

	#Generate a file with the window size of each server-client wow connection
	for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {
		set file_name_ [concat $folder_other_output_name_/window_size_wow_s_c_conn_ ]
		append file_name_ "$connection_id_"
		append file_name_ ".txt"
		set window_size [open $file_name_ w]
		if { $moment_begin_sending_packets_ != -1 } {
			$ns at $moment_begin_sending_packets_ "plot_window $tcp_connection_server_client_($connection_id_) $window_size $tick_interval_window_"
		}
	}

	#Generate a file with the window size of the upload background connections
	for {set connection_id_ 0 } { $connection_id_ < $number_of_FTP_upload_connections_ } { incr connection_id_ } {
		set file_name_ [concat $folder_other_output_name_/window_size_background_upload_ ]
		append file_name_ "$connection_id_"
		append file_name_ ".txt"
		set window_size_background_upload_($connection_id_) [open $file_name_ w]
		if { $moment_begin_sending_packets_ != -1 } {
			$ns at $moment_begin_sending_packets_ "plot_window $tcp_connection_background_upload_($connection_id_) $window_size_background_upload_($connection_id_) $tick_interval_window_"
		}
	}
	
	#Generate a file with the window size of the download background connections
	for {set connection_id_ 0 } { $connection_id_ < $number_of_FTP_download_connections_ } { incr connection_id_ } {
		set file_name_ [concat $folder_other_output_name_/window_size_background_download_ ]
		append file_name_ "$connection_id_"
		append file_name_ ".txt"
		set window_size_background_download_($connection_id_) [open $file_name_ w]
		if { $moment_begin_sending_packets_ != -1 } {
			$ns at $moment_begin_sending_packets_ "plot_window $tcp_connection_background_download_($connection_id_) $window_size_background_download_($connection_id_) $tick_interval_window_"
		}
	}
}




#set tracefile [$ns openTrace $duration_ wow]
#set tracepru [open outevent.tr w]
#$ns create-trace Enque $tracepru $node0 $node4 
#$ns create-trace Deque $tracepru $node0 $node4 
#$ns create-trace Drop $tracepru $node0 $node4 
#$ns create-trace Recv $tracepru $node0 $node4 
#$ns at 100.0 "close $tracepru"

#$ns drop-trace $node0 $node4 [$ns create-trace Enque $tracepru $node0 $node4]
#$ns drop-trace; # es  lo contrario a create-trace, o sea, desliga un fichero de traza



################# SAWTOOTH DELAY #################################
# Calling the functions for adding a "sawtooth delay" in the link node0 -> node4
# it simulates the delay which would be produced by a multiplexer

if { $mux_period_8_4_ > 0.0 } {
	set link0_8_ [$ns link $node0 $node8]
	$link0_8_ trace-callback $ns pkt_sent_8_4_				;# each time an event occurs in link0_8_, function "pkt_sent_8_4_" is called and the string trace is added as an argument
															;# $ns pkt_sent_8_4_ r 53.400003 0 4 tcp 40 ------- 111000 0.0 1.0 2498 1045
															;# the string in this case is " r 53.400003 0 4 tcp 40 ------- 111000 0.0 1.0 2498 1045"
}

if { $mux_period_9_4_ > 0.0 } {
	set link6_9_ [$ns link $node6 $node9]
	$link6_9_ trace-callback $ns pkt_sent_9_4_
}

if { $mux_period_10_4_ > 0.0 } {
	set link2_10_ [$ns link $node2 $node10]
	$link2_10_ trace-callback $ns pkt_sent_10_4_
}

if { $mux_period_11_4_ > 0.0 } {
	set link12_11_ [$ns link $node12 $node11]
	$link12_11_ trace-callback $ns pkt_sent_11_4_
}

################## COUNT PACKETS ###############################

# In order to count packets, I call the function "count_pkt_sent_" whenever a packet is generated by the MMORPG senders
if { $packet_apdu_ratio_ == 1 } {
	set link0_8_ [$ns link $node0 $node8]
	$link0_8_ trace-callback $ns count_pkt_sent_

	set link6_9_ [$ns link $node6 $node9]
	$link6_9_ trace-callback $ns count_pkt_sent_

	set link1_5_ [$ns link $node1 $node5]
	$link1_5_ trace-callback $ns count_pkt_sent_

	set link7_5_ [$ns link $node7 $node5]
	$link7_5_ trace-callback $ns count_pkt_sent_
}

################################################################

# Write the simulation time on the screen
if { $time_verbose_period_ > 0.0 } {
	$ns at 0.0 puts_time
}


# Run the simulation
$ns run