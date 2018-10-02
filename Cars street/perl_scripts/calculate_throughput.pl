# this PERL script reads two arguments:
#
# $perl calculate_throughput.pl packets_ftp_down_car_1.txt 1
#
# file where downlink packets data are
# tick to calculate throughput

#use strict; 
#use warnings; 

# this subroutine returns a line from the file. If the file is ended, it returns 0
sub read_file_line { 
  my $fh = shift; 
 
  if ($fh and my $line = <$fh>) { 
    chomp $line; 
    return [ split(/\t/, $line) ]; 
  } 
  return 0; 
} 

$file=$ARGV[0];
$tick = $ARGV[1];

open(my $file_, $file); 

my $line_ = read_file_line($file_); 

# I begin in the second of the minimum initial time from the file
my $initial_time = int($line_->[1]);

my $acum_bytes = 0;
my $num_packets = 0;
my $now = $initial_time;
my $end_file = 0;

$x_position = $line_->[4];

# I put this first line in the output file, including the title for each column
print STDOUT "tick begin\tx_position\tthroughput_bps\tpps\n";

# I read the two files, looking for the lowest sending time, and acumulating it in sum_delay_up or _down
while ($end_file == 0) {
	while (($end_file == 0) and ($now < $initial_time + $tick)) {
		# A tick begins here

		# I accumulate the packet
		#print STDOUT "acumulate one packet $line_->[3] bytes\n";
		if ( $line_->[2] != -1) {
			$acum_bytes = $acum_bytes + $line_->[3]; 
			$acum_packets = $acum_packets + 1; 
		}
		$now = $line_->[1];
		#print STDOUT "now: $now\n";
		# I read a new line from the file
		#print STDOUT "Leo de up: $line_->[1]\n";
		$line_ = read_file_line($file_);

		if (not $line_ ) {
			$end_file = 1;
		}
	} # end while of tick
	#print STDOUT "tick ended \n";
	# A tick has ended. I write the results

	$throughput = 8 * $acum_bytes / $tick;
	$pps = $acum_packets / $tick;

	# I write a line, except for the last tick
	if ($end_file == 0) {
		# I add a line to the output file
		print STDOUT "$initial_time\t$x_position\t$throughput\t$pps\n";

		# I get the position of the car in order to add it to the output file
		# I get it from the uplink file, since the position appears even if the packet does not arrive to the destination
		# The position is estimated as the one when the car sends the first packet of each tick
		$x_position = $line_->[4];
	}	

	# restart variables
	$initial_time = $initial_time + $tick;
	$acum_bytes = 0;
	$acum_packets = 0;

} # the file has ended

close($file_); 