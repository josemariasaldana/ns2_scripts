# $perl calculate_summary_one_car.pl delay_jitter_mos_car_8.txt 8 3.5 0
#
# the arguments are:
#	- file where data of a car are			delay_jitter_mos_car_8.txt
#	- number of the car						8
#	- MOS limit for an acceptable quality	3.5
#	- number of "jokers"					0
#
# the program looks for the best interval, i.e. the continuous one in which MOS is acceptable
#and puts to output the beginning and ending times and positions of the car, and also the average delay, jitter, loss and MOS

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

my $num_good_ticks = 0;
my $initial_interval_time = 0;
my $final_interval_time = 0;
my $initial_x_position = 0;
my $final_x_position = 0;
my $average_delay_interval = 0;
my $average_jitter_interval = 0;
my $average_loss_interval = 0;
my $average_mos_interval = 0;
my $current_maximum = 0;					# maximum number of continuous good ticks
my $initial_best_interval_time = 0;
my $initial_best_interval_x_position = 0;

$input_file = $ARGV[0];
$car_number = $ARGV[1];						# it is only for putting it in the output file
$mos_limit  = $ARGV[2];
$num_jokers = $ARGV[3];

open(my $input, $input_file); 
my $line_input = read_file_line($input);	# this reads the line with the titles of the columns

# the value for the MOS is in the column 13 of the input file $line_input->[13]

# I read the file
while ($line_input != 0) {
	$line_input = read_file_line($input);	# this reads another data line

	# if the tick is acceptable
	if ( $line_input->[13] >= $mos_limit ) {

		if ( $num_good_ticks == 0 ) {
			# this is the first acceptable tick
			$initial_interval_time = $line_input->[0];
			$initial_x_position = $line_input->[1];
		}

		# if the tick is acceptable, I recalculate the average of the values in an incremental manneer
		# new average = (1/n+1) * (n average + new value)

		$average_delay_interval = ( 1 / ( $num_good_ticks + 1 ) ) * ( ( $num_good_ticks * $average_delay_interval) + $line_input->[6]);
		$average_jitter_interval = ( 1 / ( $num_good_ticks + 1 ) ) * ( ( $num_good_ticks * $average_jitter_interval) + $line_input->[9]);
		$average_loss_interval = ( 1 / ( $num_good_ticks + 1 ) ) * ( ( $num_good_ticks * $average_loss_interval) + $line_input->[12]);
		$average_mos_interval = ( 1 / ( $num_good_ticks + 1 ) ) * ( ( $num_good_ticks * $average_mos_interval) + $line_input->[13]);

		$num_good_ticks = $num_good_ticks + 1;

		# if I have a new maximum, I store these values
		if ( $num_good_ticks >= $current_maximum_good_ticks ) {
			$current_maximum_good_ticks = $num_good_ticks;
			$initial_best_interval_time = $initial_interval_time;
			$initial_best_interval_x_position = $initial_x_position;
			$average_delay_best_interval = $average_delay_interval;
			$average_jitter_best_interval = $average_jitter_interval;
			$average_loss_best_interval = $average_loss_interval;
			$average_mos_best_interval = $average_mos_interval;
		}

	# if the tick is not acceptable, I reduce the number of "jokers"
	} else {
		# If the jokers have not finished, this tick is also taken into account
		if ( ( $num_jokers > 0 ) && ( $num_good_ticks > 0 ) ) {
			$num_jokers = $num_jokers - 1;			
			# although this tick is not acceptable, as I have a "joker", I recalculate the average of the values 

			$average_delay_interval = ( 1 / ( $num_good_ticks + 1 ) ) * ( ( $num_good_ticks * $average_delay_interval) + $line_input->[6]);
			$average_jitter_interval = ( 1 / ( $num_good_ticks + 1 ) ) * ( ( $num_good_ticks * $average_jitter_interval) + $line_input->[9]);
			$average_loss_interval = ( 1 / ( $num_good_ticks + 1 ) ) * ( ( $num_good_ticks * $average_loss_interval) + $line_input->[12]);
			$average_mos_interval = ( 1 / ( $num_good_ticks + 1 ) ) * ( ( $num_good_ticks * $average_mos_interval) + $line_input->[13]);

			$num_good_ticks = $num_good_ticks + 1;

			# if I have a new maximum, I store these values
			if ( $num_good_ticks >= $current_maximum_good_ticks ) {
				$current_maximum_good_ticks = $num_good_ticks;
				$initial_best_interval_time = $initial_interval_time;
				$initial_best_interval_x_position = $initial_x_position;
				$average_delay_best_interval = $average_delay_interval;
				$average_jitter_best_interval = $average_jitter_interval;
				$average_loss_best_interval = $average_loss_interval;
				$average_mos_best_interval = $average_mos_interval;
			}

		} else { ;# no more "jokers"
			# this tick is bad and there are no more "jokers". this means that this is the end of the best interval
			if ($current_maximum_good_ticks == $num_good_ticks ) {
				$final_interval_time = $line_input->[0];
				$final_x_position = $line_input->[1];
				$num_good_ticks = 0;
				# I set the number of "jokers" to its initial value again
				$num_jokers = $ARGV[3];
			}

		}
	}
	#print STDOUT "$line_input->[0]\t current maximum:$current_maximum_good_ticks\tnum_good_ticks: $num_good_ticks\tavg delay: $average_mos_best_interval\n";
}

# I add a line to the output file
print STDOUT "$car_number\t$initial_best_interval_time\t$final_interval_time\t$initial_best_interval_x_position\t$final_x_position\t$average_delay_best_interval\t$average_jitter_best_interval\t$average_loss_best_interval\t$average_mos_best_interval\n";

close($input);