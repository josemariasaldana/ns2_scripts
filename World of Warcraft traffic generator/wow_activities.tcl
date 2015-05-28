############################################
#### Calculation of the next hour advance
############################################
proc calculate_next_hour_ {ns} {
	global current_hour_ hour_verbose_ hour_duration_
	
	# Advance one hour (module 24)
	set current_hour_ [expr ($current_hour_ + 1) % 24 ]

	if {$hour_verbose_ == 1 } {
		puts "[format "%.2f" [$ns now]] Hour change: $current_hour_:00"
		puts "********************************************************************************************"
	}
	$ns at [expr [$ns now] + $hour_duration_ ] "calculate_next_hour_ $ns"
}

############################################
# Create the activity duration variables
############################################
# Initializes the variables defining the duration of each activity
proc init_durations_ {ns} {
	global dungeons_duration pvp_duration questing_duration raiding_duration_a raiding_duration_b trading_duration uncategorized_duration 

	##### Generation of the seed
	#just use seconds as the seed
	set seed_ 1[lindex [split [lindex [exec date] 3] :] 2]
    set ia_ 9301
    set ic_ 49297
    set im_ 233280
	set seed_  [expr ( ($seed_ * $ia_) + $ic_ ) % $im_]

	#If you want to have always the same behaviour, uncomment this
	#set seed_ 0; #it does not work. Generates different things always

	# Create a random generator and assign it the value of seed_
	set my_random_generator_ [new RNG]
	$my_random_generator_ seed seed_

	##### dungeons duration
	set dungeons_duration [new RandomVariable/Uniform];#it is a largest extreme value, so return location + scale * log( -log( uniform( 0., 1. ) ) )
	# each time you call this variable, you must use:  set duration [expr 1321.42 + ( 1116 * ( log ( -1.0 * log ( [$dungeons_duration value]))))]
	# since the value may be negative, and "if" clause has to be included in order to set it to 0 in that case. This means that somebody has entered and exited from a dungeon
	$dungeons_duration use-rng $my_random_generator_
	$dungeons_duration set min_ 0.0
	$dungeons_duration set max_ 1.0

	##### pvp duration
	set pvp_duration [new RandomVariable/Weibull]
	$pvp_duration use-rng $my_random_generator_
	$pvp_duration set scale_ 0.61
	$pvp_duration set shape_ 603.57

	##### questing duration
	set questing_duration [new RandomVariable/Weibull]
	$questing_duration use-rng $my_random_generator_
	$questing_duration set scale_ 0.66
	$questing_duration set shape_ 440.01

	############ raiding duration varies with the hour. So an array has to be used
	# raiding_duration_a is the first possible distribution
	# raiding_duration_b is the second possible distribution

	set raiding_duration_a(0) [new RandomVariable/Weibull]
	$raiding_duration_a(0) use-rng $my_random_generator_
	$raiding_duration_a(0) set scale_ 1.046
	$raiding_duration_a(0) set shape_ 2786.5

	set raiding_duration_a(1) [new RandomVariable/Weibull]
	$raiding_duration_a(1) use-rng $my_random_generator_
	$raiding_duration_a(1) set scale_ 1.046
	$raiding_duration_a(1) set shape_ 2786.5

	set raiding_duration_a(2) [new RandomVariable/Weibull]
	$raiding_duration_a(2) use-rng $my_random_generator_
	$raiding_duration_a(2) set scale_ 1.046
	$raiding_duration_a(2) set shape_ 2786.5

	set raiding_duration_a(3) [new RandomVariable/Weibull]
	$raiding_duration_a(3) use-rng $my_random_generator_
	$raiding_duration_a(3) set scale_ 1.046
	$raiding_duration_a(3) set shape_ 2786.5

	set raiding_duration_a(4) [new RandomVariable/Weibull]
	$raiding_duration_a(4) use-rng $my_random_generator_
	$raiding_duration_a(4) set scale_ 1.046
	$raiding_duration_a(4) set shape_ 2786.5

	set raiding_duration_a(5) [new RandomVariable/Weibull]
	$raiding_duration_a(5) use-rng $my_random_generator_
	$raiding_duration_a(5) set scale_ 1.046
	$raiding_duration_a(5) set shape_ 2786.5

	set raiding_duration_a(6) [new RandomVariable/Weibull]
	$raiding_duration_a(6) use-rng $my_random_generator_
	$raiding_duration_a(6) set scale_ 1.046
	$raiding_duration_a(6) set shape_ 2786.5

	set raiding_duration_a(7) [new RandomVariable/Weibull]
	$raiding_duration_a(7) use-rng $my_random_generator_
	$raiding_duration_a(7) set scale_ 1.046
	$raiding_duration_a(7) set shape_ 2786.5

	set raiding_duration_a(8) [new RandomVariable/Weibull]
	$raiding_duration_a(8) use-rng $my_random_generator_
	$raiding_duration_a(8) set scale_ 1.046
	$raiding_duration_a(8) set shape_ 2786.5

	set raiding_duration_a(9) [new RandomVariable/Weibull]
	$raiding_duration_a(9) use-rng $my_random_generator_
	$raiding_duration_a(9) set scale_ 1.046
	$raiding_duration_a(9) set shape_ 2786.5

	set raiding_duration_a(10) [new RandomVariable/Weibull]
	$raiding_duration_a(10) use-rng $my_random_generator_
	$raiding_duration_a(10) set scale_ 1.046
	$raiding_duration_a(10) set shape_ 2786.5

	set raiding_duration_a(11) [new RandomVariable/Weibull]
	$raiding_duration_a(11) use-rng $my_random_generator_
	$raiding_duration_a(11) set scale_ 1.046
	$raiding_duration_a(11) set shape_ 2786.5

	set raiding_duration_a(12) [new RandomVariable/Weibull]
	$raiding_duration_a(12) use-rng $my_random_generator_
	$raiding_duration_a(12) set scale_ 1.046
	$raiding_duration_a(12) set shape_ 2786.5

	set raiding_duration_a(13) [new RandomVariable/Weibull]
	$raiding_duration_a(13) use-rng $my_random_generator_
	$raiding_duration_a(13) set scale_ 1.046
	$raiding_duration_a(13) set shape_ 2786.5

	set raiding_duration_a(14) [new RandomVariable/Weibull]
	$raiding_duration_a(14) use-rng $my_random_generator_
	$raiding_duration_a(14) set scale_ 1.046
	$raiding_duration_a(14) set shape_ 2786.5

	set raiding_duration_a(15) [new RandomVariable/Weibull]
	$raiding_duration_a(15) use-rng $my_random_generator_
	$raiding_duration_a(15) set scale_ 1.046
	$raiding_duration_a(15) set shape_ 2786.5

	set raiding_duration_a(16) [new RandomVariable/Weibull]
	$raiding_duration_a(16) use-rng $my_random_generator_
	$raiding_duration_a(16) set scale_ 1.046
	$raiding_duration_a(16) set shape_ 2786.5

	set raiding_duration_a(17) [new RandomVariable/Weibull]
	$raiding_duration_a(17) use-rng $my_random_generator_
	$raiding_duration_a(17) set scale_ 1.046
	$raiding_duration_a(17) set shape_ 2786.5

	set raiding_duration_a(18) [new RandomVariable/Weibull]
	$raiding_duration_a(18) use-rng $my_random_generator_
	$raiding_duration_a(18) set scale_ 1.175
	$raiding_duration_a(18) set shape_ 2513

	set raiding_duration_a(19) [new RandomVariable/Weibull]
	$raiding_duration_a(19) use-rng $my_random_generator_
	$raiding_duration_a(19) set scale_ 1.121
	$raiding_duration_a(19) set shape_ 2583.76

	set raiding_duration_a(20) [new RandomVariable/Weibull]
	$raiding_duration_a(20) use-rng $my_random_generator_
	$raiding_duration_a(20) set scale_ 1.279
	$raiding_duration_a(20) set shape_ 3303.08

	set raiding_duration_a(21) [new RandomVariable/Weibull]
	$raiding_duration_a(21) use-rng $my_random_generator_
	$raiding_duration_a(21) set scale_ 1.368
	$raiding_duration_a(21) set shape_ 6476.7

	set raiding_duration_a(22) [new RandomVariable/Weibull]
	$raiding_duration_a(22) use-rng $my_random_generator_
	$raiding_duration_a(22) set scale_ 1.046
	$raiding_duration_a(22) set shape_ 2786.5

	set raiding_duration_a(23) [new RandomVariable/Weibull]
	$raiding_duration_a(23) use-rng $my_random_generator_
	$raiding_duration_a(23) set scale_ 1.046
	$raiding_duration_a(23) set shape_ 2786.5
	
	# Second possible distribution for raiding
	# In some hours, two different distributios are considered
	# Only the hours where two distributions exist are defined as raiding_duration_b(xx)
	set raiding_duration_b(0) -1
	set raiding_duration_b(1) -1
	set raiding_duration_b(2) -1
	set raiding_duration_b(3) -1
	set raiding_duration_b(4) -1
	set raiding_duration_b(5) -1
	set raiding_duration_b(6) -1
	set raiding_duration_b(7) -1
	set raiding_duration_b(8) -1
	set raiding_duration_b(9) -1
	set raiding_duration_b(10) -1
	set raiding_duration_b(11) -1
	set raiding_duration_b(12) -1
	set raiding_duration_b(13) -1
	set raiding_duration_b(14) -1
	set raiding_duration_b(15) -1
	set raiding_duration_b(16) -1
	set raiding_duration_b(17) -1

	set raiding_duration_b(18) [new RandomVariable/Weibull]
	$raiding_duration_b(18) use-rng $my_random_generator_
	$raiding_duration_b(18) set scale_ 6.110
	$raiding_duration_b(18) set shape_ 15306.5

	set raiding_duration_b(19) [new RandomVariable/LogNormal]
	$raiding_duration_b(19) use-rng $my_random_generator_
	$raiding_duration_b(19) set avg_ 9.4173 ;#these are the avg and the stdev of the normal distribution that generates the lognormal one
	$raiding_duration_b(19) set std_ 0.227

	set raiding_duration_b(20) [new RandomVariable/LogNormal]
	$raiding_duration_b(20) use-rng $my_random_generator_
	$raiding_duration_b(20) set avg_ 9.287 ;#these are the avg and the stdev of the normal distribution that generates the lognormal one
    $raiding_duration_b(20) set std_ 0.19762

	set raiding_duration_b(21) -1
	set raiding_duration_b(22) -1
	set raiding_duration_b(23) -1
	
	##### trading duration
	set trading_duration [new RandomVariable/Weibull]
	$trading_duration use-rng $my_random_generator_
	$trading_duration set scale_ 0.69
	$trading_duration set shape_ 190.98

	##### uncagtegorized duration
	set uncategorized_duration [new RandomVariable/Weibull]; #It is a 3-parameter Weibull, so a value of 300.96 has to be added each time the function is called
	# each time you call this variable, you have to write: set duration [expr (300.96 + [$uncategorized_duration value])];
	$uncategorized_duration use-rng $my_random_generator_
	$uncategorized_duration set scale_ 0.79
	$uncategorized_duration set shape_ 567.06
}


############################################
#### Calculation of the first activity
#### It calculates the first activity depending on the hour. When it ends, calls "calculate_next_activity_"
############################################
proc calculate_first_activity_ { current_activity_ ns connection_ident_ args } { ;#the word "args" has to be included when more than one argument is passed
	upvar $current_activity_ current_act_ ;#this links the global array variable current_activity_ with local array current_act_. Modifications in current_act_ propagate to current_activity_
	global activity_verbose_ uniform_ \
		dungeons_duration pvp_duration questing_duration raiding_duration_a raiding_duration_b trading_duration uncategorized_duration \
		activity_files_ activity_file_id_ activity_file_id_total_ pvp_subactivity_ \
		current_hour_ ;# Hour of the day: between 0 and 23

	############# Hour of the day:  0:00 - 1:00	
	set dungeons_start_(0) 0.574712643678161	
	set pvp_start_(0) 7.47126436781609	
	set questing_start_(0) 13.2183908045977	
	set raiding_start_(0) 2.29885057471264	
	set trading_start_(0) 67.2413793103448	
	set uncategorized_start_(0) 9.19540229885057	

	############# Hour of the day:  1:00 - 2:00
	set dungeons_start_(1) 2.83018867924528
	set pvp_start_(1) 5.66037735849057
	set questing_start_(1) 19.811320754717
	set raiding_start_(1) 1.88679245283019
	set trading_start_(1) 62.2641509433962
	set uncategorized_start_(1) 7.54716981132075

	############# Hour of the day:  2:00 - 3:00
	set dungeons_start_(2) 2.8169014084507
	set pvp_start_(2) 4.22535211267606
	set questing_start_(2) 9.85915492957746
	set raiding_start_(2) 2.8169014084507
	set trading_start_(2) 71.830985915493
	set uncategorized_start_(2) 8.45070422535211
	
	############# Hour of the day:  3:00 - 4:00
	set dungeons_start_(3) 0
	set pvp_start_(3) 2.5
	set questing_start_(3) 12.5
	set raiding_start_(3) 2.5
	set trading_start_(3) 75
	set uncategorized_start_(3) 7.5
	
	############# Hour of the day:  4:00 - 5:00
	set dungeons_start_(4) 0
	set pvp_start_(4) 5.55555555555556
	set questing_start_(4) 22.2222222222222
	set raiding_start_(4) 0
	set trading_start_(4) 61.1111111111111
	set uncategorized_start_(4) 11.1111111111111
	
	############# Hour of the day:  5:00 - 6:00
	set dungeons_start_(5) 0
	set pvp_start_(5) 0
	set questing_start_(5) 50
	set raiding_start_(5) 0
	set trading_start_(5) 41.6666666666667
	set uncategorized_start_(5) 8.33333333333333
	
	############# Hour of the day:  6:00 - 7:00
	set dungeons_start_(6) 0
	set pvp_start_(6) 0
	set questing_start_(6) 25
	set raiding_start_(6) 6.25
	set trading_start_(6) 68.75
	set uncategorized_start_(6) 0
	
	############# Hour of the day:  7:00 - 8:00
	set dungeons_start_(7) 0
	set pvp_start_(7) 0
	set questing_start_(7) 18.1818181818182
	set raiding_start_(7) 0
	set trading_start_(7) 75
	set uncategorized_start_(7) 6.81818181818182
	
	############# Hour of the day:  8:00 - 9:00
	set dungeons_start_(8) 1.12359550561798
	set pvp_start_(8) 2.24719101123596
	set questing_start_(8) 14.6067415730337
	set raiding_start_(8) 1.12359550561798
	set trading_start_(8) 75.2808988764045
	set uncategorized_start_(8) 5.61797752808989
	
	############# Hour of the day:  9:00 - 10:00
	set dungeons_start_(9) 0.740740740740741
	set pvp_start_(9) 5.92592592592593
	set questing_start_(9) 22.2222222222222
	set raiding_start_(9) 0
	set trading_start_(9) 62.2222222222222
	set uncategorized_start_(9) 8.88888888888889
	
	############# Hour of the day:  10:00 - 11:00
	set dungeons_start_(10) 0.458715596330275
	set pvp_start_(10) 5.5045871559633
	set questing_start_(10) 23.394495412844
	set raiding_start_(10) 0.917431192660551
	set trading_start_(10) 64.2201834862385
	set uncategorized_start_(10) 5.5045871559633
	
	############# Hour of the day:  11:00 - 12:00
	set dungeons_start_(11) 0.350877192982456
	set pvp_start_(11) 3.85964912280702
	set questing_start_(11) 21.0526315789474
	set raiding_start_(11) 1.05263157894737
	set trading_start_(11) 65.9649122807018
	set uncategorized_start_(11) 7.71929824561404
	
	############# Hour of the day:  12:00 - 13:00
	set dungeons_start_(12) 1.16618075801749
	set pvp_start_(12) 9.03790087463557
	set questing_start_(12) 20.4081632653061
	set raiding_start_(12) 0.583090379008746
	set trading_start_(12) 60.3498542274053
	set uncategorized_start_(12) 8.45481049562682
	
	############# Hour of the day:  13:00 - 14:00
	set dungeons_start_(13) 1.94986072423398
	set pvp_start_(13) 5.84958217270195
	set questing_start_(13) 19.2200557103064
	set raiding_start_(13) 1.39275766016713
	set trading_start_(13) 62.6740947075209
	set uncategorized_start_(13) 8.91364902506964
	
	############# Hour of the day:  14:00 - 15:00
	set dungeons_start_(14) 0.611620795107034
	set pvp_start_(14) 8.56269113149847
	set questing_start_(14) 21.4067278287462
	set raiding_start_(14) 1.8348623853211
	set trading_start_(14) 57.1865443425077
	set uncategorized_start_(14) 10.3975535168196
	
	############# Hour of the day:  15:00 - 16:00
	set dungeons_start_(15) 1.58730158730159
	set pvp_start_(15) 5.71428571428571
	set questing_start_(15) 23.4920634920635
	set raiding_start_(15) 2.53968253968254
	set trading_start_(15) 60
	set uncategorized_start_(15) 6.66666666666667
	
	############# Hour of the day:  16:00 - 17:00
	set dungeons_start_(16) 0.550964187327824
	set pvp_start_(16) 6.33608815426997
	set questing_start_(16) 19.0082644628099
	set raiding_start_(16) 1.92837465564738
	set trading_start_(16) 65.8402203856749
	set uncategorized_start_(16) 6.33608815426997
	
	############# Hour of the day:  17:00 - 18:00
	set dungeons_start_(17) 1.24378109452736
	set pvp_start_(17) 7.71144278606965
	set questing_start_(17) 20.1492537313433
	set raiding_start_(17) 2.48756218905473
	set trading_start_(17) 61.6915422885572
	set uncategorized_start_(17) 6.71641791044776
	
	############# Hour of the day:  18:00 - 19:00
	set dungeons_start_(18) 0.706713780918728
	set pvp_start_(18) 6.53710247349823
	set questing_start_(18) 16.2544169611307
	set raiding_start_(18) 4.77031802120141
	set trading_start_(18) 59.7173144876325
	set uncategorized_start_(18) 12.0141342756184
	
	############# Hour of the day:  19:00 - 20:00
	set dungeons_start_(19) 1.00401606425703
	set pvp_start_(19) 8.03212851405623
	set questing_start_(19) 12.85140562249
	set raiding_start_(19) 10.0401606425703
	set trading_start_(19) 62.0481927710843
	set uncategorized_start_(19) 6.02409638554217
	
	############# Hour of the day:  20:00 - 21:00
	set dungeons_start_(20) 1.30548302872063
	set pvp_start_(20) 9.13838120104439
	set questing_start_(20) 17.4934725848564
	set raiding_start_(20) 7.57180156657963
	set trading_start_(20) 56.3968668407311
	set uncategorized_start_(20) 8.09399477806789
	
	############# Hour of the day:  21:00 - 22:00
	set dungeons_start_(21) 0
	set pvp_start_(21) 10.7843137254902
	set questing_start_(21) 19.9346405228758
	set raiding_start_(21) 4.90196078431373
	set trading_start_(21) 59.1503267973856
	set uncategorized_start_(21) 5.22875816993464
	
	############# Hour of the day:  22:00 - 23:00
	set dungeons_start_(22) 0.738007380073801
	set pvp_start_(22) 9.22509225092251
	set questing_start_(22) 19.9261992619926
	set raiding_start_(22) 7.38007380073801
	set trading_start_(22) 54.2435424354244
	set uncategorized_start_(22) 8.48708487084871
	
	############# Hour of the day:  23:00 - 24:00
	set dungeons_start_(23) 3.37078651685393
	set pvp_start_(23) 7.49063670411985
	set questing_start_(23) 19.4756554307116
	set raiding_start_(23) 3.74531835205993
	set trading_start_(23) 57.3033707865169
	set uncategorized_start_(23) 8.61423220973783
	

	#I calculate a probability
	set probability_ [$uniform_ value]
	#puts "probability: $probability_"

	#Calculation of the first activity
	
		if {$probability_ < $dungeons_start_($current_hour_) } {
			set current_act_($connection_ident_) dungeons
		} else {
			if {$probability_ < [expr $dungeons_start_($current_hour_) + $pvp_start_($current_hour_) ]} {
				set current_act_($connection_ident_) pvp
				calculate_pvp_subactivity_ $connection_ident_
			} else {
				if {$probability_ < [expr $dungeons_start_($current_hour_) + $pvp_start_($current_hour_) + $questing_start_($current_hour_) ] } {
					set current_act_($connection_ident_) questing
				} else {
					if {$probability_ < [expr $dungeons_start_($current_hour_) + $pvp_start_($current_hour_) + $questing_start_($current_hour_) + $raiding_start_($current_hour_) ] } {
						set current_act_($connection_ident_) raiding
					} else {
						if {$probability_ < [expr $dungeons_start_($current_hour_) + $pvp_start_($current_hour_) + $questing_start_($current_hour_) + $raiding_start_($current_hour_) + $trading_start_($current_hour_) ] } {
							set current_act_($connection_ident_) trading
						} else {
							#if {$probability_ < [expr $dungeons_start_($current_hour_) + $pvp_start_($current_hour_) + $questing_start_($current_hour_) + $raiding_start_($current_hour_) + $trading_start_($current_hour_) + $uncategorized_start_($current_hour_) ] } {
								set current_act_($connection_ident_) uncategorized
							#}
						}
					}
				}
			}
		}
	
	
	# Set the duration depending on the value of the new current_activity_

	if { $current_act_($connection_ident_) == "dungeons" } {
		set duration [expr 1321.42 + ( 1116 * ( log ( -1.0 * log ( [$dungeons_duration value]))))]
		if { $duration < 0.0 } {
			set duration 0.0
		}
	} else {
		if { $current_act_($connection_ident_) == "pvp" } {
			set duration [$pvp_duration value]
		} else {
			if { $current_act_($connection_ident_) == "raiding" } {
				###################### Raiding duration depends on the hour of the day
				set probability_ [$uniform_ value] ;# a value between 0 and 100
				if { $current_hour_ == 18 } {
					if { $probability_ <= 42.0 } {
						set duration [$raiding_duration_a($current_hour_) value]
					} else {
						set duration [$raiding_duration_b($current_hour_) value]
					}
				} else {
					if { $current_hour_ ==19 } {
						if { $probability_ <= 44.0 } {
							set duration [$raiding_duration_a($current_hour_) value]
						} else {
							set duration [$raiding_duration_b($current_hour_) value]
						}
					} else {
						if { $current_hour_ ==20 } {
							if { $probability_ <= 42.0 } {
								set duration [$raiding_duration_a($current_hour_) value]
							} else {
								set duration [$raiding_duration_b($current_hour_) value]
							}
						} else { ;#in all these cases, only a distribution is used
							set duration [$raiding_duration_a($current_hour_) value]
						}
					}
				}
			} else {
				if { $current_act_($connection_ident_) == "trading" } {
					set duration [$trading_duration value]
				} else {
					if { $current_act_($connection_ident_) == "questing" } {
						set duration [$questing_duration value]
					} else {
						if { $current_act_($connection_ident_) == "uncategorized" } {
							set duration [expr (300.96 + [$uncategorized_duration value])];#300.96 is the value of the location parameter
						}
					}
				}
			}
		}
	}

	#set next_activity_change_ [expr [$ns now] + $duration ]

	if {$activity_verbose_ == 1 } {
		if { $current_act_($connection_ident_) != "pvp" } {
			puts "Conn. $connection_ident_: [format "%.2f" [$ns now]] First activity: $current_act_($connection_ident_) (duration [format "%.2f" $duration]) Next activity change: [format "%.2f" [expr [$ns now] + $duration ]]"

		# If the activity is PvP, I also write the name of the subactivity
		} else {
			puts "Conn. $connection_ident_: [format "%.2f" [$ns now]] First activity: $current_act_($connection_ident_) $pvp_subactivity_($connection_ident_) (duration [format "%.2f" $duration]) Next activity change: [format "%.2f" [expr [$ns now] + $duration ]]"
		}
		puts "************************************************************************************************************"
	}

	# write a line in the activity file
	if {$activity_files_ == 1 } {
		if { $current_act_($connection_ident_) != "pvp" } {
			puts $activity_file_id_($connection_ident_) "[$ns now]\t[format "%.2f" $duration]\t$current_act_($connection_ident_)\t\thour: \t$current_hour_\t:00"
			puts $activity_file_id_total_ "[$ns now]\t[format "%.2f" $duration]\t$connection_ident_\t$current_act_($connection_ident_)\t\thour: \t$current_hour_\t:00"

		# If the activity is PvP, I also write the name of the subactivity
		} else {
			puts $activity_file_id_($connection_ident_) "[$ns now]\t[format "%.2f" $duration]\t$current_act_($connection_ident_)\t$pvp_subactivity_($connection_ident_)\thour: \t$current_hour_\t:00"
			puts $activity_file_id_total_ "[$ns now]\t[format "%.2f" $duration]\t$connection_ident_\t$current_act_($connection_ident_)\t$pvp_subactivity_($connection_ident_)\thour: \t$current_hour_\t:00"
		}
	}

	# program the next activity change of this client
	$ns at [expr [$ns now] + $duration ] "calculate_next_activity_ current_activity_ $ns $connection_ident_"

}

############################################
#### Calculation of the PvP subactivity
############################################

# If PvP is the next activity, we have to calculate if it is a battleground or an arena
# If it is a battleground, we have to select one of them
# If it is an arena, we have to select between 2vs2, 3vs3 or 5vs5

proc calculate_pvp_subactivity_ { connection_ident_ } {
	global ns pvp_subactivity_ activity_verbose_ activity_files_ activity_file_id_ uniform_ current_hour_ 

	#I calculate a probability
	set probability_ [$uniform_ value]

	if { $probability_ < 50.0 } {
		# BATTLEGROUND
		set probability_ [$uniform_ value] ;# a value between 0 and 100 to select one of the 5 battlegrounds, according to their probabilities
		set acum_prob_ 32.89 ; #to save the different percentages
		if { $probability_ < $acum_prob_ } {
			# Alterac Valley
			set pvp_subactivity_($connection_ident_) "alterac_valley"
		} else {
			if { $probability_ < $acum_prob_ + 24.56 } {
				# Arathi Basin
				set pvp_subactivity_($connection_ident_) "arathi_basin"
			} else {
				if { $probability_ < $acum_prob_ + 32.50 } {
					# Warsong Gulch
					set pvp_subactivity_($connection_ident_) "warsong_gulch"
				} else {
					if { $probability_ < $acum_prob_ + 32.50 } {
						# Eye of the Storm
						set pvp_subactivity_($connection_ident_) "eye_of_the_storm"
					} else {
						# Strand of the Ancients	;# remaining probability: 2.08%
						set pvp_subactivity_($connection_ident_) "strand_of_the_ancients"
					}
				}
			}
		}
	} else {
		# ARENA
		set probability [$uniform_ value] ;# a value between 0 and 100 to select one of the 5 battlegrounds, according to their probabilities
		set acum_prob_ 45.04 ; #to save the different percentages
		if { $probability < $acum_prob_ } {
			# 2v2
			set pvp_subactivity_($connection_ident_) "arena_2v2"
		} else {
			if { $probability < $acum_prob_ + 45.16 } {
				# 3v3
				set pvp_subactivity_($connection_ident_) "arena_3v3"
			} else {
				# remaining percentage 9.78%
				# 5v5
				set pvp_subactivity_($connection_ident_) "arena_5v5"
			}
		}
	}
}


############################################
#### Calculation of the next activity
############################################
proc calculate_next_activity_ {current_activity_ ns connection_ident_ args} {
	upvar $current_activity_ current_act_ ;#this links the global array variable current_activity_ with local array current_act_
	global activity_verbose_ uniform_ \
		dungeons_duration pvp_duration questing_duration raiding_duration_a raiding_duration_b trading_duration uncategorized_duration \
		activity_files_ activity_file_id_ activity_file_id_total_ pvp_subactivity_ \
		current_hour_ ;# Hour of the day: between 0 and 23

	############# Hour of the day:  0:00 - 1:00
	set dungeons_to_dungeons_(0) 0
	set dungeons_to_pvp_(0) 3.7037037037037
	set dungeons_to_questing_(0) 28.3950617283951
	set dungeons_to_raiding_(0) 3.7037037037037
	set dungeons_to_trading_(0) 58.0246913580247
	set dungeons_to_uncategorized_(0) 6.17283950617284
	
	set pvp_to_dungeons_(0) 1.71673819742489
	set pvp_to_pvp_(0) 18.0257510729614
	set pvp_to_questing_(0) 30.0429184549356
	set pvp_to_raiding_(0) 2.14592274678112
	set pvp_to_trading_(0) 39.0557939914163
	set pvp_to_uncategorized_(0) 9.01287553648069
	
	set questing_to_dungeons_(0) 2.99625468164794
	set questing_to_pvp_(0) 10.8614232209738
	set questing_to_questing_(0) 4.68164794007491
	set questing_to_raiding_(0) 0.561797752808989
	set questing_to_trading_(0) 69.2883895131086
	set questing_to_uncategorized_(0) 11.6104868913858
	
	set raiding_to_dungeons_(0) 0
	set raiding_to_pvp_(0) 3.7593984962406
	set raiding_to_questing_(0) 8.27067669172932
	set raiding_to_raiding_(0) 0
	set raiding_to_trading_(0) 83.4586466165414
	set raiding_to_uncategorized_(0) 4.51127819548872
	
	set trading_to_dungeons_(0) 2.31335436382755
	set trading_to_pvp_(0) 8.51735015772871
	set trading_to_questing_(0) 31.8611987381703
	set trading_to_raiding_(0) 2.10304942166141
	set trading_to_trading_(0) 3.68033648790747
	set trading_to_uncategorized_(0) 51.5247108307045
	
	set uncategorized_to_dungeons_(0) 3.14814814814815
	set uncategorized_to_pvp_(0) 7.40740740740741
	set uncategorized_to_questing_(0) 19.8148148148148
	set uncategorized_to_raiding_(0) 4.07407407407407
	set uncategorized_to_trading_(0) 63.3333333333333
	set uncategorized_to_uncategorized_(0) 2.22222222222222
	
	############# Hour of the day:  1:00 - 2:00
	set dungeons_to_dungeons_(1) 0
	set dungeons_to_pvp_(1) 4.6875
	set dungeons_to_questing_(1) 23.4375
	set dungeons_to_raiding_(1) 10.9375
	set dungeons_to_trading_(1) 45.3125
	set dungeons_to_uncategorized_(1) 15.625
	
	set pvp_to_dungeons_(1) 1.61290322580645
	set pvp_to_pvp_(1) 21.505376344086
	set pvp_to_questing_(1) 25.2688172043011
	set pvp_to_raiding_(1) 1.0752688172043
	set pvp_to_trading_(1) 40.8602150537634
	set pvp_to_uncategorized_(1) 9.67741935483871
	
	set questing_to_dungeons_(1) 2.92682926829268
	set questing_to_pvp_(1) 7.5609756097561
	set questing_to_questing_(1) 3.65853658536585
	set questing_to_raiding_(1) 0.24390243902439
	set questing_to_trading_(1) 74.8780487804878
	set questing_to_uncategorized_(1) 10.7317073170732
	
	set raiding_to_dungeons_(1) 5.06329113924051
	set raiding_to_pvp_(1) 1.26582278481013
	set raiding_to_questing_(1) 0
	set raiding_to_raiding_(1) 1.26582278481013
	set raiding_to_trading_(1) 86.0759493670886
	set raiding_to_uncategorized_(1) 6.32911392405063
	
	set trading_to_dungeons_(1) 1.82370820668693
	set trading_to_pvp_(1) 8.66261398176292
	set trading_to_questing_(1) 38.145896656535
	set trading_to_raiding_(1) 3.03951367781155
	set trading_to_trading_(1) 1.06382978723404
	set trading_to_uncategorized_(1) 47.2644376899696
	
	set uncategorized_to_dungeons_(1) 4.33673469387755
	set uncategorized_to_pvp_(1) 6.63265306122449
	set uncategorized_to_questing_(1) 19.1326530612245
	set uncategorized_to_raiding_(1) 2.04081632653061
	set uncategorized_to_trading_(1) 64.030612244898
	set uncategorized_to_uncategorized_(1) 3.8265306122449
	
	############# Hour of the day:  2:00 - 3:00
	set dungeons_to_dungeons_(2) 4.16666666666667
	set dungeons_to_pvp_(2) 4.16666666666667
	set dungeons_to_questing_(2) 8.33333333333333
	set dungeons_to_raiding_(2) 4.16666666666667
	set dungeons_to_trading_(2) 66.6666666666667
	set dungeons_to_uncategorized_(2) 12.5
	
	set pvp_to_dungeons_(2) 0.675675675675676
	set pvp_to_pvp_(2) 20.9459459459459
	set pvp_to_questing_(2) 21.6216216216216
	set pvp_to_raiding_(2) 0.675675675675676
	set pvp_to_trading_(2) 45.2702702702703
	set pvp_to_uncategorized_(2) 10.8108108108108
	
	set questing_to_dungeons_(2) 0.392156862745098
	set questing_to_pvp_(2) 14.9019607843137
	set questing_to_questing_(2) 5.09803921568627
	set questing_to_raiding_(2) 0.392156862745098
	set questing_to_trading_(2) 69.8039215686274
	set questing_to_uncategorized_(2) 9.41176470588235
	
	set raiding_to_dungeons_(2) 0
	set raiding_to_pvp_(2) 4.54545454545455
	set raiding_to_questing_(2) 0
	set raiding_to_raiding_(2) 0
	set raiding_to_trading_(2) 93.1818181818182
	set raiding_to_uncategorized_(2) 2.27272727272727
	
	set trading_to_dungeons_(2) 1.66270783847981
	set trading_to_pvp_(2) 11.4014251781473
	set trading_to_questing_(2) 34.2042755344418
	set trading_to_raiding_(2) 4.27553444180523
	set trading_to_trading_(2) 2.37529691211401
	set trading_to_uncategorized_(2) 46.0807600950119
	
	set uncategorized_to_dungeons_(2) 1.19521912350598
	set uncategorized_to_pvp_(2) 13.1474103585657
	set uncategorized_to_questing_(2) 16.3346613545817
	set uncategorized_to_raiding_(2) 1.99203187250996
	set uncategorized_to_trading_(2) 64.5418326693227
	set uncategorized_to_uncategorized_(2) 2.78884462151394

	############# Hour of the day:  3:00 - 4:00
	set dungeons_to_dungeons_(3) 0
	set dungeons_to_pvp_(3) 0
	set dungeons_to_questing_(3) 22.2222222222222
	set dungeons_to_raiding_(3) 11.1111111111111
	set dungeons_to_trading_(3) 55.5555555555556
	set dungeons_to_uncategorized_(3) 11.1111111111111
	
	set pvp_to_dungeons_(3) 0.869565217391304
	set pvp_to_pvp_(3) 22.6086956521739
	set pvp_to_questing_(3) 46.0869565217391
	set pvp_to_raiding_(3) 0
	set pvp_to_trading_(3) 19.1304347826087
	set pvp_to_uncategorized_(3) 11.304347826087
	
	set questing_to_dungeons_(3) 1.50753768844221
	set questing_to_pvp_(3) 16.0804020100502
	set questing_to_questing_(3) 10.0502512562814
	set questing_to_raiding_(3) 0.50251256281407
	set questing_to_trading_(3) 64.321608040201
	set questing_to_uncategorized_(3) 7.53768844221105
	
	set raiding_to_dungeons_(3) 0
	set raiding_to_pvp_(3) 7.69230769230769
	set raiding_to_questing_(3) 0
	set raiding_to_raiding_(3) 0
	set raiding_to_trading_(3) 92.3076923076923
	set raiding_to_uncategorized_(3) 0
	
	set trading_to_dungeons_(3) 1.20967741935484
	set trading_to_pvp_(3) 8.06451612903226
	set trading_to_questing_(3) 44.758064516129
	set trading_to_raiding_(3) 2.01612903225806
	set trading_to_trading_(3) 11.6935483870968
	set trading_to_uncategorized_(3) 32.258064516129
	
	set uncategorized_to_dungeons_(3) 1.66666666666667
	set uncategorized_to_pvp_(3) 15.8333333333333
	set uncategorized_to_questing_(3) 30
	set uncategorized_to_raiding_(3) 3.33333333333333
	set uncategorized_to_trading_(3) 45
	set uncategorized_to_uncategorized_(3) 4.16666666666667
	
	############# Hour of the day:  4:00 - 5:00
	set dungeons_to_dungeons_(4) 0
	set dungeons_to_pvp_(4) 0
	set dungeons_to_questing_(4) 0
	set dungeons_to_raiding_(4) 0
	set dungeons_to_trading_(4) 100
	set dungeons_to_uncategorized_(4) 0
	
	set pvp_to_dungeons_(4) 0
	set pvp_to_pvp_(4) 25.4237288135593
	set pvp_to_questing_(4) 35.5932203389831
	set pvp_to_raiding_(4) 1.69491525423729
	set pvp_to_trading_(4) 28.8135593220339
	set pvp_to_uncategorized_(4) 8.47457627118644
	
	set questing_to_dungeons_(4) 0
	set questing_to_pvp_(4) 14.2857142857143
	set questing_to_questing_(4) 11.4285714285714
	set questing_to_raiding_(4) 0.952380952380952
	set questing_to_trading_(4) 67.6190476190476
	set questing_to_uncategorized_(4) 5.71428571428571
	
	set raiding_to_dungeons_(4) 0
	set raiding_to_pvp_(4) 8.33333333333333
	set raiding_to_questing_(4) 16.6666666666667
	set raiding_to_raiding_(4) 0
	set raiding_to_trading_(4) 75
	set raiding_to_uncategorized_(4) 0
	
	set trading_to_dungeons_(4) 0
	set trading_to_pvp_(4) 11.864406779661
	set trading_to_questing_(4) 38.9830508474576
	set trading_to_raiding_(4) 3.38983050847458
	set trading_to_trading_(4) 3.38983050847458
	set trading_to_uncategorized_(4) 42.3728813559322
	
	set uncategorized_to_dungeons_(4) 1.51515151515152
	set uncategorized_to_pvp_(4) 13.6363636363636
	set uncategorized_to_questing_(4) 28.7878787878788
	set uncategorized_to_raiding_(4) 0
	set uncategorized_to_trading_(4) 53.030303030303
	set uncategorized_to_uncategorized_(4) 3.03030303030303
	
	############# Hour of the day:  5:00 - 6:00
	set dungeons_to_dungeons_(5) 0
	set dungeons_to_pvp_(5) 0
	set dungeons_to_questing_(5) 0
	set dungeons_to_raiding_(5) 0
	set dungeons_to_trading_(5) 100
	set dungeons_to_uncategorized_(5) 0
	
	set pvp_to_dungeons_(5) 0
	set pvp_to_pvp_(5) 22.2222222222222
	set pvp_to_questing_(5) 11.1111111111111
	set pvp_to_raiding_(5) 0
	set pvp_to_trading_(5) 44.4444444444444
	set pvp_to_uncategorized_(5) 22.2222222222222
	
	set questing_to_dungeons_(5) 0
	set questing_to_pvp_(5) 16.1290322580645
	set questing_to_questing_(5) 0
	set questing_to_raiding_(5) 3.2258064516129
	set questing_to_trading_(5) 64.5161290322581
	set questing_to_uncategorized_(5) 16.1290322580645
	
	set raiding_to_dungeons_(5) 0
	set raiding_to_pvp_(5) 0
	set raiding_to_questing_(5) 50
	set raiding_to_raiding_(5) 0
	set raiding_to_trading_(5) 50
	set raiding_to_uncategorized_(5) 0
	
	set trading_to_dungeons_(5) 0
	set trading_to_pvp_(5) 9.375
	set trading_to_questing_(5) 50
	set trading_to_raiding_(5) 0
	set trading_to_trading_(5) 3.125
	set trading_to_uncategorized_(5) 37.5
	
	set uncategorized_to_dungeons_(5) 0
	set uncategorized_to_pvp_(5) 0
	set uncategorized_to_questing_(5) 30.7692307692308
	set uncategorized_to_raiding_(5) 0
	set uncategorized_to_trading_(5) 53.8461538461538
	set uncategorized_to_uncategorized_(5) 15.3846153846154
	
	############# Hour of the day:  6:00 - 7:00
	set dungeons_to_dungeons_(6) 0
	set dungeons_to_pvp_(6) 0
	set dungeons_to_questing_(6) 0
	set dungeons_to_raiding_(6) 0
	set dungeons_to_trading_(6) 0
	set dungeons_to_uncategorized_(6) 100
	
	set pvp_to_dungeons_(6) 0
	set pvp_to_pvp_(6) 0
	set pvp_to_questing_(6) 50
	set pvp_to_raiding_(6) 0
	set pvp_to_trading_(6) 50
	set pvp_to_uncategorized_(6) 0
	
	set questing_to_dungeons_(6) 3.7037037037037
	set questing_to_pvp_(6) 0
	set questing_to_questing_(6) 0
	set questing_to_raiding_(6) 0
	set questing_to_trading_(6) 81.4814814814815
	set questing_to_uncategorized_(6) 14.8148148148148
	
	set raiding_to_dungeons_(6) 0
	set raiding_to_pvp_(6) 0
	set raiding_to_questing_(6) 0
	set raiding_to_raiding_(6) 0
	set raiding_to_trading_(6) 100
	set raiding_to_uncategorized_(6) 0
	
	set trading_to_dungeons_(6) 0
	set trading_to_pvp_(6) 9.75609756097561
	set trading_to_questing_(6) 34.1463414634146
	set trading_to_raiding_(6) 0
	set trading_to_trading_(6) 2.4390243902439
	set trading_to_uncategorized_(6) 53.6585365853659
	
	set uncategorized_to_dungeons_(6) 0
	set uncategorized_to_pvp_(6) 0
	set uncategorized_to_questing_(6) 36
	set uncategorized_to_raiding_(6) 0
	set uncategorized_to_trading_(6) 60
	set uncategorized_to_uncategorized_(6) 4

	############# Hour of the day:  7:00 - 8:00
	set dungeons_to_dungeons_(7) 0
	set dungeons_to_pvp_(7) 0
	set dungeons_to_questing_(7) 100
	set dungeons_to_raiding_(7) 0
	set dungeons_to_trading_(7) 0
	set dungeons_to_uncategorized_(7) 0
	
	set pvp_to_dungeons_(7) 0
	set pvp_to_pvp_(7) 20
	set pvp_to_questing_(7) 60
	set pvp_to_raiding_(7) 0
	set pvp_to_trading_(7) 20
	set pvp_to_uncategorized_(7) 0
	
	set questing_to_dungeons_(7) 0
	set questing_to_pvp_(7) 11.7647058823529
	set questing_to_questing_(7) 3.92156862745098
	set questing_to_raiding_(7) 0
	set questing_to_trading_(7) 66.6666666666667
	set questing_to_uncategorized_(7) 17.6470588235294
	
	set raiding_to_dungeons_(7) 0
	set raiding_to_pvp_(7) 0
	set raiding_to_questing_(7) 100
	set raiding_to_raiding_(7) 0
	set raiding_to_trading_(7) 0
	set raiding_to_uncategorized_(7) 0
	
	set trading_to_dungeons_(7) 0
	set trading_to_pvp_(7) 3.125
	set trading_to_questing_(7) 60.9375
	set trading_to_raiding_(7) 0
	set trading_to_trading_(7) 1.5625
	set trading_to_uncategorized_(7) 34.375
	
	set uncategorized_to_dungeons_(7) 0
	set uncategorized_to_pvp_(7) 6.66666666666667
	set uncategorized_to_questing_(7) 33.3333333333333
	set uncategorized_to_raiding_(7) 0
	set uncategorized_to_trading_(7) 60
	set uncategorized_to_uncategorized_(7) 0

	############# Hour of the day:  8:00 - 9:00
	set dungeons_to_dungeons_(8) 0
	set dungeons_to_pvp_(8) 0
	set dungeons_to_questing_(8) 100
	set dungeons_to_raiding_(8) 0
	set dungeons_to_trading_(8) 0
	set dungeons_to_uncategorized_(8) 0
	
	set pvp_to_dungeons_(8) 0
	set pvp_to_pvp_(8) 11.7647058823529
	set pvp_to_questing_(8) 52.9411764705882
	set pvp_to_raiding_(8) 0
	set pvp_to_trading_(8) 17.6470588235294
	set pvp_to_uncategorized_(8) 17.6470588235294
	
	set questing_to_dungeons_(8) 2.22222222222222
	set questing_to_pvp_(8) 10
	set questing_to_questing_(8) 3.33333333333333
	set questing_to_raiding_(8) 0
	set questing_to_trading_(8) 71.1111111111111
	set questing_to_uncategorized_(8) 13.3333333333333
	
	set raiding_to_dungeons_(8) 0
	set raiding_to_pvp_(8) 0
	set raiding_to_questing_(8) 0
	set raiding_to_raiding_(8) 0
	set raiding_to_trading_(8) 100
	set raiding_to_uncategorized_(8) 0
	
	set trading_to_dungeons_(8) 0
	set trading_to_pvp_(8) 2.4390243902439
	set trading_to_questing_(8) 56.9105691056911
	set trading_to_raiding_(8) 0.813008130081301
	set trading_to_trading_(8) 5.69105691056911
	set trading_to_uncategorized_(8) 34.1463414634146
	
	set uncategorized_to_dungeons_(8) 0
	set uncategorized_to_pvp_(8) 8.69565217391304
	set uncategorized_to_questing_(8) 34.7826086956522
	set uncategorized_to_raiding_(8) 0
	set uncategorized_to_trading_(8) 56.5217391304348
	set uncategorized_to_uncategorized_(8) 0
		
	############# Hour of the day:  9:00 - 10:00
	set dungeons_to_dungeons_(9) 0
	set dungeons_to_pvp_(9) 12.5
	set dungeons_to_questing_(9) 37.5
	set dungeons_to_raiding_(9) 0
	set dungeons_to_trading_(9) 25
	set dungeons_to_uncategorized_(9) 25
	
	set pvp_to_dungeons_(9) 0
	set pvp_to_pvp_(9) 36.0824742268041
	set pvp_to_questing_(9) 35.0515463917526
	set pvp_to_raiding_(9) 0
	set pvp_to_trading_(9) 23.7113402061856
	set pvp_to_uncategorized_(9) 5.15463917525773
	
	set questing_to_dungeons_(9) 2.02020202020202
	set questing_to_pvp_(9) 18.1818181818182
	set questing_to_questing_(9) 4.54545454545455
	set questing_to_raiding_(9) 0
	set questing_to_trading_(9) 65.6565656565657
	set questing_to_uncategorized_(9) 9.5959595959596
	
	set raiding_to_dungeons_(9) 0
	set raiding_to_pvp_(9) 0
	set raiding_to_questing_(9) 0
	set raiding_to_raiding_(9) 0
	set raiding_to_trading_(9) 100
	set raiding_to_uncategorized_(9) 0
	
	set trading_to_dungeons_(9) 0.803212851405622
	set trading_to_pvp_(9) 10.4417670682731
	set trading_to_questing_(9) 47.3895582329317
	set trading_to_raiding_(9) 0
	set trading_to_trading_(9) 9.63855421686747
	set trading_to_uncategorized_(9) 31.7269076305221
	
	set uncategorized_to_dungeons_(9) 3.7037037037037
	set uncategorized_to_pvp_(9) 7.40740740740741
	set uncategorized_to_questing_(9) 39.5061728395062
	set uncategorized_to_raiding_(9) 1.23456790123457
	set uncategorized_to_trading_(9) 45.679012345679
	set uncategorized_to_uncategorized_(9) 2.46913580246914
	
	############# Hour of the day:  10:00 - 11:00
	set dungeons_to_dungeons_(10) 0
	set dungeons_to_pvp_(10) 0
	set dungeons_to_questing_(10) 30
	set dungeons_to_raiding_(10) 20
	set dungeons_to_trading_(10) 30
	set dungeons_to_uncategorized_(10) 20
	
	set pvp_to_dungeons_(10) 0
	set pvp_to_pvp_(10) 39.2405063291139
	set pvp_to_questing_(10) 35.4430379746835
	set pvp_to_raiding_(10) 0
	set pvp_to_trading_(10) 17.0886075949367
	set pvp_to_uncategorized_(10) 8.22784810126582
	
	set questing_to_dungeons_(10) 2.40963855421687
	set questing_to_pvp_(10) 15.3614457831325
	set questing_to_questing_(10) 7.53012048192771
	set questing_to_raiding_(10) 0.602409638554217
	set questing_to_trading_(10) 59.9397590361446
	set questing_to_uncategorized_(10) 14.1566265060241
	
	set raiding_to_dungeons_(10) 16.6666666666667
	set raiding_to_pvp_(10) 0
	set raiding_to_questing_(10) 50
	set raiding_to_raiding_(10) 0
	set raiding_to_trading_(10) 16.6666666666667
	set raiding_to_uncategorized_(10) 16.6666666666667
	
	set trading_to_dungeons_(10) 1.90023752969121
	set trading_to_pvp_(10) 6.17577197149644
	set trading_to_questing_(10) 48.6935866983373
	set trading_to_raiding_(10) 0.475059382422803
	set trading_to_trading_(10) 5.93824228028503
	set trading_to_uncategorized_(10) 36.8171021377672
	
	set uncategorized_to_dungeons_(10) 2.68817204301075
	set uncategorized_to_pvp_(10) 12.9032258064516
	set uncategorized_to_questing_(10) 29.5698924731183
	set uncategorized_to_raiding_(10) 4.3010752688172
	set uncategorized_to_trading_(10) 47.3118279569892
	set uncategorized_to_uncategorized_(10) 3.2258064516129
	
	############# Hour of the day:  11:00 - 12:00
	set dungeons_to_dungeons_(11) 0
	set dungeons_to_pvp_(11) 0
	set dungeons_to_questing_(11) 37.037037037037
	set dungeons_to_raiding_(11) 3.7037037037037
	set dungeons_to_trading_(11) 48.1481481481481
	set dungeons_to_uncategorized_(11) 11.1111111111111
	
	set pvp_to_dungeons_(11) 0
	set pvp_to_pvp_(11) 34.5864661654135
	set pvp_to_questing_(11) 31.203007518797
	set pvp_to_raiding_(11) 1.12781954887218
	set pvp_to_trading_(11) 24.812030075188
	set pvp_to_uncategorized_(11) 8.27067669172932
	
	set questing_to_dungeons_(11) 1.89075630252101
	set questing_to_pvp_(11) 19.9579831932773
	set questing_to_questing_(11) 5.04201680672269
	set questing_to_raiding_(11) 1.26050420168067
	set questing_to_trading_(11) 60.7142857142857
	set questing_to_uncategorized_(11) 11.1344537815126
	
	set raiding_to_dungeons_(11) 0
	set raiding_to_pvp_(11) 16.6666666666667
	set raiding_to_questing_(11) 16.6666666666667
	set raiding_to_raiding_(11) 0
	set raiding_to_trading_(11) 55.5555555555556
	set raiding_to_uncategorized_(11) 11.1111111111111
	
	set trading_to_dungeons_(11) 1.44230769230769
	set trading_to_pvp_(11) 10.7371794871795
	set trading_to_questing_(11) 42.7884615384615
	set trading_to_raiding_(11) 0.641025641025641
	set trading_to_trading_(11) 4.16666666666667
	set trading_to_uncategorized_(11) 40.224358974359
	
	set uncategorized_to_dungeons_(11) 2.98013245033113
	set uncategorized_to_pvp_(11) 9.60264900662252
	set uncategorized_to_questing_(11) 29.8013245033113
	set uncategorized_to_raiding_(11) 3.64238410596026
	set uncategorized_to_trading_(11) 49.6688741721854
	set uncategorized_to_uncategorized_(11) 4.3046357615894
	
	############# Hour of the day:  12:00 - 13:00
	set dungeons_to_dungeons_(12) 2.5
	set dungeons_to_pvp_(12) 0
	set dungeons_to_questing_(12) 30
	set dungeons_to_raiding_(12) 2.5
	set dungeons_to_trading_(12) 47.5
	set dungeons_to_uncategorized_(12) 17.5
	
	set pvp_to_dungeons_(12) 0.647249190938511
	set pvp_to_pvp_(12) 35.9223300970874
	set pvp_to_questing_(12) 33.3333333333333
	set pvp_to_raiding_(12) 0.647249190938511
	set pvp_to_trading_(12) 18.7702265372168
	set pvp_to_uncategorized_(12) 10.6796116504854
	
	set questing_to_dungeons_(12) 1.56794425087108
	set questing_to_pvp_(12) 16.7247386759582
	set questing_to_questing_(12) 6.44599303135888
	set questing_to_raiding_(12) 0
	set questing_to_trading_(12) 63.9372822299652
	set questing_to_uncategorized_(12) 11.3240418118467
	
	set raiding_to_dungeons_(12) 4
	set raiding_to_pvp_(12) 20
	set raiding_to_questing_(12) 20
	set raiding_to_raiding_(12) 0
	set raiding_to_trading_(12) 44
	set raiding_to_uncategorized_(12) 12
	
	set trading_to_dungeons_(12) 2.29885057471264
	set trading_to_pvp_(12) 7.91826309067688
	set trading_to_questing_(12) 43.2950191570881
	set trading_to_raiding_(12) 1.02171136653895
	set trading_to_trading_(12) 3.95913154533844
	set trading_to_uncategorized_(12) 41.507024265645
	
	set uncategorized_to_dungeons_(12) 4
	set uncategorized_to_pvp_(12) 10.6666666666667
	set uncategorized_to_questing_(12) 23.2
	set uncategorized_to_raiding_(12) 3.46666666666667
	set uncategorized_to_trading_(12) 54.6666666666667
	set uncategorized_to_uncategorized_(12) 4
	
	############# Hour of the day:  13:00 - 14:00
	set dungeons_to_dungeons_(13) 4.25531914893617
	set dungeons_to_pvp_(13) 2.12765957446809
	set dungeons_to_questing_(13) 29.7872340425532
	set dungeons_to_raiding_(13) 4.25531914893617
	set dungeons_to_trading_(13) 46.8085106382979
	set dungeons_to_uncategorized_(13) 12.7659574468085
	
	set pvp_to_dungeons_(13) 0.366300366300366
	set pvp_to_pvp_(13) 17.5824175824176
	set pvp_to_questing_(13) 35.5311355311355
	set pvp_to_raiding_(13) 2.93040293040293
	set pvp_to_trading_(13) 32.2344322344322
	set pvp_to_uncategorized_(13) 11.3553113553114
	
	set questing_to_dungeons_(13) 2.37388724035608
	set questing_to_pvp_(13) 11.1275964391691
	set questing_to_questing_(13) 2.81899109792285
	set questing_to_raiding_(13) 0.593471810089021
	set questing_to_trading_(13) 69.2878338278932
	set questing_to_uncategorized_(13) 13.7982195845697
	
	set raiding_to_dungeons_(13) 3.2258064516129
	set raiding_to_pvp_(13) 6.45161290322581
	set raiding_to_questing_(13) 9.67741935483871
	set raiding_to_raiding_(13) 0
	set raiding_to_trading_(13) 74.1935483870968
	set raiding_to_uncategorized_(13) 6.45161290322581
	
	set trading_to_dungeons_(13) 1.77267987486966
	set trading_to_pvp_(13) 9.48905109489051
	set trading_to_questing_(13) 41.9186652763295
	set trading_to_raiding_(13) 1.66840458811262
	set trading_to_trading_(13) 4.0667361835245
	set trading_to_uncategorized_(13) 41.0844629822732
	
	set uncategorized_to_dungeons_(13) 3.17796610169492
	set uncategorized_to_pvp_(13) 12.9237288135593
	set uncategorized_to_questing_(13) 25.4237288135593
	set uncategorized_to_raiding_(13) 3.38983050847458
	set uncategorized_to_trading_(13) 50.4237288135593
	set uncategorized_to_uncategorized_(13) 4.66101694915254
	
	############# Hour of the day:  14:00 - 15:00
	set dungeons_to_dungeons_(14) 0
	set dungeons_to_pvp_(14) 1.5625
	set dungeons_to_questing_(14) 21.875
	set dungeons_to_raiding_(14) 26.5625
	set dungeons_to_trading_(14) 43.75
	set dungeons_to_uncategorized_(14) 6.25
	
	set pvp_to_dungeons_(14) 0.268817204301075
	set pvp_to_pvp_(14) 29.8387096774194
	set pvp_to_questing_(14) 32.258064516129
	set pvp_to_raiding_(14) 0.806451612903226
	set pvp_to_trading_(14) 26.8817204301075
	set pvp_to_uncategorized_(14) 9.94623655913978
	
	set questing_to_dungeons_(14) 2.3943661971831
	set questing_to_pvp_(14) 17.1830985915493
	set questing_to_questing_(14) 4.36619718309859
	set questing_to_raiding_(14) 1.12676056338028
	set questing_to_trading_(14) 61.4084507042253
	set questing_to_uncategorized_(14) 13.5211267605634
	
	set raiding_to_dungeons_(14) 20.3389830508475
	set raiding_to_pvp_(14) 5.08474576271187
	set raiding_to_questing_(14) 1.69491525423729
	set raiding_to_raiding_(14) 1.69491525423729
	set raiding_to_trading_(14) 66.1016949152542
	set raiding_to_uncategorized_(14) 5.08474576271187
	
	set trading_to_dungeons_(14) 1.37795275590551
	set trading_to_pvp_(14) 9.3503937007874
	set trading_to_questing_(14) 37.6968503937008
	set trading_to_raiding_(14) 2.65748031496063
	set trading_to_trading_(14) 3.54330708661417
	set trading_to_uncategorized_(14) 45.3740157480315
	
	set uncategorized_to_dungeons_(14) 4.71544715447155
	set uncategorized_to_pvp_(14) 10.5691056910569
	set uncategorized_to_questing_(14) 22.7642276422764
	set uncategorized_to_raiding_(14) 6.01626016260163
	set uncategorized_to_trading_(14) 50.7317073170732
	set uncategorized_to_uncategorized_(14) 5.20325203252033
	
	############# Hour of the day:  15:00 - 16:00
	set dungeons_to_dungeons_(15) 2.77777777777778
	set dungeons_to_pvp_(15) 6.94444444444444
	set dungeons_to_questing_(15) 15.2777777777778
	set dungeons_to_raiding_(15) 18.0555555555556
	set dungeons_to_trading_(15) 48.6111111111111
	set dungeons_to_uncategorized_(15) 8.33333333333333
	
	set pvp_to_dungeons_(15) 0.540540540540541
	set pvp_to_pvp_(15) 25.6756756756757
	set pvp_to_questing_(15) 32.7027027027027
	set pvp_to_raiding_(15) 1.89189189189189
	set pvp_to_trading_(15) 25.1351351351351
	set pvp_to_uncategorized_(15) 14.0540540540541
	
	set questing_to_dungeons_(15) 1.85185185185185
	set questing_to_pvp_(15) 18.8271604938272
	set questing_to_questing_(15) 4.01234567901235
	set questing_to_raiding_(15) 0.771604938271605
	set questing_to_trading_(15) 60.9567901234568
	set questing_to_uncategorized_(15) 13.5802469135802
	
	set raiding_to_dungeons_(15) 15.3846153846154
	set raiding_to_pvp_(15) 3.07692307692308
	set raiding_to_questing_(15) 7.69230769230769
	set raiding_to_raiding_(15) 0
	set raiding_to_trading_(15) 63.0769230769231
	set raiding_to_uncategorized_(15) 10.7692307692308
	
	set trading_to_dungeons_(15) 0.933609958506224
	set trading_to_pvp_(15) 9.43983402489627
	set trading_to_questing_(15) 35.7883817427386
	set trading_to_raiding_(15) 2.4896265560166
	set trading_to_trading_(15) 4.149377593361
	set trading_to_uncategorized_(15) 47.1991701244813
	
	set uncategorized_to_dungeons_(15) 6.33802816901408
	set uncategorized_to_pvp_(15) 9.85915492957746
	set uncategorized_to_questing_(15) 22.5352112676056
	set uncategorized_to_raiding_(15) 4.40140845070423
	set uncategorized_to_trading_(15) 53.169014084507
	set uncategorized_to_uncategorized_(15) 3.69718309859155
	
	############# Hour of the day:  16:00 - 17:00
	set dungeons_to_dungeons_(16) 1.49253731343284
	set dungeons_to_pvp_(16) 5.97014925373134
	set dungeons_to_questing_(16) 25.3731343283582
	set dungeons_to_raiding_(16) 5.97014925373134
	set dungeons_to_trading_(16) 50.7462686567164
	set dungeons_to_uncategorized_(16) 10.4477611940298
	
	set pvp_to_dungeons_(16) 2.27272727272727
	set pvp_to_pvp_(16) 22.4025974025974
	set pvp_to_questing_(16) 34.4155844155844
	set pvp_to_raiding_(16) 1.2987012987013
	set pvp_to_trading_(16) 30.5194805194805
	set pvp_to_uncategorized_(16) 9.09090909090909
	
	set questing_to_dungeons_(16) 2.73775216138329
	set questing_to_pvp_(16) 13.9769452449568
	set questing_to_questing_(16) 2.59365994236311
	set questing_to_raiding_(16) 0.864553314121038
	set questing_to_trading_(16) 68.7319884726225
	set questing_to_uncategorized_(16) 11.0951008645533
	
	set raiding_to_dungeons_(16) 0
	set raiding_to_pvp_(16) 4.61538461538462
	set raiding_to_questing_(16) 9.23076923076923
	set raiding_to_raiding_(16) 0
	set raiding_to_trading_(16) 81.5384615384615
	set raiding_to_uncategorized_(16) 4.61538461538462
	
	set trading_to_dungeons_(16) 0.844277673545966
	set trading_to_pvp_(16) 8.72420262664165
	set trading_to_questing_(16) 38.1801125703565
	set trading_to_raiding_(16) 3.37711069418387
	set trading_to_trading_(16) 3.18949343339587
	set trading_to_uncategorized_(16) 45.6848030018762
	
	set uncategorized_to_dungeons_(16) 5.16934046345811
	set uncategorized_to_pvp_(16) 8.19964349376114
	set uncategorized_to_questing_(16) 26.3814616755793
	set uncategorized_to_raiding_(16) 3.92156862745098
	set uncategorized_to_trading_(16) 51.8716577540107
	set uncategorized_to_uncategorized_(16) 4.45632798573975
	
	############# Hour of the day:  17:00 - 18:00
	set dungeons_to_dungeons_(17) 0
	set dungeons_to_pvp_(17) 4.25531914893617
	set dungeons_to_questing_(17) 27.6595744680851
	set dungeons_to_raiding_(17) 12.7659574468085
	set dungeons_to_trading_(17) 48.936170212766
	set dungeons_to_uncategorized_(17) 6.38297872340426
	
	set pvp_to_dungeons_(17) 1.05540897097625
	set pvp_to_pvp_(17) 26.6490765171504
	set pvp_to_questing_(17) 26.3852242744063
	set pvp_to_raiding_(17) 2.37467018469657
	set pvp_to_trading_(17) 34.3007915567282
	set pvp_to_uncategorized_(17) 9.23482849604222
	
	set questing_to_dungeons_(17) 2.33516483516484
	set questing_to_pvp_(17) 16.2087912087912
	set questing_to_questing_(17) 3.57142857142857
	set questing_to_raiding_(17) 0.549450549450549
	set questing_to_trading_(17) 62.2252747252747
	set questing_to_uncategorized_(17) 15.1098901098901
	
	set raiding_to_dungeons_(17) 2.46913580246914
	set raiding_to_pvp_(17) 7.40740740740741
	set raiding_to_questing_(17) 6.17283950617284
	set raiding_to_raiding_(17) 0
	set raiding_to_trading_(17) 75.3086419753086
	set raiding_to_uncategorized_(17) 8.64197530864197
	
	set trading_to_dungeons_(17) 0.890471950133571
	set trading_to_pvp_(17) 11.3980409617097
	set trading_to_questing_(17) 35.6188780053428
	set trading_to_raiding_(17) 3.38379341050757
	set trading_to_trading_(17) 2.493321460374
	set trading_to_uncategorized_(17) 46.2154942119323
	
	set uncategorized_to_dungeons_(17) 2.8169014084507
	set uncategorized_to_pvp_(17) 10.9546165884194
	set uncategorized_to_questing_(17) 24.4131455399061
	set uncategorized_to_raiding_(17) 4.06885758998435
	set uncategorized_to_trading_(17) 53.5211267605634
	set uncategorized_to_uncategorized_(17) 4.22535211267606
	
	############# Hour of the day:  18:00 - 19:00
	set dungeons_to_dungeons_(18) 1.36986301369863
	set dungeons_to_pvp_(18) 4.10958904109589
	set dungeons_to_questing_(18) 19.1780821917808
	set dungeons_to_raiding_(18) 12.3287671232877
	set dungeons_to_trading_(18) 42.4657534246575
	set dungeons_to_uncategorized_(18) 20.5479452054795
	
	set pvp_to_dungeons_(18) 1.38067061143984
	set pvp_to_pvp_(18) 27.6134122287968
	set pvp_to_questing_(18) 33.1360946745562
	set pvp_to_raiding_(18) 2.76134122287968
	set pvp_to_trading_(18) 23.0769230769231
	set pvp_to_uncategorized_(18) 12.0315581854043
	
	set questing_to_dungeons_(18) 1.67664670658683
	set questing_to_pvp_(18) 15.9281437125748
	set questing_to_questing_(18) 5.1497005988024
	set questing_to_raiding_(18) 2.9940119760479
	set questing_to_trading_(18) 59.2814371257485
	set questing_to_uncategorized_(18) 14.9700598802395
	
	set raiding_to_dungeons_(18) 2.53164556962025
	set raiding_to_pvp_(18) 5.06329113924051
	set raiding_to_questing_(18) 3.79746835443038
	set raiding_to_raiding_(18) 0
	set raiding_to_trading_(18) 78.4810126582278
	set raiding_to_uncategorized_(18) 10.126582278481
	
	set trading_to_dungeons_(18) 1.23711340206186
	set trading_to_pvp_(18) 6.52920962199313
	set trading_to_questing_(18) 30.1030927835052
	set trading_to_raiding_(18) 4.74226804123711
	set trading_to_trading_(18) 7.07903780068728
	set trading_to_uncategorized_(18) 50.3092783505155
	
	set uncategorized_to_dungeons_(18) 4.04624277456647
	set uncategorized_to_pvp_(18) 8.90173410404624
	set uncategorized_to_questing_(18) 17.6878612716763
	set uncategorized_to_raiding_(18) 11.0982658959538
	set uncategorized_to_trading_(18) 54.2196531791908
	set uncategorized_to_uncategorized_(18) 4.04624277456647
	
	############# Hour of the day:  19:00 - 20:00
	set dungeons_to_dungeons_(19) 0
	set dungeons_to_pvp_(19) 1.72413793103448
	set dungeons_to_questing_(19) 17.2413793103448
	set dungeons_to_raiding_(19) 15.5172413793103
	set dungeons_to_trading_(19) 56.8965517241379
	set dungeons_to_uncategorized_(19) 8.62068965517241
	
	set pvp_to_dungeons_(19) 0.91533180778032
	set pvp_to_pvp_(19) 26.0869565217391
	set pvp_to_questing_(19) 23.5697940503432
	set pvp_to_raiding_(19) 7.09382151029748
	set pvp_to_trading_(19) 29.5194508009153
	set pvp_to_uncategorized_(19) 12.8146453089245
	
	set questing_to_dungeons_(19) 1.70807453416149
	set questing_to_pvp_(19) 17.7018633540373
	set questing_to_questing_(19) 3.26086956521739
	set questing_to_raiding_(19) 1.86335403726708
	set questing_to_trading_(19) 62.2670807453416
	set questing_to_uncategorized_(19) 13.1987577639752
	
	set raiding_to_dungeons_(19) 4.08163265306122
	set raiding_to_pvp_(19) 19.3877551020408
	set raiding_to_questing_(19) 3.06122448979592
	set raiding_to_raiding_(19) 1.02040816326531
	set raiding_to_trading_(19) 66.3265306122449
	set raiding_to_uncategorized_(19) 6.12244897959184
	
	set trading_to_dungeons_(19) 0.986031224322103
	set trading_to_pvp_(19) 10.1889893179951
	set trading_to_questing_(19) 26.3763352506163
	set trading_to_raiding_(19) 6.08052588331964
	set trading_to_trading_(19) 2.54724732949877
	set trading_to_uncategorized_(19) 53.8208709942481
	
	set uncategorized_to_dungeons_(19) 3.78006872852234
	set uncategorized_to_pvp_(19) 9.04925544100802
	set uncategorized_to_questing_(19) 16.7239404352806
	set uncategorized_to_raiding_(19) 18.7857961053837
	set uncategorized_to_trading_(19) 46.8499427262314
	set uncategorized_to_uncategorized_(19) 4.81099656357388
	
	############# Hour of the day:  20:00 - 21:00
	set dungeons_to_dungeons_(20) 0
	set dungeons_to_pvp_(20) 4.47761194029851
	set dungeons_to_questing_(20) 22.3880597014925
	set dungeons_to_raiding_(20) 13.4328358208955
	set dungeons_to_trading_(20) 53.7313432835821
	set dungeons_to_uncategorized_(20) 5.97014925373134
	
	set pvp_to_dungeons_(20) 0.479616306954436
	set pvp_to_pvp_(20) 24.220623501199
	set pvp_to_questing_(20) 24.220623501199
	set pvp_to_raiding_(20) 9.83213429256595
	set pvp_to_trading_(20) 27.8177458033573
	set pvp_to_uncategorized_(20) 13.4292565947242
	
	set questing_to_dungeons_(20) 2.30496453900709
	set questing_to_pvp_(20) 16.4893617021277
	set questing_to_questing_(20) 6.56028368794326
	set questing_to_raiding_(20) 1.41843971631206
	set questing_to_trading_(20) 58.3333333333333
	set questing_to_uncategorized_(20) 14.8936170212766
	
	set raiding_to_dungeons_(20) 1.88679245283019
	set raiding_to_pvp_(20) 27.3584905660377
	set raiding_to_questing_(20) 4.71698113207547
	set raiding_to_raiding_(20) 0.943396226415094
	set raiding_to_trading_(20) 60.377358490566
	set raiding_to_uncategorized_(20) 4.71698113207547
	
	set trading_to_dungeons_(20) 1.50300601202405
	set trading_to_pvp_(20) 9.81963927855711
	set trading_to_questing_(20) 27.3547094188377
	set trading_to_raiding_(20) 10.3206412825651
	set trading_to_trading_(20) 1.90380761523046
	set trading_to_uncategorized_(20) 49.0981963927856
	
	set uncategorized_to_dungeons_(20) 3.31825037707391
	set uncategorized_to_pvp_(20) 11.7647058823529
	set uncategorized_to_questing_(20) 15.5354449472097
	set uncategorized_to_raiding_(20) 17.3453996983409
	set uncategorized_to_trading_(20) 47.5113122171946
	set uncategorized_to_uncategorized_(20) 4.52488687782805
	
	############# Hour of the day:  21:00 - 22:00
	set dungeons_to_dungeons_(21) 0
	set dungeons_to_pvp_(21) 2.98507462686567
	set dungeons_to_questing_(21) 38.8059701492537
	set dungeons_to_raiding_(21) 4.47761194029851
	set dungeons_to_trading_(21) 44.7761194029851
	set dungeons_to_uncategorized_(21) 8.95522388059701
	
	set pvp_to_dungeons_(21) 1.63934426229508
	set pvp_to_pvp_(21) 20.327868852459
	set pvp_to_questing_(21) 25.5737704918033
	set pvp_to_raiding_(21) 11.8032786885246
	set pvp_to_trading_(21) 28.8524590163934
	set pvp_to_uncategorized_(21) 11.8032786885246
	
	set questing_to_dungeons_(21) 3.00500834724541
	set questing_to_pvp_(21) 14.0233722871452
	set questing_to_questing_(21) 4.17362270450751
	set questing_to_raiding_(21) 0.834724540901502
	set questing_to_trading_(21) 64.6076794657763
	set questing_to_uncategorized_(21) 13.355592654424
	
	set raiding_to_dungeons_(21) 1.69491525423729
	set raiding_to_pvp_(21) 20.3389830508475
	set raiding_to_questing_(21) 2.54237288135593
	set raiding_to_raiding_(21) 0
	set raiding_to_trading_(21) 68.6440677966102
	set raiding_to_uncategorized_(21) 6.77966101694915
	
	set trading_to_dungeons_(21) 1.88679245283019
	set trading_to_pvp_(21) 9.87791342952275
	set trading_to_questing_(21) 38.8457269700333
	set trading_to_raiding_(21) 5.66037735849057
	set trading_to_trading_(21) 4.10654827968923
	set trading_to_uncategorized_(21) 39.622641509434
	
	set uncategorized_to_dungeons_(21) 4.32220039292731
	set uncategorized_to_pvp_(21) 11.1984282907662
	set uncategorized_to_questing_(21) 23.7721021611002
	set uncategorized_to_raiding_(21) 8.64440078585462
	set uncategorized_to_trading_(21) 46.1689587426326
	set uncategorized_to_uncategorized_(21) 5.89390962671906
	
	############# Hour of the day:  22:00 - 23:00
	set dungeons_to_dungeons_(22) 0
	set dungeons_to_pvp_(22) 0
	set dungeons_to_questing_(22) 18.6440677966102
	set dungeons_to_raiding_(22) 6.77966101694915
	set dungeons_to_trading_(22) 61.0169491525424
	set dungeons_to_uncategorized_(22) 13.5593220338983
	
	set pvp_to_dungeons_(22) 1.67597765363128
	set pvp_to_pvp_(22) 26.536312849162
	set pvp_to_questing_(22) 27.0949720670391
	set pvp_to_raiding_(22) 9.77653631284916
	set pvp_to_trading_(22) 25.9776536312849
	set pvp_to_uncategorized_(22) 8.93854748603352
	
	set questing_to_dungeons_(22) 2.26904376012966
	set questing_to_pvp_(22) 14.5867098865478
	set questing_to_questing_(22) 5.18638573743922
	set questing_to_raiding_(22) 1.29659643435981
	set questing_to_trading_(22) 63.3711507293355
	set questing_to_uncategorized_(22) 13.290113452188
	
	set raiding_to_dungeons_(22) 0.938967136150235
	set raiding_to_pvp_(22) 15.962441314554
	set raiding_to_questing_(22) 4.22535211267606
	set raiding_to_raiding_(22) 0.469483568075117
	set raiding_to_trading_(22) 72.7699530516432
	set raiding_to_uncategorized_(22) 5.63380281690141
	
	set trading_to_dungeons_(22) 1.78010471204188
	set trading_to_pvp_(22) 10.3664921465969
	set trading_to_questing_(22) 35.9162303664921
	set trading_to_raiding_(22) 5.0261780104712
	set trading_to_trading_(22) 1.15183246073298
	set trading_to_uncategorized_(22) 45.7591623036649
	
	set uncategorized_to_dungeons_(22) 4.83271375464684
	set uncategorized_to_pvp_(22) 10.9665427509294
	set uncategorized_to_questing_(22) 22.8624535315985
	set uncategorized_to_raiding_(22) 5.94795539033457
	set uncategorized_to_trading_(22) 51.3011152416357
	set uncategorized_to_uncategorized_(22) 4.08921933085502
	
	############# Hour of the day:  23:00 - 24:00
	set dungeons_to_dungeons_(23) 0
	set dungeons_to_pvp_(23) 3.27868852459016
	set dungeons_to_questing_(23) 18.0327868852459
	set dungeons_to_raiding_(23) 9.83606557377049
	set dungeons_to_trading_(23) 54.0983606557377
	set dungeons_to_uncategorized_(23) 14.7540983606557
	
	set pvp_to_dungeons_(23) 1.11524163568773
	set pvp_to_pvp_(23) 8.17843866171004
	set pvp_to_questing_(23) 29.7397769516729
	set pvp_to_raiding_(23) 2.97397769516729
	set pvp_to_trading_(23) 44.6096654275093
	set pvp_to_uncategorized_(23) 13.3828996282528
	
	set questing_to_dungeons_(23) 2.13089802130898
	set questing_to_pvp_(23) 9.89345509893455
	set questing_to_questing_(23) 1.97869101978691
	set questing_to_raiding_(23) 1.21765601217656
	set questing_to_trading_(23) 71.841704718417
	set questing_to_uncategorized_(23) 12.9375951293759
	
	set raiding_to_dungeons_(23) 0.260416666666667
	set raiding_to_pvp_(23) 2.86458333333333
	set raiding_to_questing_(23) 5.20833333333333
	set raiding_to_raiding_(23) 0.520833333333333
	set raiding_to_trading_(23) 86.9791666666667
	set raiding_to_uncategorized_(23) 4.16666666666667
	
	set trading_to_dungeons_(23) 1.34228187919463
	set trading_to_pvp_(23) 10.3187919463087
	set trading_to_questing_(23) 32.7181208053691
	set trading_to_raiding_(23) 4.11073825503356
	set trading_to_trading_(23) 3.52348993288591
	set trading_to_uncategorized_(23) 47.986577181208
	
	set uncategorized_to_dungeons_(23) 6.62251655629139
	set uncategorized_to_pvp_(23) 10.7615894039735
	set uncategorized_to_questing_(23) 18.3774834437086
	set uncategorized_to_raiding_(23) 4.96688741721854
	set uncategorized_to_trading_(23) 55.6291390728477
	set uncategorized_to_uncategorized_(23) 3.64238410596026
	


	#I calculate a probability
	set probability_ [$uniform_ value]
	#puts "probability: $probability_"

	#Calculation of the next activity
	if { $current_act_($connection_ident_) == "dungeons"} {
		if {$probability_ < $dungeons_to_dungeons_($current_hour_) } {
			set current_act_($connection_ident_) dungeons
		} else {
			if {$probability_ < [expr $dungeons_to_dungeons_($current_hour_) + $dungeons_to_pvp_($current_hour_) ]} {
				set current_act_($connection_ident_) pvp
				calculate_pvp_subactivity_ $connection_ident_
			} else {
				if {$probability_ < [expr $dungeons_to_dungeons_($current_hour_) + $dungeons_to_pvp_($current_hour_) + $dungeons_to_questing_($current_hour_) ] } {
					set current_act_($connection_ident_) questing
				} else {
					if {$probability_ < [expr $dungeons_to_dungeons_($current_hour_) + $dungeons_to_pvp_($current_hour_) + $dungeons_to_questing_($current_hour_) + $dungeons_to_raiding_($current_hour_) ] } {
						set current_act_($connection_ident_) raiding
					} else {
						if {$probability_ < [expr $dungeons_to_dungeons_($current_hour_) + $dungeons_to_pvp_($current_hour_) + $dungeons_to_questing_($current_hour_) + $dungeons_to_raiding_($current_hour_) + $dungeons_to_trading_($current_hour_) ] } {
							set current_act_($connection_ident_) trading
						} else {
							#if {$probability_ < [expr $dungeons_to_dungeons_($current_hour_) + $dungeons_to_pvp_($current_hour_) + $dungeons_to_questing_($current_hour_) + $dungeons_to_raiding_($current_hour_) + $dungeons_to_trading_($current_hour_) + $dungeons_to_uncategorized_($current_hour_) ] } {
								set current_act_($connection_ident_) uncategorized
							#}
						}
					}
				}
			}
		}
	}
	
	if { $current_act_($connection_ident_) == "pvp"} {
		if {$probability_ < $pvp_to_dungeons_($current_hour_) } {
			set current_act_($connection_ident_) dungeons
		} else {
			if {$probability_ < [expr $pvp_to_dungeons_($current_hour_) + $pvp_to_pvp_($current_hour_) ]} {
				set current_act_($connection_ident_) pvp
				calculate_pvp_subactivity_ $connection_ident_
			} else {
				if {$probability_ < [expr $pvp_to_dungeons_($current_hour_) + $pvp_to_pvp_($current_hour_) + $pvp_to_questing_($current_hour_) ] } {
					set current_act_($connection_ident_) questing
				} else {
					if {$probability_ < [expr $pvp_to_dungeons_($current_hour_) + $pvp_to_pvp_($current_hour_) + $pvp_to_questing_($current_hour_) + $pvp_to_raiding_($current_hour_) ] } {
						set current_act_($connection_ident_) raiding
					} else {
						if {$probability_ < [expr $pvp_to_dungeons_($current_hour_) + $pvp_to_pvp_($current_hour_) + $pvp_to_questing_($current_hour_) + $pvp_to_raiding_($current_hour_) + $pvp_to_trading_($current_hour_) ] } {
							set current_act_($connection_ident_) trading
						} else {
							#if {$probability_ < [expr $pvp_to_dungeons_($current_hour_) + $pvp_to_pvp_($current_hour_) + $pvp_to_questing_($current_hour_) + $pvp_to_raiding_($current_hour_) + $pvp_to_trading_($current_hour_) + $pvp_to_uncategorized_($current_hour_) ] } {
								set current_act_($connection_ident_) uncategorized
							#}
						}
					}
				}
			}
		}
	}

	if { $current_act_($connection_ident_) == "questing"} {
		if {$probability_ < $questing_to_dungeons_($current_hour_) } {
			set current_act_($connection_ident_) dungeons
		} else {
			if {$probability_ < [expr $questing_to_dungeons_($current_hour_) + $questing_to_pvp_($current_hour_) ]} {
				set current_act_($connection_ident_) pvp
				calculate_pvp_subactivity_ $connection_ident_
			} else {
				if {$probability_ < [expr $questing_to_dungeons_($current_hour_) + $questing_to_pvp_($current_hour_) + $questing_to_questing_($current_hour_) ] } {
					set current_act_($connection_ident_) questing
				} else {
					if {$probability_ < [expr $questing_to_dungeons_($current_hour_) + $questing_to_pvp_($current_hour_) + $questing_to_questing_($current_hour_) + $questing_to_raiding_($current_hour_) ] } {
						set current_act_($connection_ident_) raiding
					} else {
						if {$probability_ < [expr $questing_to_dungeons_($current_hour_) + $questing_to_pvp_($current_hour_) + $questing_to_questing_($current_hour_) + $questing_to_raiding_($current_hour_) + $questing_to_trading_($current_hour_) ] } {
							set current_act_($connection_ident_) trading
						} else {
							#if {$probability_ < [expr $questing_to_dungeons_($current_hour_) + $questing_to_pvp_($current_hour_) + $questing_to_questing_($current_hour_) + $questing_to_raiding_($current_hour_) + $questing_to_trading_($current_hour_) + $questing_to_uncategorized_($current_hour_) ] } {
								set current_act_($connection_ident_) uncategorized
							#}
						}
					}
				}
			}
		}
	}

	if { $current_act_($connection_ident_) == "raiding"} {
		if {$probability_ < $raiding_to_dungeons_($current_hour_) } {
			set current_act_($connection_ident_) dungeons
		} else {
			if {$probability_ < [expr $raiding_to_dungeons_($current_hour_) + $raiding_to_pvp_($current_hour_) ]} {
				set current_act_($connection_ident_) pvp
				calculate_pvp_subactivity_ $connection_ident_
			} else {
				if {$probability_ < [expr $raiding_to_dungeons_($current_hour_) + $raiding_to_pvp_($current_hour_) + $raiding_to_questing_($current_hour_) ] } {
					set current_act_($connection_ident_) questing
				} else {
					if {$probability_ < [expr $raiding_to_dungeons_($current_hour_) + $raiding_to_pvp_($current_hour_) + $raiding_to_questing_($current_hour_) + $raiding_to_raiding_($current_hour_) ] } {
						set current_act_($connection_ident_) raiding
					} else {
						if {$probability_ < [expr $raiding_to_dungeons_($current_hour_) + $raiding_to_pvp_($current_hour_) + $raiding_to_questing_($current_hour_) + $raiding_to_raiding_($current_hour_) + $raiding_to_trading_($current_hour_) ] } {
							set current_act_($connection_ident_) trading
						} else {
							#if {$probability_ < [expr $raiding_to_dungeons_($current_hour_) + $raiding_to_pvp_($current_hour_) + $raiding_to_questing_($current_hour_) + $raiding_to_raiding_($current_hour_) + $raiding_to_trading_($current_hour_) + $raiding_to_uncategorized_($current_hour_) ] } {
								set current_act_($connection_ident_) uncategorized
							#}
						}
					}
				}
			}
		}
	}

	if { $current_act_($connection_ident_) == "trading"} {
		if {$probability_ < $trading_to_dungeons_($current_hour_) } {
			set current_act_($connection_ident_) dungeons
		} else {
			if {$probability_ < [expr $trading_to_dungeons_($current_hour_) + $trading_to_pvp_($current_hour_) ]} {
				set current_act_($connection_ident_) pvp
				calculate_pvp_subactivity_ $connection_ident_
			} else {
				if {$probability_ < [expr $trading_to_dungeons_($current_hour_) + $trading_to_pvp_($current_hour_) + $trading_to_questing_($current_hour_) ] } {
					set current_act_($connection_ident_) questing
				} else {
					if {$probability_ < [expr $trading_to_dungeons_($current_hour_) + $trading_to_pvp_($current_hour_) + $trading_to_questing_($current_hour_) + $trading_to_raiding_($current_hour_) ] } {
						set current_act_($connection_ident_) raiding
					} else {
						if {$probability_ < [expr $trading_to_dungeons_($current_hour_) + $trading_to_pvp_($current_hour_) + $trading_to_questing_($current_hour_) + $trading_to_raiding_($current_hour_) + $trading_to_trading_($current_hour_) ] } {
							set current_act_($connection_ident_) trading
						} else {
							#if {$probability_ < [expr $trading_to_dungeons_($current_hour_) + $trading_to_pvp_($current_hour_) + $trading_to_questing_($current_hour_) + $trading_to_raiding_($current_hour_) + $trading_to_trading_($current_hour_) + $trading_to_uncategorized_($current_hour_) ] } {
								set current_act_($connection_ident_) uncategorized
							#}
						}
					}
				}
			}
		}
	}

	if { $current_act_($connection_ident_) == "uncategorized"} {
		if {$probability_ < $uncategorized_to_dungeons_($current_hour_) } {
			set current_act_($connection_ident_) dungeons
		} else {
			if {$probability_ < [expr $uncategorized_to_dungeons_($current_hour_) + $uncategorized_to_pvp_($current_hour_) ]} {
				set current_act_($connection_ident_) pvp
				calculate_pvp_subactivity_ $connection_ident_
			} else {
				if {$probability_ < [expr $uncategorized_to_dungeons_($current_hour_) + $uncategorized_to_pvp_($current_hour_) + $uncategorized_to_questing_($current_hour_) ] } {
					set current_act_($connection_ident_) questing
				} else {
					if {$probability_ < [expr $uncategorized_to_dungeons_($current_hour_) + $uncategorized_to_pvp_($current_hour_) + $uncategorized_to_questing_($current_hour_) + $uncategorized_to_raiding_($current_hour_) ] } {
						set current_act_($connection_ident_) raiding
					} else {
						if {$probability_ < [expr $uncategorized_to_dungeons_($current_hour_) + $uncategorized_to_pvp_($current_hour_) + $uncategorized_to_questing_($current_hour_) + $uncategorized_to_raiding_($current_hour_) + $uncategorized_to_trading_($current_hour_) ] } {
							set current_act_($connection_ident_) trading
						} else {
							#if {$probability_ < [expr $uncategorized_to_dungeons_($current_hour_) + $uncategorized_to_pvp_($current_hour_) + $uncategorized_to_questing_($current_hour_) + $uncategorized_to_raiding_($current_hour_) + $uncategorized_to_trading_($current_hour_) + $uncategorized_to_uncategorized_($current_hour_) ] } {
								set current_act_($connection_ident_) uncategorized
							#}
						}
					}
				}
			}
		}
	}

	# Set the duration depending on the value of the new current_act_

	if { $current_act_($connection_ident_) == "dungeons" } {
		set duration [expr 1321.42 + ( 1116 * ( log ( -1.0 * log ( [$dungeons_duration value]))))]
		if { $duration < 0.0 } {
			set duration 0.0
		}
	} else {
		if { $current_act_($connection_ident_) == "pvp" } {
			set duration [$pvp_duration value]
		} else {
			if { $current_act_($connection_ident_) == "raiding" } {
				###################### Raiding duration depends on the hour of the day
				set probability_ [$uniform_ value] ;# a value between 0 and 100
				if { $current_hour_ == 18 } {
					if { $probability_ <= 42.0 } {
						set duration [$raiding_duration_a($current_hour_) value]
					} else {
						set duration [$raiding_duration_b($current_hour_) value]
					}
				} else {
					if { $current_hour_ ==19 } {
						if { $probability_ <= 44.0 } {
							set duration [$raiding_duration_a($current_hour_) value]
						} else {
							set duration [$raiding_duration_b($current_hour_) value]
						}
					} else {
						if { $current_hour_ ==20 } {
							if { $probability_ <= 42.0 } {
								set duration [$raiding_duration_a($current_hour_) value]
							} else {
								set duration [$raiding_duration_b($current_hour_) value]
							}
						} else { ;#in all these cases, only a distribution is used
							set duration [$raiding_duration_a($current_hour_) value]
						}
					}
				}
			} else {
				if { $current_act_($connection_ident_) == "trading" } {
					set duration [$trading_duration value]
				} else {
					if { $current_act_($connection_ident_) == "questing" } {
						set duration [$questing_duration value]
					} else {
						if { $current_act_($connection_ident_) == "uncategorized" } {
							set duration [expr (300.96 + [$uncategorized_duration value])];#300.96 is the value of the location parameter
						}
					}
				}
			}
		}
	}

	# I write the change by the screen
	if {$activity_verbose_ == 1 } {
		if { $current_act_($connection_ident_) != "pvp" } {
			puts "Conn. $connection_ident_: [format "%.2f" [$ns now]] New activity: $current_act_($connection_ident_) (duration [format "%.2f" $duration]) Next activity change: [format "%.2f" [expr [$ns now] + $duration ]]"

		# If the activity is PvP, I also write the name of the subactivity
		} else {
			puts "Conn. $connection_ident_: [format "%.2f" [$ns now]] New activity: $current_act_($connection_ident_) $pvp_subactivity_($connection_ident_) (duration [format "%.2f" $duration]) Next activity change: [format "%.2f" [expr [$ns now] + $duration ]]"
		}
		puts "************************************************************************************************************"
	}

	# write a line in the activity file
	if {$activity_files_ == 1 } {
		if { $current_act_($connection_ident_) != "pvp" } {
			puts $activity_file_id_($connection_ident_) "[$ns now]\t[format "%.2f" $duration]\t$current_act_($connection_ident_)\t\thour: \t$current_hour_\t:00"
			puts $activity_file_id_total_ "[$ns now]\t[format "%.2f" $duration]\t$connection_ident_\t$current_act_($connection_ident_)\t\thour: \t$current_hour_\t:00"

		# If the activity is PvP, I also write the name of the subactivity
		} else {
			puts $activity_file_id_($connection_ident_) "[$ns now]\t[format "%.2f" $duration]\t$current_act_($connection_ident_)\t$pvp_subactivity_($connection_ident_)\thour: \t$current_hour_\t:00"
			puts $activity_file_id_total_ "[$ns now]\t[format "%.2f" $duration]\t$connection_ident_\t$current_act_($connection_ident_)\t$pvp_subactivity_($connection_ident_)\thour: \t$current_hour_\t:00"
		}
	}

	# program the next activity change of this client
	$ns at [expr [$ns now] + $duration ] "calculate_next_activity_ current_activity_ $ns $connection_ident_"
}