#convert the trace file into binary for ns2 video data attachment. 
set original_file_name pru.txt 
set trace_file_name pru.dat 
set original_file_id [open $original_file_name r] 
set trace_file_id [open $trace_file_name w] 
set last_time 0

# I read the first line and o not use it
gets $original_file_id current_line

puts -nonewline $trace_file_id [binary format "I" 1 ] 
# I read line by line 

while {[eof $original_file_id] == 0} { 
    gets $original_file_id current_line 
	#puts "$current_line"
    if {[string length $current_line] == 0 || [string compare [string index $current_line 0] "#"] == 0} { 
		continue 
	} 

   # scan $current_line "%d %s %d" next_time type length
	scan $current_line "%d %d" next_time length 

    set time [expr 1000*($next_time - $last_time)] 
    set last_time $next_time 
	#puts -nonewline "$next_time $length"
	#puts -nonewline "$length"
    puts -nonewline $trace_file_id [binary format "II" "$time" " $length"] 
} 

close $original_file_id 
close $trace_file_id 