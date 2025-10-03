#!/bin/ksh

PROG='drop_tcp.ksh'
FPATH='/home/paul/local/lib/ksh'
PATH='/sbin:/bin:/usr/sbin:/usr/bin:'
RUNDIR="/tmp"
NSTAT='/usr/bin/netstat -nf inet -p tcp'
TCPDROP='/usr/sbin/tcpdrop'

TestFlg=false
Trace=false

export PATH=$PATH
autoload  #load $FPATH

function help {
    echo
    cat >&2 <<ENDUSAGE
$PROG - wrapper script for tcpdrop(8) command

Usage: drop_tcp.ksh [ -htx ] [ -i ipv4 addr | -p port num | -s socket ]

Options:
    -h		   -	 display this 'help' section
    -i ipv4 addr   -	 drop all connections to ipv4 addr
    -p port	   -	 drop all connections on given port
    -s socket	   -	 drop TCP socket (e.g., ipv4_addr.port)
    -t             -	 Debug; show but don't exec commands
			 that make modifications/changes.
    -x		   -	 turns on verbose tracing

ENDUSAGE

     exit
}

function validate_sock {
    ${Trace-:false} && set -x
    typeset s=$1
    validate_port ${s##*.} || return 1
    ipv4_validate ${s%.*} || return 1
    return 0
}

##################
### START MAIN
##################
cd $RUNDIR
[[ $PWD != $RUNDIR ]] && die "Unable to CD to $RUNDIR"

[ $# -lt 1 ] && die "invalid args"

while getopts :hi:p:s:tx OPT 2> /dev/null
do
    case $OPT in
	h) help
	   ;;
	i) ip=$OPTARG
	   ipv4_validate $ip || die "invalid ipv4 addr"
	   grep_regx=" ${ip}.[0-9]*"
	   ;;
	p) port=$OPTARG
	   validate_port $port || die "bad port"
	   grep_regx=".$port "
	   ;;
	s) sock=$OPTARG
	   validate_sock $sock || die "malformed socket"s
	   grep_regx=" ${sock} "
	   ;;
        t) TestFlg=true 
           ;;
	x) TestFlg=true
	   Trace=true
	   echo "Tracing $Prog"
	   PS4='$LINENO:       '
	   set -x
	   ;;
	?) echo "try again..." && exit
	   ;;
    esac
done

set -A sock_pairs $($NSTAT | grep "$grep_regx" | awk '{print $4, $5}')

# Exit if sock_pairs is empty
[[ -z $sock_pairs ]] && die "no sockets found"

# Validate netstat data
# Check for even number of socks in array
[[ $(( ${#sock_pairs[@]} % 2 )) -ne 0 ]] && \
  die "Error: incomplete netstat output"

# Validate socket
for sock in ${sock_pairs[@]}
do
    validate_sock $sock || \
      die "bad netstat output (malformed socket)"
done

# Validate privileges
uid=$(/usr/bin/id -u || die "id failed")
[[ $uid -ne 0 ]] && ! $TestFlg && \
  die "Requires root privileges"

# Iterate over socket_pairs and drop
i=0
while (( i < ${#sock_pairs[@]} ))
do
    local=${sock_pairs[ ((i++)) ]}
    remote=${sock_pairs[ ((i++)) ]}

    runcmd $TCPDROP $local $remote || \
      die "error dropping $local $remote"
done

