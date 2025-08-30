#!/bin/ksh

PROG='addrinfo.ksh'
FPATH='/usr/local/lib/ksh'
PATH='/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:'

Trace=false
TestFlg=false

export PATH=$PATH
autoload

function help {
    echo
    cat >&2 <<ENDUSAGE

$PROG - For given CIDR address, print addresses,
	    and network range of address in binary and
	    and human readable form.

Usage: $Prog [-hx] CIDR_address

Options:
	-h	-	this 'help' section
	-x	-	set xtrace

ENDUSAGE

    exit
}

function oct2bits {
    $Trace && set -x
    typeset o="$1"
    typeset f="${2:-128}"

    if [[ $o -ge $f ]]
    then
        bits="${bits}1"
        (( o = o - f ))
    else
        bits="${bits}0"
    fi

    [[ $f -ne 1 ]] && oct2bits $o $(( $f / 2 )) || echo "$bits"
}

function ip2bits {
    $Trace && set -x
    typeset ip="$1"
    typeset octs
    typeset b_str=  

    set -A octs $(echo $ip | awk -F. '{print $1, $2, $3, $4}')
 
    for o in ${octs[@]}
    do  
        bits=$(oct2bits "$o")
        b_str="${b_str:+${b_str} ${bits}}"
        b_str="${b_str:-$bits}"
        bits=
    done
    echo $b_str
}

while getopts :hx VAR 2> /dev/null
do
    case $VAR in
	h) help
	   ;;
	x) Trace=true
	   PS4='$LINENO	'
	   set -x
	   ;;
	?) echo "bad option"
	   exit
	   ;;
    esac
done
shift $(($OPTIND - 1))
cidr="$@"

validate_ipv4_cidr "$cidr" || die "invalid ipv4/CIDR"

set -A range $(/usr/local/bin/iprange $cidr)

echo "${range[0]}				${range[1]}"
echo "$( ip2bits ${range[0]} )	$( ip2bits ${range[1]} )"


