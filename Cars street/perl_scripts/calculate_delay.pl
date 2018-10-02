#use strict; 
#use warnings; 
 
sub read_file_line { 
  my $fh = shift; 
 
  if ($fh and my $line = <$fh>) { 
    chomp $line; 
    return [ split(/\t/, $line) ]; 
  } 
  return; 
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

my $acum_delay = 0;
my $num_packets = 0;
my $average_delay = 0;

# calculate the delay for uplink
while ($line_up) {

	if ($line_up->[1] < ($initial_time + $tick)) {
		if ($line_up->[2] != -1) {
			$acum_delay = $acum_delay + $line_up->[2] - $line_up->[1];
			$num_packets = $num_packets + 1;
		}
	} else {
		if ($acum_delay != 0) {
			$average_delay = $acum_delay / $num_packets;
		} else {
			$average_delay = 0;
		}
		print STDOUT "$initial_time\t$average_delay\n";
		$initial_time = $initial_time + $tick;
		$acum_delay = 0;
		$num_packets = 0;
  	}
	$line_up = read_file_line($up);
}



close($up); 
close($down); 
