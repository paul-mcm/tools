#!/bin/ksh 

#FPATH='/home/paul/local/lib/ksh'
FPATH='/home/paul/dev/lib/shell' #use if nothing in $HOME/local/
SCRIPTDIR='/home/paul/local/scripts'
LIBDIR='/home/paul/local/lib/ksh'
SCRIPT_REPO='/home/paul/dev/tools/scripts'
LIB_REPO='/home/paul/dev/lib/shell'

Prog='install.ksh'
Trace=false
TestFlg=false
autoload

scripts='addrinfo.ksh
    agent_setup.ksh	    
    cscope_init.ksh
    drop_tcp.ksh
    grab_openbsd.ksh
    ipfind.ksh
    iprange.pl
    paddrs.ksh
    tips.pl
    vm_manage.ksh'

libs=$(ls ./lib/ | grep -v test.ksh)

function help {
    echo
    cat >&2 <<ENDUSAGE
$Prog - install scripts from repo to local dirs

Usage: $Prog [-achlnprstx] [-i script]

    -c		-	compare mod times in repo w/ script dir
    -h		-       display this 'help' section
    -i		-	install all scripts and make links
    -t		-       debug; show but don't exec commands that
			make system modifications/changes
    -x		-       turns on xtrace

ENDUSAGE
     exit
}

function compare {
    ${Trace:-false} && set -x
    typeset repo="$1"
    typeset  installed="$2"

    if [[ ! -f $repo || ! -f $installed ]]
    then
	echo "${repo##*/}" not found
        return 1
    fi

    /usr/bin/diff -q $repo $installed > /dev/null 2>&1
    if [ $? -ne 0 ]
    then	
        rstmp=$(stat -f "%m" $repo)
        istmp=$(stat -f "%m" $installed)
        if [[ $rstmp -gt $istmp ]]
        then
	    echo "repo ahead of install for ${repo##*/}" || \
	    echo "install ahead of repo for ${repo##*/}"
	fi
    fi
}

function mk_installdir {
    ${Trace:-false} && set -x
    typeset d="$1"
    umask 022
    runcmd mkdir -p $d || die "Failed to make ${d}: $?"
}

#################
## Start MAIN CODE
#################
[[ $# -lt 1 ]] && die "needs at leat 1 arg"

while getopts :chitx VAR 2> /dev/null
do
    case $VAR in
	c) Compare=true
	   ;;
	h) help
	   exit
	   ;;
	i) Install=true
	   ;;
	t) TestFlg=true
	   ;;
	x) Trace=true
	   TestFlg=true
	   echo "Tracing $Prog"
	   PS4='$LINENO:'
	   set -x
	   ;;
	?) echo "Bad option"
	   exit
	   ;;
    esac
done

if [ $Install ]
then 
    [[ ! -d $SCRIPTDIR ]] && mk_installdir $SCRIPTDIR
    [[ ! -d $LIBDIR ]] && mk_installdir $LIBDIR

    for f in ${scripts[@]}
    do
	runcmd cp ${SCRIPT_REPO}/$f $SCRIPTDIR || die "Failed to cpy $f"
        runcmd chmod 755 ${SCRIPTDIR}/$f || die "chmod returned $? for ${f}"
    done

    for f in ${libs[@]}
    do
	runcmd cp ${LIB_REPO}/$f $LIBDIR || die "Failed to cpy $f"
        runcmd chmod 755 ${LIBDIR}/$f || die "chmod returned $? for ${f}"
    done
fi

if [ $Compare ]
then
   for s in ${scripts[@]}
   do
	compare "${SCRIPT_REPO}/$s" "${SCRIPTDIR}/$s"
   done
   for l in ${libs[@]}
   do
	compare "${LIB_REPO}/$l" "${LIBDIR}/$l"
   done
fi
