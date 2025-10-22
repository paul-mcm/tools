#!/bin/ksh

PROG='paddrs.ksh'
FPATH='/home/paul/local/lib/ksh'
PATH=/sbin:/bin:/usr/sbin:/usr/bin
Trace=false
TestFlg=false
Max=16384
Cnt=0
export PATH=$PATH
autoload

function help {
    cat >&2 <<ENDUSAGE

$PROG - print range of ipv4 addrs in CIDR address

Usage: $PROG [-hx] [-m MAX] CIDR_address

Options:
    -h        -   this 'help' section
    -m        -   set max number of addrs to print
		  Defaults 16384 (/18)
    -x        -   turn on verbose tracing

ENDUSAGE
     exit
}

function poct {
    ${Trace-:false} && set -x
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

    while ( [ $i -le $h ] )
    do
	echo ${prefx}.$i
	((i++))
	((Cnt++))	
	[[ $Cnt -eq $Max ]] && die "Reached Max: $Cnt"
    done
    return
}

while getopts :hm:x VAR 2> /dev/null
do
    case $VAR in
	h) help
	   exit
	   ;;
	m) Max=$OPTARG
	   ;;
	t) TestFlg=true
	   ;;
	x) Trace=true
	   PS4='$LINENO	'
	   set -x
	   ;;
	?) echo "Usage: [-x] [-m max] CIDR_addr"
	   exit
	   ;;
    esac
done
shift $(($OPTIND - 1))
cidr=$@

validate_ipv4_cidr $cidr || die "bad CIDR address"

set -A hi_lo_ips $(/home/paul/local/bin/iprange $cidr)
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
