#!/bin/ksh

RUNDIR=${HOME}
ENV_FILE="${RUNDIR}/.ssa_env"
UMASK=077

umask $UMASK

cd $RUNDIR
if [[ "$PWD" != $RUNDIR ]]
then
    echo "Unable to CD to $RUNDIR"
    exit
fi

[[ -f $ENV_FILE ]] && rm $ENV_FILE 

cat /dev/null > $ENV_FILE
if [ $? -ne 0 ]
then
    echo "Failed to create $ENV_FILE; aborting"
fi

file=$(ls -l $ENV_FILE | awk '{print $1, $3, $5}') #Get perms, user, size.
perm="${file%% *}"	# perms
o="${file#* }"		# owner stp 1
o="${o% *}"		# owner stp 2
sz="${file##* }"	# file size

if [[ ("$perm" != '-rw-------') || ("$o" != "$USER") || ($sz -ne 0) ]]
then
    echo "Unexpected permissions ($perm), owner ($o), or" \
    "size ($sz) for $ENV_FILE -- aborting"
    exit
fi

/usr/bin/ssh-agent | grep -v 'echo' > $ENV_FILE

