#!/usr/bin/tclsh


 ########## Code related to Socket communication Starts here ##########


proc writeSocket {stream string} {
     #set data [encoding convertto utf-8 $string]
     set data $string
     # if {[string length $data] > 0xffff} {
         # error "string to long after encoding"
     # }
     # set len [binary format S [string length $data]]
     # puts -nonewline $stream $len$data
     puts -nonewline $stream $data
     flush $stream
 }

 proc readSocket {stream} {
    global tclEngine
    #set data [read $stream 2]
    if {[eof $stream]} {
        # Closing unregisters all fileevent handlers too
        close $stream
        puts "Socket $stream is closing it's connection. Deleting it's interpreter..."
        interp delete $tclEngine($stream)
        unset tclEngine($stream)
        return -1
    }
    #binary scan $data S len
    set data [read $stream]
    #return [encoding convertfrom utf-8 $data]
	return $data
 }
 
 proc sandBox {sock userTclCmd} {
    puts "Running '$userTclCmd'in SandBox..."
    global tclEngine
    set hidden_cmds {cd	exec exit fconfigure file glob load open pwd socket	source}
    # Exposing the potentially dangerous commands
    foreach cmd $hidden_cmds {
        interp expose $tclEngine($sock) $cmd
    }
    catch {interp eval $tclEngine($sock) $userTclCmd} cmdResponse
    # Hiding the potentially dangerous commands
    foreach cmd $hidden_cmds {
        interp hide $tclEngine($sock) $cmd
    }
    return $cmdResponse
 }
 
proc svcHandler {sock} {
    global tclEngine
    set userTclCmd [readSocket $sock]; # Reading the user commands over socket 
    if {$userTclCmd!=-1} {
        puts "The command received from $sock : $userTclCmd"
        #If user sent empty string, simply returning empty string. 
        if {$userTclCmd eq {} } {
            set cmdResponse {}
        } else {
            # Checking if it is xml load or capture the packets for stcSimple
            if {[regexp {stcSimple_startup\s+-config} $userTclCmd ] || [regexp {stcSimple_captureStopAndSaveAllPorts} $userTclCmd ]} {
                set cmdResponse [sandBox $sock $userTclCmd]
            } else {
                catch {interp eval $tclEngine($sock) $userTclCmd} cmdResponse
            }
        }
        puts "My response : $cmdResponse"
        writeSocket $sock $cmdResponse; # Writing the response over socket 
    }
}


proc accept {sock addr port} {
    global tclEngine
    
    #Creating slave interpreter for the client
    set tclEngine($sock) [interp create]

    #Creating aliases for the child interpreters with respect to the FEATURE_TRAFFIC.tcl's implementation
    interp alias $tclEngine($sock) x {} x
    interp alias $tclEngine($sock) y {} y $sock
    #Hiding the dangerous commands from slaves
    set hidden_cmds {cd	exec exit fconfigure file glob load open pwd socket	source}
    foreach cmd $hidden_cmds {
        interp hide $tclEngine($sock) $cmd
    }
    # Calling 'svcHandler' function whenever the socket is readable
    fileevent $sock readable [list svcHandler $sock]
    # Setting the socket to be in 'binary' mode, instead of 'line' mode
    fconfigure $sock -buffering line -blocking 0 -translation binary
    puts "Accepted socket connection from $addr on port $port "
}

 ########## Code related to Socket communication ends here ##########


# Main starts here #

#Tcl Array Engine to hold reference of all the client Tcl interpreters
array set tclEngine {}
if {[catch {socket -server accept 0} serverSocket ]} {
    puts "Failed to start the server. :("
    puts -nonewline "Reason => $serverSocket"
    return
}
puts "I am waiting... on the port [lindex [fconfigure $serverSocket -sockname] end]"
vwait events

# Main ends here #







