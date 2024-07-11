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
	   ipv4_validate $ip || exit
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

i=0

while (( i < ${#sockets[@]} ))
do
    # Reformat sockets as ip address:port number
    sockets[$i]=$( echo ${sockets[$i]} | \
	sed 's/\.\([0-9]*\)$/:\1/g')
    ((i++))
done

i=0

if ! $Trace
then
    if [ $(/usr/bin/id -g) -ne 0 ]
    then
	echo "Requires root privileges"
	exit
    fi

    while (( i < ${#sockets[@]} ))
    do
	$DROP_CMD ${sockets[ ((i++)) ]} ${sockets[ ((i++)) ]}
	[[ $? -ne 0 ]] && exit
    done
else
    while (( i < ${#sockets[@]} ))
    do
	echo "$DROP_CMD\t${sockets[ ((i++)) ]} \t${sockets[ ((i++)) ]}"
    done
fi
exit
