#!/usr/bin/tclsh

 
 #interpreter alias without arguments
 proc parentShow {slave} {
        puts "Mr. $slave called me"
 }
 for {set i 0} {$i<5} {incr i} {
        interp create dinesh$i
        interp eval dinesh$i {proc show {} {puts wow}}
        interp alias dinesh$i show {} parentShow dinesh$i
        interp eval dinesh$i show
        interp delete dinesh$i
 } 




 #interpreter alias with arguments
 proc parentShow {slave args} {
        puts "$slave is called with $args"
 }
 for {set i 0} {$i<5} {incr i} {
        interp create dinesh$i
        interp eval dinesh$i {proc show {val} {puts $val}}
        interp alias dinesh$i show {} parentShow dinesh$i
        interp eval dinesh$i "show $i"
        interp delete dinesh$i
 }

