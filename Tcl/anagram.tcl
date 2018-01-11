#!/usr/bin/tclsh
proc get_ascii_count str { 
	set count 0
	set len [ string length $str ] 
	for { set i 0 } { $i < $len } { incr i }  {
		set chr [ string index $str $i ]
		scan $chr %c ascii
		incr count $ascii
	}
	#puts "$str's count : $count"
	return $count
}


set name "STACKOVERFLOW"
set test "flowstackover"



proc is_anagram { src dst } { 

	set result 0
	set is_same_case 0

	if { [string length $src]!=[string length $dst] } { 
		return $result
	}

	set src_count [ get_ascii_count $src ]
	set dst_count [ get_ascii_count $dst ]

	
	
	if { [ string is upper $src_count ] && [ string is upper $dst_count ] || \
	     [ string is lower $src_count ] && [ string is lower $dst_count ] } {
		set is_same_case 1

	}

	if { $is_same_case } {
		if { $src_count == $dst_count } { 
			set result 1
		}

	} else {
		if {! [ expr [ expr $src_count-$dst_count ]%32 ] } { 
			set result 1
		}
	}
	
	return $result
}

if { [ is_anagram $name $test ] } { 
 	puts "ANAGRAM"
} else { 
	puts "NO ANAGRAM"
}

