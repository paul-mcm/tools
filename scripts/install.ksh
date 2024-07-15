#!/bin/ksh 

REPO_DIR="${HOME}/dev/tools/scripts"
RUN_DIR=${REPO_DIR}
SCRIPT_DIR="${HOME}/scripts"
SCRIPT_DIR="${HOME}/tmp"

function install {
    typeset f=$1

    cp $f $SCRIPT_DIR
    if [ $? -ne 0 ]
    then
	echo "failed to cpy $f"
	exit
    fi
}

set -A links addnum bat clean dfunk libl pkgs radiotre radiouno

cd $RUN_DIR
if [[ "$PWD" != $RUN_DIR ]]
then
    echo "Unable to CD to $RUN_DIR"
    exit
fi

install agent_setup.ksh 
install cscope_init.ksh
install drop_tcp.ksh
install grab_openbsd.ksh
install iprange.pl
install tips.pl
install misc_commands.ksh 

for l in ${links[@]}
do
    ln ${SCRIPT_DIR}/misc_commands.ksh ${SCRIPT_DIR}/$l
    if [ $? -ne 0 ]
    then
	echo "Error making link for $l"
	exit
    fi
done

rm ${SCRIPT_DIR}/misc_commands.ksh

if [ ! -h ${SCRIPT_DIR}/lib ]
then
    echo "Making link to script libraries"
    ln -s ${HOME}/dev/lib/shell ${SCRIPT_DIR}/lib
    if [ $? -ne 0 ]
    then
	echo "Error making link for $l"
	exit
    fi
fi

chmod 744 ${SCRIPT_DIR}/*

exit
