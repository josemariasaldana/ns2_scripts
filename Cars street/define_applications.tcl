####################################################################################
proc define_cars_ { cars_ args } {
    global number_of_cars_ number_of_wifi_cars_ uniform_ probability_wifi_ summary_movement_file_ \
			normal_variable_ average_seconds_between_cars_ stdev_seconds_between_cars_ 
	upvar $cars_ carss_

	# use seconds as the seed
	set seed_ 1[lindex [split [lindex [exec date] 3] :] 2]
    set ia_ 9301
    set ic_ 49297
    set im_ 233280
	set seed_  [expr ( ($seed_ * $ia_) + $ic_ ) % $im_]

	# If you want to have always the same behaviour, uncomment this
	#set seed_ 0; #it does not work. Generates different things always

	# Create a random generator and assign it the value of seed_
	set my_random_generator_ [new RNG]
	$my_random_generator_ seed seed_
	
	# A uniformly distributed variable between 0 and 1
	set uniform_ [new RandomVariable/Uniform]
	$uniform_ use-rng $my_random_generator_
	$uniform_ set min_ 0.0
	$uniform_ set max_ 1.0

	set normal_variable_ [new RandomVariable/Normal]
	$normal_variable_ use-rng $my_random_generator_
	$normal_variable_ set avg_ $average_seconds_between_cars_
	$normal_variable_ set std_ $stdev_seconds_between_cars_

	for {set i 1} {$i <= $number_of_cars_} {incr i} {
		set probability_ [$uniform_ value]

		if { $probability_ < $probability_wifi_ } {
			set number_of_wifi_cars_ [expr $number_of_wifi_cars_ + 1 ]
			set carss_($number_of_wifi_cars_) $i
			puts $summary_movement_file_ "wifi car $number_of_wifi_cars_ departs in position $carss_($number_of_wifi_cars_)"		
		}
	}
}


####################################################################################
proc define_applications_ { mode } {
    global number_of_wifi_cars_ ftp_down_mask_ ftp_up_mask_ voip_down_mask_ voip_up_mask_ fps_down_mask_ fps_up_mask_ \
		ftp_downlink_ ftp_uplink_ voip_downlink_ voip_uplink_ fps_uplink_ fps_downlink_ \
		uniform_ probability_fps_ probability_ftp_up_ probability_ftp_down_ probability_voip_ \
		number_of_cars_

# The numbers correspond to WiFi cars, i.e. if probability of WiFi is 0.5, and you want the car number 100 to use an application, you have to 
#set to 1 that application for car number 50

	#### SETTING ALL APPLICATIONS TO 0 #######
	for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
		set ftp_down_mask_($i) 0	;# if this is set to 0, the car does not establish an FTP download connection with the server 
	}

	for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
		set ftp_up_mask_($i) 0	;# if this is set to 0, the car does not establish an FTP download connection with the server 
	}

	for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
		set voip_down_mask_($i) 0	;# if this is set to 0, the car does not establish a voip download connection with the server 
	}

	for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
		set voip_up_mask_($i) 0	;# if this is set to 0, the car does not establish a voip upload connection with the server 
	}

	for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
		set fps_down_mask_($i) 0	;# if this is set to 0, the car does not establish a fps download connection with the server 
	}

	for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
		set fps_up_mask_($i) 0	;# if this is set to 0, the car does not establish a fps upload connection with the server 
	}


	###### MANUAL SETTING ############# If it is "manual", I can manually set the applications that each wifi car will run
	if {$mode == "manual" } {
		######## Select the flows to send ########
		set ftp_downlink_ -1		;# 1: all cars use the application; -1 no car uses it; 0: individual setting 
		set ftp_uplink_ -1			;############### ATTENTION: FTP uplink results calculation still not implemented ############################################
		set voip_downlink_ -1	
		set voip_uplink_ -1
		set fps_uplink_ 0
		set fps_downlink_ 0

		## individual setting
		######## mask definition for ftp downlink flows ########
		if { $ftp_downlink_ == 1 } {
			for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
				set ftp_down_mask_($i) 1	;# if this is set to 1, the car establishes an FTP download connection with the server 
			}
		} else {
			if { $ftp_downlink_ == 0 } {
				# manual setting for selecting which car sends the traffic
				# first, I put everything to 0
				for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
					set ftp_down_mask_($i) 0
				}
				# and now I put some cars to 1
				set ftp_down_mask_(151) 1
			}
		} 

		######## mask definition for ftp uplink flows ########
		if { $ftp_uplink_ == 1 } {
			for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
				set ftp_up_mask_($i) 1	;# if this is set to 1, the car establishes an FTP upload connection with the server 
			}
		} else {
			if { $ftp_uplink_ == 0 } {
				# manual setting for selecting which car sends the traffic
				# first, I put everything to 0
				for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
					set ftp_up_mask_($i) 0
				}
				# and now I put some cars to 1
				set ftp_up_mask_(151) 1
			}
		} 

		######## mask definition for voip downlink flows ########
		if { $voip_downlink_ == 1 } {
			for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
				set voip_down_mask_($i) 1	;# if this is set to 1, the car establishes a voip download connection with the server 
			}
		} else {
			if { $voip_downlink_ == 0 } {
				# manual setting for selecting which car sends the traffic
				# first, I put everything to 0
				for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
					set voip_down_mask_($i) 0
				}
				# and now I put some cars to 1
				set voip_down_mask_(4) 1
			}
		} 

		######## mask definition for voip uplink flows ########
		if { $voip_uplink_ == 1 } {
			for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
				set voip_up_mask_($i) 1	;# if this is set to 1, the car establishes a voip upload connection with the server 
			}
		} else {
			if { $voip_uplink_ == 0 } {
				# manual setting for selecting which car sends the traffic
				# first, I put everything to 0
				for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
					set voip_up_mask_($i) 0
				}
				# and now I put some cars to 1
				set voip_up_mask_(4) 1
			}
		} 

		######## mask definition for fps downlink flows ########
		if { $fps_downlink_ == 1 } {
			for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
				set fps_down_mask_($i) 1	;# if this is set to 1, the car establishes a fps download connection with the server 
			}
		} else {
			if { $fps_downlink_ == 0 } {
				# manual setting for selecting which car sends the traffic
				# first, I put everything to 0
				for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
					set fps_down_mask_($i) 0
				}
				# and now I put some cars to 1
#				set fps_down_mask_(150) 1
#				set fps_down_mask_(151) 1
#				set fps_down_mask_(152) 1
#				set fps_down_mask_(153) 1
#				set fps_down_mask_(154) 1
#				set fps_down_mask_(155) 1
#				set fps_down_mask_(156) 1
#				set fps_down_mask_(157) 1
#				set fps_down_mask_(158) 1
#				set fps_down_mask_(159) 1

				set fps_down_mask_(1) 1

				# If I only want the car in the middle to use the application
				set number_middle_car_ [expr int( $number_of_wifi_cars_ / 2)]
				set fps_down_mask_($number_middle_car_) 1

			}
		} 


		######## mask definition for fps uplink flows ########
		if { $fps_uplink_ == 1 } {
			for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
				set fps_up_mask_($i) 1	;# if this is set to 1, the car establishes a fps upload connection with the server 
			}
		} else {
			if { $fps_uplink_ == 0 } {
				# manual setting for selecting which car sends the traffic
				# first, I put everything to 0
				for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
					set fps_up_mask_($i) 0
				}
				# and now I put some cars to 1
	#			set fps_up_mask_(150) 1
	#			set fps_up_mask_(151) 1
	#			set fps_up_mask_(152) 1
	#			set fps_up_mask_(153) 1
	#			set fps_up_mask_(154) 1
	#			set fps_up_mask_(155) 1
	#			set fps_up_mask_(156) 1
	#			set fps_up_mask_(157) 1
	#			set fps_up_mask_(158) 1
	#			set fps_up_mask_(159) 1

				set fps_up_mask_(1) 1

	#			set fps_up_mask_($number_middle_car_) 1

			}
		} 


	##### Random SETTING of the application assignment ############
	} else {
		if {$mode == "random" } {
			for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
				set probability_ [$uniform_ value]
				if { $probability_ < $probability_fps_ } {
					set fps_up_mask_($i) 1
					set fps_down_mask_($i) 1
				} else {
					if { $probability_ < [expr $probability_fps_ + $probability_ftp_down_]} {
						set ftp_down_mask_($i) 1
					} else {
						if { $probability_ < [expr $probability_fps_ + $probability_ftp_down_ + $probability_ftp_up_ ]} {					
							set ftp_up_mask_($i) 1
						}
					}
				}
			}
		# probability_voip_
		}
	}

	###### write the application assignement by the screen
	puts -nonewline "ftp downlink:  "
	for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
		puts -nonewline "$ftp_down_mask_($i)"
	}
	puts ""

	puts -nonewline "ftp uplink:    "
	for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
		puts -nonewline "$ftp_up_mask_($i)"
	}
	puts ""

	puts -nonewline "voip downlink: "
	for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
		puts -nonewline "$voip_down_mask_($i)"
	}
	puts ""

	puts -nonewline "voip uplink:   "
	for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
		puts -nonewline "$voip_up_mask_($i)"
	}
	puts ""

	puts -nonewline "fps downlink:  "
	for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
		puts -nonewline "$fps_down_mask_($i)"
	}
	puts ""

	puts -nonewline "fps uplink:    "
	for {set i 1} {$i <= $number_of_wifi_cars_} {incr i} {
		puts -nonewline "$fps_up_mask_($i)"
	}
	puts ""
	puts ""	
}