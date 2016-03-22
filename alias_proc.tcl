
proc create_alias {proc_name {alias "_"}} {
	# Get the proc's arguments
	set proc_args [info args $proc_name]
	# To pass the arguments to the actual procedure 
	set caller_args {}
	set idx -1 
	# Checking for the default arguments 
	foreach argument $proc_args {
		incr idx 
		if {[info default $proc_name $argument value]} {
			if {$value eq {}} {
				set value "{}"
			}
			lset proc_args $idx "$argument $value"
		}
		# Appending '$variable' representation
		append caller_args "\$$argument "
	}
	# If user doesn't pass the alias proc name
	# then simply creating alias with underscore appended to it
	if {$alias eq "_"} {
		set new_proc_name "${alias}${proc_name}"
	} else {
		set new_proc_name $alias
	}
	if {$caller_args ne {}} {
		set new_proc_code "proc $new_proc_name {$proc_args} {eval $proc_name $caller_args}"
	} else {
		set new_proc_code "proc $new_proc_name {$proc_args} {$proc_name}"
	}
	# evaluating the procedure
	eval $new_proc_code
}



