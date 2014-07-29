#!/usr/bin/tclsh

#Global stack frame values
set a 0
set b 1

proc level1 {  } {
	set t Naruto
	upvar #0  a answer
	puts $answer
	level2
}

proc level2 { } { 
	set l2 test
	level3
}
proc level3 { } {
	level4 
}

proc level4 { } { 
	#Accessing global variable 'b' with '#0' option
	upvar #0 b final
	puts "Final : (value of b) = $final"

	set z dinesh
	#Accessing local variable 'z' with '0' option
	upvar 0 z newz
	set newz vignesh
	puts $z

	#Accessing local variable of the proc 'level2' with '2' option
	#which is specifying the 2 higher level of stack frames
	upvar 2 l2 newt
	puts $newt

	#Accessing stack frame 3
	upvar 3 t sample
	puts $sample

	#Accessing stack frame 4 which is 'main' stack frame
	upvar 4 a cool
	puts $cool

	#Uncomment the below 2 lines. This will throw error as 'bad level, since there is no such level
	#upvar 5 c wow
	#puts $wow
}

#Calling the first stack frame 
level1



#############OUTPUT#####################
# dsivaji@dsivaji-VirtualBox:~/pgms/tcl$ ./upvar.tcl 
# 0
# Final : (value of b) = 1
# vignesh
# test
# Naruto
# 0
