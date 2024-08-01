#!/bin/ksh

FPATH="${HOME}/scripts/lib"
Prog=${0##*/}
Trace=false

function help {
    echo
    cat >&2 <<ENDUSAGE
    $Prog - For given CIDR address, print addresses,
	    and network range of address in binary and
	    and human readable form.

    $Prog [-th] CIDR_address

	-h	-	this 'help' section
	-t	-	Debug

ENDUSAGE

    exit
}

while getopts :ht VAR 2> /dev/null
do
    case $VAR in
	h) help
	   ;;
	t) Trace=true
	   PS4='$LINENO	'
	   set -x
	   ;;
	?) echo "Usage: $Prog [-t] <ipv4addr/netprfx>"
	   exit
	   ;;
    esac
done
shift $(($OPTIND - 1))
cidr=$@

validate_ipv4_cidr $cidr || exit

set -A range $(iprange $(padaddr $cidr))
lo=$(addr2bits ${range[0]})
hi=$(addr2bits ${range[1]})

if [[ $cidr = *.0/* ]] # if network addr
then

    echo "Low:\t${range[0]}\t$(addr2bits ${range[0]})"
    echo "High:\t${range[1]}\t$(addr2bits ${range[1]})"
else
    set -A range $(iprange $cidr)
    ip=${cidr%/*}
    echo "Low:\t${range[0]}\t$(addr2bits ${range[0]})"
    echo "Host\t$ip\t$(addr2bits $ip)"
    echo "High:\t${range[1]}\t$(addr2bits ${range[1]})"
fi


