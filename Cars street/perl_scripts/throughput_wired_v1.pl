# type: perl throughput.pl <trace file> <origin node> <destination node> <IP origin> <IP destination> <granlarity> <protocol>   >    output file

# $ perl throughput.pl out.tr 5 0.1 tcp > throughput_5.txt

# the result is in bps

# the script computes the bps RECEIVED by the node in the trace
# the script only takes into account the received packets 'r' in the trace file
# the link to study has to be included in the trace
# the IP, TCP and UDP headers are not counted

$infile=$ARGV[0];
$fromnode=$ARGV[1];
$tonode=$ARGV[2];
$ip_origin=$ARGV[3];
$ip_destination=$ARGV[4];
$granularity=$ARGV[5];
$protocol=$ARGV[6]; #'tcp' or 'cbr'

#we compute how many bits were transmitted during time interval specified
#by granularity parameter in seconds
$sum=0;
$clock=0;

      open (DATA,"<$infile")
        || die "Can't open $infile $!";
  
    while (<DATA>) {
             @x = split(' ');

#column 1 is time 
if ($x[1]-$clock <= $granularity)
{
#checking if the event corresponds to a reception 
if ($x[0] eq 'r') 
{ 
#checking if the origin corresponds to arg 1
if ($x[2] eq $fromnode) 
{ 
#checking if the destination corresponds to arg 2
if ($x[3] eq $tonode) 
{ 
#checking if the IP origin corresponds to arg 3
if ($x[8] eq $ip_origin) 
{ 
#checking if the IP destination corresponds to arg 4
if ($x[9] eq $ip_destination) 
{ 
#checking if the packet type is the name of the corresponding protocol
if ($x[4] eq $protocol) 
{
    $sum=$sum+(8*$x[5]); #multiplico por 8 para sacar bps
}
}
}
}
}
}
}
else
{   $throughput=$sum/$granularity;
    print STDOUT "$x[1]\t$throughput\n";
    $clock=$clock+$granularity;
    $sum=0;
}   
}
   $throughput=$sum/$granularity;
    print STDOUT "$x[1]\t$throughput\n";
    $clock=$clock+$granularity;
    $sum=0;

    close DATA;
exit(0);
 
