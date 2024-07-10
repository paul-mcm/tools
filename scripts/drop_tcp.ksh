#!/bin/ksh

# Get output from netstat
# Input is socket pairs (ie., ip.port) stored consecutively 
# array @sockets
#

FPATH='./lib/'
NSTAT='/usr/bin/netstat'
NSTAT_ARGS='-nf inet -p tcp'
DROP_CMD='/usr/sbin/tcpdrop'
Trace=false

prog=${0##*/}
args="$*"
autoload

function help {
    echo
    cat >&2 <<ENDUSAGE
    $prog - wrapper script for tcpdrop(8) command

    -h			-	display this 'help' section
    -i ipv4 addr	-	drop all connections to ipv4 addr
    -n			-	don't drop connections. Only show
				connections that would be dropped
    -p port		-	drop all connections on given port
    -s socket		-	drop TCP socket (e.g., ipv4_addr.port)
    -t tracing		-	same as -n, also sets 'xtrace'

ENDUSAGE

    exit
}

if [[ $# -lt 1 ]]
then
    echo "invalid args" && exit
fi

# Find & turn on tracing flag asap
if  [[ $(expr "${args}" : ".*-t.*") -gt 0 ]]
then
    Trace=true
    echo "Tracing $prog"
    PS4='[$LINENO]: '
    set -x
fi

while getopts :hni:p:s:t VAR 2> /dev/null
do
    case $VAR in
	h) help
	   ;;
	i) ip=$OPTARG
	   set -A sockets $($NSTAT $NSTAT_ARGS | \
		awk '$1 == "tcp" && 	 	 \
		$4 ~ /^'"$ip"'\./ ||		\
		$5 ~ /^'"$ip"'\./		\
		    {print $4, $5}'
	    )
	   ;;
	n) Trace=true # same as -t, but doesn't set xtrace
	   ;;
	p) port=$OPTARG
	   validate_port $port || exit
	   set -A sockets $($NSTAT $NSTAT_ARGS | \
		awk '$1 == "tcp" && 		 \
		$4 ~ /\.'"$port"'$/ ||		 \
		$5 ~ /\.'"$port"'$/ 	 	 \
		    {print $4, $5}'
	   )
	   ;;
	t) continue # checked for -t above
	   ;;
	s) sock=$OPTARG
	   port=${sock##*.}
	   validate_port $port || exit
	   ip=${sock%.*}
	   ipv4_validate $ip || exit
	   set -A sockets $($NSTAT $NSTAT_ARGS |  \
		awk '$1 == "tcp" &&		  \
		$4 == "'"$ip"'.'"$port"'" ||	\
		$5 == "'"$ip"."$port"'"		\
		    {print $4, $5}'
	   )
	   ;;
	?) echo "try again..." && exit
	   ;;
    esac
done

# exit if no sockets found
if [[ ${#sockets[@]} -eq 0 ]]
then
    echo "no connections" && exit
fi

# Validate input from netstat.
if [[ $(( ${#sockets[@]} % 2 )) -ne 0 ]]
then
    echo "Error: incomplete socket pair" && exit
fi

i=0;

while (( i < ${#sockets[@]} ))
do
    #Format sockpair as ip address:port number
    # 1st IP
    ip1=$( echo ${sockets[$i]} | sed 's/\.\([0-9]*\)$/:\1/g' )
    ((i++))

    # 2nd IP
    ip2=$( echo ${sockets[$i]} | sed 's/\.\([0-9]*\)$/:\1/g' )
    ((i++))

    if ! $Trace
    then
	if [[ $(/usr/bin/id -g) -ne 0 ]]
	then
	   echo "You need to be root" && exit
	fi
	$($DROP_CMD $ip1 $ip2 > /dev/null)
	if [[ $? -eq 0 ]]
	then
	    echo "Dropped $ip1\t\t$ip2"
	else
	    echo "Error disconnecting $ip1 $ip2" && exit
	fi
     else
	echo "$DROP_CMD\t$ip1\t$ip2"
    fi
done

exit
