#!/bin/ksh 

V='7.5'
#BASE_DIR="/mnt/OpenBSD${V}"
BASE_DIR="${HOME}/tmp/OpenBSD${V}"
URL=$(cat /etc/installurl)
CHKSUM=SHA256
SHA_SIG=SHA256.sig
Trace=false
Test=false
prog=${0##*/}

set -A amd64_set \
    INSTALL.amd64 \
    SHA256	\
    SHA256.sig  \
    base75.tgz	\
    bsd.mp	\
    bsd.rd	\
    comp75.tgz	\
    game75.tgz	\
    index.txt	\
    man75.tgz	\
    xbase75.tgz	\
    xfont75.tgz	\
    xserv75.tgz	\
    xshare75.tgz \

set -A i386_set \
    INSTALL.i386 \
    SHA256	\
    SHA256.sig	\
    base75.tgz	\
    bsd		\
    bsd.rd	\
    comp75.tgz	\
    index.txt	\
    man75.tgz	\
    xbase75.tgz	

function fetch_index {
    $Trace && set -x
    typeset a=$1
    wget ${URL}/${V}/${a}/index.txt
}

function fetch {
    $Trace && set -x
    typeset a=$1
    typeset p=$2

    if [[ ! -f $p ]]
    then 
	echo "wget ${URL}/${V}/${a}/$p"
    else 
	fsize=$(ls -l $p | awk '{print $5}' )
	index_s=$(cat index.txt | awk -v PKG=$p '$10 == PKG {print $5}')
	if [[ $fsize != $index_s ]]
	then
	    echo "wget ${URL}/${V}/${a}/$pkg"
	else
	    echo "File sizes match for $p"
	fi
    fi
}

function getset {
    $Trace && set -x
    typeset a=$1

    [ -d ${BASE_DIR}/$a ] || mkdir -p ${BASE_DIR}/$a
    if [ $? -ne 0 ]
    then
	echo "Failed to create dir ${BASE_DIR}/$a"
 	exit 1
    fi

    cd ${BASE_DIR}/$a
    if [[ $PWD != "${BASE_DIR}/$a" ]]
    then
	echo "failed to cd to ${BASE_DIR}/$a"
	exit
    fi

    if [[ ! -f index.txt ]]
    then
	echo "Fetching index.txt"
	fetch_index $a
    fi

    if [ $Test ]
    then
	eval "echo \${${a}_set[@]}" | tr ' ' '\n'
    else
	for pkg in $(eval "echo \${${a}_set[@]}")
	do
	    fetch $pkg
	done
    fi
}

##################
### START MAIN
##################
while getopts :a:hnt VAR 2> /dev/null
do
    case $VAR in
	a) arch=$OPTARG
	   ;;
	h) continue
	   ;;
	n) Test=true
	   ;;
	t) Trace=true
	   Test=true
	   echo "Tracing $prog"
	   PS4='[$LINENO]: '
	   set -x
	   ;;
	?) echo "error"
	   exit
	   ;;
    esac
done

if [ $arch == amd64 -o $arch == i386 ]
then
    getset $arch
else
    echo "missing or bad input"
    exit
fi


exit


