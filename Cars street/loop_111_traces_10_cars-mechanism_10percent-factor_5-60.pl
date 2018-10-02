system "printf 'the test begins here\n' >> prediction_results_all_traces-mechanism-60.txt";
for ($trace = 1; $trace <= 111; $trace++) {
	for ($car = 1; $car <= 1; $car++) {

		system "ns cars_street_v29.tcl MECH_10percent_60_$car $trace 0 1 1 1 mechanism 60 0.0 0.1 5";

	}
	# for every trace, I begin a new line
	system "printf '\n' >> prediction_results_all_traces-mechanism-60.txt";
}
exit();