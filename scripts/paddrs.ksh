#!/bin/ksh

FPATH="${HOME}/scripts/lib"
Prog=${0##*/}
Trace=false
Max=1024
Cnt=0

function help {
    echo
    cat >&2 <<END_USAGE
    $Prog	- 	print $Max ipv4 addrs in network range
			for given CIDR address.

    $Prog [-mth] CIDR_address

        -h      -       this 'help' section
	-m	-	set max number of addrs to print
			Defaults to 1024
        -t      -       Debug

END_USAGE
    exit
}



function poct {
    $Trace && set -x
    typeset prefx=$1	#prefix string
    typeset h=$2	#high value
    typeset l=$3	#low val
    typeset oct=$4	#oct_i
    typeset i=$l	      

    while [[ $oct -ne 4 && $i -le $h ]]
    do
	pfx="${prefx}.${i}"
	(( o = oct + 1 ))
	poct $pfx 256 0 $o
	((i++))
    done

    while ( [ $i -lt $h ] )
    do
	echo ${prefx}.$i
	((i++))
	((Cnt++))	
	[[ $Cnt -eq $Max ]] && \
	    echo "Reached Max: $Cnt" && \
	    exit
    done
    return
}

while getopts :hm:t VAR 2> /dev/null
do
    case $VAR in
	h) help
	   exit
	   ;;
	m) Max=$OPTARG
	   ;;
	t) Trace=true
	   PS4='$LINENO	'
	   set -x
	   ;;
	?) echo "Usage: [-t] [-m max] CIDR_addr"
	   exit
	   ;;
    esac
done
shift $(($OPTIND - 1))
cidr=$@

set -A hi_lo_ips $(${HOME}/bin/iprange $cidr)
set -A octs $(parse_octets $cidr)
h_oct=$(( ${cidr##*/} / 8 ))

# host octets - high, low
lo=$(echo ${hi_lo_ips[0]} | cut -d. -f $(( h_oct + 1 )) )
hi=$(echo ${hi_lo_ips[1]} | cut -d. -f $(( h_oct + 1 )) )

if [ $h_oct -ne 0 ]
then
    prefix=${octs[0]}
    i=1
    while ( [ $i -lt $h_oct ] )
    do
	prefix="${prefix}.${octs[$i]}"
	((i++))
    done
fi
 
poct $prefix $hi $lo $(( h_oct + 1 ))

exit
