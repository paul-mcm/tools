#!/bin/ksh

PROG='agent_setup.ksh'
FPATH='/home/paul/local/lib/ksh'
PATH='/sbin:/bin:/usr/sbin:/usr/bin'
RUNDIR=${HOME}
CFG="${HOME}/.tcshrc"
Trace=false
TestFlg=false
export PATH=$PATH
autoload

function help {
    cat >&2 <<ENDUSAGE

Prog: $PROG - set shell environment vars for 
                  ssh-agent in X 
                  windows environment

Usage: $PROG [-htx]

Options:
    -h	    -       display this 'help' section
    -t      -       debug; show but don't exec commands that
                    make system modifications/changes
    -x      -       turn on xtrace

ENDUSAGE
     exit
}

##################
### START MAIN
##################
while getopts :htx OPT 2> /dev/null
do
    case $OPT in
        h) help
           exit
           ;;
        t) TestFlg=true 
           ;;
        x) Trace=true
           echo "Tracing $prog"
           PS4='$LINENO:        '
           set -x
           ;;
        ?) echo "error"
           exit
           ;;
    esac
done

cd $RUNDIR
[[ "$PWD" != $RUNDIR ]] && die "Unable to CD to $RUNDIR"
[[ ! -f $CFG ]] && die "config file $CFG not found"

runcmd 'pkill ssh-agent'

sed -i -e '/SSH_AUTH_SOCK/d' -e '/SSH_AGENT_PID/d' $CFG

runcmd '/usr/bin/ssh-agent' | grep -v 'echo' >> $CFG || \
  die "ssh-agent failed"




