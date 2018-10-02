# Copyright (c) 1997 Regents of the University of California.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed by the Computer Systems
#      Engineering Group at Lawrence Berkeley Laboratory.
# 4. Neither the name of the University nor of the Laboratory may be used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# wireless2.tcl
# simulation of a wired-cum-wireless scenario consisting of 2 wired nodes
# connected to a wireless domain through a base-station node.
# http://www.isi.edu/nsnam/ns/tutorial/nsscript6.html

set car_speed_kph_ 1.0
set car_speed_mps_ [expr $car_speed_kph_ * 1000.0 / 3600.0]
set seconds_between_cars_ 30.0
set number_of_cars_ 3
set street_length_ 200.0						;# street length in meters
set street_width_ 10.0							;# street width in meters
set initial_time_ 20.0							;# time in which the first car appears at the beginning of the street
set final_time_ 3.0								;# simulation time after the last car dissapears
set base_station_X_ [expr $street_length_ / 2]	;# X coordinates of the base station. In the middle of the street
set base_station_Y_ 10.0						;# Y coordinates of the base station. In one side of the street (the minimum distance with each car are 10m)

set wifi_rate_ "11Mb"	;# Data Rate in Mbps: 1, 2, 5.5, 11

set duration_ 200
# the duration is the sum of:
#	- initial time
#	- the number of cars * the time between cars
#	- the time a car spends for going through the whole street
#	- final time
#set duration_ [expr $initial_time_ + ( $number_of_cars_ * $seconds_between_cars_ ) + ( $street_length_ / $car_speed_mps_ ) + $final_time_ ]

puts "simulation duration: $duration_ seconds"

#### Tick interval for obtaining output parameters: TCP window size, queuing size, throughput etc
set tick_interval_ 1

#### This is the folder where these data will be stored. It is a subfolder of the current folder
set folder_other_output_name_ street_output_files

#### Select the flows to send
set ftp_uplink_ 0		;# if this is set to 1, each car establishes an FTP upload connection with the server W(0)
set ftp_downlink_ 0		;# if this is set to 1, each car establishes an FTP download connection with the server W(0)
set voip_uplink_ 1		;# if this is set to 1, each car establishes an VoIP upload connection with the server W(0)
set fps_uplink_ 0		;# if this is set to 1, each car establishes an FPS upload connection with the server W(0)

set trace_format_ 0		;# 0 means old format; 1 means new (wireless) format

######################### Antenna settings #########################################
Antenna/OmniAntenna set X_ $base_station_X_		;# X position of the antenna of the base station
Antenna/OmniAntenna set Y_ $base_station_Y_		;# Y position of the antenna of the base station
Antenna/OmniAntenna set Z_ 1.51					;# Z position of the antenna of the base station	
Antenna/OmniAntenna set Gt_ 1					;# Transmit antenna gain
Antenna/OmniAntenna set Gr_ 1					;# Receive antenna gain

######################### Phy/WirelessPhy settings ######################################
Phy/WirelessPhy set L_ 1.0						;# System Loss Factor
Phy/WirelessPhy set freq_ 2.472e9				;# channel-13. 2.472GHz
Phy/WirelessPhy set bandwidth_ "$wifi_rate_"	;# Data Rate
Phy/WirelessPhy set Pt_ 0.031622777				;# Transmit Power (15dBm)
Phy/WirelessPhy set CPThresh_ 10.0				;# Collision Threshold
Phy/WirelessPhy set CSThresh_ 3.1622777e-14		;# Carrier Sense Power (-94dBm);
Phy/WirelessPhy set RXThresh_ 1.15126e-10		;# Receive Power Threshold for 160m, for using with two ray ground

######################### Mac/802_11 settings #########################################
Mac/802_11 set dataRate_ "$wifi_rate_"			;# Rate for Data Frames
Mac/802_11 set basicRate_ "$wifi_rate_"			;# Rate for Control Frames

########################### Set options to use ##########################################
set opt(chan)           Channel/WirelessChannel    ;# channel type

set opt(prop)			Propagation/TwoRayGround   ;# radio-propagation model
#set opt(prop)			Propagation/Ricean			;# radio-propagation model.  !!! NOT WORKING
#set opt(prop)			Propagation/Shadowing		;# radio-propagation model. It is suitable for indoor scenarios

set opt(netif)          Phy/WirelessPhy            ;# network interface type
set opt(mac)            Mac/802_11                 ;# MAC type
set opt(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set opt(ll)             LL                         ;# link layer type
set opt(ant)            Antenna/OmniAntenna        ;# antenna model
set opt(ifqlen)         50                         ;# max packet in ifq
set opt(nn)             $number_of_cars_           ;# number of mobilenodes
#set opt(adhocRouting)   DSDV                       ;# routing protocol
set opt(adhocRouting)   AODV                       ;# routing protocol
#set opt(adhocRouting)   MDART						;# routing protocol

set opt(cp)             ""                         ;# connection pattern file		!!!!!!!!!!!!!!!!!!!!!
set opt(sc)				"./car_movements.tcl"	   ;# node movement file. 

set opt(x)				$street_length_				;# x size of topology
set opt(y)				$street_width_				;# y size of topology
set opt(seed)			0.0							;# seed for random number gen.
set opt(stop)			$duration_					;# time to stop simulation

set num_wired_nodes      2
set num_bs_nodes         1

#################################################################################
#parameters from http://mailman.isi.edu/pipermail/ns-users/2007-July/060671.html

#Phy/WirelessPhy set freq_ 2.4e9
#Phy/WirelessPhy set L_ 1.0
#Phy/WirelessPhy set Pt_ 1.838e-5  ;#power needed to have 240m of distance
#Phy/WirelessPhy set RXThresh_ 3.16e-14
#Phy/WirelessPhy set CSThresh_ 3.16e-14   ;#Sensivity=-105 dbm
#Phy/WirelessPhy set CPThresh_ 10

#################################################################################
# parameters from http://cir.nus.edu.sg/reactivetcp/report/80211ChannelinNS2_new.pdf (Simulate 802.11b Channel within NS2)
# This is for indoor use

#Antenna/OmniAntenna set Gt_ 1 ;# Transmit antenna gain
#Antenna/OmniAntenna set Gr_ 1 ;# Receive antenna gain
#Phy/WirelessPhy set L_ 1.0 ;# System Loss Factor
#Phy/WirelessPhy set freq_ 2.472e9 ;# channel-13. 2.472GHz
#ErrorModel80211 noise1_ -104
#ErrorModel80211 noise2_ -101
#ErrorModel80211 noise55_ -97
#ErrorModel80211 noise11_ -92
#ErrorModel80211 shortpreamble_ 1
#The propagation model is Shadowing model.
#Propagation/Shadowing set pathlossExp_ 4
#Propagation/Shadowing set std_db_ 0
#Phy/WirelessPhy set bandwidth_ 11Mb ;# Data Rate
#Phy/WirelessPhy set Pt_ 0.031622777 ;# Transmit Power (15dBm)
#Phy/WirelessPhy set CPThresh_ 10.0 ;# Collision Threshold
#Phy/WirelessPhy set CSThresh_ 3.1622777e-14 ;# Carrier Sense Power (-94dBm);
#Phy/WirelessPhy set RXThresh_ 3.1622777e-13 ;# Receive Power Threshold;
#Mac/802_11 set dataRate_ 11Mb ;# Rate for Data Frames
#Mac/802_11 set basicRate_ 2Mb ;# Rate for Control Frames

#################################################################################

# ============================================================================
# check for boundary parameters and random seed
if { $opt(x) == 0 || $opt(y) == 0 } {
	puts "No X-Y boundary values given for wireless topology\n"
}
if {$opt(seed) > 0} {
	puts "Seeding Random number generator with $opt(seed)\n"
	ns-random $opt(seed)
}

# create simulator instance
set ns_ [new Simulator]

############# set up for hierarchical routing
$ns_ node-config -addressType hierarchical		;# the topology is defined into a 3-level hierarchy 
AddrParams set domain_num_ 2					;# number of domains. one for the wired nodes and one for the wireless
lappend cluster_num 2 1							;# number of clusters in each domain. is defined as "2 1" which indicates the first domain (wired) to have 2 clusters and the second (wireless) to have 1 cluster
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 1 1 [expr $opt(nn) + 1 ]	;# number of nodes in each of these clusters which is "1 1 4"; i.e one node in each of the first 2 clusters (in wired domain) and 4 nodes in the cluster in the wireless domain
AddrParams set nodes_num_ $eilastlevel

###################### trace file ######################

if { $trace_format_ == 1 } {
	$ns_ use-newtrace	;# use new trace format. If you comment this line, only wired traces appear. http://nsnam.isi.edu/nsnam/index.php/NS-2_Trace_Formats#New_Wireless_Trace_Formats
}
set tracefd  [open [concat $folder_other_output_name_/wireless2-out.tr] w]
$ns_ trace-all $tracefd

# nam trace
#set namtrace [open wireless2-out.nam w]
#$ns_ namtrace-all-wireless $namtrace $opt(x) $opt(y)

# Create topography object
set topo [new Topography]

# define topology
$topo load_flatgrid $opt(x) $opt(y)

# create God
create-god [expr $opt(nn) + $num_bs_nodes]

##################################### create wired nodes ###############################################
# the node-ids are created internally by the simulator and are assigned in the order of node creation
set temp {0.0.0 0.1.0}        ;# hierarchical addresses for wired domain
for {set i 0} {$i < $num_wired_nodes} {incr i} {
    set W($i) [$ns_ node [lindex $temp $i]]			;# JMS al nodo W(0) se le asigna la dir 0.0.0, y al nodo W(1) la dir 0.1.0
													# The two wired nodes are placed in 2 separate clusters
													# node 0 address: 0(domain 0).0(cluster 0).0(only node)
													# node 1 address: 0(domain 0).1(cluster 1).0(only node)
}

# configure for base-station node
# base-station nodes are gateways between wired and wireless domains
# they need to have wired routing mechanism turned on which is done by
# setting node-config option -wiredRouting ON

$ns_ node-config -addressType hierarchical \
				 -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop) \
                 -phyType $opt(netif) \
                 -channelType $opt(chan) \
				 -topoInstance $topo \
                 -wiredRouting ON \
				 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace OFF 
# the wireless nodes are in domain 1; we have defined one cluster (0), so all nodes are in this cluster
# Base-station: 1(second domain,1).0(cluster 0).0(first node in cluster) 1.0.0
# WL node#1 : 1.0.1(second node in cluster) 
# WL node#2 : 1.0.2(third node) 
# WL node#3 : 1.0.3(fourth node)

# create hierarchical addresses to be used for wireless domain (one for base station and one for each car)
#set temp {1.0.0 1.0.1 1.0.2 1.0.3} ;# this is valid for one base station and three cars

# if the number of cars is variable
set temp {1.0.0}							;# the address of the base station
for {set j 0} {$j < $opt(nn)} {incr j} {	;# for each car
	append temp " 1.0."						;# the first part of the address for each car
	append temp [expr $j + 1]				;# the last number of the address for each car
}

################################# create base-station node #######################################################
set BS(0) [$ns_ node [lindex $temp 0]]	;# JMS BS(0) es la estación base. Le asigno la dirección 1.0.0 (temp(0) )
$BS(0) random-motion 0					;# disable random motion

#provide some co-ord (fixed) to base station node
$BS(0) set X_ $base_station_X_ 
$BS(0) set Y_ $base_station_Y_
$BS(0) set Z_ 0.0

# create mobilenodes in the same domain as BS(0)  
# note the position and movement of mobilenodes is as defined in $opt(sc)

#configure for mobilenodes
$ns_ node-config -wiredRouting OFF	;# After creating the base-station node, we reconfigure for the rest of wireless nodes and so turn wiredRouting OFF

for {set j 0} {$j < $opt(nn)} {incr j} {								;# este bucle no incluye la estación base
    set node_($j) [ $ns_ node [lindex $temp [expr $j + 1]] ]			;# node_(0) es el primer nodo móvil. Le asigno la dirección 1.0.1 (temp(1) )
	$node_($j) base-station [AddrParams addr2id [$BS(0) node-addr]]		;# the BS(0) node is assigned as the base-station node for all the mobilenodes in the wireless domain, so that all pkts originating from mobilenodes and destined outside the wireless domain, will be forwarded by mobilenodes towards their assigned base-station
}

############################# Wired network definition #################################
#			wired		wired			wireless
#	W(0) --------- W(1) ---------- BS(0) - - - - -	node_(0)
#										 \ - - - -	node_(1)
#											\
#											  - - - node_(num_cars_)
#

#### create link between the two wired nodes
$ns_ duplex-link $W(0) $W(1) 100Mb 1ms DropTail
$ns_ queue-limit $W(0) $W(1) 50

#### create link between BS and first wired node
# uplink
$ns_ simplex-link $BS(0) $W(1) 100Mb 20ms DropTail
set uplink_buffer_ [[$ns_ link $BS(0) $W(1) ] queue]
$uplink_buffer_ set limit_ 50						;# buffer size in packets
#$ns_ queue-limit $BS(0) $W(1) 50					;# another alternative for setting the queue size

set qmon [$ns_ monitor-queue $BS(0) $W(1) ""]
set integ [$qmon get-bytes-integrator]

# downlink
$ns_ simplex-link $W(1) $BS(0) 100Mb 2ms DropTail
set downlink_buffer_ [[$ns_ link $W(1) $BS(0) ] queue]
$downlink_buffer_ set limit_ 50						;# buffer size in packets


############################## setup TCP connections ##################################
#### TCP connections for uplink FTP
for {set j 0} {$j < $opt(nn)} {incr j} {	;# the mobile nodes upload FTP traffic to the fixed network
	set tcp_source_car_server_($j) [new Agent/TCP/Sack1]
	#$tcp_source_car_server_($j) set class_ 2
	set sink1_($j) [new Agent/TCPSink]
	$ns_ attach-agent $node_($j) $tcp_source_car_server_($j)	;# attach the TCP source to each car
	$ns_ attach-agent $W(0) $sink1_($j)

	set tcp_connection_car_server_($j) [$ns_ connect $tcp_source_car_server_($j) $sink1_($j)]
	$tcp_connection_car_server_($j) set overhead_ 0
	$tcp_connection_car_server_($j) set window_ 10	;# !!!!!!!!!!!!!!!!!!!!!!!!

	# FTP uplink application
	set ftp1_($j) [$tcp_connection_car_server_($j) attach-app FTP]
	#set ftp1_($j) [new Application/FTP]					;# alternative definition of the application
	#$ftp1_($j) attach-agent $tcp_source_car_server_($j)

	if {$ftp_uplink_ == 1} {
		$ns_ at [expr $initial_time_ + ( $j * $seconds_between_cars_ ) ] "$ftp1_($j) start" ;# JMS el node_($j) (móvil) comienza a enviar tráfico FTP al nodo W(0) (fijo)
	}
}

#### TCP connections for downlink FTP
for {set j 0} {$j < $opt(nn)} {incr j} {	;# the mobile nodes download FTP traffic from the fixed network
	set tcp_source_server_car_($j) [new Agent/TCP/Sack1]
	$tcp_source_server_car_($j) set class_ 2
	$tcp_source_server_car_($j) set packetSize_ 1440
	set sink2_($j) [new Agent/TCPSink]
	$ns_ attach-agent $W(0) $tcp_source_server_car_($j)
	$ns_ attach-agent $node_($j) $sink2_($j)
	$ns_ connect $tcp_source_server_car_($j) $sink2_($j)

	# FTP downlink application
	set ftp2_($j) [new Application/FTP]
	$ftp2_($j) attach-agent $tcp_source_server_car_($j)
	if {$ftp_downlink_ == 1} {
		$ns_ at [expr $initial_time_ + ( $j * $seconds_between_cars_ ) ] "$ftp2_($j) start" ;# JMS el nodo W(1) empieza a mandar tráfico FTP al node_(2) (móvil)
	}
}

#################### UDP Connections #################
#### VoIP uplink flow
for {set j 0} {$j < $opt(nn)} {incr j} {	;# each car sends a flow to the server in W(0)
	# UDP connection from a car to a server in W(0)
	set udp_voip_($j) [new Agent/UDP]
	$ns_ attach-agent $node_($j) $udp_voip_($j)
	set udp_voip_receiver_($j) [new Agent/LossMonitor]
	$ns_ attach-agent $W(0) $udp_voip_receiver_($j)
	$ns_ connect $udp_voip_($j) $udp_voip_receiver_($j)
	$udp_voip_($j) set fid_ 2								;# for distinguishing the flows

	# CBR application
	set voip_($j) [new Application/Traffic/CBR]
	$voip_($j) attach-agent $udp_voip_($j)
	$voip_($j) set packetSize_ 60			;# this is the payload (20 bytes) plus the RTP/UDP/IP headers (40 bytes)
	$voip_($j) set interval_ 0.020			;# a packet every 20 ms
	$voip_($j) set random_ 0				;# it does not introduce a random time between different sending times
	if {$voip_uplink_ == 1} {
		$ns_ at [expr $initial_time_ + ( $j * $seconds_between_cars_ ) ] "$voip_($j) start" ;# the car begins the transmission of a VoIP flow to the server
	}
}


#################################################################################
#### Quake IV FPS uplink flow
for {set j 0} {$j < $opt(nn)} {incr j} {	;# each car sends a flow to the server in W(0)
	# UDP connection from a car to a server in W(0)
	set udp_fps_($j) [new Agent/UDP]
	$ns_ attach-agent $node_($j) $udp_fps_($j)
	set udp_fps_receiver_($j) [new Agent/Null]
	$ns_ attach-agent $W(0) $udp_fps_receiver_($j)
	$ns_ connect $udp_fps_($j) $udp_fps_receiver_($j)
	$udp_fps_($j) set fid_ 3

	# Application based on a binary trace file
	set fps_tracefile_($j) [new Tracefile]
	#$fps_tracefile_($j) filename H263_var_Mobilkom1.bin
	$fps_tracefile_($j) filename q.if-0.bin			;########## binary file in which traffic traces are
	set fps_($j) [new Application/Traffic/Trace]
	$fps_($j) attach-agent $udp_fps_($j)
	$fps_($j) attach-tracefile $fps_tracefile_($j)
	if {$fps_uplink_ == 1} {
		$ns_ at [expr $initial_time_ + ( $j * $seconds_between_cars_ ) ] "$fps_($j) start" ;# the car begins the transmission of a FPS flow to the server
	}
}

# source connection-pattern and node-movement scripts
if { $opt(cp) == "" } {
	puts "*** NOTE: no connection pattern specified."
        set opt(cp) "none"
} else {
	puts "Loading connection pattern..."
	source $opt(cp)
}
if { $opt(sc) == "" } {
	puts "*** NOTE: no scenario file specified."
        set opt(sc) "none"
} else {
	puts "Loading scenario file..."
	source $opt(sc)
	puts "Load complete..."
}

# Tell all nodes when the simulation ends
for {set i } {$i < $opt(nn) } {incr i} {
    $ns_ at $opt(stop).0 "$node_($i) reset";
}
$ns_ at $opt(stop).0 "$BS(0) reset";

#### for each car, I calculate the throughput of the traffic arrived to the base station, using a perl script. The first car is called "car1"
for {set i 0} {$i < $opt(nn)} {incr i} {
	# BS(0) is node 2
	# W(0) is node 1
	# the address of the first car (car1) is 1.0.1.0 (it means 1.0.1, connection 0 of the car)
	# the address of the BS for the connection with the first car is 0.0.0.0 (it means 0.0.0, connection 0 of the BS)
	# the address of the second car (car2) is 1.0.2.0 (it means 1.0.2, connection 0 of the car)
	# the address of the BS for the connection with the second car is 0.0.0.1 (it means 0.0.0, connection 1 of the BS)
	# and so on

	if {$ftp_uplink_ == 1} {
		# tcp traffic from the car (1.0.i+1.0) to the base station (0.0.0.i)
		$ns_ at $opt(stop).0 "exec perl throughput_wired_v1.pl [concat $folder_other_output_name_/wireless2-out.tr] 2 1   1.0.[expr $i + 1].0   0.0.0.[expr $i]   $tick_interval_ tcp > $folder_other_output_name_/throughput_uplink_tcp_car[expr $i + 1]_to_bs.txt";
		
		# ack traffic from the base station (0.0.0.i) to the car (1.0.i+1.0)
		$ns_ at $opt(stop).0 "exec perl throughput_wired_v1.pl [concat $folder_other_output_name_/wireless2-out.tr] 1 2   0.0.0.[expr $i]   1.0.[expr $i + 1].0   $tick_interval_ ack > $folder_other_output_name_/throughput_downlink_ack_bs_to_car[expr $i + 1].txt";
	}

	if {$voip_uplink_ == 1} {
		# voip traffic from the car (1.0.i+1.2) to the base station (0.0.0. 2*nun_car + i)
		$ns_ at $opt(stop).0 "exec perl throughput_wired_v1.pl [concat $folder_other_output_name_/wireless2-out.tr] 2 1   1.0.[expr $i + 1].2   0.0.0.[expr (2 * $opt(nn)) + $i]   $tick_interval_ cbr > $folder_other_output_name_/throughput_uplink_voip_car[expr $i + 1]_to_bs.txt";
	}

	if {$fps_uplink_ == 1} {
		# fps traffic from the car (1.0.i+1.3) to the base station (0.0.0. 3*num_car + i)
		$ns_ at $opt(stop).0 "exec perl throughput_wired_v1.pl [concat $folder_other_output_name_/wireless2-out.tr] 2 1   1.0.[expr $i + 1].3   0.0.0.[expr (3 * $opt(nn)) + $i]   $tick_interval_ udp > $folder_other_output_name_/throughput_uplink_fps_car[expr $i + 1]_to_bs.txt";
	}

	# the address of the first car (car1) is 1.0.1.1 (it means 1.0.1, connection 1 of the car)
	# the address of the BS for the connection with the first car is 0.0.0.3 (it means 0.0.0, connection 3 of the BS. It is $opt(nn)+$i)
	# the address of the second car (car2) is 1.0.2.1 (it means 1.0.2, connection 1 of the car)
	# the address of the BS for the connection with the second car is 0.0.0.4 (it means 0.0.0, connection 4 of the BS)
	# and so on

	if {$ftp_downlink_ == 1} {
		# tcp traffic from the base station (0.0.0.num_car+i) to the car (1.0.i+1.1)
		$ns_ at $opt(stop).0 "exec perl throughput_wired_v1.pl [concat $folder_other_output_name_/wireless2-out.tr] 1 2   0.0.0.[expr $opt(nn)+$i]   1.0.[expr $i + 1].1   $tick_interval_ tcp > $folder_other_output_name_/throughput_downlink_tcp_bs_to_car[expr $i + 1].txt";
		# ack traffic from the car (1.0.i+1.1) to the base station (0.0.0.num_car+i)
		$ns_ at $opt(stop).0 "exec perl throughput_wired_v1.pl [concat $folder_other_output_name_/wireless2-out.tr] 2 1   1.0.[expr $i + 1].1   0.0.0.[expr $opt(nn)+$i]   $tick_interval_ ack > $folder_other_output_name_/throughput_uplink_ack_car[expr $i + 1]_to_bs.txt";
	}
}

$ns_ at $opt(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"
$ns_ at $opt(stop).0001 "stop"

proc stop {} {
    global ns_ tracefd ;#namtrace
#    $ns_ flush-trace
    close $tracefd
    #close $namtrace

}

# informative headers for the beginning of the Tracefile
puts $tracefd "M 0.0 nn $opt(nn) x $opt(x) y $opt(y) rp \
	$opt(adhocRouting)"
puts $tracefd "M 0.0 sc $opt(sc) cp $opt(cp) seed $opt(seed)"
puts $tracefd "M 0.0 prop $opt(prop) ant $opt(ant)"


########## Creating output files ########

file mkdir $folder_other_output_name_

#### Queuing delay of the uplink between BS and W(1)

# Save to a file the queueing delay on link every "interval" of simulation time.
proc plot_queuing { link interval outfile} {
	global ns_ integ
	$ns_ at [expr [$ns_ now] + $interval] "plot_queuing $link $interval $outfile"
	set delay [expr 8 * [$integ set sum_] / [[$link link] set bandwidth_]]
	puts $outfile "[$ns_ now]\t$delay"
}

#Generate a file with the queuing delay between BS and W(1) (bottleneck)
set file_name_ [concat $folder_other_output_name_/queuing_delay_seconds_uplink_.txt ]
set file_queue_delay_ [open $file_name_ w]
$ns_ at 0.0 "plot_queuing [$ns_ link $BS(0) $W(1)] $tick_interval_ $file_queue_delay_"


#### Queuing size of the uplink between BS and W(1)

set size_bytes_acum_ 0
# Save to a file the queueing size on link every "interval" of simulation time.
proc plot_queuing_size { link interval outfile} {
	global ns_ integ size_bytes_acum_
	$ns_ at [expr [$ns_ now] + $interval] "plot_queuing_size $link $interval $outfile"
	set size_bytes_ [$integ set sum_]
	#set size_packets_ [$integ set pkts_]
	set size_packets_ 0

	puts $outfile "[$ns_ now]\t[expr $size_bytes_ - $size_bytes_acum_]\t$size_packets_"
	#Reset Variables
	set size_bytes_acum_ $size_bytes_
}

#Generate a file with the queuing size between BS and W(1) (bottleneck)
set file_name_ [concat $folder_other_output_name_/queuing_size_bytes_packets_uplink_.txt ]
set file_queue_size_ [open $file_name_ w]
$ns_ at 0.0 "plot_queuing_size [$ns_ link $BS(0) $W(1)] $tick_interval_ $file_queue_size_"


########## Window size info storing ######################

#procedure obtain tcp window size every "interval" sec
proc plot_window {tcpSource outfile interval} {
	global ns_ ;# global variables used in this procedure
	set now [$ns_ now]
	set cwnd [$tcpSource set cwnd_]
	puts $outfile "$now\t$cwnd"
	$ns_ at [expr $now + $interval] "plot_window $tcpSource $outfile $interval"
}

#Generate a file with the uplink window size of each connection
for {set i 0} { $i < $opt(nn) } { incr i } {
	if {$ftp_uplink_ == 1} {
		set file_name_ [concat $folder_other_output_name_/window_size_uplink_car_ ]
		append file_name_ "[expr $i +1 ]"
		append file_name_ ".txt"
		set window_size [open $file_name_ w]
		$ns_ at 0.0 "plot_window $tcp_source_car_server_($i) $window_size $tick_interval_"
	}
} 

#Generate a file with the downlink window size of each connection
for {set i 0} { $i < $opt(nn) } { incr i } {
	if {$ftp_downlink_ == 1} {
		set file_name_ [concat $folder_other_output_name_/window_size_downlink_car_ ]
		append file_name_ "[expr $i +1 ]"
		append file_name_ ".txt"
		set window_size [open $file_name_ w]
		$ns_ at 0.0 "plot_window $tcp_source_server_car_($i) $window_size $tick_interval_"
	}
} 

#################### Functions To record Statistcis of VoIP traffic (Bit Rate, Delay, Drop) #######################
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
}

# Output file with the bitrate of each voip flow car-to-server
for {set i 0} { $i < $opt(nn) } { incr i } {
	set file_name_ [concat $folder_other_output_name_/bps_voip_server_receives_car_ ]
	append file_name_ "[expr $i +1 ]"
	append file_name_ ".txt"
	set salida [open $file_name_ w]

	# Schedule bps-car-server_ 
	$ns_ at 0.0 "bps-car-server_ $udp_fps_($i) $udp_voip_receiver_($i) $salida $tick_interval_"  
}

#######################################################################################################33

for {set i 0} { $i < $opt(nn) } { incr i } {
	set holdseq_($i) 0		;#number of sequence of the last packet in the previous tick interval
	set holdtime_($i) 0		;#time of reception of the last packet in the previous tick interval
}

# Function to write a file of packet loss and average inter-packet time delay of voip
proc loss-delay-car-server_ { car_ udp_source_ udp_sink_ loss_outfile delay_outfile interval_ holdtime_ holdseq_ args} {
	upvar $holdtime_ holdt_
	upvar $holdseq_ holds_
	global ns_ ;# global variables used in this procedure

	set packets_lost_ [$udp_sink_ set nlost_]
	set packets_received_ [$udp_sink_ set npkts_]
	set last_packet_time_ [$udp_sink_ set lastPktTime_]

    set now [$ns_ now]

	# Record packet loss in trace file
	if { [expr $packets_lost_ + $packets_received_ - $holds_($car_) ] > 0 } {
		puts $loss_outfile "$now\t[expr $packets_lost_ / ( $packets_lost_ + $packets_received_ - $holds_($car_) ) ]" ;#lost in this interval / (lost + totalreceived - received in previous intervals)
	} else {
		puts $loss_outfile "$now\t0"
	}

	# Record delay in Trace Files
	if { $packets_received_ > $holds_($car_) } { ;# some new packet have arrived
		puts $delay_outfile "$now\t[expr ( $last_packet_time_ - $holdt_($car_) ) / ( $packets_received_ - $holds_($car_) ) ]"
	} else {
		# no new packets have arrived
		puts $delay_outfile "$now\t[expr ( $last_packet_time_ - $holdt_($car_))]"
	}

    set holdt_($car_) $last_packet_time_
    set holds_($car_) $packets_received_
	
	# Reset Variables
	$udp_sink_ set nlost_ 0

	# Schedule delay-car-server_ after interval sec
	$ns_ at [expr $now + $interval_] "loss-delay-car-server_ $car_ $udp_source_ $udp_sink_ $loss_outfile $delay_outfile $interval_ holdtime_ holdseq_"   
}

# Output file with the bitrate of each voip flow car-to-server
for {set i 0} { $i < $opt(nn) } { incr i } {

	set file_name_ [concat $folder_other_output_name_/loss_prob_voip_server_receives_car_ ]
	append file_name_ "[expr $i +1 ]"
	append file_name_ ".txt"
	set loss_out [open $file_name_ w]

	set file_name_ [concat $folder_other_output_name_/inter_packet_time_voip_server_receives_car_ ]
	append file_name_ "[expr $i +1 ]"
	append file_name_ ".txt"
	set delay_out [open $file_name_ w]

	# Schedule delay-car-server_ 
	$ns_ at 0.0 "loss-delay-car-server_ $i $udp_fps_($i) $udp_voip_receiver_($i) $loss_out $delay_out $tick_interval_ holdtime_ holdseq_"  
}

############################################
puts "Starting Simulation..."
$ns_ run