#!/bin/ksh 

V='7.5'
#BASE_DIR="/mnt/OpenBSD${V}"
BASE_DIR="${HOME}/tmp/OpenBSD${V}"
URL=$(cat /etc/installurl)
CHKSUM=SHA256
SHA_SIG=SHA256.sig
Trace=true 
#set -x

set -A amd64 \
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

set -A i386 \
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
    typeset a=$1
    wget ${URL}/${V}/${a}/index.txt
}

function fetch {
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

##################
### START MAIN
##################
for p_set in i386 amd64
do
    [ -d ${BASE_DIR}/$p_set ] || mkdir -p ${BASE_DIR}/$p_set
    if [ $? -ne 0 ]
    then
	echo "Failed to create dir ${BASE_DIR}/$p_set"
 	exit 1
    fi

    cd ${BASE_DIR}/$p_set
    if [[ $PWD != ${BASE_DIR}/$p_set ]]
    then
	echo "failed to cd to ${BASE_DIR}/$p_set"
	exit
    fi

    if [[ ! -f index.txt ]]
    then
	echo "Fetching index.txt"
	fetch_index $p_set
    fi

    pet="\${${p_set}[@]}"

    for pkg in $(eval "echo ${pet[@]}")
    do
	if ($Trace)
	then
	    echo "$p_set:\t$pkg"
	else
	    fetch $pkg
	fi
    done
done

