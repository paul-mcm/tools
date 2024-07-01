#!/bin/ksh

OUTPUT='/etc/mail/nospamd'
SPFHOST='_spf.google.com'
TEST=false

while getopts :n VAR 2> /dev/null
do
    case $VAR in
	n) TEST=true
	   ;;
	?) echo "-n is the only flag"
	   exit
           ;;
    esac
done

set -A netblocks $(dig $SPFHOST txt +short | \
    sed -e 's/.*"v=spf1 //' \
        -e 's/include://g'  \
	-e 's/\~all"//'     \
)

for nb in ${netblocks[@]}
do
    set -A txt $(dig $nb txt +short | \
	grep -v ip6	     |	\
	sed -e 's/.*"v=spf1//'	\
	    -e 's/ip4://g'      \
	    -e 's/\~all"//'	\
    )

    for addr in ${txt[@]}
    do
	if ($TEST)
	then
	    echo $addr
	elif [[ $(/usr/bin/id -g) -eq 0 ]]
        then
	    echo $addr >> $OUTPUT
	else
	    echo "Insufficient priviges"
	    exit
        fi
    done
done
