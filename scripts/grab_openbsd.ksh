#!/bin/ksh 

PROG='grabopenbsd.ksh'
FPATH='/home/paul/local/lib/ksh'
PATH='/sbin:/bin:/usr/sbin:/usr/bin'
BASEURL='https://mirrors.ocf.berkeley.edu/pub/OpenBSD'
ARCH='amd64' # or i386
RV='7.7' # Release version
DIR="/space/OpenBSD${RV}"
WGET="/usr/local/bin/wget'
SIGNFY='signify -Cp /etc/signify/openbsd-77-base.pub -x SHA256.sig'

Trace=false
TestFlg=false

export PATH=$PATH
autoload # search FPATH
umask 227 # octal 440 or 'r--r-----'

pv=$(echo $RV | sed 's/\.//') # no decimal for version in pkg names

amd64_set="base${pv}.tgz 
    bsd.mp		
    bsd.rd		
    comp${pv}.tgz	
    game${pv}.tgz	
    man${pv}.tgz	
    xbase${pv}.tgz	
    xfont${pv}.tgz	
    xserv${pv}.tgz	
    xshare${pv}.tgz"

i386_set="base${pv}.tgz	
    bsd			
    bsd.rd		
    comp${pv}.tgz	
    man${pv}.tgz	
    xbase${pv}.tgz"

function help {
    cat >&2 <<ENDUSAGE

$PROG - Download OpenBSD install packages/sets

Options:
    -h            -       display this 'help' section     
    -t            -       debug; no exec of commands that
			  cause modifications/changes
    -x 	          -       turn on xtrace

ENDUSAGE

     exit
}

function fetch_file {
    ${Trace:-false} && set -x
    typeset f=$1 
    runcmd ${WGET}/${BASEURL}/${RV}/${ARCH}/$f || return 1
}

function fetch_pkg {
    ${Trace-:false} && set -x
    typeset p=$1
    fetch_file $p || return 1
    $SIGNFY $p || \
      echo "signify(1) failed for $p" && return 1
}

##################
### START MAIN
##################
while getopts :htx OPT 2> /dev/null
do
    case $OPT in
	h) help
	   exit
	   ;;
	t) TestFlg=true
	   ;;
	x) Trace=true
	   echo "Tracing $prog"
	   PS4='$LINENO:	'
	   set -x
	   ;;
	?) echo "error"
	   exit
	   ;;
    esac
done

[[ ! -d ${DIR}/$ARCH ]] && (runcmd mkdir -p ${DIR}/$ARCH || \
	die "Failed to create ${DIR}/$ARCH")

cd ${DIR}/$ARCH
[[ $PWD != ${DIR}/$ARCH ]] && die "failed cd to ${DIR}/$ARCH"

[ ! -f ./SHA256 ]     && fetch_file SHA256
[ ! -f ./SHA256.sig ] && fetch_file SHA256.sig
[ ! -f ./index.txt ]  && fetch_file index.txt

# Set pkgs var to pkg set for correct architecture
[ $ARCH == 'amd64' ] && pkgs=$amd64_set || pkgs=$i386_set

for pkg in $pkgs
do
    if [ ! -f $pkg ]
    then 
        fetch_pkg $pkg || die "Failed to fetch $pkg"
    else
	$SIGNFY $pkg && continue    # continue if pkg exists/verified
	# remove if unverified pkg and fetch again
	runcmd rm $pkg || die "Couldn't rm unverified pkg $pkg"
	fetch_pkg $pkg || die "Failed to fetch $pkg"
    fi
done

# Fetch source files if amd64
if [ $ARCH == amd64 ] 
then
    [ ! -f ./src.tar.gz ]    && fetch_file src.tar.gz
    [ ! -f ./sys.tar.gz ]    && fetch_file sys.tar.gz
    [ ! -f ./ports.tar.gz ]  && fetch_file ports.tar.gz
fi
