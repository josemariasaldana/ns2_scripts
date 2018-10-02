system "printf 'the test begins here\n' >> prediction_results_all_traces_.txt";
for ($trace = 1; $trace <= 111; $trace++) {
	for ($car = 1; $car <= 3; $car++) {

		system "ns cars_street_v28.tcl MECH_$car $trace 0 1 1 1 mechanism 60";

	}
	# for every trace, I begin a new line
	system "printf '\n' >> prediction_results_all_traces_.txt";
}

exit();