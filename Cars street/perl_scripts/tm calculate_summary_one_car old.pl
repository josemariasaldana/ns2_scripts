# this PERL script reads three arguments:
#
# $perl calculate_mos_up_down.pl packets_fps_up_car_2.txt packets_fps_down_car_2.txt 1
#
# file where data of a car are
# number of the car
# column for which I am looking for the maximum (it refers to the accumulated ticks with acceptable MOS). Normally column 14
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
my $current_maximum = 0;
my $initial_best_interval_time = 0;
my $initial_best_interval_x_position = 0;

$input_file=$ARGV[0];
open(my $input, $input_file); 
my $line_input = read_file_line($input);	# this reads the line with the titles
my $line_input = read_file_line($input);	# this reads the first data line

$car_number = $ARGV[1];
$column = $ARGV[2];

# I read the first data line
# if there is a line and the tick is acceptable, I set the values 
if ( ( $line_input != 0) and ( $line_input->[$column] > 0) ) {
	$num_good_ticks = 1;
	$initial_interval_time = $line_input->[0];
	$initial_x_position = $line_input->[1];
	$average_delay_interval = $line_input->[6];
	$average_jitter_interval = $line_input->[9];
	$average_loss_interval = $line_input->[12];
	$average_mos_interval = $line_input->[13];
	$current_maximum = $line_input->[$column];
}

# I have to find the maximum value of the column number 14 ($column)

# I read the file
while ($line_input != 0) {
	$line_input = read_file_line($input);	# this reads another data line

	# if the tick is acceptable
	if ( $line_input->[$column] > 0 ) {

		if ( $num_good_ticks == 0 ) {
			# this is the first acceptable tick
			$initial_interval_time = $line_input->[0];
			$initial_x_position = $line_input->[1];
		}

		# if the number of accumulated ticks increases, I recalculate the average of the values in an incremental manneer
		# new average = (1/n+1) * (n average + new value)

		$average_delay_interval = ( 1 / ( $num_good_ticks + 1 ) ) * ( ( $num_good_ticks * $average_delay_interval) + $line_input->[6]);
		$average_jitter_interval = ( 1 / ( $num_good_ticks + 1 ) ) * ( ( $num_good_ticks * $average_jitter_interval) + $line_input->[9]);
		$average_loss_interval = ( 1 / ( $num_good_ticks + 1 ) ) * ( ( $num_good_ticks * $average_loss_interval) + $line_input->[12]);
		$average_mos_interval = ( 1 / ( $num_good_ticks + 1 ) ) * ( ( $num_good_ticks * $average_mos_interval) + $line_input->[13]);

		$num_good_ticks = $num_good_ticks + 1;

		# I have a new maximum, so I store these values
		if ( $line_input->[$column] > $current_maximum ) {
			$current_maximum = $line_input->[$column];
			$initial_best_interval_time = $initial_interval_time ;
			$initial_best_interval_x_position = $initial_x_position;
			$average_delay_best_interval = $average_delay_interval;
			$average_jitter_best_interval = $average_jitter_interval;
			$average_loss_best_interval = $average_loss_interval;
			$average_mos_best_interval = $average_mos_interval;
		}

	# if the tick is not acceptable, I maintain the average values and store the current tick as the end of the interval
	} else {
		# if I have passed from the maximum to 0, this means that this is the end of the best interval
		if ($current_maximum == $num_good_ticks ) {
			$final_interval_time = $line_input->[0];
			$final_x_position = $line_input->[1];
		}
		$num_good_ticks = 0;
	}
	#print STDOUT "$line_input->[0]\t current maximum:$current_maximum\tnum_good_ticks: $num_good_ticks\tavg delay: $average_delay_interval\n";
}

# I add a line to the output file
print STDOUT "$car_number\t$initial_best_interval_time\t$final_interval_time\t$initial_best_interval_x_position\t$final_x_position\t$average_delay_best_interval\t$average_jitter_best_interval\t$average_loss_best_interval\t$average_mos_best_interval\n";

close($input);