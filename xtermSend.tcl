#!/usr/bin/tclsh
package require Expect
set ::xtermStarted 0
set xtermCmd      $env(SHELL)
set xtermArgs     ""

# set up verbose mechanism early
set verbose 0
proc verbose {msg} {
    if {$::verbose} {
    if {[info level] > 1} {
        set proc [lindex [info level -1] 0]
    } else {
        set proc main
    }
        puts "$proc: $msg"
    }
}
# ::xtermSid is an array of xterm spawn ids indexed by process spawn ids.
# ::xtermPid is an array of xterm pids indexed by process spawn id.

######################################################################
# create an xterm and establish connections
######################################################################

proc xtermStart {cmd name} {
    verbose "starting new xterm running $cmd with name $name"
    ######################################################################
    # create pty for xterm
    ######################################################################
    set pid [spawn -noecho -pty]
    verbose "spawn -pty: pid = $pid, spawn_id = $spawn_id"
    set ::sidXterm $spawn_id
    stty raw -echo < $spawn_out(slave,name)
    regexp ".*(.)(.)" $spawn_out(slave,name) dummy c1 c2
    if {[string compare $c1 "/"] == 0} {
        set c1 0
    }
    ######################################################################
    # start new xterm
    ######################################################################
    set xtermpid [eval exec xterm -name dinesh -S$c1$c2$spawn_out(slave,fd) $::xtermArgs &]
    verbose "xterm: pid = $xtermpid"
    close -slave

    # xterm first sends back window id, save in environment so it can be
    # passed on to the new process
    log_user 0
    expect {
        eof {wait;return}
        -re (.*)\n {
            # convert hex to decimal
            # note quotes must be used here to avoid diagnostic from expr
            set ::env(WINDOWID) [expr "0x$expect_out(1,string)"]
        }
    }

    ######################################################################
    # start new process
    ######################################################################
    set pid [eval spawn -noecho $cmd]
    verbose "$cmd: pid = $pid, spawn_id = $spawn_id"
    set ::sidCmd $spawn_id

    ######################################################################
    # link everything back to spawn id of new process
    ######################################################################
   set ::xtermSid($::sidCmd) $::sidXterm
   set ::xtermPid($::sidCmd) $xtermpid

    ######################################################################
    # connect proc output to xterm output
    # connect xterm input to proc input
    ######################################################################
    expect_background {
        -i $::sidCmd
        -re ".+" {
            if {!$::xtermStarted} {set ::xtermStarted 1}
            sendTo $::sidXterm
        }
        eof [list xtermKill $::sidCmd]
        -i $::sidXterm
        -re ".+" {
            if {!$::xtermStarted} {set ::xtermStarted 1}
            sendTo $::sidCmd
        }
        eof [list xtermKill $::sidCmd]
    }
    vwait ::xtermStarted
}


######################################################################
# connect main window keystrokes to all xterms
######################################################################
proc xtermSend {A} {
    exp_send -raw -i $::sidCmd -- $A
}

proc sendTo {to} {
    exp_send -raw -i $to -- $::expect_out(buffer)
}


######################################################################
# clean up an individual process death or xterm death
######################################################################
proc xtermKill {s} {
    verbose "killing xterm $s"

    if {![info exists ::xtermPid($s)]} {
        verbose "too late, already dead"
        return
    }

    catch {exec /bin/kill -9 $::xtermPid($s)}
    unset ::xtermPid($s)

    # remove sid from activeList
    verbose "removing $s from active array"
    catch {unset ::activeArray($s)}

    verbose "removing from background handler $s"
    catch {expect_background -i $s}
    verbose "removing from background handler $::xtermSid($s)"
    catch {expect_background -i $::xtermSid($s)}
    verbose "closing proc"
    catch {close -i $s}
    verbose "closing xterm"
    catch {close -i $::xtermSid($s)}
    verbose "waiting on proc"
    wait -i $s
    wait -i $::xtermSid($s)
    verbose "done waiting"
    unset ::xtermSid($s)
    set ::forever NO
}

######################################################################
# create windows
######################################################################
# xtermKillAll is not intended to be user-callable.  It just kills
# the processes and that's it. A user-callable version would update
# the data structures, close the channels, etc.

proc xtermKillAll {} {
    foreach sid [array names ::xtermPid] {
        exec /bin/kill -9 $::xtermPid($sid)
    }
}

rename exit _exit
proc exit {{x 0}} {xtermKillAll;_exit $x}


xtermStart $xtermCmd $xtermCmd
xtermSend "ls -l\r"
xtermSend "pwd\r"
vwait ::forever
