# type: perl extraer_num_tiempo_uplink_received.pl <trace file>  >    output file

# a partir de una traza de la parte cableada, saca las columnas a otro fichero
# 11	número de serie del paquete
# 1	instante

# ejemplo línea de la traza
# r 118.06344 1 0 udp 102 ------- 0 1.0.2.4 0.0.0.9 5035 13125

$infile=$ARGV[0];

open (DATA,"<$infile")
   || die "Can't open $infile $!";
  
while (<DATA>) {

	@x = split(' ');
	print STDOUT "$x[11]\t$x[1]\n";
}

close DATA;
exit(0);
