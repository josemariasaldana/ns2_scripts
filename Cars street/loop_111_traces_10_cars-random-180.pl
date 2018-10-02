system "printf 'the test begins here\n' >> prediction_results_all_traces-random-180.txt";
for ($trace = 1; $trace <= 111; $trace++) {
	for ($car = 1; $car <= 10; $car++) {

		system "ns cars_street_v29.tcl RAND_180_$car $trace 0 1 1 1 random 180 0 0";

	}
	# for every trace, I begin a new line
	system "printf '\n' >> prediction_results_all_traces-random-180.txt";
}
exit();