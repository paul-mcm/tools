#!/bin/ksh 

REPO_DIR="${HOME}/dev/tools/scripts"
RUN_DIR=${REPO_DIR}
#SCRIPT_DIR="${HOME}/scripts"
SCRIPT_DIR="${HOME}/tmp" # for testing

function install {
    typeset f=$1
    cp $f $SCRIPT_DIR
    if [ $? -ne 0 ]
    then
	echo "failed to cpy $f"
	exit
    fi
}

function install_all {
    typeset i;
    for i in ${scripts[@]}
    do
	install $i
    done
}

function make_links {
    typeset l
    typeset file=misc_commands.ksh

    for l in ${links[@]}
    do
	[ -f ${SCRIPT_DIR}/$l ] && continue

	ln ${SCRIPT_DIR}/$file ${SCRIPT_DIR}/$l
	if [ $? -ne 0 ]
	then
	    echo "Error making link for $l"
	    exit
	fi
    done
    cd $SCRIPT_DIR 
    if [[ "$PWD" != $SCRIPT_DIR ]]
    then
	echo "Unable to CD to $SCRIPT_DIR"
	exit
    fi

    chmod 700 ${links[@]}
    if [ $? -ne 0 ]
    then
	echo "failure setting perms for links in script dir"
	exit
    fi
    exit
}

function compare {

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
	if [ $? -eq 0 ]
	then
	    continue
	fi
	
	t_f1=$(stat -f "%c" $f1)
	t_f2=$(stat -f "%c" $f2)

	if [[ $t_f1 -gt $t_f2 ]]
	then
	    echo "$s ahead of install"
	else
	    echo "$s modified ahead of repo"
	fi
    done
    
}

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
    dfunk	\
    libl	\
    pkgs	\
    radiotre	\
    radiouno

cd $RUN_DIR
if [[ "$PWD" != $RUN_DIR ]]
then
    echo "Unable to CD to $RUN_DIR"
    exit
fi

while getopts :cils VAR 2> /dev/null
do
    case $VAR in
	c) compare
	   exit
	   ;;
	i) install_all
	   make_links
	   exit
	   ;;
	l) make_links
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

chmod 744 ${SCRIPT_DIR}/*

exit
