#use strict; 
#use warnings; 
 
sub read_file_line { 
  my $fh = shift; 
 
  if ($fh and my $line = <$fh>) { 
    chomp $line; 
    return [ split(/\t/, $line) ]; 
  } 
  return 0; 
} 

$up_file=$ARGV[0];
$down_file=$ARGV[1];
$tick = $ARGV[2];

open(my $up, $up_file); 
open(my $down, $down_file); 

my $line_up = read_file_line($up); 
my $line_down = read_file_line($down); 

# I begin in the second of the minimum initial time from the two files
my $initial_time = int($line_up->[1]);
if ($initial_time > int($line_down->[1])) {
	$initial_time = int($line_down->[1]);
}

my $delay = 0;
my $sum_delay_up = 0;
my $sum_delay_down = 0;
my $sum_squares_delay_up = 0;
my $sum_squares_delay_down = 0;
my $variance_up = 0;
my $variance_down = 0;
my $stdev_up = 0;
my $stdev_down = 0;
my $num_packets_up = 0;
my $num_packets_down = 0;
my $average_delay_up = 0;
my $average_delay_down = 0;
my $loss_up = 0;
my $loss_down = 0;
my $loss_rate_up = 0;
my $loss_rate_down = 0;
my $now = $initial_time;
my $end_file = 0;

# if one of the two files has finished, I set to 1 the variable end_file
if ((not $line_up ) or (not $line_down)) {
	$end_file = 1;
}

# I read the two files, looking for the lowest sending time, and acumulating it in sum_delay_up or _down
while ($end_file == 0) {
	while (($end_file == 0) and ($now < $initial_time + $tick)) {
		if ($line_up->[1] < $line_down->[1]) {		# I accumulate the up packet
			if ($line_up->[2] != -1) {

				$delay = $line_up->[2] - $line_up->[1]; 
				$sum_delay_up = $sum_delay_up + $delay;
				$sum_squares_delay_up = $sum_squares_delay_up + ($delay * $delay) ;

				# I use an incremental calculation of the variance: 1/n(n+1) * [(n+1) sum_squares  - sum^2]
				# for the first packet, variance is 0
				if ($num_packets_up == 0) {
					$variance_up = 0;
				} else {
					$variance_up = (1 / ( $num_packets_up * ($num_packets_up + 1))) * ( ( ( $num_packets_up + 1) * $sum_squares_delay_up ) - ( $sum_delay_up * $sum_delay_up));
				}
				$num_packets_up = $num_packets_up + 1;
				$now = $line_up->[1];
			} else {
				$loss_up = $loss_up + 1;
			}

			# I read a new line from up file
			$line_up = read_file_line($up);

		} else {	# I accumulate the down packet
			if ($line_down->[2] != -1) {
				$delay = $line_down->[2] - $line_down->[1]; 
				$sum_delay_down = $sum_delay_down + $delay;
				$sum_squares_delay_down = $sum_squares_delay_down + ($delay * $delay) ;

				# I use an incremental calculation of the variance: 1/n(n+1) * [(n+1) sum_squares  - sum^2]
				# for the first packet, variance is 0
				if ($num_packets_down == 0) {
					$variance_down = 0;
				} else {
					$variance_down = (1 / ( $num_packets_down * ($num_packets_down + 1))) * ( ( ( $num_packets_down + 1) * $sum_squares_delay_down ) - ( $sum_delay_down * $sum_delay_down));
				}
				$num_packets_down = $num_packets_down + 1;
				$now = $line_down->[1];
			} else {
				$loss_down = $loss_down + 1;
			}

			# I read a new line from up file
			$line_down = read_file_line($down);
		}
		if ((not $line_up ) or (not $line_down)) {
			$end_file = 1;
		}
	}
	if ($sum_delay_up != 0) {
		$average_delay_up = $sum_delay_up / $num_packets_up;
	} else {
		$average_delay_up = 0;
	}
	if ($sum_delay_down != 0) {
		$average_delay_down = $sum_delay_down / $num_packets_down;
	} else {
		$average_delay_down = 0;
	}
	# I write the results
	# I do not write anything in the last tick
	if ($end_file == 0) {
		# calculate the average delay as the sum of the average delay up and down, but only if both exist
		if (($average_delay_up != 0) and ($average_delay_down != 0)) {
			$average_delay = $average_delay_up + $average_delay_down;
		} else {
			$average_delay = 0;
		}

		# I do some calculations
		$stdev_up = sqrt($variance_up);
		$stdev_down = sqrt($variance_down);
		#$loss_rate_up = $num_packets_up / ( $num_packets_up + $loss_up);
		#$loss_rate_down = $num_packets_down / ( $num_packets_down + $loss_down);

		print STDOUT "$initial_time\t$average_delay_up\t$num_packets_up\t$average_delay_down\t$num_packets_down\t$average_delay\t$stdev_up\t$stdev_down\t$loss_up\t$loss_down\n";
		$initial_time = $initial_time + $tick;
		$sum_delay_up = 0;
		$sum_delay_down = 0;
		$num_packets_up = 0;		
		$num_packets_down = 0;
		$loss_up = 0;
		$loss_down = 0;
		$sum_squares_delay_up = 0;
		$sum_squares_delay_down = 0;
		$variance_up = 0;
		$variance_down = 0;

	}
}

close($up); 
close($down); 
