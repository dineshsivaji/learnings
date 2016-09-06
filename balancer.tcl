proc dputs {msg} {
	global dbg
	if {[info exists dbg] && $dbg} {
		puts $msg
	}
} 

proc bye {} {
	append info \n "Supported arguments" \n
	append info "\t -f <input-file> (Mandatory)" \n
	append info "\t -d <0|1> (Optional) " \n
	puts $info
	exit 1
}

set dbg 0
if {[catch {array set aArgs $argv} issue]} {
	bye
}
if {[info exists aArgs(-f)]} {
	set inputFile $aArgs(-f)
} else {
	bye	
}
if {[info exists aArgs(-d)]} {
	set ::dbg $aArgs(-d)
}

set row 0 
set is_quote 0
set brace_count 0 
set seq_backslash_count 0
set concat_line {}

array set brace_info {}
set quote_info {}

set fp [open $inputFile r]

while {[gets $fp line]!=-1} {
	incr row
	set line [string trim $line]
	# Skipping empty lines or the lines with comments
	if {[regexp "^#" $line] || $line eq {}} {
		continue 
	}

	# Adding all line-continued statements
	# into single line
	if {[regexp {\\$} $line]} {
	  append concat_line "$line "
	  continue
	} else {
	  # If 'concat_line' is not empty means, it is
	  # the end of the concatened line.
	  if {$concat_line ne {}} {
	    append concat_line "$line "
	    # Replacingall the backslashes with empty string
	    regsub -all {\\} $concat_line {} line
	    set concat_line {}
	  }
	}
	dputs "line ->$line<-"
	set col 0 
	foreach char [split $line ""] {
		incr col 
		switch -- $char {
			"\"" {
				if {$brace_count!=0} {
					dputs "quotes inside braces"
					continue
				}
				if {$seq_backslash_count==0} {
					lappend quote_info $row,$col 
					set is_quote [expr {!$is_quote}]
					dputs "quotes @ $row,$col"
				} else {
					dputs "literal quotes @ $row,$col"
				}
				set seq_backslash_count 0
			}
			"\\" {
				incr seq_backslash_count
				set backslash_loc $col
				dputs "bs @ $row,$col , backslash_loc : $backslash_loc"
			}
			"{"  {
				if {$is_quote} {
					dputs "brace having a quote before"
					dputs "brace_count : $brace_count"
					set seq_backslash_count 0
					continue
				}

				dputs "opening of brace, seq-bs : $seq_backslash_count"
				dputs "brace_count : $brace_count"
			
				if {$brace_count==0} {
					if {$seq_backslash_count==0} {
						dputs "should increase"
						incr brace_count  
						set brace_info($brace_count,open) $row,$col 
					} else {
						dputs "literal open brace only"
					}
				} else {
					if {[expr {$seq_backslash_count%2}]==0} {
						incr brace_count  
						set brace_info($brace_count,open) $row,$col 
					} else {
						dputs "literal open brace "
					}
				}
				set seq_backslash_count 0
			}
			"}" {
				if {$is_quote} {
					dputs "brace having a quote before"
					dputs "brace_count : $brace_count"
					set seq_backslash_count 0
					continue
				}
				dputs "closing of brace, seq-bs : $seq_backslash_count"
				dputs "brace_count : $brace_count"
			
				if {$brace_count==0} {
					if {$seq_backslash_count==0} {
						dputs "should reduce"
						set brace_info($brace_count,close) $row,$col 
						incr brace_count -1 
					} else {
						dputs "literal close brace only"
					}
				} else {
					if {[expr {$seq_backslash_count%2}]==0} {
						set brace_info($brace_count,close) $row,$col 
						incr brace_count -1 
					} else {
						dputs "literal close brace "
					}
				}
				set seq_backslash_count 0
			}
			default {
				set seq_backslash_count 0
			}
		}
	}
	if {$brace_count==0} {
		array unset brace_info
		set brace_count 0 
		set seq_backslash_count 0
		set concat_line {}
		dputs "balanced brace set"
	}
	if {!$is_quote} {
		dputs "balanced quote set"
	}
}
close $fp

dputs "last : $brace_count"

if {$is_quote} {
       puts "Unbalanced or extra quotes in the input"	
       puts $quote_info
}
if {$brace_count!=0} {
	puts "Unbalanced or extra braces in the input ..."
	puts "brace->$brace_count"
	parray brace_info 
}	
