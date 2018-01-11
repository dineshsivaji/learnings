#!/usr/bin/tclsh
proc Echo_Client {host port} {
        set s [socket $host $port]
        fconfigure $s -buffering line
        return $s
}
if {$argc!=1} {
        puts "usage : $argv0 <server-port>"
        exit 1
}
set port [lindex $argv 0]
set s [Echo_Client localhost $port]
puts $s "Hello!"
puts -->[gets $s]<--
