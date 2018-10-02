# this script makes a query from two files with two columns each
# it writes in the output:
# first column and second column of the first file
# if the first column of the second file matches, it puts the second column of the second file

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
 
sub compute { 
	print STDOUT "$_[0]\t$_[1]\t$_[2]\t$_[3]\t$_[4]\t$_[5]\n"

} 

$sent_file=$ARGV[0];
$received_file=$ARGV[1];

open(my $f1, $sent_file); 
open(my $f2, $received_file); 

my $pair1 = read_file_line($f1); 
my $pair2 = read_file_line($f2); 
 
while ($pair1 and $pair2) {
  if ($pair1->[0] < $pair2->[0]) {
    compute($pair1->[0], $pair1->[1], -1);  
    $pair1 = read_file_line($f1);
  } elsif ($pair2->[0] < $pair1->[0]) { 
    compute($pair1->[0], $pair1->[1], -2, $pair2->[2], $pair2->[3], $pair2->[4]);
    $pair2 = read_file_line($f2); 
  } else {
    compute($pair1->[0], $pair1->[1], $pair2->[1], $pair2->[2], $pair2->[3], $pair2->[4]); 
    $pair1 = read_file_line($f1); 
    $pair2 = read_file_line($f2); 
  } 
} 
# I copy the rows of the first file if there are more
while ($pair1) {
    compute($pair1->[0], $pair1->[1], -1, $pair1->[2], $pair1->[3], $pair1->[4]);  
    $pair1 = read_file_line($f1);
}

close($f1); 
close($f2); 
