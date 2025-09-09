#!/bin/ksh

PROG='ipfind.ksh'
FPATH='/usr/local/lib/ksh'
PATH=/sbin:/bin:/usr/sbin:/usr/bin

Trace=false
TestFlg=false

export PATH=$PATH
autoload # search FPATH

function help {
    cat >&2 <<ENDUSAGE

$PROG - filter list for ipv4addrs in CIDR

Usage: $PROG [-htx] [-s file] [ CIDR addr]

Options:
    -h             -   display this 'help' section
    -s		   -   file containing ipv4 addrs
    -t             -   debug; (N.B no cmds to test currently)
    -x             -   turn on verbose xtrace'ing

ENDUSAGE
     exit
}

##################
### START MAIN
##################
while getopts :hs:tx OPT 2> /dev/null
do
    case $OPT in
        h) help
           exit
           ;;
        s) src=$OPTARG
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
shift $(($OPTIND - 1))
cidr=$1

validate_ipv4_cidr || die "Invalid CIDR: $cidr"

[[ -f $src ]] || die "$src isn't regular file"

net=${cidr##*/}

set -A hi_lo_ips $(${HOME}/bin/iprange $cidr)
set -A octs $(parse_octets $cidr)

# 0 based index of first octet w/ host bit
h_oct=$(( net / 8 ))

# host octets - high, low
lo=$(echo ${hi_lo_ips[0]} | cut -d. -f $(( h_oct + 1 )) )
hi=$(echo ${hi_lo_ips[1]} | cut -d. -f $(( h_oct + 1 )) )

if [ $h_oct -ne 0 ]
then
    i=0
    # build pattern matching expressions for network octets
    while ( [ $i -lt $h_oct ] )
    do
	case $i in
	    0) fltr="\$1 == ${octs[$i]}"
	    ;;
	    1) fltr="${fltr} && \$2 == ${octs[$i]}"
	    ;;
	    2) fltr="${fltr} && \$3 == ${octs[$i]}"
	    ;;
	esac
	((i++))
    done

    ((h_oct++))
    fltr="${fltr} && \$${h_oct} >= $lo && \$${h_oct} <= $hi"
else
    ((h_oct++))
    fltr="\$${h_oct} >= $lo && \$${h_oct} <= $hi"
fi

# Apply filter to awk command, send to STDOUT
echo "$src | awk -F. "${fltr} {print}""

