#!/bin/ksh

FPATH=${HOME}/scripts/lib
SRC='pfctl -T show -t spamd-white'
Cidr=$1
nmask=${Cidr##*/}

set -A hi_lo_ips $(${HOME}/bin/iprange $Cidr)
set -A octs $(parse_octets $Cidr)

# array index of first octet w/ host bit; 
h_oct=$(( nmask / 8 )) 

# host octets - high, low
lo=$(echo ${hi_lo_ips[0]} | cut -d. -f $(( h_oct + 1 )) )
hi=$(echo ${hi_lo_ips[1]} | cut -d. -f $(( h_oct + 1 )) )

if [ $h_oct -ne 0 ]
then
    i=0
    # builds expression from leading octets not changed by nmask
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
