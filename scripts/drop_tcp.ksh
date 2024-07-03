#!/bin/ksh

FPATH='./lib/'
NSTAT='/usr/bin/netstat'
NSTAT_ARGS='-nf inet -p tcp'
TEST=false
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

while getopts :hni:p:s: VAR 2> /dev/null
do
    case $VAR in
	p) port=$OPTARG
	   validate_port $port || exit
	   grx="[0-9]\.$port "
	   ;;
	h) help
	   ;;
	i) ip=$OPTARG
	   validate_ipv4 $ip || exit
	   grx="$ip\.*"
	   ;;
	n) TEST=true
	   ;;
	s) sock=$OPTARG
	   port=${sock##*.}
	   validate_port $port || exit
	   ip=${sock%.*}
	   validate_ipv4 $ip || exit
	   grx="${ip}.${port} "
	   ;;
	?) echo "try again..." && exit
	   ;;
    esac
done

if [[ -n $ip && -n $port ]]
then
    grx="${ip}.${port}"
fi

# Get output from netstat
# Input is socket pairs (ie., ip.port) stored consecutively
#
set -A sockets $($NSTAT $NSTAT_ARGS | grep $grx | \
    awk '{print $4, $5}')

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

    if ! $TEST 
    then
	if [[ $(/usr/bin/id -g) -ne 0 ]]
	then
	   echo "You need to be root" && exit
	fi
	$(/usr/sbin/tcpdrop $ip1 $ip2 > /dev/null)
	if [[ $? -eq 0 ]]
	then
	    echo "Dropped $ip1\t\t$ip2"
	else
	    echo "Error disconnecting $ip1 $ip2" && exit
	fi
     else
	echo "$ip1\t$ip2"
    fi
done

exit
