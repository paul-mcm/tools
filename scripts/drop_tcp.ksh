#!/bin/ksh

# Get output from netstat
# Input is socket pairs (ie., ip.port) stored consecutively
#

FPATH='./lib/'
NSTAT='/usr/bin/netstat'
NSTAT_ARGS='-nf inet -p tcp'
DROP_CMD='/usr/sbin/tcpdrop'
TRACE=false

prog=${0##*/}
autoload

function help {

    cat >&2 <<ENDUSAGE
    drop_tcp.ksh - wrapper script for tcpdrop(8) command

    -h			-	show this 'help' section    
    -i ipv4 addr	-	Drop all connections to ipv4 addr
    -n			-	Don't drop connections. Only show
				connections that would be dropped
    -p port		-	Drop all connections on given port
    -s socket		-	Drop TCP socket (e.g., ipv4_addr.port)

    -p and -i used together is equivalent to '-s <socket>'

ENDUSAGE

    exit
}

if [[ $# -lt 1 ]]
then
    echo "invalid args" && exit
fi

while getopts :hni:p:s:t VAR 2> /dev/null
do
    case $VAR in
	h) help
	   ;;
	i) ip=$OPTARG
	   ipv4_validate $ip || exit
	   set -A sockets $($NSTAT $NSTAT_ARGS | \
		awk '$1 ~ /tcp/ && 	 	 \
		     $4 ~ /'"$ip"'\./ || 	 \
		     $5 ~ /'"$ip"'\./ 	 	 \
		     {print $4, $5}')
	   ;;
	n) TRACE=true
	   ;;
	p) port=$OPTARG
	   validate_port $port || exit
	   set -A sockets $($NSTAT $NSTAT_ARGS | \
		awk '$1 ~ /tcp/ && 		 \
		     $4 ~ /\.'"$port"'$/ || 	 \
		     $5 ~ /\.'"$port"'$/ 	 \
		     {print $4, $5}')
	   ;;
	t) TRACE=true
	   echo "Tracing $prog"
	   set -x
	   PS4='[$LINENO]: '
	   ;;
	s) sock=$OPTARG
	   port=${sock##*.}
	   validate_port $port || exit
	   ip=${sock%.*}
	   ipv4_validate $ip || exit
	   set -A sockets $($NSTAT $NSTAT_ARGS |  \
		awk '$1 ~ /tcp/ && 		  \
		     $4 ~ /'"$ip"'\.'"$port"'/ || \
		     $5 ~ /'"$ip"'\.'"$port"'/ 	  \
		     {print $4, $5}')
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

while (( $i < ${#sockets[@]} ))
do
    #Format sockpair as ip address:port number
    # 1st IP
    ip1=$( echo ${sockets[$i]} | sed 's/\.\([0-9]*\)$/:\1/g' )
    ((i++))

    # 2nd IP
    ip2=$( echo ${sockets[$i]} | sed 's/\.\([0-9]*\)$/:\1/g' )
    ((i++))

    if ! $TRACE
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
	echo "$DROP_CMD $ip1\t$ip2"
    fi
done

exit
