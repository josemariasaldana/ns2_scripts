#### additional TCL files required. they must be in the same directory
source car_movements.tcl
source calculate_fps_results.tcl
source calculate_ftp_results.tcl
#source calculate_voip_results.tcl NOT YET IMPLEMENTED
source define_applications.tcl
source trace_durations_.tcl
source procedures_and_stop.tcl
source write_connection_time_predictions.tcl

#### additional PERL scripts required. they must be in the ./perl_scripts/ directory
# calculate_mos_up_down.pl
# extract_num_time_wired_trace.pl
# extract_num_time_wireless_trace.pl
# join_up_files.pl
# join_down_files.pl

#### arguments for calling the script
set argument1 [lindex $argv 0]		;# takes the first argument used when calling the script and puts it in the variable "argument1"
set argument2 [lindex $argv 1]		;# takes the second argument used when calling the script and puts it in the variable "argument2"
set argument3 [lindex $argv 2]		;# takes the third argument used when calling the script and puts it in the variable "argument3"
set argument4 [lindex $argv 3]		;# takes the fourth argument used when calling the script and puts it in the variable "argument4"
set argument5 [lindex $argv 4]		;# takes the fifth argument used when calling the script and puts it in the variable "argument5"
set argument6 [lindex $argv 5]		;# takes the sixth argument used when calling the script and puts it in the variable "argument6"
set argument7 [lindex $argv 6]		;# takes the seventh argument used when calling the script and puts it in the variable "argument7"
set argument8 [lindex $argv 7]		;# takes the seventh argument used when calling the script and puts it in the variable "argument8"
set argument9 [lindex $argv 8]		;# takes the eigth argument used when calling the script and puts it in the variable "argument9"
set argument10 [lindex $argv 9]		;# takes the tenth argument used when calling the script and puts it in the variable "argument10"
set argument11 [lindex $argv 10]	;# takes the eleventh argument used when calling the script and puts it in the variable "argument11"
set argument12 [lindex $argv 11]	;# takes the eleventh argument used when calling the script and puts it in the variable "argument12"
set argument13 [lindex $argv 12]	;# takes the eleventh argument used when calling the script and puts it in the variable "argument13"

# for calling the script use (e.g.):
#
# $ ns cars_street_v30.tcl hello B 1 0.1 0.25 5000 all_time 60 0.15 0.30 1.2
#
# this means that	1	- hello	The name of the output folder will be "hello"
#					2	- B		traces of group B will be used.
#								If you write "all", then all the traces are used
#								If you write "fixed", then a fixed speed is used
#								If you write, 58, all the cars will use this trace
#					3	- 1		v2v communications will be used
#					4	- 0.1	the probability of a car having wifi is 0.1
#					5	- 0.25	the probability of a WiFi car playing a FPS is 0.25
#								if you write "manual" then there is no probability
#					6	- 5000	the number of cars is 5000
#					7	- behaviour of the prediction mechanism:	"all_time" the FPS cars send traffic all the simulation time. No prediction is used
#																	"mechanism" the FPS cars send traffic once the prediction of the connection time has been calculated
#																	"random" the FPS cars send traffic in a uniformly distributed random moment while they are under coverage
#					8	- duration of a FPS game in seconds:		if the previous argument is "all_time", this argument is not used
#					9	- 0.15	proportion of the street in which the prediction begins
#					10	- 0.30	proportion of the street in which the prediction ends
#					11	- 1.2	factor for widening the prediction: The predicted connection time is enlarged according to this factor
#					12	- 10.0	width of the street
#					13	- Freespace / TwoRayGround / Shadowing			(http://www.isi.edu/nsnam/ns/doc/node216.html)

############################################################################################
################################ PARAMETERS TO TUNE ########################################
############################################################################################
set obtain_ftp_up_results_ 0		;# if this is 1, after the end of the simulation, the throughput of each FTP flow is calculated from the traces
set obtain_ftp_down_results_ 0		;# if this is 1, after the end of the simulation, the throughput of each FTP flow is calculated from the traces
set obtain_voip_results_ 0			;# NOT YET IMPLEMENTED. if this is 1, after the end of the simulation, the delay, jitter, MOS of VoIP applications are calculated from the traces
set obtain_fps_results_ 1			;# if this is 1, after the end of the simulation, the delay, jitter, MOS of FPS applications are calculated from the traces

set remove_intermediate_files_ 1	;# if this is set to 1, the intermediate files for calculating the results, and the main .tr file, are removed once used


############################################################################################
################################ IMPORT THE VALUES OF THE ARGUMENTS ########################
############################################################################################
# probability of a car being wifi enabled
# set this to 1 in order to get all the cars wifi-enabled
if { $argument4 == "" } {
	set probability_wifi_ 1
} else {
	set probability_wifi_ $argument4
}

# decision about if the applications are defined manually or randomly
if { $argument5 == "manual" } {
	set mode_define_applications_ "manual"		;# in this case, the applications run by each car are manually defined in define_applications.tcl

} else {
	set mode_define_applications_ "random"

	# probability of a wifi-enabled car running each application. By now, a car only can execute one application. It executes it during all the simulation
	# the probability of a wifi car not running any application is 1 - probability_fps_ - probability_tcp_ - probability_voip_
	# example: if probability_wifi_ = 0.5, and probability_fps = 0.1 then there will be approx 0.05 cars running a FPS

	# these values are only taken into account if mode_define_applications_ is "random"
	set probability_ftp_down_ 0.0
	set probability_ftp_up_ 0.0
	set probability_voip_ 0.0		;# VoIP and FPS are bidirectional, so there is no difference between up and down

	# probability of playing a FPS is argument5
	set probability_fps_ $argument5
}

# this is the total amount of cars, including wifi and non-wifi enabled
# if it is set to 0, this means that the number of cars is calculated by the program,
# as the ( movement trace duration / average seconds between cars ), in order to "fill the street with cars"
set number_of_cars_ $argument6

set deterministic_time_between_cars_ 1	;# if it is 1, the time between cars is always exactly the same
										;# if it is 0, the time between cars has a statistical distribution

set average_seconds_between_cars_ 1		;# e.g. a car every 0.25 seconds playing a FPS is too much, and does not work properly

# set this to 1 if you want the time between cars to be adapted to the speed of the cars
# if only a set of traces is used, in some cases it is more fair that the time between cars is modified in order to have in all the cases the same number
#of cars under coverage.
set correct_average_seconds_between_cars_ 0

set stdev_seconds_between_cars_ 0.1		;# stdev of the normal variable seconds between cars

if { $argument2 == "fixed" } {
	set fixed_speed_ 1			;# if this is 0, each car takes its speed from an external movement trace file.
								;# if it is 1, the speed is fixed

	set car_speed_mps_ [expr 50 / 3.6]		;# 50 kmh
	#set car_speed_mps_ [expr 25 / 3.6]		;# 25 kmh
	#set car_speed_mps_ [expr 10 / 3.6]		;# 10 kmh
	#set car_speed_mps_ [expr 100 / 3.6]	;# 100 kmh
	#set car_speed_mps_ 10					;# 10 m/s

# there are 111 movement traces. trace 001 is the slowest. trace 111 is the fastest
} else {
	set fixed_speed_ 0
	set trace_select_ 000		;# if trace_select_ == 000, then each car will use a different random trace
	
	# This only works if trace_select is 000:
	set movement_group_allowed_(1) 0			;# this allows to use the movement traces belonging to group A (slowest)
	set movement_group_allowed_(2) 0			;# this allows to use the movement traces belonging to group B
	set movement_group_allowed_(3) 0			;# this allows to use the movement traces belonging to group C
	set movement_group_allowed_(4) 0			;# this allows to use the movement traces belonging to group D
	set movement_group_allowed_(5) 0			;# this allows to use the movement traces belonging to group E (fastest)

	# the second argument specifies the group of movement traces to use
	if { $argument2 == "all" } {
		set movement_group_allowed_(1) 1
		set movement_group_allowed_(2) 1
		set movement_group_allowed_(3) 1
		set movement_group_allowed_(4) 1
		set movement_group_allowed_(5) 1
		
		
	} else {
		if { $argument2 == "A" } {
			set movement_group_allowed_(1) 1			;# this allows to use the movement traces belonging to group A (slowest)
			# I check if I have to correct the value of "seconds between cars" for making it be the same number of cars under coverage
			if { $correct_average_seconds_between_cars_ == 1 } {
				set average_seconds_between_cars_ [expr $average_seconds_between_cars_ * 50 / 8.413]
			}
		} else {
			if { $argument2 == "B" } {
				set movement_group_allowed_(2) 1			;# this allows to use the movement traces belonging to group B
				if { $correct_average_seconds_between_cars_ == 1 } {
					set average_seconds_between_cars_ [expr $average_seconds_between_cars_ * 50 / 10.89]
				}
			} else {
				if { $argument2 == "C" } {
					set movement_group_allowed_(3) 1			;# this allows to use the movement traces belonging to group C
					if { $correct_average_seconds_between_cars_ == 1 } {
						set average_seconds_between_cars_ [expr $average_seconds_between_cars_ * 50 / 14.48]
					}
				} else {
					if { $argument2 == "D" } {
						set movement_group_allowed_(4) 1			;# this allows to use the movement traces belonging to group D
						if { $correct_average_seconds_between_cars_ == 1 } {
							set average_seconds_between_cars_ [expr $average_seconds_between_cars_ * 50 / 21.18]
						}
					} else {
						if { $argument2 == "E" } {
							set movement_group_allowed_(5) 1			;# this allows to use the movement traces belonging to group E (fastest)
							if { $correct_average_seconds_between_cars_ == 1 } {
								set average_seconds_between_cars_ [expr $average_seconds_between_cars_ * 50 / 29.18]
							}

						# the argument2 is the number of the trace (e.g. 058)
						} else {
							set trace_name_ ""
							# I add 00 for the first 9 traces, and 0 for traces 10 to 99
							if {$argument2 < 10} {
								append trace_name_ "00"
							} else {
								if {$argument2 < 100 } {
									append trace_name_ "0"
								}
							}
							append trace_name_ [format "%.0f" $argument2 ]
							set trace_select_ $trace_name_
						}
					}
				}
			}
		}	
	}
}


set street_length_ 380								;# if the speed is fixed, then the length of the street can be tuned
set base_station_X_ [expr $street_length_ / 2]		;# X coordinates of the base station. In the middle of the street
set base_station_Y_ $argument12						;# Y coordinates of the base station. In one side of the street (the minimum distance with each car are 10m)
set street_width_ $argument12						;# street width in meters
set initial_movement_time_ 0.0						;# time in which the cars start moving
set final_time_ 0.0									;# simulation time after the last car gets out the coverage of the AP

set coverage_area_ 500.0		;# default value of the diameter. estimation of the coverage area of the AP. This variable is used for calculating the duration of the simulation
#set coverage_area_ 70.0		;# diameter of the coverage area (radius 35m)
#set coverage_area_ 200.0		;# diameter of the coverage area (radius 100m)

set one_way_delay_wired_part_ 20		;# ms of OWD in the wired part of the scenario

# Establish the propagation model
set propagation_model_ $argument13

# FreeSpace and TwoRayGround do not require additional parameters
# Shadowing model requires additional parameters
if { $propagation_model_ == "Shadowing" } {
	# first set values of shadowing model				;# http://www.isi.edu/nsnam/ns/doc/node221.html
	Propagation/Shadowing set pathlossExp_ 2.0  ;# path loss exponent
	Propagation/Shadowing set std_db_ 4.0       ;# shadowing deviation (dB)
	Propagation/Shadowing set dist0_ 1.0        ;# reference distance (m)
	Propagation/Shadowing set seed_ 0           ;# seed for RNG
}

#### WIFI rate #####
#set wifi_rate_ "11Mb"	;# Data Rate in Mbps: 1, 2, 5.5, 11
#set wifi_rate_ "22Mb"	;# Data Rate in Mbps: 1, 2, 5.5, 11
set wifi_rate_ "54Mb"	;# Data Rate in Mbps: 1, 2, 5.5, 11

# set this to 0 in order to avoid packets being retransmitted between cars. In addition, everything happens in the wireless part
set v2v_ $argument3	

if { $v2v_ == 1 } {
	#### parameters of DSDV algorithm
	set perupdate_ 0.5				;# seconds between periodical updates
	#set perupdate_ 1				;# seconds between periodical updates

	set num_update_periods_ 1		;# number of periods failed to consider a link broken
	#set num_update_periods_ 4		;# number of periods failedto consider a link broken
}

# Parameter of the 802.11 module. It is the number of times a MAC packet is retransmitted if it does not arrive
set num_retransmissions_ -1		;# set this to -1 in order to leave the default value

#### TTL value for the packets (number of retransmissions allowed)
set max_ttl_ 32		;# default value is 32
#set max_ttl_ 3		;# set this to 3 in order to avoid retransmissions between cars in the downlink. But they still exist in the uplink
#set max_ttl_ 4		;# set this to 4 in order to permit one retransmissions between cars in the downlink. But they still exist in the uplink
#set max_ttl_ 6		;# set this to 6 in order to permit three retransmissions between cars in the downlink. But they still exist in the uplink

#### Tick interval in seconds for obtaining output parameters: TCP window size, queuing size, throughput etc
set tick_interval_ 1

############################################################################################
################################ END PARAMETERS TO TUNE ####################################
############################################################################################

######################### prediction mechanism ########################
#it only works if movement traces are used

set coverage_init_position_ [expr $base_station_X_ - ( $coverage_area_ / 2 ) ]
if { $coverage_init_position_ < 0 } {
	set coverage_init_position_ 0
}
set coverage_end_position_ [expr $base_station_X_ + ( $coverage_area_ / 2 ) ]
if { $coverage_end_position_ > $street_length_ } {
	set coverage_end_position_ $street_length_
}

#set prediction_init_position_ [expr $coverage_init_position_ + ( 0.15 * $coverage_area_) ]
#set prediction_end_position_ [expr $coverage_init_position_ + (0.36 * $coverage_area_) ]

set prediction_init_position_ [expr $coverage_init_position_ + ($argument9 * $coverage_area_) ]
set prediction_end_position_ [expr $coverage_init_position_ + ($argument10 * $coverage_area_) ]

set game_duration_ $argument8
set factor_widen_prediction_ $argument11

# prediction based on the sum of average speed plus stdev of the speed from 15% to 36% of the coverage area
if { $argument7 != "all_time" } {
	set calculate_prediction_ 1		;# set this to 1 if you want the script to calculate the prediction of the contact time



} else {
	set calculate_prediction_ 0
}


#### end prediction mechanism calculations


if { $fixed_speed_ == 0 } {
	# I fill the trace duration array
	trace_duration_fill_ trace_duration_
	trace_group_fill_ trace_group_
}


# if the number of cars has to be calculated by the program, I have to "fill the street with cars"
if { $number_of_cars_ == 0 } {
	if { $fixed_speed_ == 0 } {
		# if a movement trace is being used
		set number_of_cars_ [expr ($trace_duration_($trace_select_) / $average_seconds_between_cars_ ) * 1.1]
	} else {
		# if the speed is constant
		set number_of_cars_ [expr ( ($street_length_ / $car_speed) / $average_seconds_between_cars_ ) * 1.1]
	}
}


#### This is the folder where these data will be stored. It is a subfolder of the current folder

# I obtain the name of the original directory where the script is run
set original_directory_ [pwd]

set folder_output_name_ "../_results_street/"

# I take the argument when calling the script and put it as the beginning of the name of the output folder
if { $argument1 != "" } {
	append folder_output_name_ $argument1
	# I append to the name the string "-street_output_files"
	# append folder_output_name_ "-street_output_files"

# if there is no argument
} else {
	append folder_output_name_ "street_output_files"
}

# append the hierarchical mode to the folder name
if { $v2v_ == 1 } {
	append folder_output_name_ "-v2v_yes"
} else {
	append folder_output_name_ "-v2v_no"
}

# I add to the name the number of cars
append folder_output_name_ "-"
append folder_output_name_ [expr int($number_of_cars_)]
append folder_output_name_ "_cars-"
if { $mode_define_applications_ == "random" } {
	append folder_output_name_ "pr_wifi_"
	append folder_output_name_ $probability_wifi_
} else {
	append folder_output_name_ "manual"
}

if { $fixed_speed_ == 0 } {

	# if all the cars follow a trace, then I include the trace number in the folder name
	if { $trace_select_ != "000" } {
		append folder_output_name_ "-"
		append folder_output_name_ $trace_select_

	# if each car follows a random trace, I also include it in the folder name
	} else {
		append folder_output_name_ "-"
		append folder_output_name_ $argument2
		append folder_output_name_ "_traces"
	}

# if the speed is fixed
} else {
		append folder_output_name_ "-fixed_speed_"
		append folder_output_name_ [format "%.2f" $car_speed_mps_]
		append folder_output_name_ "mps"
}

append folder_output_name_ "-street_"
append folder_output_name_ $street_length_
append folder_output_name_ "m"

# I create the directory
exec mkdir $folder_output_name_

# I define a file for summarizing the movements of each car
set summary_movement_file_name_ $folder_output_name_
append summary_movement_file_name_ "/summary_movement_.txt"
set summary_movement_file_ [open $summary_movement_file_name_ w]

puts $summary_movement_file_ "number of cars: $number_of_cars_"
if { $fixed_speed_ == 0 } {
	if { $trace_select_ != "000" } {
		puts $summary_movement_file_ "time for going through the street: $trace_duration_($trace_select_)"
	}
} else {
	puts $summary_movement_file_ "time for going through the street: [expr $street_length_ / $car_speed_mps_ ]"
}

# call the procedure that decides if each car is wifi-enabled or not
set number_of_wifi_cars_ 0
define_cars_ cars_

# after this procedure:
# - the number_of_wifi_cars_ is updated
# - the variable cars_($i)	has the size of number_of_wifi_cars_
#							each position contains the total position of the car. e.g. if the first wifi car appears after two non-wifi cars, then cars_(1) = 3 
#							so the moment the car appears in the street is [expr $initial_movement_time_ + ( $seconds_between_cars_ * ($cars_($i) - 1) ) ]

#### Trace format for the wireless packets
set trace_format_ 1		;# 0 means old format; 1 means new (wireless) format (http://nsnam.isi.edu/nsnam/index.php/NS-2_Trace_Formats#New_Wireless_Trace_Formats)

# Call the procedure which defines the applications used by each car
# if the parameter is "manual", then the applications are defined manually
# if the parameter is "random", then different probabilities for each application are used
define_applications_ $mode_define_applications_

# ====================================================================== 
# Define wireless options 
# ====================================================================== 
set val(chan)         Channel/WirelessChannel				;# channel type 
set val(prop)         Propagation/$propagation_model_		;# radio-propagation model 
set val(ant)          Antenna/OmniAntenna					;# Antenna type 
set val(ll)           LL									;# Link layer type 
set val(ifq)          Queue/DropTail/PriQueue				;# Interface queue type 
set val(ifqlen)       50									;# max packet in ifq 
#set val(ifqlen)       5									;# max packet in ifq (a queue in the 802.11 layer)
set val(netif)        Phy/WirelessPhy						;# network interface type 
set val(mac)          Mac/802_11							;# MAC type 
set val(nn)           [expr $number_of_wifi_cars_ +1]		;# number of wireless nodes. Includes the fixed node and the cars

#################### I set the parameters of the routing protocol #####################
# if I am using hierarchical routing, I use DSDV
if { $v2v_ == 1 } {
	set val(rp) DSDV							;# proactive ad-hoc routing protocol
	#set val(rp)           OLSR
	#set val(rp)           AODV							;# reactive ad-hoc routing protocol. Uplink packets do not arrive
	#set val(rp)           AOMDV						;# ad-hoc routing protocol. Uplink packets do not arrive

	Agent/DSDV set perup_		$perupdate_				;# time in seconds between perdiodical update messages. the default value is 15
	Agent/DSDV set alpha_		0.875					;# 0.875=7/8, as in RIP(?)

	# number of failures necessary so as to consider that the link is broken
	Agent/DSDV set min_update_periods_ $num_update_periods_	

	#Agent/DSDV set use_mac_      0			;# if you set this to 1, it is worse
	#Agent/DSDV set wst0_         6  
	#Agent/DSDV set be_random_    1 

	# if these two lines are set to 1, you will see the DSDV packets in the trace file
	Agent/DSDV set trace_wst_ 0;
	Agent/DSDV  set verbose_ 0;

# if not, I do not use routing
} else {
	set val(rp)	DumbAgent
}


######################### Phy/WirelessPhy settings ######################################

# if nothing is changed in the Phy/WirelessPhy parameters, the coverage area is radius=250m, diameter=500m

#Phy/WirelessPhy set L_ 1.0						;# System Loss Factor
#Phy/WirelessPhy set freq_ 2.472e9				;# channel-13. 2.472GHz
#Phy/WirelessPhy set Pt_ 0.031622777			;# Transmit Power (15dBm) for 250m radius

# by default, coverage area is 250 m radius
if { $coverage_area_ == 70.0 } {
	Phy/WirelessPhy set Pt_	7.214e-4			;# 70m of coverage area (diameter)
}


if { $coverage_area_ == 200.0 } {
	Phy/WirelessPhy set Pt_	7.214e-3			;# 200m of coverage area (diameter)
	#Phy/WirelessPhy set Pt_	6e-3			;# 190m of coverage area (diameter)
}

#Phy/WirelessPhy set CPThresh_ 10.0			;# Collision Threshold
#Phy/WirelessPhy set CSThresh_ 3.1622777e-14	;# Carrier Sense Power (-94dBm);
#Phy/WirelessPhy set RXThresh_ 1.15126e-10		;# Receive Power Threshold for 160m, for using with two ray ground

Phy/WirelessPhy set bandwidth_ "$wifi_rate_"	;# Data Rate

######################### Mac/802_11 settings #########################################
Mac/802_11 set dataRate_ "$wifi_rate_"						;# Rate for Data Frames
Mac/802_11 set basicRate_ "$wifi_rate_"						;# Rate for Control Frames
if { $num_retransmissions_ != -1 } {
	Mac/802_11 set ShortRetryLimit $num_retransmissions_		;# Number or retries The ShortRetryLimit de?nes thebnumber of retransmissions for packets with size less thanthe RTST hreshold (2347)
	Mac/802_11 set LongRetryLimit $num_retransmissions_			;# Number or retries. It de?nes thebnumber of retransmissions for packets with size is more than the RTST hreshold (2347)
}

################################# Random seed #################################
##### Generation of the seed
#just use seconds as the seed
set seed_ 1[lindex [split [lindex [exec date] 3] :] 2]
set ia_ 9301
set ic_ 49297
set im_ 233280
set seed_  [expr ( ($seed_ * $ia_) + $ic_ ) % $im_]

# define the seed
ns-random $seed_

# Create simulator
set ns_ [new Simulator]

###################### teletraffic trace file ######################
if { $trace_format_ == 1 } {
	$ns_ use-newtrace	;# use new trace format. If you comment this line, only wired traces appear. http://nsnam.isi.edu/nsnam/index.php/NS-2_Trace_Formats#New_Wireless_Trace_Formats
}
set tracefd [open [concat $folder_output_name_/cars_street.tr] w]
$ns_ trace-all $tracefd

# Create the "general operations director"
# Used internally by MAC layer: must create!
create-god $val(nn)
set god_ [God instance]

############# if hierarchical is enabled, I set up for hierarchical routing
if { $v2v_ == 1 } {

	$ns_ node-config -addressType hierarchical		;# the topology is defined into a 3-level hierarchy 
	AddrParams set domain_num_ 2					;# number of domains. one for the wired nodes and one for the wireless
	lappend cluster_num 1 2							;# number of clusters in each domain. is defined as "1 2" which indicates the first domain (wired) to have 1 clusters and the second (wireless) to have 2 clusters
	AddrParams set cluster_num_ $cluster_num
	lappend eilastlevel 1 1 [expr $val(nn) + 1 ]	;# number of nodes in each of these clusters which is "1 1 number_cars+1"; i.e one node in each of the first 2 clusters (in wired domain) and 4 nodes in the cluster in the wireless domain
	AddrParams set nodes_num_ $eilastlevel

	# create a fixed node
	set fixed_node [$ns_ node [lindex 0.0.0 0]]
} else {
	set fixed_node [$ns_ node]
}
puts "created fixed node"

# Create and configure topography (used for mobile scenarios)
set topo [new Topography]

# street_length_ * 11 x 10m terrain. I use that length because the cars that finish the street are quicly sent to street_length * 10
$topo load_flatgrid [expr $street_length_ * 11.0] 10

# Node configuration essentially consists of defining the different node characteristics before creating them.
if { $v2v_ == 1 } {
	$ns_ node-config -adhocRouting $val(rp) \
				-addressType hierarchical \
				-llType $val(ll) \
				-macType $val(mac) \
				-ifqType $val(ifq) \
				-ifqLen $val(ifqlen) \
				-antType $val(ant) \
				-propType $val(prop) \
				-phyType $val(netif) \
				-channel [new $val(chan)] \
				-topoInstance $topo \
				-agentTrace OFF \
				-routerTrace ON \
				-macTrace ON \
				-movementTrace OFF
			;# what traces should be put in the trace file
			;# agent traces are the ones written by traffic sources/destinations

			;# Router traces are written by packet forwarders
			;# MAC traces are written by each node's MAC.
			;# Nodes' movements can be traced by switching movementTrace ON

	# before creating node 0, I establish the value of wiredRouting to ON
	# thus, node0 will be able to do wiredRouting
	$ns_ node-config -wiredRouting ON
	set node_(0) [$ns_ node [lindex 1.0.0 0]]	;# node_(0) es la estación base. Le asigno la dirección 1.0.0

	#set node_(0) [$ns_ node]	;# this is the fixed node (the AP)
	puts "node 0 has address 1.0.0"

	# Defining the node 0 to be an AP (no).
	set mac_(0) [$node_(0) getMac 0]
	set AP_ADDR0 [$mac_(0) id]
	#$mac_(0) ap $AP_ADDR0		;# make node_(0) be an AP. Si se activa, deja de llegar el tráfico en los dos sentidos
	$mac_(0) ScanType ACTIVE
	#$mac_(0) ScanType PASSIVE	;# si se pone PASSIVE y no es un ap, da error
	$mac_(0) set BeaconInterval_ 1	;# if the node is in PASSIVE mode, every BeaconInterval_ seconds, a MAC BCN frame is sent to ffffff (everyone)

	######################## create the rest of nodes ####################
	$ns_ node-config -wiredRouting OFF

	for {set i 1} {$i < $val(nn) } {incr i} {
		set temp " 1.0."		
		append temp $i				;# the last number of the address for each car
		set node_($i) [ $ns_ node [lindex $temp 0] ]			;# node_(1) es el primer nodo móvil. Le asigno la dirección 1.0.1 (temp(1) )

		$node_($i) random-motion 0				;# disable random motion
		$node_($i) set Y_ 0.0
		$node_($i) set Z_ 0.0

		$node_($i) base-station [AddrParams addr2id [$node_(0) node-addr]]	;# set node_(0) as access point
		puts "car $i address $temp. Access point [$node_(0) node-addr]"
	}

# non hierarchical mode
} else {
	$ns_ node-config -adhocRouting $val(rp) \
				-llType $val(ll) \
				-macType $val(mac) \
				-ifqType $val(ifq) \
				-ifqLen $val(ifqlen) \
				-antType $val(ant) \
				-propType $val(prop) \
				-phyType $val(netif) \
				-channel [new $val(chan)] \
				-topoInstance $topo \
				-agentTrace OFF \
				-routerTrace ON \
				-macTrace ON \
				-movementTrace OFF
			;# what traces should be put in the trace file
			;# agent traces are the ones written by traffic sources/destinations

			;# Router traces are written by packet forwarders
			;# MAC traces are written by each node's MAC.
			;# Nodes' movements can be traced by switching movementTrace ON

	set node_(0) [$ns_ node]	;# this is the fixed node (the AP)
	puts "created node 0"

	######################## create the rest of nodes ####################

	for {set i 1} {$i < $val(nn) } {incr i} {
		set node_($i) [ $ns_ node ]				;# node_(1) es el primer nodo móvil. Le asigno la dirección 1.0.1 (temp(1) )

		$node_($i) random-motion 0				;# disable random motion
		$node_($i) set Y_ 0.0
		$node_($i) set Z_ 0.0

		$node_($i) base-station [AddrParams addr2id [$node_(0) node-addr]]	;# set node_(0) as access point
		puts "car $i created"
	}
}

##################################################################
############ positions and movements of the cars #################
##################################################################

# I calculate the first value of the duration of the simulation
set simulation_duration_ $initial_movement_time_

# for each car, I calculate the moment in which it begins, and all its movements
set current_time_ 0
set j 1					;# j is the index for the wifi cars

# for each car (wifi or non-wifi)
for {set i 1} {$i <= $number_of_cars_ } {incr i} {

	# I calculate the time between cars
	if { $deterministic_time_between_cars_ == 1 } {
		set current_time_ [expr $current_time_ + $average_seconds_between_cars_]
	} else {
		# if it is not deterministic, I use a statistical distribution
		set current_time_ [expr $current_time_ + [$normal_variable_ value]]
	}

	#cars_($j) is the position of the wifi car j, i.e. if cars_(2)=7, it means that the second wifi car departs in position 7
	if { $cars_($j) == $i } {
		set initial_time_car_($j) $current_time_
		if { $j < $number_of_wifi_cars_ } {
			set j [expr $j + 1]
		}
	}
}

# for each wifi car
for {set i 1} {$i <= $number_of_wifi_cars_ } {incr i} {
	puts $summary_movement_file_ "car\t$i\tbegins in\t$initial_time_car_($i)"
	# in order to avoid interactions between cars, at the beginning the car 1 is at X=-1000, car 2 is at X=-2000
	set position_ [expr - 1000 * $i]
	$node_($i) set X_ $position_

	# at the suitable moment, I put the car at the beginning of the street
	$ns_ at $initial_time_car_($i) "$node_($i) set X_ 0"

	#### If the speed is fixed, I set the movements
	if { $fixed_speed_ == 1 } {
		############## speeds of the cars #################
		$ns_ at $initial_time_car_($i) "$node_($i) setdest [expr $street_length_ - 0.001] 0.0001 $car_speed_mps_"
		$ns_ at $initial_time_car_($i) "puts \"wifi car $i starts. speed: [format "%.2f" $car_speed_mps_] meters per second\""

		# I program the end of the car
		$ns_ at [expr $initial_time_car_($i) + ( $street_length_ / $car_speed_mps_ ) ] "car_finishes_ $ns_ $node_($i) $i"

	#### If the speed depends on the traces, I assign each car a trace, calling the procedure car_movements_
	} else {
		############# movements of the cars ########################
		car_movements_ $ns_ $node_($i) $i $initial_time_car_($i) $street_length_ $trace_select_ prediction_each_car_ prediction_moment_each_car_ moment_enters_coverage_each_car_ moment_gets_out_coverage_each_car_
		# this procedure is also in charge of finishing the car when it arrives at the end of the street
	}
}

# the simulation ends when the last car running an application goes out of the street:
#	- initial movement time
#	- the number of cars * the time between cars
#	- the time a car spends for going through the whole street
#	- final time

if { $fixed_speed_ == 1 } {
	# in this case I consider the time the last car enters in the street, plus the trace_duration_($trace_select_)
	set simulation_duration_ [expr $initial_time_car_($number_of_wifi_cars_) + ( $street_length_ / $car_speed_mps_ ) + $final_time_ ]

# real movement traces are being used
} else {
	# in this case, the procedure car_movements_ has calculated the simulation duration. I only add the final simulation time
	set simulation_duration_ [expr $simulation_duration_ + $final_time_ ]
}

puts $summary_movement_file_ "simulation duration: $simulation_duration_ seconds"
puts "simulation duration: $simulation_duration_ seconds"


# los coches buscan activamente un AP. Se ganan 2 segundos
for {set i 1} {$i < $val(nn) } {incr i} {
	set mac_($i) [$node_($i) getMac 0]
	$mac_($i) ScanType ACTIVE	;# sends out a broadcast Probe Request (PRRQ), evoking all APs within range, to respond.
}


$node_(0) random-motion 0              ;# disable random motion
$node_(0) set X_ $base_station_X_
$node_(0) set Y_ 10.0
$node_(0) set Z_ 0.0


# connect the fixed_node and the base station
$ns_ duplex-link $fixed_node $node_(0) 100Mb [expr $one_way_delay_wired_part_]ms DropTail
set uplink_buffer_ [[$ns_ link $fixed_node $node_(0)] queue]
$uplink_buffer_ set limit_ 20
set downlink_buffer_ [[$ns_ link $node_(0) $fixed_node] queue]
$downlink_buffer_ set limit_ 20
	
############################## setup TCP connections ##################################
Agent/TCP set packetSize_ 1440
Agent/TCP set ttl_ $max_ttl_	;# with TTL=6 it works with a fixed node, an AP, and 4 cars in line. With TTL=5 it only works with 3 cars in line
# this only works for downlink connections
Agent/TCP set defttl_ $max_ttl_	;# with TTL=6 it works with a fixed node, an AP, and 4 cars in line. With TTL=5 it only works with 3 cars in line
# this only works for downlink connections

#### TCP connections for downlink FTP
for {set i 1} {$i <= $number_of_wifi_cars_ } {incr i} {	;# the mobile nodes download FTP traffic from the fixed network
	set tcp_source_server_car_($i) [new Agent/TCP/Sack1]
	set sink1_($i) [new Agent/TCPSink]
	set ftp_down_($i) [new Application/FTP]
	$ftp_down_($i) attach-agent $tcp_source_server_car_($i)
	$ftp_down_($i) set fid_ [expr 10000 + $i]								;# for distinguishing the flows
	if { $v2v_ == 1 } {
		$ns_ attach-agent $fixed_node $tcp_source_server_car_($i)	;# attach the TCP source to the fixed node
	} else {
		$ns_ attach-agent $node_(0) $tcp_source_server_car_($i)		;# attach the TCP source to the fixed node
	}
	$ns_ attach-agent $node_($i) $sink1_($i)						;# attach the TCP sink to the car
	$ns_ connect $tcp_source_server_car_($i) $sink1_($i)

	#el node_($i) (móvil) comienza a enviar tráfico FTP al fixed node
	if {$ftp_down_mask_($i) == 1} {
		$ns_ at $initial_time_car_($i) "$ftp_down_($i) start" 
		$ns_ at $initial_time_car_($i) "puts begin_ftp_downlink$i"
	}
}

#### TCP connections for uplink FTP
for {set i 1} {$i < $val(nn)} {incr i} {	;# the mobile nodes upload FTP traffic to the fixed network
	set tcp_source_car_server_($i) [new Agent/TCP/Sack1]
	set sink2_($i) [new Agent/TCPSink]
	set ftp_up_($i) [new Application/FTP]
	$ftp_up_($i) attach-agent $tcp_source_car_server_($i)
	$ftp_up_($i) set fid_ [expr 20000 + $i]								;# for distinguishing the flows

	$ns_ attach-agent $node_($i) $tcp_source_car_server_($i)	;# attach the TCP source to the car
	if { $v2v_ == 1 } {
		$ns_ attach-agent $fixed_node $sink2_($i)					;# attach the TCP sink to the fixed node
	} else {
		$ns_ attach-agent $node_(0) $sink2_($i)					;# attach the TCP sink to the fixed node
	}
	$ns_ connect $tcp_source_car_server_($i) $sink2_($i)

	# JMS el node_($i) (móvil) comienza a enviar tráfico FTP al fixed node
	if {$ftp_up_mask_($i) == 1} {	
		$ns_ at $initial_time_car_($i) "$ftp_up_($i) start"
		$ns_ at $initial_time_car_($i) "puts begin_ftp_uplink$i"
	}
}

######################################################
#################### UDP Connections #################
######################################################
Agent/UDP set ttl_ $max_ttl_	;# it works properly for downlink. it does not affect uplink. a value of 6 allows 4 cars
Agent/UDP set defttl_ $max_ttl_	;# it works properly for downlink. it does not affect uplink. a value of 6 allows 4 cars

################### VoIP downlink ####################
for {set i 1} {$i < $val(nn)} {incr i} {	;# the fixed node sends a flow to each car
	# UDP connection from the fixed node to a car 
	set udp_voip_down_($i) [new Agent/UDP]
	if { $v2v_ == 1 } {
		$ns_ attach-agent $fixed_node $udp_voip_down_($i)
	} else {
		$ns_ attach-agent $node_(0) $udp_voip_down_($i)
	}
	set voip_down_($i) [new Application/Traffic/CBR]
	$voip_down_($i) attach-agent $udp_voip_down_($i)
	set udp_voip_down_receiver_($i) [new Agent/LossMonitor]
	$ns_ attach-agent $node_($i) $udp_voip_down_receiver_($i)
	$ns_ connect $udp_voip_down_($i) $udp_voip_down_receiver_($i)
	$udp_voip_down_($i) set fid_ [expr 30000 + $i]								;# for distinguishing the flows

	# CBR application parameters
	$voip_down_($i) set packetSize_ 60			;# this is the payload (20 bytes) plus the RTP/UDP/IP headers (40 bytes)
	$voip_down_($i) set interval_ 0.020			;# a packet every 20 ms
	$voip_down_($i) set random_ 0				;# it does not introduce a random time between different sending times
	if {$voip_down_mask_($i) == 1} {
		$ns_ at $initial_time_car_($i) "$voip_down_($i) start" ;# the car begins the transmission of a VoIP flow to the server
		$ns_ at $initial_time_car_($i) "puts begin_voip_downlink_$i"
	}
}


Agent/UDP set ttl_ $max_ttl_	;# it works properly for downlink. it does not affect uplink. a value of 6 allows 4 cars
Agent/UDP set defttl_ $max_ttl_	;# it works properly for downlink. it does not affect uplink. a value of 6 allows 4 cars

################## VoIP uplink ######################
for {set i 1} {$i < $val(nn)} {incr i} {	;# each car sends a flow to the server in fixed node
	# UDP connection from a car to a server in the fixed node
	set udp_voip_up_($i) [new Agent/UDP]
	$ns_ attach-agent $node_($i) $udp_voip_up_($i)
	set voip_up_($i) [new Application/Traffic/CBR]
	$voip_up_($i) attach-agent $udp_voip_up_($i)
	set udp_voip_up_receiver_($i) [new Agent/LossMonitor]
	if { $v2v_ == 1 } {
		$ns_ attach-agent $fixed_node $udp_voip_up_receiver_($i)
	} else {
		$ns_ attach-agent $node_(0) $udp_voip_up_receiver_($i)
	}
	$ns_ connect $udp_voip_up_($i) $udp_voip_up_receiver_($i)
	$udp_voip_up_($i) set fid_ [expr 40000 + $i]								;# for distinguishing the flows

	# CBR application parameters
	$voip_up_($i) set packetSize_ 60			;# this is the payload (20 bytes) plus the RTP/UDP/IP headers (40 bytes)
	$voip_up_($i) set interval_ 0.020			;# a packet every 20 ms
	$voip_up_($i) set random_ 0				;# it does not introduce a random time between different sending times
	if {$voip_up_mask_($i) == 1} {
		$ns_ at $initial_time_car_($i) "$voip_up_($i) start" ;# the car begins the transmission of a VoIP flow to the server	;# if it begins at 70, the packets do not find the route
		$ns_ at $initial_time_car_($i) "puts begin_voip_uplink_$i"
	}
}


Agent/UDP set ttl_ $max_ttl_	;# it works properly for downlink. it does not affect uplink. a value of 6 allows 4 cars
Agent/UDP set defttl_ $max_ttl_	;# it works properly for downlink. it does not affect uplink. a value of 6 allows 4 cars

#############################################################################################
#### Quake IV FPS downlink flow for a 5 player party; it is about 25 kbps and 14.4 pps ######
#############################################################################################
for {set i 1} {$i < $val(nn)} {incr i} {	;# the server in W(0) sends a flow to each car
	# UDP connection from a server to a car
	set udp_fps_down_($i) [new Agent/UDP]
	if { $v2v_ == 1 } {
		$ns_ attach-agent $fixed_node $udp_fps_down_($i)
	} else {
		$ns_ attach-agent $node_(0) $udp_fps_down_($i)
	}
	set udp_fps_down_receiver_($i) [new Agent/LossMonitor]
	$ns_ attach-agent $node_($i) $udp_fps_down_receiver_($i)
			
	$ns_ connect $udp_fps_down_($i) $udp_fps_down_receiver_($i)
	$udp_fps_down_($i) set fid_ [expr 60000 + $i]

	# Application based on a binary trace file
	set fps_down_tracefile_($i) [new Tracefile]
	$fps_down_tracefile_($i) filename teletraffic_traces/quake4_5pl_server_to_one_client_64sec.txt.if-0.bin
	set fps_down_($i) [new Application/Traffic/Trace]
	$fps_down_($i) attach-agent $udp_fps_down_($i)
	$fps_down_($i) attach-tracefile $fps_down_tracefile_($i)
	if {$fps_up_mask_($i) == 1} {

		# I am sending the traffic during all the simulation
		if { $argument7 == "all_time" } {
			$ns_ at $initial_time_car_($i) "$fps_down_($i) start" ;# the car begins the transmission of a FPS flow to the server
			$ns_ at $initial_time_car_($i) "puts begin_FPS_downlink_$i"
		} else {

			# I am using the prediction mechanism: the traffic begins in the moment the prediction is available
			#and ends when the duration of the game has passed
			if { $argument7 == "mechanism" } {

				# I only play if the prediction is bigger than the game duration
				if { $prediction_each_car_($i) >= $game_duration_ } {
					# begins in the moment the prediction is available
					$ns_ at $prediction_moment_each_car_($i) "$fps_down_($i) start" ;# the car begins the transmission of a FPS flow to the server
					$ns_ at $prediction_moment_each_car_($i) "puts begin_FPS_downlink_$i"

					# ends when the game ends
					$ns_ at [expr $prediction_moment_each_car_($i) + $game_duration_] "$fps_down_($i) stop" ;# the car begins the transmission of a FPS flow to the server
					$ns_ at [expr $prediction_moment_each_car_($i) + $game_duration_] "puts end_FPS_downlink_$i"

				}
				set begin_moment_each_car_($i) $prediction_moment_each_car_($i)

			} else {	;# the value of the argument is "random", i.e. the game begins in a random moment while the car is under coverage
				
				set probability_ [$uniform_ value]
				set begin_moment_each_car_($i) [expr $moment_enters_coverage_each_car_($i) + ( $probability_ * ($moment_gets_out_coverage_each_car_($i) - $moment_enters_coverage_each_car_($i) ) )]

				puts "enters: $moment_enters_coverage_each_car_($i)"
				puts "gets out: $moment_gets_out_coverage_each_car_($i)"
				puts "random begin: $begin_moment_each_car_($i)"

				# begins in the random moment we have just calculated
				$ns_ at $begin_moment_each_car_($i) "$fps_down_($i) start" ;# the server begins the transmission of a FPS flow to the car
				$ns_ at $begin_moment_each_car_($i) "puts begin_FPS_downlink_$i"

				# ends when the game ends
				$ns_ at [expr $begin_moment_each_car_($i) + $game_duration_] "$fps_down_($i) stop"
				$ns_ at [expr $begin_moment_each_car_($i) + $game_duration_] "puts end_FPS_downlink_$i"

			}
		}
	}
}


Agent/UDP set ttl_ $max_ttl_	;# it works properly for downlink. it does not affect uplink. a value of 6 allows 4 cars
Agent/UDP set defttl_ $max_ttl_	;# it works properly for downlink. it does not affect uplink. a value of 6 allows 4 cars

#################################################################################
#### Quake IV FPS uplink. it is about 50 kbps and 61 pps ######################## data are from a 2 player party, but uplink traffic does not depend on the number of players
#################################################################################
for {set i 1} {$i < $val(nn)} {incr i} {	;# each car sends a flow to the server in W(0)
	# UDP connection from a car to a server
	set udp_fps_up_($i) [new Agent/UDP]
	$ns_ attach-agent $node_($i) $udp_fps_up_($i)
	set udp_fps_up_receiver_($i) [new Agent/LossMonitor]
	if { $v2v_ == 1 } {
		$ns_ attach-agent $fixed_node $udp_fps_up_receiver_($i)
	} else {
		$ns_ attach-agent $node_(0) $udp_fps_up_receiver_($i)
	}
	$ns_ connect $udp_fps_up_($i) $udp_fps_up_receiver_($i)
	$udp_fps_up_($i) set fid_ [expr 50000 + $i]

	# Application based on a binary trace file
	set fps_up_tracefile_($i) [new Tracefile]
	$fps_up_tracefile_($i) filename teletraffic_traces/quake4_2pl_one_client_to_server_67sec.txt.if-0.bin
	set fps_up_($i) [new Application/Traffic/Trace]
	$fps_up_($i) attach-agent $udp_fps_up_($i)
	$fps_up_($i) attach-tracefile $fps_up_tracefile_($i)
	if {$fps_up_mask_($i) == 1} {

		# I am sending the traffic during all the simulation
		if { $argument7 == "all_time" } {
			$ns_ at $initial_time_car_($i) "$fps_up_($i) start" ;# the car begins the transmission of a FPS flow to the server
			$ns_ at $initial_time_car_($i) "puts begin_FPS_uplink_$i"
		} else {

			# I am using the prediction mechanism: the traffic begins in the moment the prediction is available
			#and ends when the duration of the game has passed
			if { $argument7 == "mechanism" } {

				# I only play if the prediction is bigger than the game duration
				if { $prediction_each_car_($i) >= $game_duration_ } {
					# begins in the moment the prediction is available
					$ns_ at $prediction_moment_each_car_($i) "$fps_up_($i) start" ;# the car begins the transmission of a FPS flow to the server
					$ns_ at $prediction_moment_each_car_($i) "puts begin_FPS_uplink_$i"

					# ends when the game ends
					$ns_ at [expr $prediction_moment_each_car_($i) + $game_duration_] "$fps_up_($i) stop"
					$ns_ at [expr $prediction_moment_each_car_($i) + $game_duration_] "puts end_FPS_uplink_$i"

				}
				set begin_moment_each_car_($i) $prediction_moment_each_car_($i)

			} else {	;# the value of the argument is "random", i.e. the game begins in a random moment while the car is under coverage
				
				# begins in the random moment we have just calculated
				$ns_ at $begin_moment_each_car_($i) "$fps_up_($i) start" ;# the car begins the transmission of a FPS flow to the server
				$ns_ at $begin_moment_each_car_($i) "puts begin_FPS_uplink_$i"

				# ends when the game ends
				$ns_ at [expr $begin_moment_each_car_($i) + $game_duration_] "$fps_up_($i) stop" ;# the car begins the transmission of a FPS flow to the server
				$ns_ at [expr $begin_moment_each_car_($i) + $game_duration_] "puts end_FPS_uplink_$i"
			}
		}
	}
}



################################################################################################
################### calculation of output files ################################################
################### Functions To record Statistcis #############################################

############## bitrate of each voip and FPS flow car-to-server ################



#### first call to the procedure for bitrate of voip and FPS uplink and downlink
for {set i 1} { $i < $val(nn) } { incr i } {

	# Schedule VoIP bps-car-server_ uplink
	if {$voip_up_mask_($i) == 1} {
		set file_name_ [concat $folder_output_name_/bps_voip_uplink_car_ ]
		append file_name_ "$i"
		append file_name_ ".txt"
		set salida_voip_up_ [open $file_name_ w]
		$ns_ at 0.0 "bps-car-server_ $udp_voip_up_($i) $udp_voip_up_receiver_($i) $salida_voip_up_ $tick_interval_"

	}
	# Schedule VoIP bps-car-server_ downlink
	if {$voip_down_mask_($i) == 1} {
		set file_name_ [concat $folder_output_name_/bps_voip_downlink_car_ ]
		append file_name_ "$i"
		append file_name_ ".txt"
		set salida_voip_down_ [open $file_name_ w]
		$ns_ at 0.0 "bps-car-server_ $udp_voip_down_($i) $udp_voip_down_receiver_($i) $salida_voip_down_ $tick_interval_"
	}
	# Schedule FPS bps-car-server_ uplink
	if {$fps_up_mask_($i) == 1} {
		set file_name_ [concat $folder_output_name_/bps_fps_uplink_car_ ]
		append file_name_ "$i"
		append file_name_ ".txt"
		set salida_fps_up_ [open $file_name_ w]
		$ns_ at 0.0 "bps-car-server_ $udp_fps_up_($i) $udp_fps_up_receiver_($i) $salida_fps_up_ $tick_interval_"

	}
	# Schedule FPS bps-car-server_ downlink
	if {$fps_down_mask_($i) == 1} {
		set file_name_ [concat $folder_output_name_/bps_fps_downlink_car_ ]
		append file_name_ "$i"
		append file_name_ ".txt"
		set salida_fps_down_ [open $file_name_ w]
		$ns_ at 0.0 "bps-car-server_ $udp_fps_down_($i) $udp_fps_down_receiver_($i) $salida_fps_down_ $tick_interval_"
	}
}



##########################################################################################
############## packet loss and average inter-packet time delay of voip ###################

for {set i 1} { $i < $val(nn) } { incr i } {
	set holdseq_up_($i) 0		;#number of sequence of the last packet in the previous tick interval
	set holdtime_up_($i) 0		;#time of reception of the last packet in the previous tick interval
}



#### first call to the procedure for loss and delay of voip uplink and downlink
for {set i 1} { $i < $val(nn) } { incr i } {

	# Schedule delay-car-server_
	if {$voip_up_mask_($i) == 1} {
		set file_name_ [concat $folder_output_name_/loss_prob_voip_uplink_car_ ]
		append file_name_ "$i"
		append file_name_ ".txt"
		set loss_out_up_ [open $file_name_ w]

		set file_name_ [concat $folder_output_name_/inter_packet_time_voip_uplink_car_ ]
		append file_name_ "$i"
		append file_name_ ".txt"
		set delay_out_up_ [open $file_name_ w]

		$ns_ at 0.0 "loss-delay-car-server_ $i $udp_voip_up_($i) $udp_voip_up_receiver_($i) $loss_out_up_ $delay_out_up_ $tick_interval_ holdtime_up_ holdseq_up_"  
	}
}


$ns_ at $simulation_duration_ "$ns_ halt"

$ns_ run
puts "Simulation end"

#### Calculate and write the results in files

# I call some procedures which calculate the FPS results from the traces. The simulation is finished by now
if { $obtain_fps_results_ == 1 } {
	write_file_for_calculating_fps_results_					;# from the trace, for each car it creates a file, with the departure and arrival time of each packet
	calculate_fps_delay_jitter_loss_mos_ $tick_interval_	;# from the previous files, for each car, it extracts delay, jitter, loss and MOS for every tick
	calculate_summary_fps_all_cars_							;# from the previous files, it creates one single file with a line summarizing the results of each car
}

# I call some procedures which calculate the FTP results from the traces. The simulation is finished by now
if { ($obtain_ftp_up_results_ == 1) || ($obtain_ftp_down_results_ == 1) } {
	write_file_for_calculating_ftp_results_				;# from the trace, for each car it creates a file, with the departure and arrival time of each packet
	calculate_ftp_throughput_ $tick_interval_			;# from the previous files, for each car, it extracts delay, jitter, loss and MOS for every tick
	#calculate_summary_ftp_all_cars_					;# from the previous files, it creates one single file with a line summarizing the results of each car
}

# I call some procedures to write the predictions of connection time, and the moment in which they are available
if { $argument7 != "all_time" } {
	write_connection_time_predictions_
}

# I remove the file with the whole trace if selected
if { $remove_intermediate_files_ == 1 } {
	cd ./$folder_output_name_

	exec rm cars_street.tr

	if { $obtain_fps_results_ == 1 } {
		exec rm cars_street_fps_up_sent.tr
		exec rm cars_street_fps_up_received.tr
		exec rm cars_street_fps_down_sent.tr
		exec rm cars_street_fps_down_received.tr
	}

	if { $obtain_ftp_up_results_ == 1 } {
		exec rm cars_street_ftp_up_sent.tr
		exec rm cars_street_ftp_up_received.tr
	}

	if { $obtain_ftp_down_results_ == 1 } {
		exec rm cars_street_ftp_down_sent.tr
		exec rm cars_street_ftp_down_received.tr
	}

	cd ..
}

stop