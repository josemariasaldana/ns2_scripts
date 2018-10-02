# this PERL script reads three arguments:
#
# $perl calculate_mos_up_down.pl packets_fps_up_car_2.txt packets_fps_down_car_2.txt 1 20
#
# file where uplink packet data are
# file where downlink packets data are
# tick to calculate delay, jitter, MOS
# extra owd in ms to add artificially

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

$up_file=$ARGV[0];
$down_file=$ARGV[1];
$tick = $ARGV[2];
$extra_owd = $ARGV[3] / 1000;	# I pass it to seconds

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
my $stdev_total = 0;
my $stdev_total_ms = 0;
my $num_packets_up = 0;
my $num_packets_down = 0;
my $average_delay_up = 0;
my $average_delay_down = 0;
my $average_delay = 0;
my $average_delay_ms = 0;
my $loss_up = 0;
my $loss_down = 0;
my $loss_rate_up = 0;
my $loss_rate_down = 0;
my $x = 0;
my $mos = 0;
my $acceptable = 1;
my $acum_acceptable_ticks = 0;
my $acum_acceptable_ticks_3 = 0;
my $x_position = 0;

my $now = $initial_time;
my $end_file = 0;

# if one of the two files has finished, I set to 1 the variable end_file
if ((not $line_up ) or (not $line_down)) {
	$end_file = 1;
} else {
	# I get the position of the car in order to add it to the output file
	# I get it from the uplink file, since the position appears even if the packet does not arrive to the destination
	# The position is estimated as the one when the car sends the first packet of each tick
	$x_position = $line_up->[4];
}

# I put this first line in the output file, including the title for each column
print STDOUT "tick begin\tx_position\taverage_delay_up\tnum_packets_up\taverage_delay_down\tnum_packets_down\taverage_delay_ms\tstdev_up\tstdev_down\tstdev_total_ms\tloss_rate_up\tloss_rate_down\tloss_rate_total\tMOS\n";

# I read the two files, looking for the lowest sending time, and acumulating it in sum_delay_up or _down
while ($end_file == 0) {
	while (($end_file == 0) and ($now < $initial_time + $tick)) {
		# A tick begins here

		# If the next packet is in the uplink, I accumulate the up packet
		if ($line_up->[1] < $line_down->[1]) {		
			if (($line_up->[2] != -1) and ($line_up->[2] != -2)) {
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
			} else {
				$loss_up = $loss_up + 1;
			}
			$now = $line_up->[1];

			# I read a new line from up file
			#print STDOUT "Leo de up: $line_up->[1]\n";
			$line_up = read_file_line($up);

		# if the next packet is in the downlink, I accumulate the down packet
		} else {	
			if (($line_down->[2] != -1) and ($line_down->[2] != -2)) {

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
			} else {
				$loss_down = $loss_down + 1;
			}
			$now = $line_down->[1];

			# I read a new line from up file
			#print STDOUT "Leo de down: $line_down->[1]\n";
			$line_down = read_file_line($down);
		}
		if ((not $line_up ) or (not $line_down)) {
			$end_file = 1;
		}
	} # end while of tick
	#print STDOUT "tick ended \n";
	# A tick has ended. I write the results

	if ($sum_delay_up != 0) {
		$average_delay_up = $extra_owd + ( $sum_delay_up / $num_packets_up );
	} else {
		$average_delay_up = 0;
	}
	if ($sum_delay_down != 0) {
		$average_delay_down = $extra_owd + ( $sum_delay_down / $num_packets_down );
	} else {
		$average_delay_down = 0;
	}

	# I write a line, except for the last tick
	if ($end_file == 0) {
		# calculate the average delay as the sum of the average delay up and down, but only if both exist
		if (($average_delay_up != 0) and ($average_delay_down != 0)) {
			$average_delay = $average_delay_up + $average_delay_down;
		} else {
			$average_delay = 0;
		}

		# I do some calculations
		# jitter
		$stdev_up = sqrt($variance_up);
		$stdev_down = sqrt($variance_down);
		$stdev_total = sqrt( ($stdev_up *$stdev_up ) + ($stdev_down * $stdev_down));

		# packet loss
		if ( $num_packets_up + $loss_up > 0 ) {
			$loss_rate_up = $loss_up / ( $num_packets_up + $loss_up);
		} else {
			$loss_rate_up = 1;	# there are no packets
		}
		if ( $num_packets_down + $loss_down > 0 ) {
			$loss_rate_down = $loss_down / ( $num_packets_down + $loss_down);
		} else {
			$loss_rate_down = 1;	# there are no packets
		}
		$loss_rate_total = ( $loss_up + $loss_down ) / ( $num_packets_up + $loss_up + $num_packets_down + $loss_down );

		# I use a factor of 1000 in order to obtain milliseconds
		$average_delay_ms = $average_delay * 1000;
		$stdev_total_ms = $stdev_total * 1000;

		# MOS calculation
		# X=0.104*ping_average (ms) + jitter_average(ms)
		# MOS = -0.00000587 X3 + 0.00139 X2 – 0.114 X + 4.37
		if ( ( $loss_rate_total < 0.35 ) and ( $average_delay != 0) ) {
			$x = ( 0.104 * $average_delay_ms ) + ( $stdev_total_ms );
			$mos = ( -0.00000587 * $x * $x * $x ) + ( 0.00139 * $x * $x ) - (0.114 * $x) + 4.37;

			# the minimum value for MOS is 1
			if ( $mos < 1.0 ) {
				$mos = 1;
			}
		} else {
			$mos = 1;
		}

		# I add a line to the output file
		print STDOUT "$initial_time\t$x_position\t$average_delay_up\t$num_packets_up\t$average_delay_down\t$num_packets_down\t$average_delay_ms\t$stdev_up\t$stdev_down\t$stdev_total_ms\t$loss_rate_up\t$loss_rate_down\t$loss_rate_total\t$mos\n";

		# I get the position of the car in order to add it to the output file
		# I get it from the uplink file, since the position appears even if the packet does not arrive to the destination
		# The position is estimated as the one when the car sends the first packet of each tick
		$x_position = $line_up->[4];
	}	

	# restart variables
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

} # one of the files has ended

close($up); 
close($down); 
