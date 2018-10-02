proc trace_duration_fill_ { movement_trace_duration_ args } {
	upvar $movement_trace_duration_ trace_duration_
	global movement_scale_factor_

	set trace_duration_(000) 217.0	;# trace 0 does not exist. If I select 000 it means a random trace. So I put the biggest duration
	set trace_duration_(001) 217.0
	set trace_duration_(002) 217.0
	set trace_duration_(003) 209.0
	set trace_duration_(004) 200.0
	set trace_duration_(005) 176.0
	set trace_duration_(006) 170.0
	set trace_duration_(007) 174.0
	set trace_duration_(008) 169.0
	set trace_duration_(009) 169.0
	set trace_duration_(010) 164.0
	set trace_duration_(011) 159.0
	set trace_duration_(012) 153.0
	set trace_duration_(013) 153.0
	set trace_duration_(014) 153.0
	set trace_duration_(015) 150.0
	set trace_duration_(016) 149.0
	set trace_duration_(017) 153.0
	set trace_duration_(018) 147.0
	set trace_duration_(019) 142.0
	set trace_duration_(020) 140.0
	set trace_duration_(021) 140.0
	set trace_duration_(022) 141.0
	set trace_duration_(023) 140.0
	set trace_duration_(024) 145.0
	set trace_duration_(025) 143.0
	set trace_duration_(026) 137.0
	set trace_duration_(027) 132.0
	set trace_duration_(028) 136.0
	set trace_duration_(029) 133.0
	set trace_duration_(030) 126.0
	set trace_duration_(031) 128.0
	set trace_duration_(032) 129.0
	set trace_duration_(033) 124.0
	set trace_duration_(034) 124.0
	set trace_duration_(035) 121.0
	set trace_duration_(036) 121.0
	set trace_duration_(037) 121.0
	set trace_duration_(038) 118.0
	set trace_duration_(039) 122.0
	set trace_duration_(040) 120.0
	set trace_duration_(041) 118.0
	set trace_duration_(042) 117.0
	set trace_duration_(043) 115.0
	set trace_duration_(044) 112.0
	set trace_duration_(045) 113.0
	set trace_duration_(046) 110.0
	set trace_duration_(047) 110.0
	set trace_duration_(048) 106.0
	set trace_duration_(049) 109.0
	set trace_duration_(050) 108.0
	set trace_duration_(051) 106.0
	set trace_duration_(052) 106.0
	set trace_duration_(053) 105.0
	set trace_duration_(054) 105.0
	set trace_duration_(055) 99.0
	set trace_duration_(056) 96.0
	set trace_duration_(057) 94.0
	set trace_duration_(058) 91.0
	set trace_duration_(059) 89.0
	set trace_duration_(060) 91.0
	set trace_duration_(061) 86.0
	set trace_duration_(062) 80.0
	set trace_duration_(063) 81.0
	set trace_duration_(064) 81.0
	set trace_duration_(065) 77.0
	set trace_duration_(066) 73.0
	set trace_duration_(067) 76.0
	set trace_duration_(068) 71.0
	set trace_duration_(069) 70.0
	set trace_duration_(070) 72.0
	set trace_duration_(071) 69.0
	set trace_duration_(072) 69.0
	set trace_duration_(073) 69.0
	set trace_duration_(074) 66.0
	set trace_duration_(075) 69.0
	set trace_duration_(076) 65.0
	set trace_duration_(077) 65.0
	set trace_duration_(078) 65.0
	set trace_duration_(079) 65.0
	set trace_duration_(080) 62.0
	set trace_duration_(081) 62.0
	set trace_duration_(082) 60.0
	set trace_duration_(083) 59.0
	set trace_duration_(084) 58.0
	set trace_duration_(085) 58.0
	set trace_duration_(086) 59.0
	set trace_duration_(087) 57.0
	set trace_duration_(088) 56.0
	set trace_duration_(089) 55.0
	set trace_duration_(090) 54.0
	set trace_duration_(091) 55.0
	set trace_duration_(092) 52.0
	set trace_duration_(093) 52.0
	set trace_duration_(094) 51.0
	set trace_duration_(095) 50.0
	set trace_duration_(096) 50.0
	set trace_duration_(097) 51.0
	set trace_duration_(098) 51.0
	set trace_duration_(099) 49.0
	set trace_duration_(100) 49.0
	set trace_duration_(101) 48.0
	set trace_duration_(102) 50.0
	set trace_duration_(103) 47.0
	set trace_duration_(104) 45.0
	set trace_duration_(105) 38.0
	set trace_duration_(106) 44.0
	set trace_duration_(107) 42.0
	set trace_duration_(108) 40.0
	set trace_duration_(109) 38.0
	set trace_duration_(110) 38.0
	set trace_duration_(111) 34.0
}


proc trace_group_fill_ { movement_trace_group_ args } {
	upvar $movement_trace_group_ trace_group_

	# I assign four different groups to the traces: 22 traces in each group

	# group A:	 traces 1 to 22
	for { set i 1 } { $i <= 22 } {incr i} {
		set trace_group_($i) 1
	}

	# group B:	 traces 23 to 44
	for { set i 23 } { $i <= 44 } {incr i} {
		set trace_group_($i) 2
	}

	# group C:	 traces 45 to 66
	for { set i 45 } { $i <= 66 } {incr i} {
		set trace_group_($i) 3
	}

	# group D:	 traces 67 to 88
	for { set i 67 } { $i <= 88 } {incr i} {
		set trace_group_($i) 4
	}

	# group E:	 traces 89 to 111
	for { set i 89 } { $i <= 111 } {incr i} {
		set trace_group_($i) 5
	}
}