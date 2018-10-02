# type: perl throughput_wireless_v1.pl <trace file> <origin node> <destination node> <granlarity> <protocol>   >    output file

# $ perl throughput.pl out.tr 5 0.1 tcp > throughput_5.txt

# the result is in bps

# the script computes the bps RECEIVED by the node in the trace
# the script only takes into account the received packets 'r' in the trace file
# the link to study has to be included in the trace
# the IP, TCP and UDP headers are not counted

$infile=$ARGV[0];
$fromnode=$ARGV[1];
$tonode=$ARGV[2];
$granularity=$ARGV[3];
$protocol=$ARGV[4]; #'tcp' or 'cbr'

#we compute how many bits were transmitted during time interval specified
#by granularity parameter in seconds
$sum=0;
$clock=0;

      open (DATA,"<$infile")
        || die "Can't open $infile $!";
  
    while (<DATA>) {
             @x = split(' ');

#column 3 is time 
if ($x[2]-$clock <= $granularity)
{
#checking if the event corresponds to a sending
if ($x[0] eq 's') 
{ 
#checking if the origin ethernet address corresponds to arg 1 (it is -Ms)
if ($x[26] eq $fromnode) 
{ 
#checking if the destination ethernet address corresponds to arg 2 (it is -Md)
if ($x[24] eq $tonode) 
{ 
#checking if the packet type is the name of the corresponding protocol (it is -It)
if ($x[34] eq $protocol) 
{
    $sum=$sum+(8*$x[36]); #multiplico por 8 para sacar bps (it is -Il)
}
}
}
}
}
else
{   $throughput=$sum/$granularity;
    print STDOUT "$x[2] $throughput\n";
    $clock=$clock+$granularity;
    $sum=0;
}   
}
   $throughput=$sum/$granularity;
    print STDOUT "$x[2] $throughput\n";
    $clock=$clock+$granularity;
    $sum=0;

    close DATA;
exit(0);
 
