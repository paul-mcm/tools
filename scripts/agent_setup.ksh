#!/bin/ksh

RUNDIR=${HOME}
ENV_FILE="${RUNDIR}.ssa_env"
UMASK 077

umask $UMASK

cd $RUNDIR
if [[ "$PWD" != $RUNDIR ]]
then
    echo "Unable to CD to $RUNDIR"
    exit
fi

[[ -f $ENV_FILE ]] && rm $ENV_FILE 
cat /dev/null > $ENV_FILE

line=$(ls -l $ENV_FILE | awk '{print $1, $3, $5}')   # Get perms, user, size.
perm="${Line%% *}"                                 # Parse out perms.
o="${Line#* }"                                  # Parse out owner, stp 1
o="${Owner% *}"                                 # Parse out owner, stp 2
sz="${Line##* }"                                  # Parse out size

if [[ ("$perm" != '-rw-------') || ("$o" != "$USER") || ($sz -ne 0) ]]
then
    echo "Unexpected permissions ($Perms), owner ($Owner), or" \
    "data ($Size) in $Env_file -- aborting" >&2
fi

/usr/bin/ssh-agent | grep -v 'echo' > $ENV_FILE

