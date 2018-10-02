# type: perl extraer_parametros.pl <trace file>  >    output file

# $ perl extraer_parametros.pl out.tr > output.txt

# saca las columnas a otro fichero

# 40 número serie
# 2 tiempo
# 36 tamaño del paquete a nivel IP
# 11 posición X
# 42 TTL (depende del número de veces que se ha retransmitido

$infile=$ARGV[0];

open (DATA,"<$infile")
   || die "Can't open $infile $!";
  
while (<DATA>) {

	@x = split(' ');
	print STDOUT "$x[40]\t$x[2]\t$x[36]\t$x[10]\t$x[42]\n";
}

close DATA;
exit(0);
 
 
