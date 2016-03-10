#!/usr/bin/tclsh
proc Echo_Server {} {
        global echo
        set echo(main) [socket -server EchoAccept 0]
        puts "I'm waiting... on the port [lindex [fconfigure $echo(main) -sockname] end]"
        vwait events

}
proc EchoAccept {sock addr port} {
        global echo
        puts "Accept $sock from $addr port $port"
        set echo(addr,$sock) [list $addr $port]
        fconfigure $sock -buffering line
        fileevent $sock readable [list Echo $sock]
}
proc Echo {sock} {
        global echo
        if {[eof $sock] || [catch {gets $sock line}]} {
                # end of file or abnormal connection drop
                close $sock
                puts "Close $echo(addr,$sock)"
                unset echo(addr,$sock)
        } else {
                puts "I received $line"
                if {[string compare $line "quit"] == 0} {
                        # Prevent new connections.
                        # Existing connections stay open.
                        close $echo(main)
                }
                puts $sock $line
        }
}
Echo_Server

