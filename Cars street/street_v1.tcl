#set the required parameters for the VANET wireless 				#
#################################################################################
Antenna/OmniAntenna set X_ 100	;						#
Antenna/OmniAntenna set Y_ 10	;						#
Antenna/OmniAntenna set Z_ 1.51	;						#	
Antenna/OmniAntenna set Gt_ 1.0	;						#	
Antenna/OmniAntenna set Gr_ 1.0	;						#
Phy/WirelessPhy set CPThresh_ 10.0	;					#
Phy/WirelessPhy set CSThresh_ 1.559e-11	;					#
Phy/WirelessPhy set RXThresh_ 3.61705e-09	;				#
Phy/WirelessPhy set bandwidth_ 2e6		;				#	
Phy/WirelessPhy set Pt_ 0.2818			;				#
Phy/WirelessPhy set freq_ 5.90e+9		;				#
Phy/WirelessPhy set L_ 1.0			;				#
										#
# ====================================================================== 
# Define options 
# ====================================================================== 
set val(chan)         Channel/WirelessChannel  ;# channel type 
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model 
set val(ant)          Antenna/OmniAntenna      ;# Antenna type 
set val(ll)           LL                       ;# Link layer type 
set val(ifq)          Queue/DropTail/PriQueue  ;# Interface queue type 
set val(ifqlen)       50                       ;# max packet in ifq 
set val(netif)        Phy/WirelessPhy          ;# network interface type 
set val(mac)          Mac/802_11               ;# MAC type 
set val(rp)           DSDV                     ;# ad-hoc routing protocol  
set val(nn)           1                        ;# number of mobilenodes 


# Create simulator
set ns_    [new Simulator]
 
# Set up trace file
$ns_ use-newtrace
set tracefd [open simple.tr w]
$ns_ trace-all $tracefd
 
# Create the "general operations director"
# Used internally by MAC layer: must create!
create-god $val(nn)
 

# Create and configure topography (used for mobile scenarios)
set topo [new Topography]
# 200x10m terrain
$topo load_flatgrid 200 10

# create channel variable
set chan [new $val(chan)]

$ns_ node-config -adhocRouting $val(rp) \
         -llType $val(ll) \
         -macType $val(mac) \
         -ifqType $val(ifq) \
         -ifqLen $val(ifqlen) \
         -antType $val(ant) \
         -propType $val(prop) \
         -phyType $val(netif) \
         -channel $chan \
         -topoInstance $topo \
         -agentTrace ON \
         -routerTrace ON \
         -macTrace OFF \
         -movementTrace ON	;# JMS puts this to ON
 
for {set i 0} {$i < $val(nn) } {incr i} {
         set node_($i) [$ns_ node]       
         $node_($i) random-motion 0              ;# JMS enable/disable random motion
}

$node_(0) set X_ 0.0
$node_(0) set Y_ 0.0
$node_(0) set Z_ 0.0

#$god_ set-dist 0 1 2

$ns_ at 0.0 "$node_(0) setdest 199.99 0.001 13.9" ;# Si pones algo que limita con el borde, no funciona (0.0, 200.0, etc)
#$ns_ at 5.0 "$node_(1) setdest 200.0 0.0 0.0" ;#JMS adds this
#$node_(1) at 5.0 setdest 200.0 0.0 0.0			;#JMS adds this

$node_(0) start ;# JMS This makes the random motion start at 0.0
$node_(1) start
#$ns_ at 99 "$node_(0) start" ;# JMS Según si pones 99 o 99.0 o 50 o 50.0 funciona o no. Es muy raro. Quizá lo mejor sea que se empiece a mover en 0.0


#$node_(0) set X_ 0.0	;#JMS If the random movement is active, then you should avoid this
#$node_(1) set X_ 200.0
#$node_(2) set X_ 400.0
#$node_(3) set X_ 600.0
#$node_(4) set X_ 800.0
 

# 1500 - 20 byte IP header - 40 byte TCP header = 1440 bytes
Agent/TCP set packetSize_ 1440 ;# This size EXCLUDES the TCP header
 
set agent [new Agent/TCP]
set app [new Application/FTP]
set sink [new Agent/TCPSink]
 
$app attach-agent $agent
 
$ns_ attach-agent $node_(0) $agent
$ns_ attach-agent $node_(1) $sink
$ns_ connect $agent $sink


# 30 seconds of warmup time for routing
$ns_ at 0.0 "$app start"
# 60 seconds of running the simulation time
$ns_ at 120.0 "$ns_ halt"
$ns_ run
 
$ns_ flush-trace
close $tracefd
 