#!/bin/ksh

FPATH="${HOME}/scripts/lib"
Trace=false
Max=1024
Cnt=0

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

while getopts :c:m:t VAR 2> /dev/null
do
    case $VAR in
	c) cidr=$OPTARG
	   ;;
	m) Max=$OPTARG
	   ;;
	t) Trace=true
	   PS4='$LINENO	'
	   set -x
	   ;;
	?) echo "something is missing"
	   exit
	   ;;
    esac
done

set -A hi_lo_ips $(${HOME}/bin/iprange $cidr)
set -A octs $(parse_octets $cidr)
h_oct=$(( ${cidr##*/} / 8))

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
