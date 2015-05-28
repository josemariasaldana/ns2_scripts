###############################
# Create the random variables #
###############################
proc init_apdu_iat_variables_ { ns } {
	global  client_IAT_dungeons server_APDU_dungeons_a server_APDU_dungeons_b server_IAT_dungeons_a server_IAT_dungeons_b \
			client_IAT_pvp server_APDU_pvp server_IAT_pvp \
			client_IAT_raiding server_APDU_raiding_a server_APDU_raiding_b server_IAT_raiding \
			client_IAT_trading_a client_IAT_trading_b server_APDU_trading server_IAT_trading \
			client_IAT_questing_a client_IAT_questing_b server_APDU_questing server_IAT_questing_a	server_IAT_questing_b \
			#client_APDU_uncategorized client_IAT_uncategorized server_APDU_uncategorized server_IAT_uncategorized \
			uniform_ numplayers_ total_number_of_connections_ flavor_wow_ \
			number_apdu_client_server_ number_apdu_server_client_ \
			number_packets_no_saturation_client_server_ number_packets_no_saturation_server_client_

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
	
	# A uniformly distributed variable between 0 and 100
	set uniform_ [new RandomVariable/Uniform]
	$uniform_ use-rng $my_random_generator_
	$uniform_ set min_ 0.0
	$uniform_ set max_ 100.0

	# APDU and IAT parameters of different activities' distributions

	################ DUNGEONS ######################
	set client_IAT_dungeons [new RandomVariable/Weibull]
	$client_IAT_dungeons use-rng $my_random_generator_
	$client_IAT_dungeons set shape_ 268.37
	$client_IAT_dungeons set scale_ 0.58

	set server_APDU_dungeons_a [new RandomVariable/Weibull]
	$server_APDU_dungeons_a use-rng $my_random_generator_
	$server_APDU_dungeons_a set shape_ 221.83 ; #gamma
	$server_APDU_dungeons_a set scale_ 0.89 ; #alpha

	set server_APDU_dungeons_b [new RandomVariable/Uniform];#it is a largest extreme value, so return location + scale * log( -log( uniform( 0., 1. ) ) )
	# each time you call this variable, you must use:  set apdu_ [expr floor (7698.83 + ( 198.842 * ( log ( -1.0 * log ( [$server_APDU_dungeons value])))))]
	# since the value may be negative, and "if" clause has to be included in order to set it to 0 in that case. This means that somebody has entered and exited from a dungeon
	$server_APDU_dungeons_b use-rng $my_random_generator_
	$server_APDU_dungeons_b set min_ 0.0
	$server_APDU_dungeons_b set max_ 1.0

	set server_IAT_dungeons_a [new RandomVariable/Weibull]
	$server_IAT_dungeons_a use-rng $my_random_generator_
	$server_IAT_dungeons_a set shape_ 231.3 ; #gamma
	$server_IAT_dungeons_a set scale_ 2.28 ; #alpha

	set server_IAT_dungeons_b [new RandomVariable/Weibull]
	$server_IAT_dungeons_b use-rng $my_random_generator_
	$server_IAT_dungeons_b set shape_ 344.14 ; #gamma
	$server_IAT_dungeons_b set scale_ 0.79 ; #alpha

	################ PVP ######################
	
	# PvP client APDU is a set of deterministic values

	# PvP client IAT uses a Weibull distribution and two deterministic values
	set client_IAT_pvp [new RandomVariable/Weibull]
	$client_IAT_pvp use-rng $my_random_generator_
	$client_IAT_pvp set shape_ 208.50
	$client_IAT_pvp set scale_ 0.79

	# The server APDU depends on the PvP subactivity
	set server_APDU_pvp(alterac_valley) [new RandomVariable/Weibull]
	$server_APDU_pvp(alterac_valley) use-rng $my_random_generator_
	$server_APDU_pvp(alterac_valley) set shape_ [expr (258.33 + ( 38 * 21.32 ))/ 1.177897 ]
	$server_APDU_pvp(alterac_valley) set scale_ 0.87

	set server_APDU_pvp(arathi_basin) [new RandomVariable/Weibull]
	$server_APDU_pvp(arathi_basin) use-rng $my_random_generator_
	$server_APDU_pvp(arathi_basin) set shape_ [expr (258.33 + ( 38 * 10.90)) / 1.177897 ]
	$server_APDU_pvp(arathi_basin) set scale_ 0.87

	set server_APDU_pvp(warsong_gulch) [new RandomVariable/Weibull]
	$server_APDU_pvp(warsong_gulch) use-rng $my_random_generator_
	$server_APDU_pvp(warsong_gulch) set shape_ [expr ( 258.33 + ( 38 * 10.11)) / 1.177897 ]
	$server_APDU_pvp(warsong_gulch) set scale_ 0.87

	set server_APDU_pvp(eye_of_the_storm) [new RandomVariable/Weibull]
	$server_APDU_pvp(eye_of_the_storm) use-rng $my_random_generator_
	$server_APDU_pvp(eye_of_the_storm) set shape_ [expr (258.33 + ( 38 * 13.14)) / 1.177897 ]
	$server_APDU_pvp(eye_of_the_storm) set scale_ 0.87

	set server_APDU_pvp(strand_of_the_ancients) [new RandomVariable/Weibull]
	$server_APDU_pvp(strand_of_the_ancients) use-rng $my_random_generator_
	$server_APDU_pvp(strand_of_the_ancients) set shape_ [expr (258.33 + ( 38 * 15 ))/ 1.177897 ]
	$server_APDU_pvp(strand_of_the_ancients) set scale_ 0.87

	set server_APDU_pvp(arena_2v2) [new RandomVariable/Weibull]
	$server_APDU_pvp(arena_2v2) use-rng $my_random_generator_
	$server_APDU_pvp(arena_2v2) set shape_ [expr (258.33 + ( 38 * 4 ))/ 1.177897 ]
	$server_APDU_pvp(arena_2v2) set scale_ 0.76

	set server_APDU_pvp(arena_3v3) [new RandomVariable/Weibull]
	$server_APDU_pvp(arena_3v3) use-rng $my_random_generator_
	$server_APDU_pvp(arena_3v3) set shape_ [expr (258.33 + ( 38 * 6)) / 1.177897 ]
	$server_APDU_pvp(arena_3v3) set scale_ 0.76

	set server_APDU_pvp(arena_5v5) [new RandomVariable/Weibull]
	$server_APDU_pvp(arena_5v5) use-rng $my_random_generator_
	$server_APDU_pvp(arena_5v5) set shape_ [expr (258.33 + ( 38 * 10)) / 1.177897 ]
	$server_APDU_pvp(arena_5v5) set scale_ 0.76

	# The server IAT does not depend on the PvP subactivity
	set server_IAT_pvp [new RandomVariable/Weibull]
	$server_IAT_pvp use-rng $my_random_generator_
	$server_IAT_pvp set shape_ 193.26
	$server_IAT_pvp set scale_ 1.71

	################ RAIDING ####################
	set client_IAT_raiding [new RandomVariable/Weibull]
	$client_IAT_raiding use-rng $my_random_generator_
	$client_IAT_raiding set shape_ 299.52
	$client_IAT_raiding set scale_ 0.76

	set server_APDU_raiding_a [new RandomVariable/Weibull]
	$server_APDU_raiding_a use-rng $my_random_generator_
	$server_APDU_raiding_a set shape_ 941.79
	$server_APDU_raiding_a set scale_ 0.86

	set server_APDU_raiding_b [new RandomVariable/Weibull]
	$server_APDU_raiding_b use-rng $my_random_generator_
	$server_APDU_raiding_b set shape_ 1183.28
	$server_APDU_raiding_b set scale_ 0.91

	set server_IAT_raiding [new RandomVariable/Weibull]
	$server_IAT_raiding use-rng $my_random_generator_
	$server_IAT_raiding set shape_ 188.92
	$server_IAT_raiding set scale_ 1.99

	################ TRADING ####################
	set client_IAT_trading_a [new RandomVariable/Weibull]
	$client_IAT_trading_a use-rng $my_random_generator_
	$client_IAT_trading_a set shape_ 176.74
	$client_IAT_trading_a set scale_ 0.99

	set client_IAT_trading_b [new RandomVariable/Weibull]
	$client_IAT_trading_b use-rng $my_random_generator_
	$client_IAT_trading_b set shape_ 1220.33
	$client_IAT_trading_b set scale_ 0.66

	# In trading category, the IAT and APDU depends on the number of players in the server
	# for each connection, a Weibull random variable depending on the number of players on the server is generated

	for {set connection_id_ 0} { $connection_id_ < $total_number_of_connections_ } { incr connection_id_ } {
		set server_APDU_trading($connection_id_) [new RandomVariable/Weibull]
		$server_APDU_trading($connection_id_) use-rng $my_random_generator_
		$server_APDU_trading($connection_id_) set shape_ [expr 55.0688 * pow ( $numplayers_($connection_id_) , 0.356694 )]
		$server_APDU_trading($connection_id_) set scale_ [expr 1.02 + ( 0.000406 * $numplayers_($connection_id_) )  ]

		#THE NEXT TWO LINES WILL BE REMOVED
		#puts "$numplayers_($connection_id_) players server APDU_trading scale [expr 82.796 * pow ( $numplayers_($connection_id_) , 0.2701 )]"
		#puts "$numplayers_($connection_id_) players server APDU_trading shape [expr ( 0.0004 * $numplayers_($connection_id_) ) + 1.0174 ]"

		set server_IAT_trading($connection_id_) [new RandomVariable/Weibull]
		$server_IAT_trading($connection_id_) use-rng $my_random_generator_
		$server_IAT_trading($connection_id_) set shape_ [expr 118.508 + ( 298.763 * pow ( 2.718281 , (-0.0119498 * $numplayers_($connection_id_))))]
		$server_IAT_trading($connection_id_) set scale_ [expr 1.41942 * pow ( $numplayers_($connection_id_) , 0.0681572 )]

	}

	################ QUESTING ####################
	set client_IAT_questing_a [new RandomVariable/Weibull]
	$client_IAT_questing_a use-rng $my_random_generator_
	$client_IAT_questing_a set shape_ 236.22
	$client_IAT_questing_a set scale_ 1.19

	set client_IAT_questing_b [new RandomVariable/Weibull]
	$client_IAT_questing_b use-rng $my_random_generator_
	$client_IAT_questing_b set shape_ 1073.63
	$client_IAT_questing_b set scale_ 0.84

	set server_APDU_questing [new RandomVariable/LogNormal]
	$server_APDU_questing use-rng $my_random_generator_
	$server_APDU_questing set avg_ 1.22
	$server_APDU_questing set std_ 4.55

	set server_IAT_questing_a [new RandomVariable/Normal]
	$server_IAT_questing_a use-rng $my_random_generator_
	$server_IAT_questing_a set avg_ 212.87
	$server_IAT_questing_a set std_ 96.59

	set server_IAT_questing_b [new RandomVariable/Weibull]
	$server_IAT_questing_b use-rng $my_random_generator_
	$server_IAT_questing_b set shape_ 451.55
	$server_IAT_questing_b set scale_ 0.91

	################ UNCATEGORIZED ####################

	# the variables are the same as for TRADING

	#set client_APDU_uncategorized [new RandomVariable/Weibull]
	#$client_APDU_uncategorized use-rng $my_random_generator_
	#$client_APDU_uncategorized set shape_ 10.0
	#$client_APDU_uncategorized set scale_ 1.0

	#set client_IAT_uncategorized [new RandomVariable/Weibull]
	#$client_IAT_uncategorized use-rng $my_random_generator_
	#$client_IAT_uncategorized set shape_ 10.0
	#$client_IAT_uncategorized set scale_ 1.0

	#set server_APDU_uncategorized [new RandomVariable/Weibull]
	#$server_APDU_uncategorized  use-rng $my_random_generator_
	#$server_APDU_uncategorized set shape_ 10.0
	#$server_APDU_uncategorized set scale_ 1.0

	#set server_IAT_uncategorized [new RandomVariable/Weibull]
	#$server_IAT_uncategorized  use-rng $my_random_generator_
	#$server_IAT_uncategorized set shape_ 10.0
	#$server_IAT_uncategorized set scale_ 1.0

}

#####################################
# Calculation of the client packets #
#####################################
proc calculate_apdu_iat_client {ns tcp_connection_c_s_ ftp_application_c_s_ connection_ident_} {
	global	current_activity_ pvp_subactivity_ packet_verbose_ \
			client_APDU_dungeons client_IAT_dungeons \
			client_IAT_pvp \
			client_IAT_raiding server_APDU_raiding \
			client_IAT_trading_a client_IAT_trading_b \
			client_IAT_questing_a client_IAT_questing_b \
			#client_APDU_uncategorized client_IAT_uncategorized \
			uniform_ MTU_size_ apdu_iat_files_ apdu_iat_client_file_id_ maximum_APDU_ flavor_wow_ \
			number_apdu_client_server_ number_packets_no_saturation_client_server_ 	total_bytes_apdu_client_server_

	
	# "think" is used for calculating inter-arrival-time (IAT)
	# "apdu_" is used for calculating the APDU

	################################# DUNGEONS #################################
	if { $current_activity_($connection_ident_) == "dungeons" } {

		########## DUNGEONS CLIENT IAT ###########
		set probability_ [$uniform_ value] ;# a value between 0 and 100
		set acum_prob_ 95.86 ; #to save the different percentages
		if { $probability_ < $acum_prob_ } {
			set think [expr [$client_IAT_dungeons value] / 1000 ]
		} else {
			# deterministic value
			set think 0.500
		}

		########## DUNGEONS CLIENT APDU ###########
		set probability_ [$uniform_ value] ;# a value between 0 and 100
		set acum_prob_ 4.57 ; #to save the different percentages
		if { $probability_ < $acum_prob_ } {
			# deterministic			
			set apdu_ 6
		} else {
			set acum_prob_ [expr $acum_prob_ + 8.00]
			if { $probability_ < $acum_prob_ } {
				# deterministic
				set apdu_ 10
			} else {
				set acum_prob_ [expr $acum_prob_ + 16.28]
				if { $probability_ < $acum_prob_ } {
					# deterministic										
					set apdu_ 14
				} else {
					set acum_prob_ [expr $acum_prob_ + 4.04]
					if { $probability_ < $acum_prob_ } {
						# deterministic
						set apdu_ 19
					} else {
						set acum_prob_ [expr $acum_prob_ + 8.28]
						if { $probability_ < $acum_prob_ } {
							# deterministic
							set apdu_ 22
						} else {
							set acum_prob_ [expr $acum_prob_ + 55.70]
							if { $probability_ < $acum_prob_ } {
								# deterministic
								set apdu_ 35
							} else { ;#probability 3.13%
								# deterministic
								set apdu_ 51
							}
						}
					}
				}
			}
		}
	} else {
		################################# PVP #################################
		if { $current_activity_($connection_ident_) == "pvp" } {

			########## PVP CLIENT IAT ###########
			set probability_ [$uniform_ value] ;# a value between 0 and 100
			set acum_prob_ 78.4 ; #to save the different percentages
			if { $probability_ < $acum_prob_ } {
				# weibull variable
				set think [expr [$client_IAT_pvp value] / 1000 ]
			} else {
				set acum_prob_ [expr $acum_prob_ + 20.18]
				if { $probability_ < $acum_prob_ } {
					# deterministic value
					set think 0.001 ;#it is 0, but I have to put this in order to be able to change the apdu size
				} else { ;# probability 1.42%
					# deterministic value
					set think 0.500
				}
			}

			########## PVP CLIENT APDU ###########
			set probability_ [$uniform_ value] ;# a value between 0 and 100
			set acum_prob_ 7.63 ; #to save the different percentages
			if { $probability_ < $acum_prob_ } {
				# deterministic			
				set apdu_ 6
			} else {
				set acum_prob_ [expr $acum_prob_ + 5.60]
				if { $probability_ < $acum_prob_ } {
					# deterministic
					set apdu_ 10
				} else {
					set acum_prob_ [expr $acum_prob_ + 13.12]
					if { $probability_ < $acum_prob_ } {
						# deterministic										
						set apdu_ 14
					} else {
						set acum_prob_ [expr $acum_prob_ + 3.11]
						if { $probability_ < $acum_prob_ } {
							# deterministic
							set apdu_ 19
						} else {
							set acum_prob_ [expr $acum_prob_ + 59.50]
							if { $probability_ < $acum_prob_ } {
								# deterministic
								set apdu_ 35
							} else {
								set acum_prob_ [expr $acum_prob_ + 6.66]
								if { $probability_ < $acum_prob_ } {
									# deterministic
									set apdu_ 51
								} else { ;#probability 4.38%
									# deterministic
									set apdu_ 58
								}
							}
						}
					}
				}
			}
		} else {
			################################# RAIDING #################################
			if { $current_activity_($connection_ident_) == "raiding" } {

				########## RAIDING CLIENT IAT ###########
				set probability_ [$uniform_ value] ;# a value between 0 and 100
				set acum_prob_ 85.73 ; #to save the different percentages
				if { $probability_ < $acum_prob_ } {
					set think [expr [$client_IAT_raiding value] / 1000 ]
				} else {
					set think 0.0
				}

				########## RAIDING CLIENT APDU ###########
				set probability_ [$uniform_ value] ;# a value between 0 and 100
				set acum_prob_ 3.81 ; #to save the different percentages
				if { $probability_ < $acum_prob_ } {
					# deterministic			
					set apdu_ 6
				} else {
					set acum_prob_ [expr $acum_prob_ + 4.35]
					if { $probability_ < $acum_prob_ } {
						# deterministic
						set apdu_ 10
					} else {
						set acum_prob_ [expr $acum_prob_ + 12.15]
						if { $probability_ < $acum_prob_ } {
							# deterministic										
							set apdu_ 14
						} else {
							set acum_prob_ [expr $acum_prob_ + 20.18]
							if { $probability_ < $acum_prob_ } {
								# deterministic
								set apdu_ 19
							} else {
								set acum_prob_ [expr $acum_prob_ + 3.63]
								if { $probability_ < $acum_prob_ } {
									# deterministic
									set apdu_ 20
								} else {
									set acum_prob_ [expr $acum_prob_ + 6.81]
									if { $probability_ < $acum_prob_ } {
										# deterministic
										set apdu_ 29
									} else {
										set acum_prob_ [expr $acum_prob_ + 45.53]
										if { $probability_ < $acum_prob_ } {
											# deterministic
											set apdu_ 35
										} else { ;# probability 3.54%
											# deterministic
											set apdu_ 51
										}
									}
								}
							}
						}
					}
				}
			} else {
				################################# TRADING AND UNCATEGORIZED #################################
				if { $current_activity_($connection_ident_) == "trading" || $current_activity_($connection_ident_) == "uncategorized" } {

					########## TRADING AND UNCATEGORIZED CLIENT IAT ###########
					set probability_ [$uniform_ value] ;# a value between 0 and 100
					set acum_prob_ 50.53 ; #to save the different percentages
					if { $probability_ < $acum_prob_ } {
						# weibull		
						set think [expr [$client_IAT_trading_a value] / 1000]
					} else {
						set acum_prob_ [expr $acum_prob_ + 28.53]
						if { $probability_ < $acum_prob_ } {
							# weibull
							set think [expr (500.95 + [$client_IAT_trading_b value] )/ 1000 ];#525.95 is mu parameter
						} else {
							set acum_prob_ [expr $acum_prob_ + 17.60 ]
							if { $probability_ < $acum_prob_ } {
								# deterministic
								set think 0.001 ;#it is 0, but I have to put this in order to be able to change the apdu size
							} else { ;# 3.34%
								# deterministic
								set think 0.500
							}
						}
					}

					########## TRADING AND UNCATEGORIZED CLIENT APDU ###########
					set probability_ [$uniform_ value] ;# a value between 0 and 100
					set acum_prob_ 5.25 ; #to save the different percentages
					if { $probability_ < $acum_prob_ } {
						# deterministic			
						set apdu_ 6
					} else {
						set acum_prob_ [expr $acum_prob_ + 4.21]
						if { $probability_ < $acum_prob_ } {
							# deterministic
							set apdu_ 10
						} else {
							set acum_prob_ [expr $acum_prob_ + 34.05]
							if { $probability_ < $acum_prob_ } {
								# deterministic										
								set apdu_ 14
							} else {
								set acum_prob_ [expr $acum_prob_ + 5.72]
								if { $probability_ < $acum_prob_ } {
									# deterministic
									set apdu_ 15
								} else {
									set acum_prob_ [expr $acum_prob_ + 3.19]
									if { $probability_ < $acum_prob_ } {
										# deterministic
										set apdu_ 18
									} else {
										set acum_prob_ [expr $acum_prob_ + 32.50]
										if { $probability_ < $acum_prob_ } {
											# deterministic
											set apdu_ 35
										} else {
											set acum_prob_ [expr $acum_prob_ + 9.14]
											if { $probability_ < $acum_prob_ } {
												# deterministic
												set apdu_ 39
											} else { ;# probability 5.94%
												# deterministic
												set apdu_ 51
											}
										}
									}
								}
							}
						}
					}
				} else {
					################################# QUESTING #################################
						if { $current_activity_($connection_ident_) == "questing" } { ; # Questing: two Weibull and two deterministic

							########## QUESTING CLIENT IAT ###########
							set probability_ [$uniform_ value] ;# a value between 0 and 100
							set acum_prob_ 55.7 ; #to save the different percentages
							if { $probability_ < $acum_prob_ } {
								# weibull		
								set think [expr [$client_IAT_questing_a value] / 1000]
							} else {
								set acum_prob_ [expr $acum_prob_ + 12.6]
								if { $probability_ < $acum_prob_ } {
									# weibull
									set think [expr (525.95 + [$client_IAT_questing_b value] )/ 1000 ];#525.95 is mu parameter
								} else {
									set acum_prob_ [expr $acum_prob_ + 16.46]
									if { $probability_ < $acum_prob_ } {
										# deterministic
										set think 0.001 ;#it is 0, but I have to put this in order to be able to change the apdu size
									} else {
										# deterministic
										set think 0.500
									}
								}
							}

							######### QUESTING CLIENT APDU ##############
							set probability_ [$uniform_ value] ;# a value between 0 and 100
							set acum_prob_ 4.96 ; #to save the different percentages
							if { $probability_ < $acum_prob_ } {
								# deterministic			
								set apdu_ 6
							} else {
								set acum_prob_ [expr $acum_prob_ + 7.34]
								if { $probability_ < $acum_prob_ } {
									# deterministic
									set apdu_ 10
								} else {
									set acum_prob_ [expr $acum_prob_ + 20.75]
									if { $probability_ < $acum_prob_ } {
										# deterministic										
										set apdu_ 14
									} else {
										set acum_prob_ [expr $acum_prob_ + 2.82]
										if { $probability_ < $acum_prob_ } {
											# deterministic
											set apdu_ 18
										} else {
											set acum_prob_ [expr $acum_prob_ + 2.36]
											if { $probability_ < $acum_prob_ } {
												# deterministic
												set apdu_ 21
											} else {
												set acum_prob_ [expr $acum_prob_ + 50.18]
												if { $probability_ < $acum_prob_ } {
													# deterministic
													set apdu_ 35
												} else {
													set acum_prob_ [expr $acum_prob_ + 9.20]
													if { $probability_ < $acum_prob_ } {
														# deterministic
														set apdu_ 39
														} else { ;# probability 20.75%
															# deterministic
															set apdu_ 51
														}
													}
												}
											}
										}
									}
								}
							#} else {
							################################# UNCATEGORIZED #################################
							#if { $current_activity_($connection_ident_) == "uncategorized" } {
								######### UNCATEGORIZED CLIENT IAT ##############
							#	set think [expr [$client_IAT_uncategorized value] / 1000]
								######### UNCATEGORIZED CLIENT APDU ##############
							#	set apdu_ [expr floor([$client_APDU_uncategorized value])]
							#}
						}
					}
				}
			}
		}

	if { $think < 0.0 } {
		set think 0.001
	}

	# I use this part in order to limit the maximum size of the APDU to $maximum_APDU_ bytes
	# First, I substract 1000.0, and then I add an uniformly distributed number between 0 and 1000
	if { $apdu_ > $maximum_APDU_ } {
		set probability_ [$uniform_ value] ;# between 0 and 100
		set apdu_ [expr $maximum_APDU_ - 1000.0 + ( 10.0 * $probability_ )]
	}
	
	#### calculation of the number of MTU (full) packets
	set number_of_full_packets_ [ expr floor( $apdu_ / $MTU_size_) ]; #number_of_full_packets_ are MTU packets, and the last one is not full
	# send the last packet, only if the APDU is not a multiple of MTU
	if { $apdu_ != [expr $MTU_size_ * $number_of_full_packets_ ] } {
		if { $flavor_wow_ == "FullTcp" } {
			$ns at [$ns now] "$ftp_application_c_s_ send [expr $apdu_ - ($number_of_full_packets_ * $MTU_size_ ) ]"	;# using FullTcp, this sends one packet of the MTU_size_packet size
		} else {
			$ns at [$ns now] "$tcp_connection_c_s_ set packetSize_ [expr $apdu_ - ($number_of_full_packets_ * $MTU_size_ ) ]; $ftp_application_c_s_ send 1"	;# this sends one packet of the defined packet size
		}
	}
	#puts "full packets: $number_of_full_packets_"
	for {set i 1} { $i <= $number_of_full_packets_ } { incr i } {
		if { $flavor_wow_ == "FullTcp" } {
			$ns at [expr [$ns now] + 0.01 ] "$ftp_application_c_s_ send $MTU_size_"	;# using FullTcp, this sends one packet of the MTU_size_packet size
		} else {
			$ns at [expr [$ns now] + 0.01 ] "$tcp_connection_c_s_ set packetSize_ $MTU_size_; $ftp_application_c_s_ send 1"	;# this sends one packet of the defined packet size
		}
	}

	if { $packet_verbose_ == 1 } {
		if { $current_activity_($connection_ident_) != "pvp" } {
			puts "[format "%.3f" [$ns now]]: Client $connection_ident_ sends a $current_activity_($connection_ident_) APDU of length [format "%.0f" $apdu_] to server and sleeps [format "%.0f" [expr $think * 1000]] ms"

		# If the activity is PvP, I also write the name of the subactivity
		} else {
			puts "[format "%.3f" [$ns now]]: Client $connection_ident_ sends a $current_activity_($connection_ident_) $pvp_subactivity_($connection_ident_) APDU of length [format "%.0f" $apdu_] to server and sleeps [format "%.0f" [expr $think * 1000]] ms"
		}
	}

	# write a line in the output file
	if { $apdu_iat_files_ == 1 } {
		puts $apdu_iat_client_file_id_($connection_ident_) "[$ns now]\t$apdu_\t$think"
	}
	$ns at [expr [$ns now] + $think ] "calculate_apdu_iat_client $ns $tcp_connection_c_s_ $ftp_application_c_s_ $connection_ident_"

	# increase the counter of APDUs
	set number_apdu_client_server_($connection_ident_) [expr $number_apdu_client_server_($connection_ident_) + 1]
	set number_packets_no_saturation_client_server_($connection_ident_) [expr $number_packets_no_saturation_client_server_($connection_ident_) + $number_of_full_packets_ + 1]
	set total_bytes_apdu_client_server_($connection_ident_) [expr $total_bytes_apdu_client_server_($connection_ident_) + int ($apdu_) ]
}


#####################################
# Calculation of the server packets #
#####################################
proc calculate_apdu_iat_server {ns tcp_connection_s_c_ ftp_application_s_c_ connection_ident_} {
	global	current_activity_ pvp_subactivity_ packet_verbose_ \
			server_APDU_dungeons_a server_APDU_dungeons_b server_IAT_dungeons_a server_IAT_dungeons_b \
			server_APDU_pvp server_IAT_pvp \
			server_APDU_raiding_a server_APDU_raiding_b server_IAT_raiding \
			server_APDU_trading server_IAT_trading \
			server_APDU_questing server_IAT_questing_a	server_IAT_questing_b \
			#server_APDU_uncategorized server_IAT_uncategorized \
			uniform_ MTU_size_ apdu_iat_files_ apdu_iat_server_file_id_ maximum_APDU_ flavor_wow_ \
			number_apdu_server_client_ number_packets_no_saturation_server_client_ 	total_bytes_apdu_server_client_


	################################# DUNGEONS #################################
	if { $current_activity_($connection_ident_) == "dungeons" } {

		########## DUNGEONS SERVER IAT ##########
		set probability_ [$uniform_ value] ;# a value between 0 and 100
		set acum_prob_ 78.35 ; #to save the different percentages
		if { $probability_ < $acum_prob_ } {	
			# normal variable		
			set think [expr [$server_IAT_dungeons_a value] / 1000]
		} else {
			set acum_prob_ [expr $acum_prob_ + 2.58]
			if { $probability_ < $acum_prob_ } {
				# weibull variable
				set think [expr (405.96 + [$server_IAT_dungeons_b value] ) / 1000 ]
			} else {
				# deterministic
				set acum_prob_ [expr $acum_prob_ + 3.06]
				if { $probability_ < $acum_prob_ } {
					set think 0.044
				} else {
					# deterministic
					set acum_prob_ [expr $acum_prob_ + 9.55]
					if { $probability_ < $acum_prob_ } {
						set think 0.200
					} else { ;#probability 6.46%
						# deterministic
						set think 0.328
					}
				}
			}
		}

		########## DUNGEONS SERVER APDU ##########
		set probability_ [$uniform_ value] ;# a value between 0 and 100
		set acum_prob_ 99.15 ; #to save the different percentages
		if { $probability_ < $acum_prob_ } {	
			# weibull variable		
			set apdu_ [expr floor ([$server_APDU_dungeons_a value] ) ]
		} else {
			# largest extreme value variable
			set apdu_ [expr floor (7698.83 + ( 198.842 * ( log ( -1.0 * log ( [$server_APDU_dungeons_b value])))))]
			if { $apdu_ < 0 } {
				set apdu_ 0
			}
		}
	} else {
		################################# PVP #################################
		if { $current_activity_($connection_ident_) == "pvp" } {
			set probability_ [$uniform_ value] ;# a value between 0 and 100 to select between Battleground and Arena

			########## PVP SERVER IAT ###########
			# The IAT does not depend on the pvp subactivity
			# I have to use a Weibull and three deterministic values
			set probability_ [$uniform_ value] ;# a value between 0 and 100
			set acum_prob_ 83.32 ; #to save the different percentages
			if { $probability_ < $acum_prob_ } {	
				# weibull variable		
				set think [expr [$server_IAT_pvp value] / 1000 ]
			} else {
				set acum_prob_ [expr $acum_prob_ + 4.13]
				if { $probability_ < $acum_prob_ } {
					# deterministic value
					set think 0.044
				} else {
					set acum_prob_ [expr $acum_prob_ + 4.11]
					if { $probability_ < $acum_prob_ } {
						# deterministic value
						set think 0.2
					} else {
						# remaining probability 8.44%
						# deterministic value
						set think 0.328
					}
				}
			}

			########## PVP SERVER APDU ###########
			# I calculate the APDU depending on the pvp subactivity of each connection
			set apdu_ [expr floor([$server_APDU_pvp($pvp_subactivity_($connection_ident_)) value])]

		} else {
			################################# RAIDING #################################
			if { $current_activity_($connection_ident_) == "raiding" } {

				########## RAIDING SERVER IAT ##########
				set probability_ [$uniform_ value] ;# a value between 0 and 100
				set acum_prob_ 84.39 ; #to save the different percentages
				if { $probability_ < $acum_prob_ } {
					# weibull variable
					set think [expr [$server_IAT_raiding value] / 1000 ]
				} else {
					set acum_prob_ [expr $acum_prob_ + 9.55]
					if { $probability_ < $acum_prob_ } {
						# deterministic value
						set think 0.044
					} else {
						# deterministic value
						set think 0.2
					}
				}

				########## RAIDING SERVER APDU ##########
				set probability_ [$uniform_ value] ;# a value between 0 and 100
				set acum_prob_ 98.97 ; #to save the different percentages
				if { $probability_ < $acum_prob_ } {	
					# weibull variable		
					set apdu_ [expr floor ([$server_APDU_raiding_a value] ) ]
				} else {
					# three parameter weibull variable
					set apdu_ [expr floor ( 7298.20 + [$server_APDU_raiding_b value] ) ]
					if { $apdu_ < 0 } {
						set apdu_ 0
					}
				}
			} else {
				################################# TRADING AND UNCATEGORIZED #################################
				if { $current_activity_($connection_ident_) == "trading" || $current_activity_($connection_ident_) == "uncategorized" } {

					########## TRADING AND UNCATEGORIZED SERVER IAT ###########
					# weibull depending on the number of players of each connection
					set think [expr [$server_IAT_trading($connection_ident_) value] / 1000 ]

					########## TRADING AND UNCATEGORIZED SERVER APDU ##########
					# weibull depending on the number of players of each connection
					set apdu_ [expr floor([$server_APDU_trading($connection_ident_) value])]
				} else {
					################################# QUESTING #################################					
					if { $current_activity_($connection_ident_) == "questing" } { ; # Questing: two Weibull and two deterministic

						########## QUESTING SERVER IAT ###########
						set probability_ [$uniform_ value] ;# a value between 0 and 100
						set acum_prob_ 71.51 ; #to save the different percentages
						if { $probability_ < $acum_prob_ } {	
							# normal variable		
							set think [expr [$server_IAT_questing_a value] / 1000]
						} else {
							set acum_prob_ [expr $acum_prob_ + 7.49]
							if { $probability_ < $acum_prob_ } {
								# weibull variable
								set think [expr (419.96 + [$server_IAT_questing_b value] ) / 1000 ]
							} else {
								# deterministic
								set acum_prob_ [expr $acum_prob_ + 2.15]
								if { $probability_ < $acum_prob_ } {
									set think 0.044
								} else {
									# deterministic
									set acum_prob_ [expr $acum_prob_ + 12.27]
									if { $probability_ < $acum_prob_ } {
										set think 0.218
									} else { ;#probability 6.58%
										# deterministic
										set think 0.328
									}
								}
							}
						}

						########## QUESTING SERVER APDU ###########
						# lognormal
						set apdu_ [expr ceil([$server_APDU_questing value])]
					#} else {
						################################# UNCATEGORIZED #################################
						#if { $current_activity_($connection_ident_) == "uncategorized" } {
							########## UNCATEGORIZED SERVER IAT ##########
						#	set think [expr [$server_IAT_uncategorized value] / 1000]
							########## UNCATEGORIZED SERVER APDU ##########
						#	set apdu_ [expr floor([$server_APDU_uncategorized value])]
						#}
					}
				}
			}
		}
	}
	if { $think < 0.0 } {
		set think 0.001
	}

	# I use this part in order to limit the maximum size of the APDU to $maximum_APDU_ bytes
	# First, I substract 1000.0, and then I add an uniformly distributed number between 0 and 1000
	if { $apdu_ > $maximum_APDU_ } {
		set probability_ [$uniform_ value] ;# between 0 and 100
		set apdu_ [expr $maximum_APDU_ - 1000.0 + ( 10.0 * $probability_ )]
	}

	#### calculation of the number of MTU (full) packets
	set number_of_full_packets_ [ expr floor( $apdu_ / $MTU_size_) ]; #number_of_full_packets_ are MTU packets, and the last one is not full
	# send the last packet, only if the APDU is not a multiple of MTU
	if { $apdu_ != [expr $MTU_size_ * $number_of_full_packets_ ] } {

		if { $flavor_wow_ == "FullTcp" } {
			$ns at [$ns now] "$ftp_application_s_c_ send [expr $apdu_ - ($number_of_full_packets_ * $MTU_size_ ) ]"	;# using FullTcp, this sends one packet of the MTU_size_packet size
		} else {
			$ns at [$ns now] "$tcp_connection_s_c_ set packetSize_ [expr $apdu_ - ($number_of_full_packets_ * $MTU_size_ ) ]; $ftp_application_s_c_ send 1" 	;# this sends one packet of the defined packet size
		}
	}
	#puts "full packets: $number_of_full_packets_"
	for {set i 1} { $i <= $number_of_full_packets_ } { incr i } {

		if { $flavor_wow_ == "FullTcp" } {
			$ns at [expr [$ns now] + 0.01 ] "$ftp_application_s_c_ send $MTU_size_"	;# using FullTcp, this sends one packet of the MTU_size_packet size
		} else {
			$ns at [expr [$ns now] + 0.01 ] "$tcp_connection_s_c_ set packetSize_ $MTU_size_; $ftp_application_s_c_ send 1" 	;# this sends one packet of the defined packet size
		}
	}
	
	if { $packet_verbose_ == 1 } {
		if { $current_activity_($connection_ident_) != "pvp" } {
			puts "[format "%.3f" [$ns now]]: Server $connection_ident_ sends a $current_activity_($connection_ident_) APDU of length [format "%.0f" $apdu_] to client and sleeps [format "%.0f" [expr $think * 1000]] ms"
		# If the activity is PvP, I also write the name of the subactivity
		} else {
			puts "[format "%.3f" [$ns now]]: Server $connection_ident_ sends a $current_activity_($connection_ident_) $pvp_subactivity_($connection_ident_) APDU of length [format "%.0f" $apdu_] to client and sleeps [format "%.0f" [expr $think * 1000]] ms"
		}
	}
	
	# write a line in the output file
	if { $apdu_iat_files_ == 1 } {
		puts $apdu_iat_server_file_id_($connection_ident_) "[$ns now]\t$apdu_\t$think"
	}

	$ns at [expr [$ns now] + $think ] "calculate_apdu_iat_server $ns $tcp_connection_s_c_ $ftp_application_s_c_ $connection_ident_"

	# increase the counter of APDUs
	set number_apdu_server_client_($connection_ident_) [expr $number_apdu_server_client_($connection_ident_) + 1]
	set number_packets_no_saturation_server_client_($connection_ident_) [expr $number_packets_no_saturation_server_client_($connection_ident_) + $number_of_full_packets_ + 1]
	set total_bytes_apdu_server_client_($connection_ident_) [expr $total_bytes_apdu_server_client_($connection_ident_) + int($apdu_) ]

}