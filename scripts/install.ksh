#!/bin/ksh 

FPATH="${HOME}/scripts/lib"
REPO_DIR="${HOME}/dev/tools/scripts"
RUN_DIR=${REPO_DIR}
SCRIPT_DIR="${HOME}/scripts"
#SCRIPT_DIR="${HOME}/tmp" # for testing

Prog=${0##*/}
Trace=false
autoload

set -A scripts		\
    agent_setup.ksh	\
    cscope_init.ksh	\
    drop_tcp.ksh	\
    grab_openbsd.ksh	\
    iprange.pl		\
    misc_commands.ksh	\
    tips.pl

set -A links	\
    addnum	\
    bat		\
    clean	\
    scon	\
    dfunk	\
    ll		\
    pkgs	\
    radiotre	\
    radiouno	\
    tg7		\
    wapoc	

function help {
    echo
    cat >&2 <<ENDUSAGE
    $Prog - install scripts from repo to local dirs

    -a			-	install all scripts and make links
    -c			-	compare mod times in repo w/ script dir
    -h                  -       display this 'help' section
    -i script	 	-       install script from repo
    -l 		        -       make file system links
    -n                  -       
    -p			-	set perms on install files
    -r			-	remove hard links to misc_commands.ksh
    -t			-       turns on tracing to debug

ENDUSAGE

     exit
}

function install {
    $Trace && set -x
    typeset f=$1

    if [ ! -f $f ]
    then
	echo "$f not in repo dir"
	return 1
    fi

    cp $f $SCRIPT_DIR
    if [ $? -ne 0 ]
    then
	echo "failed to cpy $f"
	exit
    fi
}

function install_all {
    $Trace && set -x
    typeset i;

    for i in ${scripts[@]}
    do
	install $i
    done
}

function rm_links {
    $Trace && set -x
    typeset l
    for l in ${links[@]}
    do
	if [ -f ${SCRIPT_DIR}/$l ]
	then   
	    rm -r ${SCRIPT_DIR}/$l
	    [ $? -ne 0 ] && echo "Error removing old link: $l"
	fi
    done
}

function make_links {
    $Trace && set -x
    typeset f='misc_commands.ksh'
    typeset l

    if [ ! -f ${SCRIPT_DIR}/$f ]
    then
	echo "File $f not in dir.  Copying file from repo."
	cp ${REPO_DIR}/$f ${SCRIPT_DIR}/
	if [ $? -ne 0 ]
	then
	    echo "failed to copy $f to $SCRIPT_DIR"
	    exit
	fi
    fi

    for l in ${links[@]}
    do
	if [ ! -h ${SCRIPT_DIR}/$l ] 
	then 
	    ln -s ${SCRIPT_DIR}/$f ${SCRIPT_DIR}/$l
	    [ $? -ne 0 ] && echo "Error making link for $l"
	fi
    done
}

function compare {
    $Trace && set -x

    for s in ${scripts[@]}
    do
	if [[ ! -f ${REPO_DIR}/$s || ! -f ${SCRIPT_DIR}/$s ]]
	then	
	    echo "$s missing from repo or script dir"
	    continue
	fi

	f1="${REPO_DIR}/$s"
	f2="${SCRIPT_DIR}/$s"

	diff -q $f1 $f2 > /dev/null
	[ $? -eq 0 ] && continue
	
	t_f1=$(stat -f "%m" $f1)
	t_f2=$(stat -f "%m" $f2)

	if [[ $t_f1 -gt $t_f2 ]]
	then
	    echo "repo ahead of install for $s"
	else
	    echo "install modified ahead of repo for $s"
	fi
    done    
}

function set_perms {
    $Trace && set -x

    cd $SCRIPT_DIR 
    if [[ "$PWD" != $SCRIPT_DIR ]]
    then
	echo "Unable to CD to $SCRIPT_DIR"
	exit
    fi

    chmod -h 700 $@ # -h for symlinks
    if [ $? -ne 0 ]
    then
	echo "failure setting perms for links in script dir"
	exit
    fi
}

#################
## START MAIN CODE
#################
if [[ $# -lt 1 ]]
then
    echo "needs at leat 1 arg" && exit
fi

# Find & turn on tracing flag asap
if $(trace $@)
then
    Trace=true
    echo "Tracing $Prog"
    PS4='$LINENO:	'
    set -x
fi

if [[ ! -d $REPO_DIR || ! -d $RUN_DIR || ! -d $SCRIPT_DIR ]]
then
    echo "Missing directories"
    exit
fi	

cd $RUN_DIR
if [[ "$PWD" != $RUN_DIR ]]
then
    echo "Unable to CD to $RUN_DIR"
    exit
fi

while getopts :achi:lpr:t VAR 2> /dev/null
do
    case $VAR in
	a) install_all
	   make_links
	   set_perms ${links[@]} ${scripts[@]}
	   ;;
	c) compare
	   exit
	   ;;
	h) help
	   exit
	   ;;
	i) install $OPTARG
	   set_perms $OPTARG
	   exit
	   ;;
	l) make_links
	   set_perms ${links[@]}
	   ;;
	p) set_perms ${links[@]} ${scripts[@]}
	   exit
	   ;;
	r) rm_links
	   exit
	   ;;
	t) continue #checked for -t above
	   ;;
	?) echo "Bad option"
	   exit
	   ;;
    esac
done

if [ ! -h ${SCRIPT_DIR}/lib ]
then
    echo "Creating link libs"
    ln -s ${HOME}/dev/lib/shell ${SCRIPT_DIR}/lib
    if [ $? -ne 0 ]
    then
	echo "Error making link for $l"
	exit
    fi
fi

exit
