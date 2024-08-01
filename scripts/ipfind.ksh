#!/bin/ksh
###
# ipfind.ksh <CIDR>
#
# Read IPv4 addrs from SRC and filter for
# addrs in same network designated by <CIDR>
###
FPATH=${HOME}/scripts/lib
SRC='cat ../ips'
cidr=$1
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
	    0) exp="\$1 == ${octs[$i]}"
	    ;;
	    1) exp="${exp} && \$2 == ${octs[$i]}"
	    ;;
	    2) exp="${exp} && \$3 == ${octs[$i]}"
	    ;;
	esac
	((i++))
    done

    ((h_oct++))
    exp="${exp} && \$${h_oct} >= $lo && \$${h_oct} <= $hi"
else
    ((h_oct++))
    exp="\$${h_oct} >= $lo && \$${h_oct} <= $hi"
fi

# Run Command, filter w/ awk, send to STDOUT
$SRC | awk -F. "${exp} {print}"

